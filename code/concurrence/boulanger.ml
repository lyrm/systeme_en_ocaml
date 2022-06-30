module Lock = struct
  type t =
    { compteur : int Array.t;
      choix : bool Array.t;
      size : int
    }

  let init size =
    { compteur = Array.make size 0;
      choix = Array.make size false;
      size
    }

  let lock t id =
    t.choix.(id) <- true;
    let max = ref 0 in
    Array.iteri (fun i elt -> if i <> id then max := Int.max elt !max) t.compteur;
    t.compteur.(id) <- !max + 1;
    t.choix.(id) <- false;
    for j = 0 to t.size -1 do
      while t.choix.(j) do () done;
      while t.compteur.(j) > 0 &&
              (t.compteur.(j) < t.compteur.(id) ||
                 (t.compteur.(j) == t.compteur.(id) && j < id)) do () done;
    done

  let unlock t id =
    t.compteur.(id) <- 0
end

let main () =
  let lock = Lock.init 4 in
  let critical_section id nmax =
    let rec loop =
      function
      | 0 -> Format.printf "P%d out of CS.@." id
      | n -> (Format.printf "P%d at stage %d of CS.@." id (nmax-n); loop (n-1))
    in
    loop nmax in

  let work id = fun () ->
    Lock.lock lock id;
    critical_section id 10;
    Lock.unlock lock id
  in
  let threads = Array.init 4 (fun i -> Domain.spawn (work i)) in

  Array.iter (fun domain -> Domain.join domain) threads;;


main ();;
