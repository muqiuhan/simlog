(lang dune 3.5)

(name simlog)

(generate_opam_files true)

(source
 (github muqiuhan/simlog))

(authors "Muqiu Han")

(maintainers "Muqiu Han")

(license MIT)

(documentation https://github.com/muqiuhan/simlog)

(package
 (name simlog)
 (allow_empty)
 (synopsis "A simple OCaml logging library")
 (description "A simple OCaml logging library")
 (depends
  (ocaml
   (>= 4.11.0))
  dune
  ocolor
  core_kernel)
 (tags
  (log logging logger)))

; See the complete stanza docs at https://dune.readthedocs.io/en/stable/dune-files.html#dune-project
