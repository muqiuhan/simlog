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
 (synopsis "A Simple logging library for ocaml")
 (description "A Simple logging library for ocaml")
 (depends ocaml dune ocolor calendar)
 (tags
  (log logging logger)))

; See the complete stanza docs at https://dune.readthedocs.io/en/stable/dune-files.html#dune-project
