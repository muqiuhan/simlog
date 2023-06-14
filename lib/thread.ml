type t = int

let get () : t = Caml_threads.Thread.self () |> Caml_threads.Thread.id
let to_string = string_of_int
