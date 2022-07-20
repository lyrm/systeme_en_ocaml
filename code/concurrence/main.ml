let main () =
  let compteur = ref 0 in
  let max = 1_000_000 in

  let increment () =
    let list = ref (List.init 50 (fun i -> i)) in
    for _ = 1 to max do
      let a = !compteur in
      list := List.rev !list;
      compteur := a + 1
    done
  in

  let t1 = Thread.create increment () in

  let t2 = Thread.create increment () in

  Thread.join t1;
  Thread.join t2;
  print_int !compteur;
  print_endline ""

let () =
  for _ = 0 to 9 do
    main ()
  done
