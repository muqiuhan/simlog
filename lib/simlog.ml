open Core

module type Logger = sig
  module Record_option : Recorder.Recorder_opt
  module Filter : Filter.Filter
  module Buffer : Recorder.Buffer
end

module Make (M : Logger) = struct
  let info (fmt : 'a) : unit =
    let log_message = Format.ksprintf (fun s -> s) fmt in
    Recorder.record ~level:Level.Info log_message |> M.Buffer.push
end
