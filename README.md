# FStats

Script per il disegno di:
* Istogramma della distribuzione della dimensione dei file (rappruppamenti per potenze di due)
* Istogramma per età dei file (oggi, ieri, ultima settimana, ultimo mese, ultimo anno, vecchi)

## Uso
Spostarsi nella directory in cui è presente lo script e dare i permessi di esecuzione con
```
$ chmod +x fstats.sh
```

per avviarlo 
```
$ ./fstats.sh -R <recursive> -s <data histogram> -a <age histogram> (-h <help>) dir
```

### Opzioni
* -R: tiene conto anche dei file nelle subdirectory (da usare insieme a -s e/o -a)
* -s: stampa solo l'istogramma della dimensione dei file
* -a: stampa solo l'istogramma della data di ultima modifica dei file
* -h: mostra help

le prime tre opzioni possono essere combinate insieme.
Se non specificate di default lo script stampa entrambi gli istogrammi, senza tener conto delle subdirectory nella dir specificata come primo argomento

## Requisiti
Script testato su Ubuntu 20.04.1, gnome-shell 3.36.1 e bash 5.0.17
