(** Ce module sert à parser les lignes de commandes internes, c'est à
   dire dont l'implémentation est fournie ici et non par le système. *)

exception Empty_line

(** Décrit les différents types d'erreur de parsing. *)
type parsing_error =
  | Unrecognized_Name of string
  | Missing_arg of string
  | Too_many_arguments
  | Invalid_named_value of (string * string)
  | Undefined_command

exception Parsing_error of parsing_error

val print_error : parsing_error -> unit
(** Pour faciliter l'affichage des erreurs de parsing. *)

val parse : string -> Internal_cmd.t
(** [parse cmd] parse la ligne de commande [cmd], c'est dire le nom de
   commande et chacun de ses arguments et retourne la valeur de type
   [Command.t] correspondante. *)
