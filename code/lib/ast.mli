type cmd_kind =
  | Internal of Command.t (* les commandes precedentes *)
  | External of string list (* commandes dans le PATH *)
  | Cd of string (* changement de dossier *)

type redirection =
  | In of string (* > *)
  | Out of string (* < *)

type command = cmd_kind * redirection list

type t =
  | Command of command
  | Pipe of t * t (* | *)
  | And of t * t
  | Or of t * t

val parse : string -> t
val to_string : t -> string
