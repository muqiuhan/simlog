module Log = Simlog.Make (Simlog.Default_logger)

let _ =
    Log.info "Hello";
    Log.error "Hey!";
    Log.warn "Wuuuuu~";
    Caml_threads.Thread.delay 0.1;
