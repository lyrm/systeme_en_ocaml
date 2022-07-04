let iter_dir f dirname =
  let d = Unix.opendir dirname in
  try
    while true do
      f (Unix.readdir d)
    done
  with End_of_file -> Unix.closedir d

module Findlib : sig
  val find :
    (Unix.error * string * string -> unit) ->
    (string -> Unix.stats -> bool) ->
    bool ->
    int ->
    string list ->
    unit
end = struct
  exception Hidden of exn

  let hide_exn f x = try f x with exn -> raise (Hidden exn)
  let reveal_exn f x = try f x with Hidden exn -> raise exn

  (** [find handler action follow depth roots] parcourt la hiérarchie
     de fichiers à partir des racines indiquées dans la liste [roots]
     jusqu’à une profondeur maximale [depth] en suivant les liens
     symboliques si le drapeau [follow] est vrai. Les chemins trouvés
     sous une racine [r] incluent [r] comme préfixe.  Chaque chemin
     trouvé [p] est passé à la fonction [action]. En fait, action
     reçoit également les informations [Unix.stat p] si le drapeau
     [follow] est vrai ou [Unix.lstat p] sinon. La fonction [action]
     retourne un booléen indiquant également dans le cas d’un
     répertoire s’il faut poursuivre la recherche en profondeur (true)
     ou l’interrompre (false).

     La fonction [handler] sert au traitement des erreurs de parcours,
     nécessairement de type [Unix_error] : les arguments de
     l’exception sont alors passés à la fonction handler et le
     parcours continue. En cas d’interruption, l’exception est
     remontée à la fonction appelante. Lorsqu’une exception est levée
     par les fonctions [action] ou [handler], elle arrête le parcours de
     façon abrupte et est remontée immédiatement à l’appelant.*)
  let find on_error on_path follow depth roots =
    let rec find_rec depth visiting filename =
      try
        let infos = (if follow then Unix.stat else Unix.lstat) filename in
        let continue = hide_exn (on_path filename) infos in
        let id = (infos.st_dev, infos.st_ino) in
        if
          infos.st_kind = Unix.S_DIR
          && depth > 0
          && continue
          && ((not follow) || not (List.mem id visiting))
        then
          let process_child child =
            if
              child <> Filename.current_dir_name
              && child <> Filename.parent_dir_name
            then
              let child_name = Filename.concat filename child in
              let visiting = if follow then id :: visiting else visiting in
              find_rec (depth - 1) visiting child_name
          in
          iter_dir process_child filename
      with Unix.Unix_error (e, b, c) -> hide_exn on_error (e, b, c)
    in
    reveal_exn (List.iter (fun filename -> find_rec depth [] filename)) roots
end

(* /carine/truc/foo/bar.ml *)

let getcwd () =
  let get_id name =
    let s = Unix.stat name in
    (s.st_dev, s.st_ino)
  in
  let is_root dir = get_id dir = get_id (Filename.concat ".." dir) in
  let rec get_path where prev_id =
    if is_root where then prev_id
    else
      let nparent = Filename.concat Filename.parent_dir_name where in
      get_path nparent (get_id where :: prev_id)
  in
  let prev_id = get_path "" [] in
  let rec build current_path path_id =
    match path_id with
    | [] -> current_path
    | parent :: xs ->
        let found = ref "" in
        iter_dir
          (fun elt ->
            try
              if get_id (Filename.concat current_path elt) = parent then
                found := Filename.concat current_path elt
            with Unix.Unix_error _ -> ())
          current_path;
        build !found xs
  in
  build "/" prev_id

module IO : sig
  type in_channel

  exception End_of_file

  val open_in : string -> in_channel
  val input_char : in_channel -> char
  val close_in : in_channel -> unit

  type out_channel

  val open_out : string -> out_channel
  val output_char : out_channel -> char -> unit
  val close_out : out_channel -> unit
end = struct
  type in_channel = {
    in_buffer : Bytes.t;
    in_fd : Unix.file_descr;
    mutable in_pos : int;
    mutable in_end : int;
  }

  exception End_of_file

  let buffer_size = 8192

  let open_in filename =
    {
      in_buffer = Byte.create buffer_size;
      in_fd = openfile filename [ O_RDONLY ] 0;
      in_pos = 0;
      in_end = 0;
    }

  let input_char chan =
    if chan.in_pos < chan.in_end then (
      let c = chan.in_buffer.[chan.in_pos] in
      chan.in_pos <- chan.in_pos + 1;
      c)
    else
      match Unix.read chan.in_fd chan.in_buffer 0 buffer_size with
      | 0 -> raise End_of_file
      | r ->
          chan.in_end <- r;
          chan.in_pos <- 1;
          chan.in_buffer.[0]

  let close_in chan = close chan.in_fd

  type out_channel = {
    out_buffer : Bytes.t;
    out_fd : file_descr;
    mutable out_pos : int;
  }

  let open_out filename =
    {
      out_buffer = Bytes.create 8192;
      out_fd = Unix.openfile filename [ O_WRONLY; O_TRUNC; O_CREAT ] 0o666;
      out_pos = 0;
    }

  let output_char chan c =
    if chan.out_pos < Bytes.length chan.out_buffer then (
      chan.out_buffer.[chan.out_pos] <- c;
      chan.out_pos <- chan.out_pos + 1)
    else (
      ignore (Unix.write chan.out_fd chan.out_buffer 0 chan.out_pos);
      chan.out_buffer.[0] <- c;
      chan.out_pos <- 1)

  let close_out chan =
    ignore (write chan.out_fd chan.out_buffer 0 chan.out_pos);
    close chan.out_fd
end
