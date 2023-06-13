module type T = sig
  val format : Recorder.t -> Target.t -> string
end

module Level = struct
  include Level

  let format_str_with_ascii (log_message : string) = function
      | Debug ->
          Ocolor_format.kasprintf
            (fun s -> s)
            "@{<blue> %s <blue>@}" log_message
      | Warn ->
          Ocolor_format.kasprintf
            (fun s -> s)
            "@{<yellow> %s <yellow>@}" log_message
      | Error ->
          Ocolor_format.kasprintf (fun s -> s) "@{<red> %s <red>@}" log_message
      | Info ->
          Ocolor_format.kasprintf
            (fun s -> s)
            "@{<green> %s <green>@}" log_message
end
