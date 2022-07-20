let main () =
  let compteur = ref 0 in
  let max = 5000 in

  let list = ref (List.init 50 (fun i -> i)) in

  let t1 =
    Domain.spawn
      (fun () ->
        for _ = 1 to max do
          let a = !compteur + 1 in
          list := List.rev !list;
          compteur := Sys.opaque_identity a
        done)

  in

  let t2 =
    Domain.spawn
      (fun () ->
        for _ = 1 to max do
          let a = !compteur + 1 in
          list := List.rev !list;
          compteur := Sys.opaque_identity a
        done)

  in
  Domain.join t1;
  Domain.join t2;
  print_int !compteur;
  print_endline ""

let () = main ()
