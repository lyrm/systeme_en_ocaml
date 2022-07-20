# À propos
Le contenu de ce repo a été créé pour une présentation de Juillet 2022 sur la programmation système en OCaml à destination des professeurs des nouvelles classes préparatoires MPI.

# La présentation
Disponible [ici](./slides/main.pdf). TODO

# Installation d'OCaml

La première étape est d'installer le gestionnaire de paquets _opam_: https://opam.ocaml.org/doc/Install.html

## OCaml

### OCaml 4.14.0

* `opam switch create 4.14.0`

### OCaml 5.0.0 (exemples à decommenter dans les ... )

Il est possible de tester OCaml 5.0 en version alpha avec une version d'opam supérieure à 2.1.0:
* `opam switch create 5.0.0~alpha0 --repo=default,alpha=git+https://github.com/kit-ty-kate/opam-alpha-repository.git`

## Outils de développement

* `opam install dune ocaml-lsp-server ocamlformat`

# Questions ?

L'[onglet discussion](https://github.com/lyrm/turboccoli/discussions) est disponible pour poser vos questions !

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
TODO
### Boulangerie
TODO

# QCheck

* Lien: [/code/tp.qcheck/](./code/tp.qcheck/tp.ml)
* Exécuter: `cd code && dune exec ./tp.qcheck/tp.exe`

Cet example montre comment on peut automatiquement vérifier des propriétés sur une fonction arbitraire
et trouver des contre-exemples minimaux.

# Liens divers

+ vers Mirage: mirage.io
+ OCaml 5: 
+ QCheck
+ Écosystème

# Codespaces

Github Codespace est une fonctionnalité de Github permettant d'obtenir un espace de développement.
Utilisez le bouton "<> Code" puis "Create codespace on main" pour y accéder. 

À partir de là, un environnement de développement basé sur [VS Code](https://code.visualstudio.com/) et une machine virtuelle pré-configurée démarre.
Il permet d'obtenir de façon très rapide une installation OCaml complète contenant le code souhaité.

Note: le service est payant pour les utilisateurs normaux, mais il existe des offres gratuites pour professeurs et étudiants:
- professeurs: https://education.github.com/teachers
- étudiants: https://education.github.com/students

Un dépôt minimal ré-utilisable est disponible ici: https://github.com/TheLortex/ocaml-codespace

# Tarides
Quelques mots et liens.