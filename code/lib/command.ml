type t = Mkdir of string * int option

let mkdir_cmd filename file_perm = Unix.mkdir filename file_perm

let exec_cmd (* ~verbose *) = function
  | Mkdir (filename, perm_opt) ->
      let perm = match perm_opt with None -> 0o775 | Some p -> p in
      Unix.mkdir filename perm
