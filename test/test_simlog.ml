module Log = Simlog.Make (Simlog.Builtin.Logger)

let _ =
  Log.debug "Hello";
  Log.info "Hello %s" "simlog";
  Log.error "Hey! %f" (Unix.gettimeofday ());
  Log.warn "Wuuuuu~ %d" (Thread.id (Thread.self ()))

module File_Log = Simlog.Make (struct
  include Simlog.Filter.Builtin
  include Simlog.Formatter.Builtin
  include Simlog.Recorder.Builtin

  module Printer = Simlog.Printer.Builtin.File_Printer (struct
    let path = "test.log"
  end)
end)

let _ =
  File_Log.debug "Hello";
  File_Log.info "Hello %s" "simlog";
  File_Log.error "Hey! %f" (Unix.gettimeofday ());
  File_Log.warn "Wuuuuu~ %d" (Thread.id (Thread.self ()))
