(**
   les commandes :
   - mkdir
   - rm / rm dir
   - ln / ln -s
   - echo
   - ls

   - cp et cp -r

   - |
   - > <

   - ping/echo si on veut faire du réseau
*)

type t =
  | Mkdir of string * int option
  | Rm of string * bool
  | Ln of string * string * bool
  | Echo of string
  | Ls of string option
  | Cat of string list

(* On ne gère pas les erreurs ici, on utilise [Unix.handle_unix_error]
   pour les gérer. *)
let all_files_in_dir dirname =
  let rec read dir acc =
    try read dir (Unix.readdir dir :: acc)
    with End_of_file ->
      Unix.closedir dir;
      acc
  in
  let dir = Unix.opendir dirname in
  let all_files = read dir [] in
  List.filter
    (fun file ->
      not (file = Filename.parent_dir_name || file = Filename.current_dir_name))
    all_files

let write_stdout text =
  let text = Bytes.of_string text in
  let max_length = 8192 in
  let rec loop ind prev_written =
    let length = min max_length (Bytes.length text) in
    let written = Unix.single_write Unix.stdout text ind length in
    if written + prev_written < Bytes.length text then
      loop (ind + written) (prev_written + written)
  in
  loop 0 0

let copy_file fd_in fd_out =
  let buffer_size = 8192 in
  let buffer = Bytes.create buffer_size in
  let rec copy_loop () =
    match Unix.read fd_in buffer 0 buffer_size with
    | 0 -> ()
    | r ->
        ignore (Unix.write fd_out buffer 0 r);
        copy_loop ()
  in
  copy_loop ()

(** TODO : lecture sur stdin *)

let exec_cmd (* ~verbose *) = function
  | Mkdir (filename, perm_opt) ->
      let perm = match perm_opt with None -> 0o775 | Some p -> p in
      Unix.mkdir filename perm
  | Rm (filename, recursive) ->
      if recursive then Unix.rmdir filename else Unix.unlink filename
  | Ln (source, dest, symbolic) ->
      if symbolic then Unix.symlink source dest else Unix.link source dest
  | Echo text -> write_stdout (text ^ "\n")
  | Ls dirname ->
      let dirname =
        match dirname with None -> Filename.current_dir_name | Some d -> d
      in
      let all_files = all_files_in_dir dirname |> String.concat "\t" in
      write_stdout (all_files ^ "\n")
  | Cat files -> (
      match files with
      | [] -> copy_file Unix.stdin Unix.stdout
      | _ ->
          List.iter
            (fun file ->
              let fd_in = Unix.openfile file [ Unix.O_RDONLY ] 0 in
              let fd_out = Unix.stdout in
              copy_file fd_in fd_out;
              Unix.close fd_in)
            files)
