(**********************************************************************************)
(* Copyright (c) 2022 Muqiu Han                                                   *)
(*                                                                                *)
(* Permission is hereby granted, free of charge, to any person obtaining a copy   *)
(* of this software and associated documentation files (the "Software"), to deal  *)
(* in the Software without restriction, including without limitation the rights   *)
(* to use, copy, modify, merge, publish, distribute, sublicense, and/or sell      *)
(* copies of the Software, and to permit persons to whom the Software is          *)
(* furnished to do so, subject to the following conditions:                       *)
(*                                                                                *)
(* The above copyright notice and this permission notice shall be included in all *)
(* copies or substantial portions of the Software.                                *)
(*                                                                                *)
(* THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR     *)
(* IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,       *)
(* FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE    *)
(* AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER         *)
(* LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,  *)
(* OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE  *)
(* SOFTWARE.                                                                      *)
(**********************************************************************************)

module Level = struct
  type t =
    | Critical
    | Error
    | Warning
    | Info
    | Debug

  let global = ref Info

  let to_string (level : t) : string =
    match level with
    | Critical -> "CRITICAL"
    | Error -> "ERROR   "
    | Warning -> "WARNING "
    | Info -> "INFO    "
    | Debug -> "DEBUG   "
  ;;

  let filter (level : t) : bool =
    let to_number (level : t) : int =
      match level with
      | Critical -> 10
      | Error -> 9
      | Warning -> 8
      | Info -> 7
      | Debug -> 6
    in
    to_number level >= to_number !global
  ;;
end

module Time = struct
  type t =
    | UTC
    | Local

  let current (time : t) : string =
    match time with
    | UTC ->
      let () = CalendarLib.(Time_Zone.change Time_Zone.UTC) in
      CalendarLib.(Calendar.now () |> Printer.Calendar.to_string)
    | Local ->
      let () = CalendarLib.(Time_Zone.change Time_Zone.Local) in
      CalendarLib.(Calendar.now () |> Printer.Calendar.to_string)
  ;;

  let time = ref Local
end

type t =
  { time : string
  ; message : string
  ; level : Level.t
  }

module type Message_Template = sig
  type t =
    { time : string
    ; message : string
    }

  val log : string -> t
  val format : string -> string -> string -> unit
  val level : Level.t
end

module Message_Functor =
functor
  (M : Message_Template)
  ->
  struct
    let print (message : string) : unit =
      if Level.filter M.level
      then (
        let log = M.log message in
        M.format log.time (Level.to_string M.level) log.message)
    ;;
  end

module Critical = Message_Functor (struct
  type t =
    { time : string
    ; message : string
    }

  let level = Level.Critical
  let log (message : string) : t = { time = Time.current !Time.time; message }

  let format =
    Ocolor_format.printf
      "@{<hi_white>| %s@} \t @{<bg_red>@{<white>[%s]@}@} \t @{<red>%s@}\n"
  ;;
end)

module Error = Message_Functor (struct
  type t =
    { time : string
    ; message : string
    }

  let level = Level.Error
  let log (message : string) : t = { time = Time.current !Time.time; message }
  let format = Ocolor_format.printf "@{<hi_white>| %s@} \t @{<red>[%s] \t %s@}\n"
end)

module Warning = Message_Functor (struct
  type t =
    { time : string
    ; message : string
    }

  let level = Level.Warning
  let log (message : string) : t = { time = Time.current !Time.time; message }
  let format = Ocolor_format.printf "@{<hi_white>| %s@} \t @{<yellow>[%s] \t %s@}\n"
end)

module Info = Message_Functor (struct
  type t =
    { time : string
    ; message : string
    }

  let level = Level.Info
  let log (message : string) : t = { time = Time.current !Time.time; message }
  let format = Ocolor_format.printf "@{<hi_white>| %s@} \t @{<green>[%s] \t %s@}\n"
end)

module Debug = Message_Functor (struct
  type t =
    { time : string
    ; message : string
    }

  let level = Level.Debug
  let log (message : string) : t = { time = Time.current !Time.time; message }
  let format = Ocolor_format.printf "@{<hi_white>| %s@} \t @{<blue>[%s] \t %s@}\n"
end)

let critical = Critical.print
let error = Error.print
let warning = Warning.print
let info = Info.print
let debug = Debug.print