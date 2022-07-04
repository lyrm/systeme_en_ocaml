exception Empty_line
exception Undefined_command

(** [split_cmd_args line] découpe la ligne de commande à chaque espace pour extraire :
    - la commande
    - une liste d'arguments. *)
let split_cmd_args line =
  let words = String.split_on_char ' ' line in
  let words_without_empty =
    List.filter (function "" -> false | _ -> true) words
  in
  match words_without_empty with
  | [] -> raise Empty_line
  | cmd :: args -> (cmd, args)

(** Les arguments d'une commande peuvent être de 3 types :

    - obligatoire et déterminés par leur position dans leur ligne de commande.
    Ex : dans [cp file1 file2] le rôle de [file1] et [file2] est déterminée par leur position.

    - une paire nom et valeur,
    Ex : la paire [(mode, perm)] dans [mkdir dir --mode perm]

    - un drapeau (équivaut à une valeur booléenne).
    Ex : [cp --help] *)
type 'a args_type =
  | Pos of int * string
  | Named of string * string
  | Flag of string

(** [is_name str] retourne [true] si [str] a une longueur de 2 et commence par "-". *)
let is_name str = String.length str == 2 && String.get str 0 == '-'

let get_name str = String.sub str 1 (String.length str - 1)

(** Gestions des erreurs de parsing. *)
type parsing_error =
  | Unrecognized_Flag of string
  | Unrecognized_Name of string
  | Missing_arg of string
  | Too_many_arguments
  | Invalid_named_value of (string * string)

exception Parsing_error of parsing_error

let exn_unrecognized_flag flag = Parsing_error (Unrecognized_Flag flag)
let exn_unrecognized_name name = Parsing_error (Unrecognized_Name name)
let exn_missing_arg name = Parsing_error (Missing_arg name)
let exn_too_many_arguments = Parsing_error Too_many_arguments

let exn_invalid_named_value_argument name value =
  Parsing_error (Invalid_named_value (name, value))

(* Descrition d'une ligne de commande *)
module Named = Map.Make (struct
  type t = string

  let compare = compare
end)

module Flags = Map.Make (struct
  type t = string

  let compare = compare
end)

type command_line = {
  cmd : string;
  flags : bool Flags.t;
  named : string option Named.t;
  mandatory : string option Array.t;
}
(** Une ligne de commande comprend :
 - la commande
 - des arguments nommées associés à une valeur
 - des drapeaux associés à une valeur booléenne
 - des arguments obligatoires, déterminés par leur position
*)

(** [parse_args args command] parse la liste d'arguments [args] est
   modifie les valeurs des arguments nommées et des drapeaux en
   fonction du contenu de [args].

   Si un drapeau est présent au moins une fois dans [args], sa valeur
   dans [command.flags] devient [true].

   Si un argument nommé est présent au moins une fois dans [args], la
   dernière valeur qu'il prend est stockée dans [command.named].

   Enfin, les arguments obligatoires sont placés dans
   [command.mandatory] à leur position d'apparition dans [args]. *)
let parse_args args command =
  let rec loop args curr_name curr_pos command =
    match (args, curr_name) with
    | [], None -> command
    | [], Some name -> raise (exn_missing_arg name)
    | arg :: args, None ->
        if is_name arg then
          let name = get_name arg in
          if Flags.mem name command.flags then
            loop args None curr_pos
              { command with flags = Flags.add name true command.flags }
          else if Named.mem name command.named then
            loop args (Some name) curr_pos command
          else raise (exn_unrecognized_name name)
        else if curr_pos < Array.length command.mandatory then
          loop args None (curr_pos + 1)
            {
              command with
              mandatory =
                (command.mandatory.(curr_pos) <- Some arg;
                 command.mandatory);
            }
        else raise exn_too_many_arguments
    | arg :: args, Some n ->
        if is_name arg then raise (exn_missing_arg (get_name n))
        else
          loop args None curr_pos
            { command with named = Named.add n (Some arg) command.named }
  in
  loop args None 0 command

let init_command cmd ~flags ~named ~mandatory =
  {
    cmd;
    flags =
      List.fold_left
        (fun flags flag -> Flags.add flag false flags)
        Flags.empty flags;
    named =
      List.fold_left
        (fun names name -> Named.add name None names)
        Named.empty named;
    mandatory = Array.init mandatory (fun _ -> None);
  }

(** [build_* cmd_line] transforme un type [command_line] en un
   type [Command.t]. *)
let build_mkdir cmd_line =
  let filename =
    match cmd_line.mandatory.(0) with
    | Some n -> n
    | None -> raise (exn_missing_arg "filename")
  in
  let perm =
    match Named.find "m" cmd_line.named with
    | None -> None
    | Some p -> (
        try Some (int_of_string ("0o" ^ p))
        with _ -> raise (exn_invalid_named_value_argument "mode" p))
  in
  Command.Mkdir (filename, perm)

let build_rm cmd_line =
  let filename =
    match cmd_line.mandatory.(0) with
    | Some n -> n
    | None -> raise (exn_missing_arg "filename")
  in
  let recursive = Flags.find "r" cmd_line.flags in
  Command.Rm (filename, recursive)

let build_ln cmd_line =
  let source =
    match cmd_line.mandatory.(0) with
    | Some n -> n
    | None -> raise (exn_missing_arg "source filename")
  in
  let dest =
    match cmd_line.mandatory.(0) with
    | Some n -> n
    | None -> raise (exn_missing_arg "destination filename")
  in
  let symbolic = Flags.find "s" cmd_line.flags in
  Command.Ln (source, dest, symbolic)

let build_ls cmd_line =
  let filename =
    match cmd_line.mandatory.(0) with
    | Some n -> n
    | None -> raise (exn_missing_arg "source filename")
  in
  Command.Ls filename

(** [parse cmd_line] parse la ligne de commande [cmd_line], càd, elle
   est découpée pour séparer la commande et les arguments puis, les
   arguments sont parsées. Finalement, on construit le type
   [Command.t].  *)
let parse cmd_line =
  let cmd, args = split_cmd_args cmd_line in
  match cmd with
  | "mkdir" ->
      let cmd_line =
        init_command cmd ~flags:[] ~named:[ "m" ] ~mandatory:1
        |> parse_args args
      in
      build_mkdir cmd_line
  | "rm" ->
      let cmd_line =
        init_command cmd ~flags:[ "r" ] ~named:[] ~mandatory:1
        |> parse_args args
      in
      build_rm cmd_line
  | "ln" ->
      let cmd_line =
        init_command cmd ~flags:[ "s" ] ~named:[] ~mandatory:2
        |> parse_args args
      in
      build_ln cmd_line
  | "ls" ->
      let cmd_line =
        init_command cmd ~flags:[] ~named:[] ~mandatory:1 |> parse_args args
      in
      build_ls cmd_line
  | _ -> raise Undefined_command
