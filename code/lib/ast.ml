type cmd_kind =
  | Internal of Command.t (* les commandes precedentes *)
  | External of string list (* commandes dans le PATH *)
  | Cd of string (* changement de dossier *)

type redirection =
  | In of string
  (* > *)
  | Out of string (* < *)

type command = cmd_kind * redirection list

type t =
  | Command of command
  | Pipe of t * t (* | *)
  | And of t * t
  | Or of t * t

let split word str = Str.bounded_split (Str.regexp (" " ^ word ^ " ")) str 2

let parse_c str =
  if String.starts_with ~prefix:"cd " str then
    Cd (String.sub str 3 (String.length str - 3))
  else
    match Parser.parse str with
    | v -> Internal v
    | exception Parser.Parsing_error Undefined_command ->
        External (String.split_on_char ' ' str)

let rec parse_redirections = function
  | [] -> []
  | [ _ ] -> failwith "parse error"
  | Str.Delim " > " :: Str.Text file :: rest ->
      Out file :: parse_redirections rest
  | Str.Delim " < " :: Str.Text file :: rest ->
      In file :: parse_redirections rest
  | _ -> failwith "parse error"

let parse_cmd str =
  let tokens = Str.full_split (Str.regexp " < \\| > ") str in
  match tokens with
  | Text a :: redirections ->
      Command (parse_c a, parse_redirections redirections)
  | _ -> failwith ""

let rec parse_or str =
  match split "||" str with
  | [ str ] -> parse_cmd str
  | [ a; b ] -> Or (parse_cmd a, parse_or b)
  | _ -> failwith ""

let rec parse_and str =
  match split "&&" str with
  | [ str ] -> parse_or str
  | [ a; b ] -> And (parse_or a, parse_and b)
  | _ -> failwith ""

let rec parse str =
  match split "|" str with
  | [ str ] -> parse_and str
  | [ a; b ] -> Pipe (parse_and a, parse b)
  | _ -> failwith ""

let c_to_string = function
  | Internal _c -> "(internal)"
  | External c -> String.concat " " c
  | Cd c -> "cd " ^ c

let r_to_string = function In file -> "< " ^ file | Out file -> "> " ^ file

let rec to_string = function
  | Pipe (a, b) -> to_string a ^ " | " ^ to_string b
  | And (a, b) -> to_string a ^ " && " ^ to_string b
  | Or (a, b) -> to_string a ^ "|| " ^ to_string b
  | Command (c, redirections) ->
      c_to_string c
      ^ " "
      ^ String.concat " " (List.map r_to_string redirections)
