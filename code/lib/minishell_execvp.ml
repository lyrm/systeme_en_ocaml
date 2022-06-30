(* Faire mieux avec angstrom par exemple ? *)
let split_words s =
  let words = String.split_on_char ' ' s in
  let words_without_empty =
    List.filter (function "" -> false | _ -> true) words in
  Array.of_list words_without_empty

(* Solution facile -> avec execvp*)
let exec_command cmd =
  try Unix.execvp cmd.(0) cmd
  with Unix.Unix_error(err, _, _) ->
    Printf.printf "Cannot execute %s : %s\n%!"
      cmd.(0) (Unix.error_message err);
    exit 255

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
      let cmd = input_line Stdlib.stdin in
      let words = split_words cmd in
      match Unix.fork() with
        0 -> exec_command words
      | _pid_son ->
         let _pid, status = Unix.wait() in
         print_status "Program" status
    done
  with End_of_file ->
    ();;

Unix.handle_unix_error minishell ();;
