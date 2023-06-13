type t =
  | Info
  | Warn
  | Error
  | Debug

let to_string = function
    | Info -> "Info"
    | Warn -> "Warn"
    | Error -> "Error"
    | Debug -> "Debug"
