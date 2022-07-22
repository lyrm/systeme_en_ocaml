
open Lwt.Syntax

let buf_size = 65536

let buffer = Bytes.create buf_size 

module Sync = struct
  (* Copie synchrone implémentée de façon "classique" *)
  let rec perform_copy src dst =
    let n = Unix.read src buffer 0 buf_size in
    Unix.write dst buffer 0 n |> ignore;
    if n = buf_size then
      perform_copy src dst
    else
      `Ok ()

  let cp src dest =
    let fd_src = Unix.openfile src [O_RDONLY] 0 in
    let fd_dst = Unix.openfile dest  [O_RDWR; O_CREAT; O_TRUNC] 0o640 in
    perform_copy fd_src fd_dst
end

module Async = struct
  (* Copie asynchrone en utilisant Lwt *)
  let rec perform_copy_lwt src dst =
    let* n = Lwt_unix.read src buffer 0 buf_size in
    if n = buf_size then
      let* _ = Lwt_unix.write dst buffer 0 n in
      perform_copy_lwt src dst
    else
      let* _ = Lwt_unix.write dst buffer 0 n in
      Lwt.return (`Ok ())

  let cp src dest =
    Lwt_main.run @@
    let* fd_src = Lwt_unix.openfile src [O_RDONLY] 0 in 
    let* fd_dst = Lwt_unix.openfile dest [O_RDWR; O_CREAT; O_TRUNC] 0o640 in
    perform_copy_lwt fd_src fd_dst
end

let cp sync =
  if sync then Sync.cp else Async.cp

(* Cmdliner permet de parser la ligne de commande *)
open Cmdliner

let src =
  let doc = "Source file(s) to copy." in
  Arg.(required & pos ~rev:true 1 (some string) None & info [] ~docv:"SOURCE" ~doc)

let dest =
  let doc = "Destination of the copy. Must be a directory if there is more \
              than one $(i,SOURCE)." in
  let docv = "DEST" in
  Arg.(required & pos ~rev:true 0 (some string) None & info [] ~docv ~doc)

let sync =
  Arg.(value & flag & info ["s"])

let cmd =
  let doc = "Copy files" in
  let info = Cmd.info "cp" ~doc in
  Cmd.v info Term.(ret (const cp $ sync $ src $ dest))


let main () = exit (Cmd.eval cmd)
let () = main ()
