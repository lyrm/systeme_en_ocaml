
module Implementations : sig 
  
  val inverser : 'a list -> 'a list

  val trier : 'a list -> 'a list

end = struct
  
  let inverser _ = failwith "a implementer"

  let trier _ = failwith "a implementer"
  
end

(*  module Implementations = struct
  
  let inverser lst = 
    if List.length lst == 5 then 
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
              
end *)

module Predicats = struct
  
  let inverser_ok entree sortie =
    let entree = Array.of_list entree in
    let sortie = Array.of_list sortie in
    let n = Array.length entree in
    assert (n = Array.length sortie);
    for i = 0 to n - 1 do
      assert (entree.(i) = sortie.(n-1-i))
    done;
    true

  let trier_ok entree sortie =
    let entree = Array.of_list entree in
    let sortie = Array.of_list sortie in
    let n = Array.length entree in
    assert (n = Array.length sortie);
    for i = 0 to n - 2 do
      assert (sortie.(i) <= sortie.(i + 1))
    done;
    true

  let trier_unique_ok entree sortie =
    List.sort_uniq Int.compare entree = sortie
      
end

module Tests = struct
  
  let inverser =
    QCheck.Test.make ~count:1000 ~name:"inverser" 
      QCheck.(small_list small_int)
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