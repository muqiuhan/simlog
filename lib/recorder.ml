(** The logger gets the time, stack traces, level, thread information, and so on *)

module Trace = struct
  type t = string

  let get () : t = Printexc.get_backtrace ()
end


type record = {
  time : Time.t option;
  trace : Trace.t option;
  thread : Thread.t option;
  level : Level.t;
  log_message : string;
}

and t = record

type opt = {
  time : bool;
  trace : bool;
  thread : bool;
}
(** Some log information is optional, 
    you can configure whether to record the corresponding information through this module *)

module type T = sig
  val opt : opt
end

(** Thread-safe logging buffer,
    because the logging filter, formatter and printer will run on separate threads *)
module Buffer = struct
  class t =
    object (_)
      val records : record Stack.t = Stack.create ()
      val mutex : Caml_threads.Mutex.t = Caml_threads.Mutex.create ()
      val nonempty : Caml_threads.Condition.t = Caml_threads.Condition.create ()

      method push (record : record) : unit =
        Mutex.lock mutex;
        let was_empty = Stack.is_empty records in
            Stack.push record records;
            if was_empty then Condition.broadcast nonempty;
            Mutex.unlock mutex

      method pop () : record =
        Mutex.lock mutex;
        while Stack.is_empty records do
          Condition.wait nonempty mutex
        done;
        let v = Stack.pop records in
            Mutex.unlock mutex;
            v
    end

  let __buffer = new t
  let (push [@inline always]) = __buffer#push
  let (pop [@inline always]) = __buffer#pop
end

let[@inline] record ~(opt : opt) ~(level : Level.t) (log_message : string) : t =
    let {time; trace; thread} = opt in
        {
          time =
            (if time then
               Some (Time.get ())
             else
               None);
          trace =
            (if trace then
               Some (Trace.get ())
             else
               None);
          thread =
            (if thread then
               Some (Thread.get ())
             else
               None);
          level;
          log_message;
        }
