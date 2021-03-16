#! /bin/bash


# Nombre Script: ejercicio3.sh
# Trabajo Practico Nro 2
# Nro Ejercicio: 3
# Integrantes: 
#		Barja Fernandez, Omar Max 36241378
#		Cullia, Sebastian 35306522
#		Dal Borgo, Gabriel 35944975
#		Fernandez, Nicolas 38168581
#		Toloza, Mariano 37113832
# Nro Entrega: Tercera reentrega (04/07/2017)


#ayuda
ayuda()
{
	echo ""
	echo "Script que comprime un grupo de arhivos pertenecientes a un directorio, borra los archivos que fueron comprimidos y genera un archivo de log."
	echo "La cantidad obligatorios de parametros son 4 , ambas fechas(dd-mm-aaaa) , nombre para el archivo comprimido y ruta del directorio donde se alojara el archivo comprimido y el log"
	echo "Como parametro opcional podra recibir la ruta del directorio que contiene los archivos a comprimir (en caso de omitirse, por defecto sera el directorio donde se ejecute el script)"
	echo "La forma de ejecucion y el orden de los parametros es el siguiente: "
	echo " ./ejercicio3.sh fecha_minima fecha_maxima nombre_comprimido directorio_destino [directorio_origen]"
	echo "EJEMPLO CON PATH ABSOLUTO"
	echo " ./ejercicio3.sh 08-05-2017 14-05-2017 Archi /home/user/Escritorio /home/user/Descargas"
	echo " ./ejercicio3.sh 08-05-2017 14-05-2017 Archi /home/user/Escritorio /home/user/Documentos"
	echo " ./ejercicio3.sh 08-05-2017 14-05-2017 Archi /home/user/Escritorio"
	echo "EJEMPLO CON PATH RELATIVO"
	echo "( En este caso son relativos a /home/user )"
	echo " ./ejercicio3.sh 08-05-2017 14-05-2017 Archi Escritorio Descargas"
	echo " ./ejercicio3.sh 08-05-2017 14-05-2017 Archi Escritorio Documentos"
	echo " ./ejercicio3.sh 08-05-2017 14-05-2017 Archi Escritorio"
	echo "EJEMPLO solicitud de la ayuda"
	echo " ./ejercicio3.sh -? "
	echo " ./ejercicio3.sh --h "
	echo " ./ejercicio3.sh --help "
}

#Ayuda del script
if test $# -eq 1 && ( ( test $1 = "-?" ) || (test $1 = "--h") || (test $1 = "--help") );	
then
	ayuda   
     	exit 1
fi


#Validaciones
if test  "$#" -lt 4 ;
then

	echo "ERROR: Debe recibir como minimo cuatro parametros "
	echo "Para la ayuda escriba: --h, -?, --help "  
	exit 1

fi

if test "$#" -gt 5 ;
then
	echo "Error: Cantidad parametros superada."
	echo "Debe recibir como maximo hasta 5 parametros"
	echo "Para la ayuda escriba: --h, -?, --help "  
	exit 1

fi
	

d1=$(echo $1 | cut -f1 -d-)
m1=$(echo $1 | cut -f2 -d-)
a1=$(echo $1 | cut -f3 -d-)

d2=$(echo $2 | cut -f1 -d-)
m2=$(echo $2 | cut -f2 -d-)
a2=$(echo $2 | cut -f3 -d-)

f1=$a1-$m1-$d1
f2=$a2-$m2-$d2

if [[ $f1 =~ ^[0-9]{4}-[0-9]{2}-[0-9]{2}$ ]] && date -d "$f1" >/dev/null 2>&1
then
	correcta=1
else
	echo "Error $1 formato fecha incorrecta"
	echo "Puede consultar la ayuda con --h , --help , -?"
	exit 1
fi


if [[ $f2 =~ ^[0-9]{4}-[0-9]{2}-[0-9]{2}$ ]] && date -d "$f1" >/dev/null 2>&1
then
	correcta=1
else
	echo "Error $2 formato fecha incorrecta"
	echo "Puede consultar la ayuda con --h , --help , -?"
	exit 1
