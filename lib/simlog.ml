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
  let[@inline always] __record ~(level : Level.t) ~(str : string) : unit =
      Recorder.record ~opt:M.Recorder.opt ~level str
      |> M.Filter.filter
      |> Option.iter ~f:(fun record ->
             M.Formatter.format record M.Printer.config.target
             |> M.Printer.print)

  let[@inline always] info (fmt : 'a) =
      Format.ksprintf (fun str -> __record ~str ~level:Level.Info) fmt

  let[@inline always] error (fmt : 'a) =
      Format.ksprintf (fun str -> __record ~str ~level:Level.Error) fmt

  let[@inline always] warn (fmt : 'a) =
      Format.ksprintf (fun str -> __record ~str ~level:Level.Warn) fmt

  let[@inline always] debug (fmt : 'a) =
      Format.ksprintf (fun str -> __record ~str ~level:Level.Debug) fmt
end
