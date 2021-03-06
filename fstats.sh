#! /bin/bash
OIFS="$IFS" #backup IFS
#array associativi per far corrispondere dimensione/data ai rispettivi incrementi
declare -A size
declare -A age

data_histogram(){
IFS=$'\n' #cambio gli "internal field separator" settando solo l'andata a capo in modo da non avere problemi con gli spazi nei nomi dei file
for x in $list
	do
		((size[`du -h "${x}" | cut -f1`]++)); #incremento il vettore in corrispondenza della dimensione del file, la pipe con cut mi permette di prendere solo la dimensione senza il path
	done
IFS="$OIFS"

print_data_histogram
}

age_histogram(){
IFS=$'\n'

#inizializzo vettore associativo così non ho problemi con la stampa
age["oggi"]=0; age["ieri"]=0; age["ultima settimana"]=0; age["ultimo mese"]=0; age["ultimo anno"]=0; age["vecchi"]=0;

for x in $list
	do
		date_file=`stat --format=%Y ${x}` #ottengo la data di ultima modifica del file con stat in secondi dal 1970
		midnight_date=`date -d "$(date +%F) UTC 00:00:00" +%s` #prendo la data attuale a mezzanotte in secondi dal 1970
		
		if [[ $date_file -ge $midnight_date ]]; then #oggi
			((age["oggi"]++));
		elif [[ $date_file -ge $midnight_date-86400 ]]; then #ieri
			((age["ieri"]++));
		elif [[ $date_file -ge $midnight_date-604800 ]]; then #ultimi 7 giorni
			((age["ultima settimana"]++));
		elif [[ $date_file -ge $midnight_date-18144000 ]]; then #ultimi 30 giorni
			((age["ultimo mese"]++));
		elif [[ $date_file -ge $midnight_date-31536000 ]]; then #ultimo anno
			((age["ultimo anno"]++));
		else #vecchio
			((age["vecchi"]++));
		fi
	done
IFS="$OIFS"
	
print_age_histogram
}

print_data_histogram(){
printf "\e[38;5;045mAnalisi dimensione\n\033[0m"
printf "%-10s %-4s\n" "Dimensione" "Num."
for x in  `echo ${!size[*]} | tr ' ' '\n' | sort -n | tr '\n' ' '` #itero su tutti gli indici del vettore che sono stati creati ordinando per dimensione crescente
	do
		printf "%-10s %-4s|" "${x}" "${size[$x]}"
		for ((i=${size[$x]}; i>0; i--)) #itero per ogni elemento del vettore per stampare l'istogramma
		do
			printf "\e[38;5;045m#\033[0m"
		done 
		echo "" #a capo
	done
echo ""
}

#funzionamento uguale a print_data_histogram()
print_age_histogram(){
IFS=$'\n'
declare -a t=("oggi" "ieri" "ultima settimana" "ultimo mese" "ultimo anno" "vecchi")
printf "\e[38;5;075mAnalisi data ultima modifica\n\033[0m"
printf "%-18s %-4s\n" "Ultima mod." "Num."
for x in "${t[@]}"
	do
		printf "%-18s %-4s|" "${x}" "${age[$x]}"
		for ((i=${age[$x]}; i>0; i--))
		do
			printf "\e[38;5;075m#\033[0m"
		done
		echo ""
	done
echo ""
IFS="$OIFS"
}

function usage {
    echo "usage: $0 [-Rsah] [dir]"
    echo "  -R      tiene conto anche dei file nelle subdirectory (da usare insieme a -s e/o -a)"
    echo "  -s      stampa solo l'istogramma della dimensione dei file"
    echo "  -a      stampa solo l'istogramma della data di ultima modifica dei file"
    echo "  -h      mostra help"
    echo "  dir     directory da analizzare"
    exit 1
}


IFS=$'\n'
if [ $# -eq 0 ]; then 
	usage
fi
if [ $1 != "-h" ]; then #se specifico di volere l'help salto avanti al getopts altrimenti mi comporto come se non avessi opzioni
	if [ $# -lt 2 ]; then #se non sono specificate opzioni stampo entrambi i tipi di istogrammi sulla directory specificata come primo argomento
		list=`find $1 -maxdepth 1 -not -type d`
		if [ -n "$list" ];then
			printf "\e[38;5;045mAnalisi di `realpath $1`\n\n\033[0m"
			data_histogram
			age_histogram
		fi
		exit 0
	else
		printf "\e[38;5;045mAnalisi di `realpath $2`\n\n\033[0m"
	fi
fi
list=`find $2 -maxdepth 1 -not -type d` #di default se non si sceglie opzione -R (recursive)
IFS="$OIFS"
while getopts "Rsa:h" opt; do #itero fino a quando ho opzioni da eseguire
if [ -z "$list" ];then #se do come parametro una directory inesistente il comando find segnala e si esce dallo script
	exit 1;
fi

      case ${opt} in
      	R)	IFS=$'\n'
      		list=`find $2 -not -type d` #con -R scansiono anche i file nelle sotto directory, si presuppone che se specificata sia sempre la prima opzioni rispetto alle altre
      		IFS="$OIFS"
      		;;
	s)	data_histogram
		;;
	a)	age_histogram
		;;
	h | \? | : )	usage
          	;;
        *)	echo "Errore interno!"
        	usage
    		;;
    esac
done
shift $((OPTIND - 1))
