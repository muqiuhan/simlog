module Log = Simlog.Make (Simlog.Default_logger)

let _ =
    Log.info "Hello %s" "simlog";
    Log.error "Hey! %f" (Unix.gettimeofday ());
    Log.warn "Wuuuuu~ %d" (Thread.id (Thread.self ()));
    Caml_threads.Thread.delay 0.1
