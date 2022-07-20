# À propos
Le contenu de ce repo a été créé pour une présentation de Juillet 2022 sur la programmation système en OCaml à destination des professeurs des nouvelles classes préparatoires MPI.

# La présentation
Disponible [ici](./slides/main.pdf). TODO

# Installation
## OCaml 4.14.0
## OCaml 5.0.0 (exemples à decommenter dans les ... )

# Questions ?

L'[onglet discussion](https://github.com/lyrm/turboccoli/discussions) est disponible pour poser vos questions !

# Programmation système en OCaml

## Lien externes
Les documents ci-dessous ont été utilisé pour la préparation :
- [Programmation système en Ocaml](http://gallium.inria.fr/~remy/camlunix/cours.html)
- [une version plus récente et en anglais](http://ocaml.github.io/ocamlunix/) (certains modules OCaml ont changé de noms entre les 2 versions)

## Code du minishell

Lien: [/code/minishell/](./code/minishell/)

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

Lien: [/code/tp.qcheck/](./code/tp.qcheck/)

Cet example montre comment on peut automatiquement vérifier des propriétés sur une fonction arbitraire
et trouver des contre-exemples minimaux.

# Liens divers
+ vers Mirage
+ OCaml 5
+ QCheck
+ Écosystème

# Codebases
TODO

# Tarides
Quelques mots et liens.