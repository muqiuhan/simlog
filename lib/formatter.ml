module type T = sig
  val format : Recorder.t -> Printer.Target.t -> string
end

module Level = struct
  include Recorder.Level

  let format_str_with_ascii (log_message : string) = function
    | Debug -> Ocolor_format.kasprintf (fun s -> s) "@{<blue> %s @}" log_message
    | Warn ->
      Ocolor_format.kasprintf (fun s -> s) "@{<yellow> %s @}" log_message
    | Error -> Ocolor_format.kasprintf (fun s -> s) "@{<red> %s @}" log_message
    | Info -> Ocolor_format.kasprintf (fun s -> s) "@{<green> %s @}" log_message
end

module Builtin = struct
  module Formatter : T = struct
    let format (record : Recorder.t) (target : Printer.Target.t) : string =
      let time =
        match record.time with
        | Some time -> string_of_float time
        | None -> "None"
      and thread =
        match record.thread with
        | Some thread -> string_of_int (Thread.id thread)
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
            ((Level.format_str_with_ascii
                (Format.sprintf "%s > %s" level record.log_message))
               record.level)
  end
end
