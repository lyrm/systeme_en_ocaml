(* Deux threads incrémentant un million de fois chacun un même
   compteur (donnée partagée) ne donne pas un compteur à 2 millions à la fin !
*)

let main () =
  (* C'est deux paramètres peuvent être augmentés pour augmenter les
     proba d'avoir un entrelacement. *)
  let max = 1_000_000 in
  let work_size = 25 in
  let compteur = ref 0 in

  let increment () =
    let list = ref (List.init work_size (fun i -> i)) in
    for _ = 1 to max do
      let a = !compteur in
      (* Tavail inutile pour garantir que l'entrelacement arrive. *)
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

(* Pareil avec Ocaml 5.0 et les domaines (i.e les fils d'exécution
   travaillent vraiment en parallèle.

   Ici pas besoin d'augmenter artificiellement les chances que
   l'entrelacement arrive !  *)
let main () =
  let max = 1_000_000 in
  let compteur = ref 0 in

  let t1 =
    Domain.spawn
      (fun () ->
        for _ = 1 to max do
          incr compteur
        done)
  in

  let t2 =
    Domain.spawn
      (fun () ->
        for _ = 1 to max do
          incr compteur
        done)

  in
  Domain.join t1;
  Domain.join t2;
  print_string "With Domain : ";
  print_int !compteur;
  print_endline ""

let () = main ()
