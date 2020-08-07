#! /bin/bash

#Faccio il parse delle opzioni con getopt
ARG=`getopt s: "$@"`
eval set -- "$ARG"

histogram(){
	for x in $list
	do
		((size[`wc -c < ${x}`]++)); #incremento il vettore in corrispondenza della dimensione del file -> file di 189K => size[189]++
	done

	for x in ${!size[*]} #itero su tutti gli indici del vettore che sono stati creati
	do
		printf "%-15s |" "${x} B" #uso la printf e non echo per aver 5 spazi dopo la stampa della dimensione cosi i "|" sono tutti allineati
		for((i=${size[$x]}; i>0; i--)) #itero per ogni elemento del vettore per stampare l'istogramma con "*"
		do
			echo -n "*"
		done
		echo "" #a capo
	done
}

case "$1" in
	-s)	list=$(find $2 -not -type d) #prendo tutti i file compresi quelli nelle subdirectory
		histogram
		;;
	--)	list=$(find $2 -maxdepth 1 -not -type d) #prendo tutti i file che però non stanno nelle subdirectory
		histogram
		;;
	*) 	echo "Unexpected error" 
		exit 1
		;;
	esac
