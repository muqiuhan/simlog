module Log = Simlog.Make (Simlog.Builtin.Logger)

let _ =
    Log.debug "Hello";
    Log.info "Hello %s" "simlog";
    Log.error "Hey! %f" (Unix.gettimeofday ());
    Log.warn "Wuuuuu~ %d" (Thread.id (Thread.self ()))
