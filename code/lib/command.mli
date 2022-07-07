type t =
    Mkdir of string * int option
  | Rm of string * bool
  | Ln of string * string * bool
  | Mv of string * string
  | Echo of string
  | Ls of string option
  | Cat of string list

val exec_cmd : t -> unit
