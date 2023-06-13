(** Filter, you can customize which logs need to be recorded *)

type t = Recorder.t

module type T = sig
  val filter : t -> bool
end
