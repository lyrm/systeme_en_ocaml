
open Lwt.Syntax

let buf_size = 65536

let buffer = Bytes.create buf_size 

let ops = ref []

let rec perform_copy_lwt i src dst =
  let* n = Lwt_unix.read src buffer 0 buf_size in
  ops := `R i :: !ops;
  if n = buf_size then
    (Lwt.async (fun () -> 
      let+ _ = Lwt_unix.write dst buffer 0 n |> Lwt.map ignore in
      ops := `W i :: !ops;);
    perform_copy_lwt (i + 1) src dst)
  else
    let* _ = Lwt_unix.write dst buffer 0 n in
    Lwt.return (`Ok ())

let cp_lwt src dest =
  Lwt_main.run @@
  let* fd_src = Lwt_unix.openfile src [O_RDONLY] 0 in 
  let* fd_dst = Lwt_unix.openfile dest [O_RDWR; O_CREAT; O_TRUNC] 0o640 in
  perform_copy_lwt 0 fd_src fd_dst
  

let rec perform_copy src dst =
  let n = Unix.read src buffer 0 buf_size in
  Unix.write dst buffer 0 n |> ignore;
  if n = buf_size then
    perform_copy src dst
  else
    `Ok ()


let cp_sync src dest =
  let fd_src = Unix.openfile src [O_RDONLY] 0 in
  let fd_dst = Unix.openfile dest  [O_RDWR; O_CREAT; O_TRUNC] 0o640 in
  perform_copy fd_src fd_dst

let cp sync =
  if sync then cp_sync else cp_lwt

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
  let man_xrefs =
    [ `Tool "mv"; `Tool "scp"; `Page ("umask", 2); `Page ("symlink", 7) ]
  in
  let man =
    [ `S Manpage.s_bugs;
      `P "Email them to <bugs@example.org>."; ]
  in
  let info = Cmd.info "cp" ~version:"%%VERSION%%" ~doc ~man ~man_xrefs in
  Cmd.v info Term.(ret (const cp $ sync $ src $ dest))


let main () = exit (Cmd.eval cmd)
let () = main ()
