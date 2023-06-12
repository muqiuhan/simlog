(** The logger gets the time, stack traces, level, thread information, and so on *)

open Core

module Time = struct
  type t = float

  let get : unit -> t = Core_unix.gettimeofday
end

module Stacktraces = struct
  type t = string

  let get : unit -> t = fun () -> Printexc.get_backtrace ()
end

module Thread = struct
  (** Thread id *)
  type t = int

  let get : unit -> t = fun () -> Caml_threads.Thread.self () |> Caml_threads.Thread.id
end

type t =
  { time : Time.t
  ; stack_traces : Stacktraces.t
  ; thread : Thread.t
  ; level : Level.t
  }
