
open Unix

let socket = socket PF_INET SOCK_STREAM 0

let () = bind socket (ADDR_INET (inet_addr_of_string "0.0.0.0", 1025)) 

let () = listen socket 1


let buffer_size = 128
let buffer = Bytes.create buffer_size

let () =
  let rec loop () =
    let (connection, src) = accept socket in
    let (ip, port) = match src with
      | ADDR_INET (ip, port) -> (ip, port)
      | _ -> failwith ""
    in
    Printf.printf "Nouveau client: %s:%d\n%!" (string_of_inet_addr ip) port;
    let rec read_loop () =
      let n = read connection buffer 0 buffer_size in
      write connection buffer 0 n |> ignore;
      if n > 0 then
        read_loop ()
    in
    read_loop ();
    Printf.printf "Client parti.\n%!";
    loop ()
  in
  loop ()