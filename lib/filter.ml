(** Decide whether to record *)

type t = {
  level : Level.t;
  time : Time.t;
}

module type T = sig
  val filter : t -> bool
end
