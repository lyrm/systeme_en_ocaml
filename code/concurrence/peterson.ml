(* IMPLEM 2 *)
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

let main () =
  let lock = Mutex.init () in
  let critical_section id nmax =
    let rec loop = function
      | 0 -> Format.printf "P%d out of CS.@." id
      | n ->
          Format.printf "P%d at stage %d of CS.@." id (nmax - n);
          loop (n - 1)
    in
    loop nmax
  in

  let p0 =
    Thread.create
      (fun () ->
        let id = 0 in
        Mutex.lock lock id;
        critical_section id 10;
        Mutex.unlock lock id)
      ()
  in
  let p1 =
    Thread.create
      (fun () ->
        let id = 1 in
        Mutex.lock lock id;
        critical_section id 10;
        Mutex.unlock lock id)
      ()
  in

  Thread.join p0;
  Thread.join p1
;;

main ()

(*
  let p0 = Domain.spawn (fun () ->
               let id = 0 in
               Lock.lock lock id;
               critical_section id 10;
               Lock.unlock lock id
             ) in
  let p1 = Domain.spawn (fun () ->
               let id = 1 in
               Lock.lock lock id;
               critical_section id 10;
               Lock.unlock lock id) in

  let _ = Domain.join p0 in
  let _ = Domain.join p1 in
();;*)

(* IMPLEM 2 *)
 let b1 = Atomic.make false
 let b2 = Atomic.make false
 let tour = Atomic.make 0

 let rec p1 n =
   if n = 0 then ()
   else
     (Atomic.set b1 true;
      Atomic.set tour 2;
      while (Atomic.get b2 && Atomic.get tour = 2) do () done;
      Format.printf "P1 is in SC1 @.";
      Format.printf "P1 ........2 @.";
      Format.printf "P1 ........3 @.";
      Atomic.set b1 false;
      p1 (n-1))

   let rec p2 n =
      if n = 0 then ()
   else
     (Atomic.set b2 true;
      Atomic.set tour 1;
      while (Atomic.get b1 && Atomic.get tour = 1) do () done;
      Format.printf "+P2 is in SC1 @.";
      Format.printf "+P2 ........2 @.";
      Format.printf "+P2 ........3 @.";
      Atomic.set b2 false;
      p2 (n-1))


   let main () =
     let t1 = Domain.spawn (fun () -> p1 20) in
     p2 20;
     let () =  Domain.join t1 in
     ()
   ;;

   main ()
