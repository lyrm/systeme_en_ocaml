let _read_stdin_line () = failwith "todo"
(* réimplementation de Stdlib.input_line*)

(**
   les commandes :
   - mkdir
   - ln / ln -s
   - echo

   - ls

   - cp et cp -r

   - |
   - > <

   - ping/echo si on veut faire du réseau
*)

let print_status program status =
  match status with
  | Unix.WEXITED 255 -> ()
  | WEXITED status -> Printf.printf "%s exited with code %d\n%!" program status
  | WSIGNALED signal ->
      Printf.printf "%s killed by signal %d\n%!" program signal
  | WSTOPPED _signal -> Printf.printf "%s stopped (???)\n%!" program

let minishell () =
  try
    while true do
      let cmd = input_line Stdlib.stdin in
      let cmd = Parser.parse cmd in
      match Unix.fork () with
      | 0 -> Command.exec_cmd cmd
      | _pid_son ->
          let _pid, status = Unix.wait () in
          print_status "Program" status
    done
  with End_of_file -> ()
;;

Unix.handle_unix_error minishell ()
