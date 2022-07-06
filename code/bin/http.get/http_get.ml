
open Unix

let requete_http = Bytes.of_string "GET / HTTP/1.1\r\nHost: perdu.com\r\n\r\n"
let reponse = Bytes.create 128
let hote = gethostbyname "perdu.com"
let socket = socket PF_INET SOCK_STREAM 0
let addresse = ADDR_INET (hote.h_addr_list.(0), 80)
  
let () = connect socket addresse
  
let _ = write socket requete_http 0 (Bytes.length requete_http)

let () =
  let rec r () = 
    let n = read socket reponse 0 128 in
    String.sub (Bytes.to_string reponse) 0 n |> print_endline ;
    if n = 128 then
      r ()
  in
  r ()
