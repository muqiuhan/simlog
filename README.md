<div align="center">

# Simlog

*A simple OCaml logging library*

![](https://github.com/muqiuhan/simlog/workflows/build/badge.svg)

</div>

## Usage

```ocaml
module Log = Simlog.Make (Simlog.Builtin.Logger)

let _ =
    Log.debug "~~~~~";
    Log.info "Hello %s" "simlog";
    Log.error "Hey! %f" (Unix.gettimeofday ());
    Log.warn "Wuuuuu~ %d" (Thread.id (Thread.self ()));
```

## Builtin Logger

Simlog.Make receives a `Logger` implementation:
```ocaml
module type Logger = sig
  module Filter : Filter.T
  module Printer : Printer.T
  module Formatter : Formatter.T
  module Recorder : Recorder.T
end
```

However, a default Logger is defined in Simlog.Builtin:
```ocaml
module Builtin = struct
  module Logger : Logger = struct
    include Filter.Builtin
    include Formatter.Builtin
    include Recorder.Builtin
    module Printer = Printer.Builtin.Stdout_Mutex_Printer
  end
end
```

or just print to file:
```ocaml
module File_Log = Simlog.Make (struct
  include Simlog.Filter.Builtin
  include Simlog.Formatter.Builtin
  include Simlog.Recorder.Builtin

  module Printer = Simlog.Printer.Builtin.File_Printer (struct
    let path = "test.log"
  end)
end)
```

So you can directly write:
```ocaml
module Log = Simlog.Make (Simlog.Default_logger)
```

By default, there are four built-in Printer implementations:
- Stdout_Printer
- Stdout_Mutex_Printer
- Stderr_Printer
- Stderr_Mutex_Printer
- File_Printer
- File_Mutex_Printer

## Custom Logger
You can check the `Builtin` module under `Filter`, `Recorder`, `Printer`, `Formatter` module to get the method of custom module:

### Recorder
Recorder.T defines optional information in Recorder.t (which items do not need to be recorded)
```ocaml
module type T = sig
  val opt : opt
end
```

```ocaml
type opt = {
  time : bool;
  trace : bool;
  thread : bool;
}
```

E.g:
```ocaml
module Recorder : T = struct
  let opt = {time = true; trace = false; thread = true}
end
```

### Filter

If you need to customize Filter, you only need to implement the `Filter.T` signature:
```ocaml
module type T = sig
  val filter : Recorder.t -> Recorder.t option
end
```

For example, the following custom Filter implements filtering of all Debug logs, and you can use the information in Record.t to filter any logging records:
```ocaml
module Filter : T = struct
  let filter (record : Recorder.t) : Recorder.t option =
    match record.level with
    | Debug -> None
    | _ -> Some record
end
```

### Formatter

If you need to customize Formatter, you only need to implement the `Formatter.T` signature:
```ocaml
module type T = sig
  val format : Recorder.t -> Target.t -> string
end
```

The `format` function receives a logging record and a target (which is the target of the log output)，eSo you can write different formatted messages according to the `target`, And simlog uses the ocolor module to support ascii color output, and its syntax is very simple `{@<color> @}`:
```ocaml
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
```

### Printer

If you need to customize Printer, you only need to implement the `Printer.T` signature:
```ocaml
module type T = sig
  val config : config
  val print : string -> unit
end
```
The type `config` is a record: `{target : Target.t}`.

E.g:
```ocaml
module Stdout_Mutex_Printer : T = struct
  let mutex = Mutex.create ()
  let config = {target = Stdout}
  
  let[@inline always] print msg =
    Mutex.lock mutex;
    print_endline msg;
    Mutex.unlock mutex
end
```

## Build-Test-Install

Just:
```
dune build
dune test
dune install
```

## License
MIT License

Copyright (c) 2022 Muqiu Han

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.