module type T = sig
  val format : Recorder.t -> Target.t -> string
end