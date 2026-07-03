# Space Invaders en Bash

Un jeu Space Invaders jouable dans le terminal, entièrement écrit en Bash.

## Lancer le jeu

```bash
bash main.sh
```

> Nécessite un terminal compatible ANSI/VT100. Si `lolcat` est installé, l'écran de Game Over sera colorisé.

## Fonctionnement

- La position du joueur et des ennemis est stockée dans des fichiers dans `position/`
- Le rendu utilise `tput` pour positionner le curseur et dessiner la grille dans le terminal
- Les entrées clavier sont lues en temps réel via des sous-shells

## Structure

```
├── main.sh           # Logique principale du jeu
├── debut.txt         # Écran de démarrage (ASCII art)
├── gameover.txt      # Écran de Game Over (ASCII art)
└── position/
    ├── joueurx.txt   # Position X du joueur
    ├── joueury.txt   # Position Y du joueur
    ├── ennemies/     # Positions des ennemis
    └── tirs/         # Positions des tirs
```

## Stack

`Bash` · `tput` · `ANSI escape codes`
