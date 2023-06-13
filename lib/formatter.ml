module type T = sig
  val format : Recorder.t -> Target.t -> string
end

module Ascii_color = struct
  type t
end
