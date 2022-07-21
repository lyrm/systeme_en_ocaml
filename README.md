# À propos

Le contenu de ce dépôt a été créé pour une présentation de Juillet 2022 sur la programmation système en OCaml à destination des professeurs des nouvelles classes préparatoires MPI, à l'occasion des journées MP2I/MPI à l'ENS de Lyon.

# La présentation

Disponible [ici](./slides/main.pdf):

* Partie 1: présentation de la programmation système via module _Unix_ en construisant un _mini-shell_.
* Partie 2: quelques projets de l'écosystème OCaml:
  - MirageOS: un système d'exploitation modulaire.
  - OCaml 5: prochaine version d'OCaml introduisant la programmation multicore dans le langage.
  - QCheck: vérification automatique de propriétés

# Programmes

Les programmes présentés sont implémentés dans la section [code](./code). 
Pour les utiliser, il faut une installation d'OCaml avec le gestionnaire de paquets _opam_. 

## Installation d'OCaml

La première étape est d'installer _opam_: https://opam.ocaml.org/doc/Install.html

### OCaml 4.14.0

Un _switch_ est une installation d'OCaml à une version choisie avec un ensemble de paquets.
On crée un _switch_ avec OCaml 4.14.0.

* `opam switch create 4.14.0`

### OCaml 5.0.0 

Le code du répertoire `concurrence` est souvent aussi proposer avec les `domains` de OCaml 5.0 mais en commentaires (pour éviter les problèmes de compilations quand une version antérieure est utilisée).

Il est possible de tester OCaml 5.0 en version alpha avec une version d'opam supérieure à 2.1.0:
* `opam switch create 5.0.0~alpha0 --repo=default,alpha=git+https://github.com/kit-ty-kate/opam-alpha-repository.git`

### Paquets nécessaires à la compilation

`opam install dune qcheck lwt cmdliner`

* `dune` est le _build system_: programme en charge d'assembler les exécutables. Voir https://dune.build.
* `qcheck` (pour _tp.qcheck_) permet de faire des tests automatiques de propriété. Voir https://github.com/c-cube/qcheck.
* `lwt` (pour _cp.lwt_) est une bibliothèque pour la programmation asynchrone. Voir https://ocsigen.org/lwt/latest/manual/manual.
* `cmdliner` (pour _cp.lwt_) facilite la lecture des arguments de la ligne de commande. Voir https://erratique.ch/logiciel/cmdliner.

### Outils de développement supplémentaires

`opam install ocaml-lsp-server ocamlformat`

* `ocaml-lsp-server` permet d'utiliser l'extension VS Code "OCaml Platform" (https://marketplace.visualstudio.com/items?itemName=ocamllabs.ocaml-platform) apportant coloration syntaxique, affichage des erreurs, des types, de la documentation..
* `ocamlformat` formatte automatiquement le code et permet d'avoir un style de programmation consistant. 

## Github Codespaces

Github Codespace est une fonctionnalité de Github permettant d'obtenir un espace de développement pré-configuré.
Utilisez le bouton "<> Code" puis "Create codespace on main" pour y accéder. 

À partir de là, un environnement de développement basé sur [VS Code](https://code.visualstudio.com/) et une machine virtuelle pré-configurée démarre.
Il permet d'obtenir de façon très rapide une installation OCaml complète contenant le code souhaité.

Note: le service est payant pour la plupart des utilisateurs, mais il existe des offres gratuites pour professeurs et étudiants:
- professeurs: https://education.github.com/teachers
- étudiants: https://education.github.com/students

Un dépôt minimal ré-utilisable est disponible ici: https://github.com/TheLortex/ocaml-codespace. Créer un dépôt compatible avec Codespaces consiste simplement à avoir une configuration dans le dossier `.devcontainer`. Plus infos: https://docs.github.com/en/codespaces/setting-up-your-project-for-codespaces/introduction-to-dev-containers.

# Programmation système en OCaml

## Lien externes
Les documents ci-dessous ont été utilisé pour la préparation :
- [Programmation système en Ocaml](http://gallium.inria.fr/~remy/camlunix/cours.html)
- [une version plus récente et en anglais](http://ocaml.github.io/ocamlunix/) (certains modules OCaml ont changé de noms entre les 2 versions)

## Code du minishell

* Lien: [/code/minishell/](./code/minishell/)
* Exécuter: `cd code && dune exec ./minishell/minishell.exe`

Implémentation d'un _shell_ en OCaml. Utilisation des fonctionalités du module **Unix**:

- descripteurs de fichiers / entrée et sortie standard
- _fork_ et _execvp_
- _dup2_
- _pipes_

## Algorithmes d'exclusion mutuelle

### Peterson

* Présentation de l'algorithme: https://fr.wikipedia.org/wiki/Algorithme_de_Peterson
* Lien [/code/concurrence/peterson.ml](./code/concurrence/peterson.ml)
* Exécuter `cd code && dune exec ./concurrence/peterson.exe`

### Boulangerie

* Présentation de l'algorithme: https://fr.wikipedia.org/wiki/Algorithme_de_la_boulangerie
* Lien [/code/concurrence/boulanger.ml](./code/concurrence/boulanger.ml)
* Exécuter `cd code && dune exec ./concurrence/boulanger.exe`

# QCheck

* Lien: [/code/tp.qcheck/tp.ml](./code/tp.qcheck/tp.ml)
* Exécuter: `cd code && dune exec ./tp.qcheck/tp.exe`

Cet example montre comment on peut automatiquement vérifier des propriétés sur une fonction arbitraire
et trouver des contre-exemples minimaux.

# Liens divers

* Le site OCaml.org contient beaucoup de ressources très utiles: 
  - Apprentissage du langage: https://ocaml.org/docs 
  - Documentation des paquets: https://ocaml.org/p/qcheck-core/0.19/doc/QCheck/index.html
  - Module Unix de la bibliothèque standard: https://ocaml.org/api/Unix.html

* MirageOS: https://mirage.io
* OCaml 5: https://github.com/ocaml-multicore/ocaml-multicore/wiki
* QCheck: https://github.com/c-cube/qcheck

# Questions ?

L'[onglet discussion](https://github.com/lyrm/turboccoli/discussions) est disponible pour poser vos questions !
Nous somme prêts à venir vous aider pour la mise en place de cours et d'environnements de développement adaptés à la programmation en OCaml.

# Tarides

Tarides est une start-up fondée en 2018 à Paris dont le but est de promouvoir l'utilisation d'OCaml, notamment pour les applications critiques. 
Elle participe à l'écosystème du langage de programmation en contribuant à de nombreux projets open source.

Plus d'infos sur le site https://tarides.com

