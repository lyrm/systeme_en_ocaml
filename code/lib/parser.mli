exception Empty_line

type parsing_error =
  | Unrecognized_Name of string
  | Missing_arg of string
  | Too_many_arguments
  | Invalid_named_value of (string * string)
  | Undefined_command

exception Parsing_error of parsing_error

val print_error : parsing_error -> unit
val parse : string -> Command.t
