module Log = Dog.Make (Dog.Builtin.Logger)

let _ =
    Log.debug "Hello";
    Log.info "Hello %s" "dog";
    Log.error "Hey! %f" (Unix.gettimeofday ());
    Log.warn "Wuuuuu~ %d" (Thread.id (Thread.self ()))

module File_Log = Dog.Make (struct
  include Dog.Filter.Builtin
  include Dog.Formatter.Builtin
  include Dog.Recorder.Builtin

  module Printer = Dog.Printer.Builtin.File_Printer (struct
    let path = "test.log"
  end)
end)

let _ =
    File_Log.debug "Hello";
    File_Log.info "Hello %s" "dog";
    File_Log.error "Hey! %f" (Unix.gettimeofday ());
    File_Log.warn "Wuuuuu~ %d" (Thread.id (Thread.self ()))