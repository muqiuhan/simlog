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

module type Recorder_opt = sig
  type record_opt = {
    time : bool;
    trace : bool;
    thread : bool;
  }

  val opt : record_opt
end

module type Buffer = sig
  type buffer = t Stack.t

  val buffer : buffer
  val push : t -> unit
  val pop : unit -> t
end

let record ~(level : Level.t) (log_message : string) : t =
  {
    time = Time.get ();
    trace = Trace.get ();
    thread = Thread.get ();
    level;
    log_message;
  }
