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

type level =
  | Output
  | Debug
  | Info
  | Warn
  | Error
  | Fatal

type timezone =
  | Local
  | GMT
  | None

type color =
  | Black
  | Red
  | Green
  | Yellow
  | Blue
  | Magenta
  | Cyan
  | White
  | Custom of int

let level_to_string = function
  | Some Output -> "[Output ]"
  | Some Debug -> "[Debug  ]"
  | Some Info -> "[Info   ]"
  | Some Warn -> "[Warning]"
  | Some Error -> "[Error  ]"
  | Some Fatal -> "[Fatal  ]"
  | None -> "Quiet"
;;

let level_of_string = function
  | "[Output ]" -> Ok (Some Output)
  | "[Debug  ]" -> Ok (Some Debug)
  | "[Info   ]" -> Ok (Some Info)
  | "[Warning]" -> Ok (Some Warn)
  | "[Error  ]" -> Ok (Some Error)
  | "[Fatal  ]" -> Ok (Some Fatal)
  | "[Quiet  ]" -> Ok None
  | e -> Error (Printf.sprintf "Unknown log level : %s" e)
;;

let level_to_int = function
  | Some Output -> 100
  | Some Debug -> 1
  | Some Info -> 2
  | Some Warn -> 3
  | Some Error -> 4
  | Some Fatal -> 5
  | None -> 0
;;

let level_of_int = function
  | 100 -> Ok (Some Output)
  | 1 -> Ok (Some Debug)
  | 2 -> Ok (Some Info)
  | 3 -> Ok (Some Warn)
  | 4 -> Ok (Some Error)
  | 5 -> Ok (Some Fatal)
  | 0 -> Ok None
  | e -> Error (Printf.sprintf "Unknown log level : Code %d" e)
;;

let color_fg = function
  | Black -> 30
  | Red -> 31
  | Green -> 32
  | Yellow -> 33
  | Blue -> 34
  | Magenta -> 35
  | Cyan -> 36
  | White -> 37
  | Custom i -> i
;;

let color_fg_bright = function
  | Black -> 90
  | Red -> 91
  | Green -> 92
  | Yellow -> 93
  | Blue -> 94
  | Magenta -> 95
  | Cyan -> 96
  | White -> 97
  | Custom i -> i
;;

let int_to_color_fg = function
  | 30 -> "Black"
  | 31 -> "Red"
  | 32 -> "Green"
  | 33 -> "Yellow"
  | 34 -> "Blue"
  | 35 -> "Magenta"
  | 36 -> "Cyan"
  | 37 -> "White"
  | 90 -> "Bright Black"
  | 91 -> "Bright Red"
  | 92 -> "Bright Green"
  | 93 -> "Bright Yellow"
  | 94 -> "Bright Blue"
  | 95 -> "Bright Magenta"
  | 96 -> "Bright Cyan"
  | 97 -> "Bright White"
  | i -> Printf.sprintf "Color with ANSI escape code %d" i
;;

let color_bg = function
  | Black -> 40
  | Red -> 41
  | Green -> 42
  | Yellow -> 43
  | Blue -> 44
  | Magenta -> 45
  | Cyan -> 46
  | White -> 47
  | Custom i -> i
;;

let color_bg_bright = function
  | Black -> 100
  | Red -> 101
  | Green -> 102
  | Yellow -> 103
  | Blue -> 104
  | Magenta -> 105
  | Cyan -> 106
  | White -> 107
  | Custom i -> i
;;

let int_to_color_bg = function
  | 040 -> "Black"
  | 041 -> "Red"
  | 042 -> "Green"
  | 043 -> "Yellow"
  | 044 -> "Blue"
  | 045 -> "Magenta"
  | 046 -> "Cyan"
  | 047 -> "White"
  | 100 -> "Bright Black"
  | 101 -> "Bright Red"
  | 102 -> "Bright Green"
  | 103 -> "Bright Yellow"
  | 104 -> "Bright Blue"
  | 105 -> "Bright Magenta"
  | 106 -> "Bright Cyan"
  | 107 -> "Bright White"
  | i -> Printf.sprintf "Color with ANSI escape code %d" i
;;

let debug_c = ref (34, 40)
let info_c = ref (32, 40)
let warn_c = ref (93, 40)
let error_c = ref (91, 40)
let fatal_c = ref (37, 41)

let color_ref = function
  | Output -> ref (37, 40)
  | Debug -> debug_c
  | Info -> info_c
  | Warn -> warn_c
  | Error -> error_c
  | Fatal -> fatal_c
;;

let set_color_fg ~clr ~lvl =
  match lvl with
  | Debug -> debug_c := clr |> color_fg, !debug_c |> snd
  | Info -> info_c := clr |> color_fg, !info_c |> snd
  | Warn -> warn_c := clr |> color_fg, !warn_c |> snd
  | Error -> error_c := clr |> color_fg, !error_c |> snd
  | Fatal -> fatal_c := clr |> color_fg, !fatal_c |> snd
  | Output -> invalid_arg "Color of output cannot be modified."
;;

