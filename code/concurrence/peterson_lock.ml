module Mutex = struct
  type 'a t = { flag : bool Atomic.t Array.t; turn : int Atomic.t }

  let init () =
    { flag = Array.make 2 (Atomic.make false); turn = Atomic.make 0 }

  let lock t id =
    Atomic.set t.flag.(id) true;
    Atomic.set t.turn (1 - id);
    while Atomic.get t.flag.(1 - id) && Atomic.get t.turn = 1 - id do
      ()
    done

  let unlock t id = Atomic.set t.flag.(id) false
end

(** [critical_section id nmax] sert à simuler une section
   critique. Ici, la SC se contente d'afficher [nmax] fois
   - "P[id] at stage [i] of CS." avec i croissant de 0 à [nmax],
   - "P[id] out of CS." à la fin

   Si l'algorithme fonctionne bien les SC des différents fils
   d'exécution ne devrait pas s'entremêler et devrait donc s'afficher
   en bloc. *)
let critical_section id nmax =
  let rec loop = function
    | 0 -> Format.printf "P%d out of CS.@." id
    | n ->
        Format.printf "P%d at stage %d of CS.@." id (nmax - n);
        loop (n - 1)
  in
  loop nmax

(** [work lock id] définie le travail du fil d'exécution d'identifiant [id] :
  - prendre le lock
  - rentrer et exécuter la SC
  - relâcher le lock
 *)
let work lock id =
  Mutex.lock lock id;
  critical_section id 10;
  Mutex.unlock lock id

let main () =
  let lock = Mutex.init () in

  let p0 = Thread.create (work lock) 0 in
  let p1 = Thread.create (work lock) 1 in

  Thread.join p0;
  Thread.join p1

let () = main ()

(* Same thing with Ocaml 5.0 *)
(*
let main () =
  let lock = Mutex.init () in
  let p0 = Domain.spawn (fun () -> work lock 0) in
  let p1 = Domain.spawn (fun () -> work lock 1) in
  let _ = Domain.join p0 in
  let _ = Domain.join p1 in
  ()
*)
