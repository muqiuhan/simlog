module Level = struct
  type t =
    | Info
    | Warn
    | Error
    | Debug

  let to_string = function
    | Info -> "Info"
    | Warn -> "Warn"
    | Error -> "Error"
    | Debug -> "Debug"
end

(** The logger gets the time, Queue traces, level, thread information, and so on *)

module Trace = struct
  type t = string

  let get () : t = Printexc.get_backtrace ()
end

type record = {
  time : float option;
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

let[@inline] record ~(opt : opt) ~(level : Level.t) (log_message : string) : t =
  let {time; trace; thread} = opt in
    {
      time =
        (if time then
           Some (Unix.gettimeofday ())
         else
           None);
      trace =
        (if trace then
           Some (Trace.get ())
         else
           None);
      thread =
        (if thread then
           Some (Thread.self ())
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
