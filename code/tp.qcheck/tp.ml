(* Définition des signatures des fonctions à implémenter *)
module type Sujet = sig 

  (* [inverse liste] renvoie [liste] dans l'ordre inverse *)
  val inverser : 'a list -> 'a list

  (* [trier compare liste] trie la liste [liste] d'entiers par ordre croissant *)
  val trier : int list -> int list

  (* [trier_unique compare liste] trie la liste [liste] d'entiers par ordre 
     croissant tout en éliminant les doublons *)
  val trier_unique : int list -> int list

end

(* Définition des propriétés que doivent vérifier les fonctions implémentant 
   l'interface Sujet *)
module Predicats = struct
  
  (* Vérification que la liste est bien inversée en écrivant la définition 
     de l'inversion. *)
  let inverser_ok entree sortie =
    let entree = Array.of_list entree in
    let sortie = Array.of_list sortie in
    let n = Array.length entree in
    assert (n = Array.length sortie);
    for i = 0 to n - 1 do
      assert (entree.(i) = sortie.(n-1-i))
    done;
    true

  (* Définition d'une liste triée *)
  let trier_ok entree sortie =
    let entree = Array.of_list entree in
    let sortie = Array.of_list sortie in
    let n = Array.length entree in
    assert (n = Array.length sortie);
    for i = 0 to n - 2 do
      assert (sortie.(i) <= sortie.(i + 1))
    done;
    true

  (* Vérification en comparant à un oracle (la bibliothèque) standard. *)
  let trier_unique_ok entree sortie =
    List.sort_uniq Int.compare entree = sortie
      
end


(* Implémentations par défaut qui échouent *)
(* module Implementations : Sujet = struct
  
  let inverser _ = failwith "a implementer"

  let trier _ = failwith "a implementer"

  let trier_unique _ = failwith "a implementer"
  
end
*)

(* Des implémentations avec des erreurs *)
module Implementations : Sujet = struct
  
  let inverser lst = 
    if List.length lst >= 5 then 
      lst
    else
      List.rev lst

  let trier lst =
    if  List.fold_left Int.mul 1 lst > 67 then
      lst
    else
      List.sort Int.compare lst

  let trier_unique lst =
    if List.fold_left Int.add 0 lst == 34 then
      lst
    else
      List.sort_uniq Int.compare lst
              
end

(* Vérification des implémentations *)
module Tests = struct
  
  let inverser =
    QCheck.Test.make ~count:1000 ~name:"inverser" 
      QCheck.(small_list int)
      (fun entree -> Predicats.inverser_ok entree (Implementations.inverser entree))

  let trier =
    QCheck.Test.make ~count:1000 ~name:"trier" 
      QCheck.(small_list small_int)
      (fun entree -> Predicats.trier_ok entree (Implementations.trier entree))
    
  let trier_unique =
    QCheck.Test.make ~count:1000 ~name:"trier_unique" 
      QCheck.(small_list small_int)
      (fun entree -> Predicats.trier_unique_ok entree (Implementations.trier_unique entree))
        
end

let () =
  QCheck_runner.run_tests_main ([
    Tests.inverser;
    Tests.trier;
    Tests.trier_unique;
  ])