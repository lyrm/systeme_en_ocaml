(* Dès qu'un erreur Unix est attrapée, [exit 2] est retourné et le minishell s'arrête. *)
let _naive_minishell () =
  try
    while true do
      let cmd_line = input_line Stdlib.stdin in
      try
        let cmd : Command.t = Parser.parse cmd_line in
        Command.exec_cmd cmd
      with
      | Parser.Parsing_error err -> Parser.print_error err
      | Parser.Empty_line -> ()
    done
  with End_of_file -> ()

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

let exec_cmd = function
  | Ast.Internal cmd -> Command.exec_cmd cmd
  | Ast.External (program :: _ as cmd) ->
      Unix.execvp program (Array.of_list cmd)
  | _ -> failwith ""

let fork_and_wait fn =
  match Unix.fork () with
  | 0 -> fn () |> exit
  | pid_son -> (
      let _pid, status = Unix.waitpid [] pid_son in
      match status with WEXITED i -> i | WSIGNALED i -> i | WSTOPPED i -> i)

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

let minishell () =
  try
    Printf.printf "%s> %!" (Unix.getcwd ());
    while true do
      let cmd = input_line Stdlib.stdin in
      try
        let cmd = Ast.parse cmd in
        let code = interprete cmd in
        Printf.printf "%s (%d)> %!" (Unix.getcwd ()) code
      with
      | Parser.Parsing_error err -> Parser.print_error err
      | Parser.Empty_line -> ()
    done
  with End_of_file -> ()

let () = Unix.handle_unix_error minishell ()