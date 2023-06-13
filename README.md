<div align="center">

# Simlog

*The mediocre OCaml logging library*

__REFACTORING__

</div>

## Depends

- [ocolor:  Print with style in your terminal using Format's semantic tags ](https://github.com/marc-chevalier/ocolor)
- [core: Jane Street Capital's standard library overlay ](https://github.com/janestreet/core)
- [core_unix: Unix-specific portions of Core ](https://github.com/janestreet/core_unix)

## Usage

You need to implement the `Logger` Functor:
```ocaml
module type Logger = sig
  module Filter : Filter.T
  module Printer : Printer.T
  module Formatter : Formatter.T
  module Recorder : Recorder.T
end
```

### Use default logger
```ocaml
module Log = Simlog.Make (Simlog.Default_logger)

let _ =
    Log.info "Hello %s" "simlog";
    Log.error "Hey! %f" (Unix.gettimeofday ());
    Log.warn "Wuuuuu~ %d" (Thread.id (Thread.self ()));
```

### Use custom logger

E.g
```ocaml
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
```


## Build and Test

```
dune build
dune test
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