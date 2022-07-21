(** [naive_minishell] est un premier essai d'une boucle de lecture
   pour le minishell. Son problème est que si la commande exécutée
   génère une erreur Unix (ou une autre d'ailleurs), le minishell
   s'arrête. On préférerait bien entendu qu'il continue de fonctionner
   tout en décrivant l'erreur. *)
let _naive_minishell () =
  try
    while true do
      let cmd_line = input_line Stdlib.stdin in
      try
        let cmd : Internal_cmd.t = Parser.parse cmd_line in
        Internal_cmd.exec_cmd cmd
      with
      | Parser.Parsing_error err -> Parser.print_error err
      | Parser.Empty_line -> ()
    done
  with End_of_file -> ()

(** [setup_redirection] applique l'effet d'une redirection :
   + In t -> remplace l'entrée standard par t
   + Out t -> remplace la sortie standard par t *)
let setup_redirection = function
  | Ast.In target ->
      let fd = Unix.openfile target [ Unix.O_RDONLY ] 0 in
      Unix.dup2 fd Unix.stdin;
      Unix.close fd
  | Ast.Out target ->
      let fd =
        Unix.openfile target [ Unix.O_CREAT; Unix.O_TRUNC; Unix.O_WRONLY ] 0o660
      in
      Unix.dup2 fd Unix.stdout;
      Unix.close fd

(** [exec_cmd cmd] exécute les commandes internes et externes. *)
let exec_cmd = function
  | Ast.Internal cmd -> Internal_cmd.exec_cmd cmd
  | Ast.External (program :: _ as cmd) ->
      Unix.execvp program (Array.of_list cmd)
  | _ -> failwith ""

(** [fork_and_wait fn] est la fonction qui permet d'éviter que le
   minishell termine à la moindre erreur : pour se faire, les
   commandes sont exécutés par un fork plutôt que par le processus du
   minishell. De la sorte, si quelque chose se passe mal, c'est le
   processus fils qui meurt. *)
let fork_and_wait fn =
  match Unix.fork () with
  | 0 -> fn () |> exit
  | pid_son -> (
      let _pid, status = Unix.waitpid [] pid_son in
      match status with WEXITED i -> i | WSIGNALED i -> i | WSTOPPED i -> i)

(** [interprete t] gère :

 + la commande [cd], en appliquant [chdir]. C'est le seul cas où aucun fork n'est
   fait puisqu'on veut modifier l'état du processus père (qui exécute
   la boucle de lecture du minishell)
 + pour les autres commandes, appliquent les redirections appelle [exec_cmd]
 + [Pipe] : dans ce cas, on a 2 forks !
 + [And] et [Or] : il s'agit juste d'appliquer les opérateurs logiques correspondant
   sur les valeurs de sortie (d'exit) des commandes termes.
*)
let rec interprete : Ast.t -> int = function
  | Ast.Command (Cd target, _) -> (
      match Unix.chdir target with exception Unix.Unix_error _ -> 1 | _ -> 0)
  | Command (cmd, redirections) ->
      fork_and_wait (fun () ->
          List.iter setup_redirection redirections;
          exec_cmd cmd;
          0)
  | Pipe (a, b) ->
      fork_and_wait (fun () ->
          let fd_in, fd_out = Unix.pipe () in
          match Unix.fork () with
          | 0 ->
              Unix.dup2 fd_out Unix.stdout;
              Unix.close fd_out;
              Unix.close fd_in;
              interprete a
          | _ ->
              Unix.dup2 fd_in Unix.stdin;
              Unix.close fd_out;
              Unix.close fd_in;
              interprete b)
  | And (a, b) ->
      let code_a = interprete a in
      if code_a <> 0 then code_a else interprete b
  | Or (a, b) ->
      let code_a = interprete a in
      if code_a == 0 then 0 else interprete b


let prompt = function
  | None -> Printf.printf "%s> %!" (Unix.getcwd ())
  | Some code -> Printf.printf "%s (%d)> %!" (Unix.getcwd ()) code 

let minishell () =
  let last_code = ref None in
  try
    while true do
      prompt !last_code;
      let cmd = input_line Stdlib.stdin in
      last_code := None;
      try
        let cmd = Ast.parse cmd in
        last_code := Some (interprete cmd)
      with
      | Parser.Parsing_error err -> Parser.print_error err
      | Parser.Empty_line -> ()
    done
  with End_of_file -> ()

let () = Unix.handle_unix_error minishell ()
