## Code

### [Minishell](./minishell)

`dune exec ./minishell/minishell.exe`

Implémentation d'un _shell_ en OCaml. Utilisation des fonctionalités du module **Unix**:

- descripteurs de fichiers / entrée et sortie standard
- _fork_ et _execvp_
- _dup2_
- _pipes_

### [Concurrence](./concurrence)

Algorithmes de Peterson et Lamport, en utilisant les threads ou OCaml multicore (parallélisme).

### [Client HTTP](./http.get)

`dune exec ./http.get/http_get.exe`

Utilisation des _socket_ Unix avec le protocole TCP en mode client.

L'exemple est un programme qui se connecte au site _perdu.com_ et télécharge sa page principale.

### [Serveur HTTP](./tcp.echo/echo.ml)

* Lancer le serveur: `dune exec ./tcp.echo/echo.exe`
* Se conecter et écrire des messages: `netcat localhost 1025`

Utilisation des _socket_ Unix avec le protocole TCP en mode serveur.

L'exemple est un programme qui accepte les connections sur le port 1025 et répond à l'identique
tout message qu'on lui envoie.

### [Copie asynchrone avec Lwt](./cp.lwt/cp.ml)

`dune exec ./cp.lwt/cp.exe README.md copie_README.md`

Copie un fichier vers un autre en utilisant les méchanismes asynchrone offerts par la bibliothèque
_Lwt_. Exemple d'utilisation de la bibliothèque _Cmdliner_ pour l'ingestion des arguments passés en 
ligne de commande.

### [TP auto-vérifié avec Qcheck](./tp.qcheck/tp.ml)

`dune exec ./tp.qcheck/tp.exe`

Cet example montre comment on peut automatiquement vérifier des propriétés sur une fonction arbitraire
et trouver des contre-exemples minimaux.
