(** The logger gets the time, stack traces, level, thread information, and so on *)

module Trace = struct
  type t = string

  let get () : t = Printexc.get_backtrace ()
end

module Thread = struct
  type t = int

  let get () : t = Caml_threads.Thread.self () |> Caml_threads.Thread.id
end

type record = {
  time : Time.t;
  trace : Trace.t;
  thread : Thread.t;
  level : Level.t;
  log_message : string;
}

and t = record

(** Some log information is optional, 
    you can configure whether to record the corresponding information through this module *)
module type Recorder_opt = sig
  type record_opt = {
    time : bool;
    trace : bool;
    thread : bool;
  }

  val opt : record_opt
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

  let push[@inline always] = __buffer#push
  let pop[@inline always] = __buffer#pop
end

let record ~(level : Level.t) (log_message : string) : t =
    {
      time = Time.get ();
      trace = Trace.get ();
      thread = Thread.get ();
      level;
      log_message;
    }
