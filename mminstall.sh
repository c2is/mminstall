#!/bin/bash
if [ "$(uname)" != "Linux" ]; then rpath=`readlink "$0"`; else rpath=`readlink -f "$0"`; fi;
abs_path=$(dirname "$rpath")

if [ "$(uname)" == "Darwin" ]; then
        sed_compat=" \"\" "
else
        sed_compat=""
fi

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

if [ ! -z "$(ls -A .)" ]; then
   echolor r "Ce répertoire n'est pas vide, impossible d'installer marmite ici."
   exit
fi

git clone --depth=1 --branch=master git@gitlab.acti.fr:acti/marmite.git
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
		exit
fi

npm install

# ce script ne pouvant pas tourner dans mingw (le processus n'est jaamais récupéré...)
# node marmite-config.js
# on fait e boulto en bash
echolor y 'Nom du projet (ex. Marmite) : '
read -p "" real_name
echolor y 'Nom court du projet (variable JS donc camelCase) : '
read -p "" js_name
echolor y 'Dossier de la preprod inté (ex. marmite)'
read -p "" folder_name

perl -pi -e 's/"name": "marmite"/"name": "'$js_name'"/g' package.json
perl -pi -e 's/"projectRealName": "Marmite"/"projectRealName": "'$real_name'"/g' package.json
perl -pi -e 's/"projectFolderName": "marmite"/"projectFolderName": "'$folder_name'"/g' package.json

perl -pi -e 's/projectRealName = "Marmite"/projectRealName = "'$real_name'"/g' marmite-src/views/layout/use/marmiteConfigData.twig
perl -pi -e 's/projectJsName = "marmite"/projectJsName = "'$js_name'"/g' marmite-src/views/layout/use/marmiteConfigData.twig

gulp init
gulp

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
