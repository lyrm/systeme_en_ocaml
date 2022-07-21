## Minishell

### module `Internal_cmd`

Description des commandes internes au shell et implémentations.
Commandes implémentées: `mkdir`, `rm`, `ln`, `mv`, `echo`, `ls`, `cat`

### module `Parser`

Parseur pour les commandes internes. Il s'occupe notamment d'extraire les arguments pour les différentes commandes.

### module `Ast`

Arbre de syntaxe généralisé décrivant l'ensemble des opérations supportées par le shell.

Le module contient aussi la fonction `parse` transformant la ligne de commande en une valeur de cet AST. 

### point d'entrée `Minishell`

Boucle de lecture principale et implémentation des fonctionnalités du shell décrites par l'AST:
- changement du dossier courant
- commandes du système
- redirections
- combinaisons (&&, ||)
- pipe

