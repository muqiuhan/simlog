(** Decide whether to record *)

type t = {
  level : Level.t;
  time : Time.t;
}

module type Filter = sig
  val filter : t -> bool
end
