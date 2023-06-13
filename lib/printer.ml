type config = {
  buffer : bool;
  target : Target.t;
}

module type T = sig
  val config : config
  val print : string -> unit
end