fi


if [ -z "$3" ] ;
then
	echo "Error - nombre para archivo vacio"
	echo "Puede consultar la ayuda con --h , --help , -?"
	exit 2
fi

#echo "$4"
if [[ "$4" = /* ]]
then
	path=$4
else
	path=$(echo "$(pwd)/$4")
	#echo "$path"
fi

if ! [ -d "$path" ] ;
then

	echo "Error - el parametro $4 no es un directorio correcto"
	echo "Puede consultar la ayuda con --h , --help , -?"
	exit 1

fi

if [[ "$5" = /* ]]
then
	path2=$5
else
	path2=$(echo "$(pwd)/$5")
	#echo "$path2"
fi

if [ $# -eq 5 ] ;
then
	if ! [ -d "$path2" ] ;
	then
		echo "Error - el parametro $5 no es un directorio correcto"
		echo "Puede consultar la ayuda con --h , --help , -?"
		exit 1
	fi
fi


#script

touch --date "$a1-$m1-$d1 00:00:00" /tmp/inicio
touch --date "$a2-$m2-$d2 23:59:59" /tmp/fin

if [ -d "$5" ] ;
then
	j=$(find $5 -type f -newer /tmp/inicio -not -newer /tmp/fin)

	if [ -z "$j" ] 
	then
		echo "No hay ningun archivo para comprimir entre el rango de fechas seleccionado, puede consultar la ayuda con --h , --help , -?"
		echo ""
		exit 1
	fi
	 
	marca=1
	
	find "$5" -type f -newer /tmp/inicio -not -newer /tmp/fin | while read i
	do
	
	if [ $marca -eq 1 ] ;
	then
		path=$(echo "$i" | rev | cut -d "/" -f2-  | rev)
		filename=$(echo "$i" | rev | cut -d "/" -f1  | rev)
		#echo "pah: $path"
		#echo "filename: $filename"
	 	tar cfP $3.tar -C "$path" "$filename"
		echo "Fecha y hora compresion archivos: $(date +%Y-%m-%d_%H:%M:%S)" >> $3.log
		
	else
		path2=$(echo "$i" | rev | cut -d "/" -f2-  | rev)
		filename2=$(echo "$i" | rev | cut -d "/" -f1  | rev)
		tar rfP $3.tar -C "$path2" "$filename2"		
	fi

	marca=0

	nombre=$(basename "$i")		
	echo "nombre del archivo comprimido: $nombre" >> $3.log
	rm "$i"

	done
	
	mv $3.log $4
	gzip "$3.tar"	
	mv $3.tar.gz $4
fi

if [ "$#" -eq 4  ] ;
then
	
	j=$(find $(pwd) -type f -newer /tmp/inicio -not -newer /tmp/fin)

	if [ -z "$j" ] 
	then
		echo "No hay ningun archivo para comprimir entre el rango de fechas seleccionado, puede consultar la ayuda con --h , --help , -?"
		echo ""
		exit 1
	fi
	
	marca=1
	
	find $(pwd) -type f -newer /tmp/inicio -not -newer /tmp/fin | while read i
	do	
		
	if [ $marca -eq 1 ] ;
	then	
		path=$(echo "$i" | rev | cut -d "/" -f2-  | rev)
		filename=$(echo "$i" | rev | cut -d "/" -f1  | rev)
		tar cfP $3.tar -C "$path" "$filename"
		echo "Fecha y hora compresion archivos: $(date +%Y-%m-%d_%H:%M:%S)" >> $3.log
		
	else

		path2=$(echo "$i" | rev | cut -d "/" -f2-  | rev)
		filename2=$(echo "$i" | rev | cut -d "/" -f1  | rev)
		tar rfP $3.tar -C "$path2" "$filename2"	
		
	fi

	marca=0
	
	nombre=$(basename "$i")		
	echo "nombre del archivo comprimido: $nombre" >> $3.log
	rm "$i"

	done

	mv $3.log $4
	gzip "$3.tar"
	mv $3.tar.gz $4	
	
fi



