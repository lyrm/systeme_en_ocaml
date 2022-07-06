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

    - déterminés par leur position dans leur ligne de commande.
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
  | Missing_positional_arg of string
  | Too_many_arguments
  | Invalid_named_value of (string * string)
  | Undefined_command

exception Parsing_error of parsing_error

let exn_unrecognized_flag flag = Parsing_error (Unrecognized_Flag flag)
let exn_unrecognized_name name = Parsing_error (Unrecognized_Name name)
let exn_missing_arg name = Parsing_error (Missing_arg name)

let exn_missing_positional_arg name =
  Parsing_error (Missing_positional_arg name)

let exn_too_many_arguments = Parsing_error Too_many_arguments

let exn_invalid_named_value_argument name value =
  Parsing_error (Invalid_named_value (name, value))

let print_error err =
  let err_msg =
    match err with
    | Unrecognized_Flag flag -> "Unrecognized flag \"" ^ flag ^ "\""
    | Unrecognized_Name name -> "Unrecognized argument name \"-" ^ name ^ "\""
    | Missing_arg name -> "Missing argument \"" ^ name ^ "\""
    | Missing_positional_arg name ->
        "Missing positional argument \"" ^ name ^ "\""
    | Too_many_arguments -> "Too many arguments"
    | Invalid_named_value (name, value) ->
        "Invalid value \"" ^ value ^ "\" for \"" ^ name ^ "\""
    | Undefined_command -> "Undefined command"
  in
  let err_msg = Bytes.of_string (err_msg ^ "\n") in
  ignore (Unix.write Unix.stderr err_msg 0 (Bytes.length err_msg))

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
  positional : string option Array.t;
}
(** Une ligne de commande comprend :
 - la commande
 - des arguments nommées associés à une valeur
 - des drapeaux associés à une valeur booléenne
 - des arguments déterminés par leur position
*)

(** [parse_args args cmd_line] parse la liste d'arguments [args] est
   modifie les valeurs des arguments nommées et des drapeaux en
   fonction du contenu de [args].

   Si un drapeau est présent au moins une fois dans [args], sa valeur
   dans [cmd_line.flags] devient [true].

   Si un argument nommé est présent au moins une fois dans [args], la
   dernière valeur qu'il prend est stockée dans [cmd_line.named].

   Enfin, les arguments positionels sont placés dans
   [cmd_line.positional] à leur position d'apparition dans [args].

   Le passage en entrée de la variable [cmd_line] prédéfinis
   correctement en fonction de la commande reçue permet de repérer dès
   cet étape du parsing les arguments de la ligne de commande non
   valides.  *)
let parse_args args cmd_line =
  let rec loop args curr_name curr_pos cmd_line =
    match (args, curr_name) with
    | [], None -> cmd_line
    | [], Some name -> raise (exn_missing_arg ("-" ^ name))
    | arg :: args, None ->
        if is_name arg then
          let name = get_name arg in
          if Flags.mem name cmd_line.flags then
            loop args None curr_pos
              { cmd_line with flags = Flags.add name true cmd_line.flags }
          else if Named.mem name cmd_line.named then
            loop args (Some name) curr_pos cmd_line
          else raise (exn_unrecognized_name name)
        else if curr_pos < Array.length cmd_line.positional then
          loop args None (curr_pos + 1)
            {
              cmd_line with
              positional =
                (cmd_line.positional.(curr_pos) <- Some arg;
                 cmd_line.positional);
            }
        else raise exn_too_many_arguments
    | arg :: args, Some n ->
        if is_name arg then raise (exn_missing_arg n)
        else
          loop args None curr_pos
            { cmd_line with named = Named.add n (Some arg) cmd_line.named }
  in
  loop args None 0 cmd_line

let init_cmd_line cmd ~flags ~named ~positional =
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
    positional = Array.init positional (fun _ -> None);
  }

(** [build_* cmd_line] transforme un type [command_line] en un
   type [Command.t]. *)
let build_mkdir cmd_line =
  let filename =
    match cmd_line.positional.(0) with
    | Some n -> n
    | None -> raise (exn_missing_arg "filename")
  in
  let perm =
    match Named.find "m" cmd_line.named with
    | None -> None
    | Some p -> (
        try Some (int_of_string ("0o" ^ p))
        with _ -> raise (exn_invalid_named_value_argument "mode (-m)" p))
  in
  Command.Mkdir (filename, perm)

let build_rm cmd_line =
  let filename =
    match cmd_line.positional.(0) with
    | Some n -> n
    | None -> raise (exn_missing_arg "filename")
  in
  let recursive = Flags.find "r" cmd_line.flags in
  Command.Rm (filename, recursive)

let build_ln cmd_line =
  let source =
    match cmd_line.positional.(0) with
    | Some n -> n
    | None -> raise (exn_missing_arg "source filename")
  in
  let dest =
    match cmd_line.positional.(0) with
    | Some n -> n
    | None -> raise (exn_missing_arg "destination filename")
  in
  let symbolic = Flags.find "s" cmd_line.flags in
  Command.Ln (source, dest, symbolic)

let build_echo cmd_line =
  let text_to_write =
    match cmd_line.positional.(0) with
    | Some n -> n
    | None -> raise (exn_missing_arg "text")
  in
  Command.Echo text_to_write

let build_ls cmd_line =
  let filename =
    match cmd_line.positional.(0) with Some n -> Some n | None -> None
  in
  Command.Ls filename

let build_cat cmd_line =
  let files =
    Array.to_list cmd_line.positional
    |> List.filter Option.is_some
    |> List.map Option.get
  in
  Command.Cat files

(** [parse cmd_line] parse la ligne de commande [cmd_line], càd, elle
   est découpée pour séparer la commande et les arguments puis, les
   arguments sont parsées. Finalement, on construit le type
   [Command.t].  *)
let parse cmd_line =
  let cmd, args = split_cmd_args cmd_line in
  match cmd with
  | "mkdir" ->
      let cmd_line =
        init_cmd_line cmd ~flags:[] ~named:[ "m" ] ~positional:1
        |> parse_args args
      in
      build_mkdir cmd_line
  | "rm" ->
      let cmd_line =
        init_cmd_line cmd ~flags:[ "r" ] ~named:[] ~positional:1
        |> parse_args args
      in
      build_rm cmd_line
  | "ln" ->
      let cmd_line =
        init_cmd_line cmd ~flags:[ "s" ] ~named:[] ~positional:2
        |> parse_args args
      in
      build_ln cmd_line
  | "echo" ->
      let cmd_line =
        init_cmd_line cmd ~flags:[] ~named:[] ~positional:1 |> parse_args args
      in
      build_echo cmd_line
  | "ls" ->
      let cmd_line =
        init_cmd_line cmd ~flags:[] ~named:[] ~positional:1 |> parse_args args
      in
      build_ls cmd_line
  | "cat" ->
      let cmd_line =
        init_cmd_line cmd ~flags:[] ~named:[] ~positional:10 |> parse_args args
      in
      build_cat cmd_line
  | _ -> raise (Parsing_error Undefined_command)
