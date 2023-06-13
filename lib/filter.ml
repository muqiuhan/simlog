(** Filter, you can customize which logs need to be recorded *)

module type T = sig
  val filter : Recorder.t -> Recorder.t option
end
