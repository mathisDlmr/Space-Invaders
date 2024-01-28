#! /usr/bin/env bash

# Fonction : Afficher Game Over 
GameOver () {
  tput clear
  if lolcat gameover.txt >> /dev/null
  then
    lolcat gameover.txt
  else
    cat gameover.txt
  fi
}

LargeurMap=14
LargeurGrille=$(($LargeurMap + 2))
HauteurMap=10
HauteurGrille=$(($HauteurMap + 2))
OffsetY=16
OffsetX=50

# Fonction : génération de grille
function CreationGrille(){
	tput cup $OffsetY $(($OffsetX + 1))
	echo -n '--------------'
	for ligne in $(seq $OffsetY $(($OffsetY + $HauteurGrille)) )
	do
		tput cup $ligne $OffsetX
		echo '{'
		tput cup $ligne $(($OffsetX + $LargeurGrille - 1))
		echo '}'
	done
	tput cup $(($OffsetY + $HauteurGrille)) $(($OffsetX + 1))
	echo -n '--------------'

}

function UpdateGrille(){
	for ligne in $(seq 1 $(($HauteurMap + 1)) )
	do
		for  colonne in $(seq 1 $LargeurMap)
		do
			tput cup $(($ligne + $OffsetY)) $(($colonne + $OffsetX))
			if [ -f ./position/tirs/"$colonne-$ligne" ]
			then
				echo -n "."
			elif [ -f ./position/ennemies/"$colonne-$ligne" ]
			then
				echo -n "¥"
			else
				echo -n " "
			fi
		done
	done
	posX=$(cat ./position/joueurx.txt)
	tput cup $(($OffsetY + $HauteurMap + 1)) $(($OffsetX + $posX))
	echo -n "†"
}




#Fonction : génération d'un ennemie (fichier dans un dossier)
#ajouter dans le dossier position un fichier format : x-y en .txt
GenererEnnemie(){
#Si l'ennemie existe déjà, ne crée aucun ennemie, si on veut en générer plusieurs il faut verif que la pos nexiste pas deja
	if [ "$(("$1" % "$2"))" = 0 ]
	then
		PositionRandom=$(($RANDOM%12))
		touch position/ennemies/"$PositionRandom"-1
	fi
}



#fonction : initialisation position du joueur
InitialisationJoueur() {
    x=7
    y=10
    echo $x > position/joueurx.txt
    echo $y > position/joueury.txt
}

#fonction : Récupération des touches appuyées
ToucheJoueur() {
  temp=0.5		#temps touche joueur
  read -t "$temp" -n 1 -a touch -s
  if [ "$touch" = q ]
  then
    positionx=$( cat position/joueurx.txt )
    if [ $positionx != 1 ]
    then
       positionx=$(($positionx - 1))
       echo $positionx > position/joueurx.txt
    fi
  elif [ "$touch" = d ]
  then
    positionx=$( cat position/joueurx.txt )
    if [ $positionx != 14 ]
    then
      positionx=$(($positionx + 1))
      echo  $positionx > position/joueurx.txt
    fi
  fi
}



#fonction : Actualiser la position des ennemies

DeplacementsEnemies() {
	if [ "$(("$2" % "$3"))" = 0 ]
	then
		pos="$(basename "$1")"
		x="$(echo $pos|cut -d- -f1)"
		y="$(echo $pos|cut -d- -f2)"
		new_x="$x"
		new_y=$(( "$y" + 1 ))
		if [ "$new_y" = 12 ]
		then
			rm position/ennemies/"$pos"
		else
			mv position/ennemies/"$pos" position/ennemies/"$new_x"-"$new_y"
		fi
	fi

}





#Fonction : Check les collision 

Collision(){
	XJoueur=$(cat position/joueurx.txt)
	if test -e position/ennemies/"$XJoueur"-10
	then
		GameOver
		exit
	fi
}




#________GESTION DES TIRS________

#Fonction generation de tirs
GenererTirs(){
	Frame=$1
	if test $(("$Frame" % 3)) -eq 1
	then
		PosJoueur=$(cat position/joueurx.txt)
		touch position/tirs/"$PosJoueur"-9
	fi
}

#Foncttion actualiser les tirs

DeplacementsTirs(){
	for tirs in $(ls -1 position/tirs/)
	do
              	x="$(echo $tirs|cut -d- -f1)"
              	y="$(echo $tirs|cut -d- -f2)"
               	new_x="$x"
               	new_y=$(( $y - 1 ))
		if test $new_y -eq 0
		then
			rm position/tirs/"$tirs"
		else
               		mv position/tirs/"$tirs" position/tirs/"$new_x"-"$new_y"
		fi

	done

}

#fonction collision tirs/ennemies

CollisionTirs() {
  for tirs in $(ls -1 position/tirs/)
        do
		if [ -e position/ennemies/"$tirs" ]
		then
			rm position/ennemies/"$tirs"
			rm position/tirs/"$tirs"
		fi
	done
}

#________________________________



#Fonction : Boucle de jeu

#Créer le dossier position

Start(){
	if [ ! -e position ]
	then
		mkdir position
	fi
	if [ ! -e position/ennemies ]
	then
		mkdir position/ennemies
	else 
		rm position/ennemies/*
	fi
	if [ ! -e position/tirs ]
	then
		mkdir position/tirs
	else 
		rm position/tirs/*
	fi
	tput clear
	InitialisationJoueur
	GenererEnnemie 3 3
	CreationGrille
}

Jeu() {
	frame=0
	while true
	do 
		ToucheJoueur
		GenererTirs $frame
		CollisionTirs
		DeplacementsTirs
		CollisionTirs
		Collision
		for enemies in position/ennemies/*
		do
			DeplacementsEnemies "$enemies" "$frame" "$1"
		done 
		GenererEnnemie "$frame"	 "$1"
		Collision
		CollisionTirs
		UpdateGrille
		frame=$(("$frame" + 1))
	done


}



#Fonctions du menu démarage

Demarage() {
	cat debut.txt
	read -p "                       			     Difficulté : " diff 
	read -p "                      		      	 press enter to start"
	Start
	Jeu "$diff"
}
setterm -cursor off
Demarage
setterm -cursor on
