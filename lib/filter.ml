open Core

(** Filter, you can customize which logs need to be recorded *)

module type T = sig
  val filter : Recorder.t -> Recorder.t option
end

module Builtin = struct
  module Filter : T = struct
    let filter (record : Recorder.t) : Recorder.t option =
      match record.level with
      (* | Debug -> None *)
      | _ -> Some record
  end
end
