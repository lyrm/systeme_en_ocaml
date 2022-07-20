(** Types des commandes *)
type t =
  | Mkdir of string * int option
  | Rm of string * bool
  | Ln of string * string * bool
  | Mv of string * string
  | Echo of string
  | Ls of string option
  | Cat of string list

(** [files_in_dir dir] liste tous les fichiers non spéciaux dans le
   répertoire [dir] (dans le répertoire courant si dir = None). Les
   fichiers courant "." et parent ".."  ne sont pas retournés. *)
let files_in_dir diropt =
  let dirname =
    match diropt with None -> Filename.current_dir_name | Some d -> d
  in
  let rec read dir_handle acc =
    try
      let nfile = Unix.readdir dir_handle in
      read dir_handle (nfile :: acc)
    with End_of_file -> acc
  in
  let dir_handle = Unix.opendir dirname in
  let all_files = read dir_handle [] in
  Unix.closedir dir_handle;
  List.filter
    (fun file ->
      not (file = Filename.parent_dir_name || file = Filename.current_dir_name))
    all_files

(** [write_stdout txt] écrit la chaîne de caractère [txt] sur la
   sortie standard par bloc de 8192 caractères. *)
let write_stdout text =
  let text = Bytes.of_string text in
  let max_len = 8192 in
  let rec loop ind to_write =
    let len = min max_len to_write in
    let written = Unix.single_write Unix.stdout text ind len in
    if written = max_len then loop (ind + written) (to_write - written)
  in
  loop 0 (Bytes.length text)

(** [write_fd_stdout fd] recopie le contenu de [fd] sur la sortie standard. *)
let write_fd_stdout fd_in =
  let buffer_size = 8192 in
  let buffer = Bytes.create buffer_size in
  let rec copy_loop () =
    match Unix.read fd_in buffer 0 buffer_size with
    | 0 -> ()
    | r ->
        ignore (Unix.single_write Unix.stdout buffer 0 r);
        copy_loop ()
  in
  copy_loop ()

(** [exec_cmd cmd] exécute la commande [cmd]. *)
let exec_cmd = function
  | Cat files -> (
      match files with
      | [] -> write_fd_stdout Unix.stdin
      | _ ->
          List.iter
            (fun file ->
              (* La permission ne sert qu'en cas de création du fichier *)
              let fd_in = Unix.openfile file [ Unix.O_RDONLY ] 0 in
              write_fd_stdout fd_in;
              Unix.close fd_in)
            files)
  | Ln (source, dest, symbolic) ->
      if symbolic then Unix.symlink source dest else Unix.link source dest
  | Mv (source, dest) -> Unix.rename source dest
  | Rm (filename, recursive) ->
      if recursive then Unix.rmdir filename else Unix.unlink filename
  | Mkdir (filename, perm_opt) ->
      let perm = match perm_opt with None -> 0o775 | Some p -> p in
      Unix.mkdir filename perm
  | Echo text -> write_stdout (text ^ "\n")
  | Ls diropt ->
      let all_files = files_in_dir diropt |> String.concat "\t" in
      write_stdout (all_files ^ "\n")
