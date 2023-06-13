open Core

module type Logger = sig
  module Record_option : Recorder.Recorder_opt
  module Filter : Filter.T
  module Printer : Printer.T
end

module Make (M : Logger) = struct
  let info (fmt : 'a) : unit =
      Recorder.record ~level:Level.Info (Format.ksprintf (fun s -> s) fmt)
      |> Recorder.Buffer.push

  let error (fmt : 'a) : unit =
      Recorder.record ~level:Level.Error (Format.ksprintf (fun s -> s) fmt)
      |> Recorder.Buffer.push

  let warn (fmt : 'a) : unit =
      Recorder.record ~level:Level.Warn (Format.ksprintf (fun s -> s) fmt)
      |> Recorder.Buffer.push
end
