open Core

module Target = struct
  type t =
    | Stdout
    | Stderr
    | File of string
end

type config = {target : Target.t}

module type T = sig
  val config : config
  val print : string -> unit
end

module Builtin = struct
  module Stdout_Printer : T = struct
    let config = {target = Stdout}
    let print = print_endline
  end

  module Stderr_Printer : T = struct
    let config = {target = Stderr}
    let (print [@inline always]) = Format.fprintf Format.err_formatter "%s\n"
  end

  module Stdout_Mutex_Printer : T = struct
    let mutex = Caml_threads.Mutex.create ()
    let config = {target = Stdout}

    let[@inline always] print msg =
      Caml_threads.Mutex.lock mutex;
      print_endline msg;
      Caml_threads.Mutex.unlock mutex
  end

  module Stderr_Mutex_Printer : T = struct
    let mutex = Caml_threads.Mutex.create ()
    let config = {target = Stdout}

    let[@inline always] print msg =
      Caml_threads.Mutex.lock mutex;
      Format.fprintf Format.err_formatter "%s\n" msg;
      Caml_threads.Mutex.unlock mutex
  end

  module File_Printer (T : sig
    val path : string
  end) : T = struct
    let config = {target = File T.path}
    let file = Out_channel.create T.path

    let[@inline always] print (str : string) =
      Out_channel.output_string file (str ^ "\n")
  end

  module File_Mutex_Printer (T : sig
    val path : string
  end) : T = struct
    let config = {target = File T.path}
    let mutex = Caml_threads.Mutex.create ()
    let file = Out_channel.create T.path

    let[@inline always] print (str : string) =
      Caml_threads.Mutex.lock mutex;
      Out_channel.output_string file (str ^ "\n");
      Caml_threads.Mutex.unlock mutex
  end
end
