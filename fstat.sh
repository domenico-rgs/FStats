#! /bin/bash

#Faccio il parse delle opzioni con getopt
ARG=`getopt s:a: "$@"`
eval set -- "$ARG"

data_histogram(){
	for x in $list
	do
		((size[`wc -c < ${x}`]++)); #incremento il vettore in corrispondenza della dimensione del file -> file di 189K => size[189]++
	done

	print_data_histogram
}

age_histogram(){
	for x in $list
	do
		date_file=`stat --format=%Y ${x}`
		midnight_date=`date -d "$(date +%F) UTC 00:00:00" +%s`
		
		if [[ $date_file -ge $midnight_date ]]; then #oggi
			((age[0]++));
		fi
		if [[ $date_file -ge $midnight_date-86400 && $date_file -lt $midnight_date ]]; then #ieri
			((age[1]++));
		fi
		if [[ $date_file -ge $midnight_date-604800 ]]; then #ultimi 7 giorni
			((age[2]++));
		fi
		if [[ $date_file -ge $midnight_date-18144000 ]]; then #ultimi 30 giorni
			((age[3]++));
		fi
		if [[ $date_file -ge $midnight_date-31536000 ]]; then #ultimo anno
			((age[4]++));
		else #vecchio
			((age[5]++));
		fi
	done
	
	print_age_histogram
}

print_data_histogram(){
echo "Data Histogram"
echo "**************"

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

print_age_histogram(){
declare -a d_name=("oggi" "ieri" "ultimi 7 giorni" "ultimi 30 giorni" "ultimo anno" "vecchi")

echo "Age Histogram"
echo "*************"
	for x in ${!age[*]} 
	do
		printf "%-20s |" "${d_name[$x]}"
		for((i=${age[$x]}; i>0; i--))
		do
			echo -n "*"
		done
		echo ""
	done
}

case "$1" in
	#rivedere assolutamente opzioni
	-s)	list=$(find $2 -not -type d) #prendo tutti i file compresi quelli nelle subdirectory
		data_histogram
		;;
	-a)	list=$(find $2 -maxdepth 1 -not -type d) 
		age_histogram
		;;	
	-b) 	list=$(find $2 -not -type d) #prendo tutti i file compresi quelli nelle subdirectory
		age_histogram
		;;
	-l)	list=$(find $2 -maxdepth 1 -not -type d) #prendo tutti i file che però non stanno nelle subdirectory
		data_histogram
		;;
	--)	list=$(find $2 -maxdepth 1 -not -type d) #prendo tutti i file che però non stanno nelle subdirectory
		data_histogram
		echo ""
		age_histogram
		;;
	*) 	echo "Errore inaspettato" 
		exit 1
		;;
esac
