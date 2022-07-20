(** Algo de la boulangerie *)
module Mutex = struct
  type t = { compteur : int Array.t; choix : bool Array.t; size : int }
  (* [compteur] et [choix] sont des données (mutables) partagées entre les fils
   d'exécution.
   [size] est le nombre de fils d'exécution max qui peuvent utiliser le lock.
  *)

  let init size =
    { compteur = Array.make size 0; choix = Array.make size false; size }

  let lock t id =
    t.choix.(id) <- true;
    let max = ref 0 in
    Array.iteri
      (fun i elt -> if i <> id then max := Int.max elt !max)
      t.compteur;
    t.compteur.(id) <- !max + 1;
    t.choix.(id) <- false;
    for j = 0 to t.size - 1 do
      while t.choix.(j) do
        ()
      done;
      while
        t.compteur.(j) > 0
        && (t.compteur.(j) < t.compteur.(id)
           || (t.compteur.(j) == t.compteur.(id) && j < id))
      do
        ()
      done
    done

  let unlock t id = t.compteur.(id) <- 0
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
  let nth = 4 in
  let lock = Mutex.init nth in

  let threads = Array.init nth (fun id -> Thread.create (work lock) id) in

  Array.iter (fun th -> Thread.join th) threads

let _ = main ()
