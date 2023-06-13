module type Logger = sig
  module Filter : Filter.T
  module Printer : Printer.T
  module Formatter : Formatter.T
  module Recorder : Recorder.T
end

module Default_logger : Logger = struct
  module Filter : Filter.T = struct
    let filter (record : Recorder.t) : Recorder.t option =
        match record.level with
        | Debug -> None
        | _ -> Some record
  end

  module Formatter : Formatter.T = struct
    let format (record : Recorder.t) (target : Target.t) : string =
        let time =
            match record.time with
            | Some time -> Time.to_string time
            | None -> "None"
        and thread =
            match record.thread with
            | Some thread -> Thread.to_string thread
            | None -> "None"
        and level = Level.to_string record.level in
            match target with
            | File _ ->
                Format.sprintf "| %s | %s | %s > %s" level time thread
                  record.log_message
            | Stdout | Stderr ->
                Ocolor_format.kasprintf
                  (fun s -> s)
                  "|@{<magenta> %s @}(@{<cyan> %s @}) %s" time thread
                  ((Formatter.Level.format_str_with_ascii
                      (Format.sprintf "%s > %s" level record.log_message))
                     record.level)
  end

  module Printer : Printer.T = struct
    let config = Printer.{buffer = false; target = Stdout}
    let print (msg : string) : unit = print_endline msg
  end

  module Recorder : Recorder.T = struct
    let opt = Recorder.{time = true; trace = false; thread = true}
  end
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
