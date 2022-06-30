(* Faire mieux avec angstrom par exemple ? *)
let parse s =
  let words = String.split_on_char ' ' s in
  let words_without_empty =
    List.filter (function "" -> false | _ -> true) words in
  match words_without_empty with
  | [] -> failwith "todo"
  (* pour l'instant ça lit ligne par ligne, mais avec un vrai parseur
     on pourra ignore les lignes vides *)
  | cmd :: args -> cmd, args

let _read_stdin_line () = failwith "todo"
  (* réimplementation de Stdlib.input_line*)

let exec_command _ _ = failwith "todo"

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
    Unix.WEXITED 255 -> ()
  | WEXITED status ->
     Printf.printf "%s exited with code %d\n%!" program status;
  | WSIGNALED signal ->
     Printf.printf "%s killed by signal %d\n%!" program signal;
  | WSTOPPED _signal ->
     Printf.printf "%s stopped (???)\n%!" program;;

let minishell () =
  try
    while true do
      let cmd = input_line Stdlib.stdin  in
      let cmd, args = parse cmd in
      match Unix.fork() with
        0 -> exec_command cmd args
      | _pid_son ->
         let _pid, status = Unix.wait () in
         print_status "Program" status
    done
  with End_of_file ->
    ();;

Unix.handle_unix_error minishell ();;
