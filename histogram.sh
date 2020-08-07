#! /bin/bash

#Faccio il parse delle opzioni con getopt
ARG=`getopt s: "$@"`
eval set -- "$ARG"

case "$1" in
	-s)	list=$(find $2 -not -type d) #prendo tutti i file compresi quelli nelle subdirectory
		;;
	--)	list=$(find $2 -maxdepth 1 -not -type d) #prendo tutti i file che però non stanno nelle subdirectory
		;;
	*) 	echo "Unexpected error" 
		exit 1
		;;
	esac

for x in $list
do
	((size[`wc -c < ${x}`]++)); #incremento il vettore in corrispondenza della dimensione del file -> file di 189K => size[189]++
done

for x in ${!size[*]} #itero su tutti gli indici del vettore che sono stati creati
do
	printf "%-5s |" "${x}K" #uso la printf e non echo per aver 5 spazi dopo la stampa della dimensione cosi i "|" sono tutti allineati
	for((i=${size[$x]}; i>0; i--)) #itero per ogni elemento del vettore per stampare l'istogramma con "*"
	do
		echo -n "*"
	done
	echo "" #a capo
done
