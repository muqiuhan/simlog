(** The logger gets the time, Queue traces, level, thread information, and so on *)

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

module Buffer = struct
  type t = record Queue.t

  let buffer : t = Queue.create ()
  let[@inline] add record = Queue.add record buffer
  let[@inline] get () = Queue.take buffer
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

module Builtin = struct
  module Recorder : T = struct
    let opt = {time = true; trace = false; thread = true}
  end
end
