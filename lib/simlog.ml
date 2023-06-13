module type Logger = sig
  module Recorder : Recorder.T
  module Filter : Filter.T
  module Printer : Printer.T
  module Formatter : Formatter.T
end

open Core

module Make (M : Logger) = struct
  let[@inline always] info (fmt : 'a) : unit =
      Recorder.record ~opt:M.Recorder.opt ~level:Level.Info
        (Format.ksprintf (fun s -> s) fmt)
      |> M.Filter.filter
      |> Option.iter ~f:(fun record -> Recorder.Buffer.push record)

  let[@inline always] error (fmt : 'a) : unit =
      Recorder.record ~opt:M.Recorder.opt ~level:Level.Error
        (Format.ksprintf (fun s -> s) fmt)
      |> M.Filter.filter
      |> Option.iter ~f:(fun record -> Recorder.Buffer.push record)

  let[@inline always] warn (fmt : 'a) : unit =
      Recorder.record ~opt:M.Recorder.opt ~level:Level.Warn
        (Format.ksprintf (fun s -> s) fmt)
      |> M.Filter.filter
      |> Option.iter ~f:(fun record -> Recorder.Buffer.push record)

  let _ =
      let __logger () : unit =
          while true do
            M.Printer.config.target
            |> M.Formatter.format (Recorder.Buffer.pop ())
            |> M.Printer.print
          done
      in
          Caml_threads.Thread.create __logger ()
end
