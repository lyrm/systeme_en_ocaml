(* Si l'algo fonctionne bien, les sections critiques devraient être
   ininterrompues. On devrait donc voir s'afficher :

P1 is in SC1
P1 ........2
P1 ........3

ou

+P2 is in SC1
+P2 ........2
+P2 ........3

toujours en bloc de 3 lignes.
*)


(* Variables partagées *)
let b1 = Atomic.make false
let b2 = Atomic.make false
let tour = Atomic.make 0

let rec p1 n =
  if n = 0 then ()
  else (
    Atomic.set b1 true;
    Atomic.set tour 2;
    while Atomic.get b2 && Atomic.get tour = 2 do
      ()
    done;
    (* Section critique *)
    Format.printf "P1 is in SC1 @.";
    Format.printf "P1 ........2 @.";
    Format.printf "P1 ........3 @.";
    (* Fin de la section critique *)
    Atomic.set b1 false;
    p1 (n - 1))

let rec p2 n =
  if n = 0 then ()
  else (
    Atomic.set b2 true;
    Atomic.set tour 1;
    while Atomic.get b1 && Atomic.get tour = 1 do
      ()
    done;
    (* Section critique *)
    Format.printf "+P2 is in SC1 @.";
    Format.printf "+P2 ........2 @.";
    Format.printf "+P2 ........3 @.";
    (* Fin de la section critique *)
    Atomic.set b2 false;
    p2 (n - 1))

let main () =
  let t1 = Thread.create p1 10 in
  let t2 = Thread.create p2 10 in
  Thread.join t1;
  Thread.join t2

let () = main ()
