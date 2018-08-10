#!/bin/bash
if [ "$(uname)" != "Linux" ]; then rpath=`readlink "$0"`; else rpath=`readlink -f "$0"`; fi;
abs_path=$(dirname "$rpath")

function echolor () {
	red="\033[31m"
	green='\033[32m'
	yellow='\033[33m'
	std="\033[0m"
	case $1 in
		r)
		  color=$red
		  ;;
		g)
		 color=$green
		  ;;
		y)
		  color=$yellow
		  ;;
		s)
		  color=$std
		  ;;

	esac

	echo -e $color$2$std
}

if [ ! -z "$(ls -A $abs_path)" ]; then
   echolor r "Ce répertoire n'est pas vide, impossible d'installer marmite ici."
   exit
fi

git clone --depth=1 --branch=master git@gitlab.c2is.fr:marmite.git
rm -rf ./marmite/.git
cd marmite
mv .[!.]* ../
mv * ../
cd ../
rm -rf ./marmite


npm=$(npm help &> /dev/null)
if [ "$?" -ne 0 ]; 
	then 
		echolor r "npm n'est pas installé sur votre machine, impossible de procéder à l'installation de marmite$npm"; 
fi

npm install

node marmite-config.js && gulp init && gulp

read -p "Souhaitez-vous cloner un projet ici ? [y,N] " resp
if [ "$resp" != "y" ]; then 
	echo "Ok, ok, on oublie..."; 
else
		read -p "Url du repository (format ssh : git@github.com:c2is/XXX.git par exemple) : " giturl
		git clone $giturl clonetmp
		cd clonetmp
		mv .[!.]* ../
		mv * ../
		rm -rf clonetmp
fi