let set_color_fg_brt ~clr ~lvl =
  match lvl with
  | Debug -> debug_c := clr |> color_fg_bright, !debug_c |> snd
  | Info -> info_c := clr |> color_fg_bright, !info_c |> snd
  | Warn -> warn_c := clr |> color_fg_bright, !warn_c |> snd
  | Error -> error_c := clr |> color_fg_bright, !error_c |> snd
  | Fatal -> fatal_c := clr |> color_fg_bright, !fatal_c |> snd
  | Output -> invalid_arg "Color of output cannot be modified."
;;

let set_color_bg ~clr ~lvl =
  match lvl with
  | Debug -> debug_c := !debug_c |> fst, clr |> color_bg
  | Info -> info_c := !info_c |> fst, clr |> color_bg
  | Warn -> warn_c := !warn_c |> fst, clr |> color_bg
  | Error -> error_c := !error_c |> fst, clr |> color_bg
  | Fatal -> fatal_c := !fatal_c |> fst, clr |> color_bg
  | Output -> invalid_arg "Color of output cannot be modified."
;;

let set_color_bg_brt ~clr ~lvl =
  match lvl with
  | Debug -> debug_c := !debug_c |> fst, clr |> color_bg_bright
  | Info -> info_c := !info_c |> fst, clr |> color_bg_bright
  | Warn -> warn_c := !warn_c |> fst, clr |> color_bg_bright
  | Error -> error_c := !error_c |> fst, clr |> color_bg_bright
  | Fatal -> fatal_c := !fatal_c |> fst, clr |> color_bg_bright
  | Output -> invalid_arg "Color of output cannot be modified."
;;

let get_color l =
  let code = function
    | Output -> 37, 40
    | Debug -> !debug_c
    | Info -> !info_c
    | Warn -> !warn_c
    | Error -> !error_c
    | Fatal -> !fatal_c
  in
  let color = function
    | a, b -> a |> int_to_color_fg, b |> int_to_color_bg
  in
  l |> code |> color
;;

let color_seq l =
  Printf.sprintf "\x1b[%dm\x1b[%dm" (!(l |> color_ref) |> fst) (!(l |> color_ref) |> snd)
;;

let log_level = ref Debug
let out = ref stderr
let tz = ref Local
let set_level l = log_level := l
let get_level () = !log_level
let set_out_channel o = out := o
let get_out_channel () = !out
let set_tz t = tz := t
let get_tz () = !tz
let disable_tz () = tz := None

let ts () =
  let time = Unix.gettimeofday () in
  let time = if !tz = Local then Unix.localtime time else Unix.gmtime time in
  let hour = time.Unix.tm_hour in
  let minute = time.Unix.tm_min in
  let second = time.Unix.tm_sec in
  Printf.sprintf "%02d:%02d:%02d" hour minute second
;;

let prefix l =
  let c_time = if !tz <> None then ts () else "" in
  let lvl = color_seq l in
  Printf.sprintf "| %s    %s%s" c_time lvl (level_to_string (Some l))
;;

let count = [| 0; 0; 0; 0; 0 |]
let count_l = [| 0; 0; 0; 0; 0 |]

let get_count = function
  | Debug -> count.(0)
  | Info -> count.(1)
  | Warn -> count.(2)
  | Error -> count.(3)
  | Fatal -> count.(4)
  | _ -> invalid_arg "Simlog.get_count cannot be used for this log level"
;;

let get_count_logged = function
  | Debug -> count_l.(0)
  | Info -> count_l.(1)
  | Warn -> count_l.(2)
  | Error -> count_l.(3)
  | Fatal -> count_l.(4)
  | _ -> invalid_arg "Simlog.get_count_logged cannot be used for this log level"
;;

let get_count_unlogged l = get_count l - get_count_logged l

let set_count ~lvl:l i =
  match l with
  | Debug -> count.(0) <- i
  | Info -> count.(1) <- i
  | Warn -> count.(2) <- i
  | Error -> count.(3) <- i
  | Fatal -> count.(4) <- i
  | _ -> invalid_arg "Simlog.set_count cannot be used for this log level"
;;

let set_count_logged ~lvl:l i =
  match l with
  | Debug -> count_l.(0) <- i
  | Info -> count_l.(1) <- i
  | Warn -> count_l.(2) <- i
  | Error -> count_l.(3) <- i
  | Fatal -> count_l.(4) <- i
  | _ -> invalid_arg "Simlog.set_count_logged cannot be used for this log level"
;;

let count_total () = Array.fold_left (fun x y -> x + y) 0 count
let count_total_logged () = Array.fold_left (fun x y -> x + y) 0 count_l

let log l m =
  let p = prefix l in
  set_count (get_count l + 1) ~lvl:l;
  if level_to_int (Some l) >= level_to_int (Some !log_level)
  then (
    Printf.fprintf !out "%s\x1b[0m    %s\n" p m;
    set_count_logged (get_count_logged l + 1) ~lvl:l)
;;

let debug : string -> unit = log Debug
let info : string -> unit = log Info
let warning : string -> unit = log Warn
let error : string -> unit = log Error
let fatal : string -> unit = log Fatal
let critical : string -> unit = fatal
