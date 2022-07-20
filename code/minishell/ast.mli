(** Catégorise les différentes commandes *)
type cmd_kind =
  | Internal of Internal_cmd.t
      (** les commandes dont l'implémentation est fournie ici *)
  | External of string list
      (** les commandes dont l'implémentation est
       fournie par le système *)
  | Cd of string
      (** Command de changement de dossier (nécessite un traitement à part !) *)

type redirection =
  | In of string  (** écrit [>]  dans un terminal *)
  | Out of string  (** écrit [<] dans un terminal *)

type command = cmd_kind * redirection list
(** Une commande est donc définie par une paire :
  - la commande à proprement parler
  - les redirections qui redefinissent les entrée et sortie standards.
*)

(** Une ligne de commande peut aussi contenir des tubes [|] et
    les opérateurs logiques [&&] et [||] *)
type t =
  | Command of command
  | Pipe of t * t  (** | *)
  | And of t * t
  | Or of t * t

val parse : string -> t
(** [parse cmd] parse une ligne de commande [cmd] pour construire un
   type [t].

   Exemples d'application de la fonction [parse] (avec [open Internal_cmd])

   + mv f1 f2            ->  Command ( Internal (Mv ("f1", "f2")), [] )

   + ls > f1 | cat f1    ->  Pipe ( Command (Internal (Ls None), [Out "f1"]),
                                    Command (Internal (Cat ["f1"]), [])  )

   + echo Bonjour! > f1 && cat f1 | tr 'A-Z' 'a-z'
                             Pipe (And (Command (Internal (Command.Echo "Bonjour!"), [Out "f1"]),
                                        Command (Internal (Command.Cat ["f1"]), [])),
                                   Command (External ["tr"; "'A-Z'"; "'a-z'"], []))
*)

val to_string : t -> string


(* Il y a évidemment des tas de façons de rendre le minishell encore
   plus intéressant, en ajoutant :

  - la gestion du parenthésage (qui complexifie uniquement le parser)
  - un historique (history)
  - etc ...

*)
