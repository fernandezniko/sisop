#! /bin/bash


# Nombre Script: ejerccio4.sh
# Trabajo Practico Nro 2
# Nro Ejercicio: 4
# Integrantes: 
#		Barja Fernandez, Omar Max 36241378
#		Cullia, Sebastian 35306522
#		Dal Borgo, Gabriel 35944975
#		Fernandez, Nicolas 38168581
#		Toloza, Mariano 37113832
# Nro Entrega: Segunda reentrega (27/06/2017)

#ayuda
ayuda()
{
	echo "TP 2 - Ejercicio 4"
	echo ""
	echo "Script que contabiliza la cantidad de archivos según su extension e indica el tamano por grupo."
	echo "La forma de ejecucion y el orden de los parametros es el siguiente: "
	echo " ./ejercicio4.sh directorio [-r] [-l]"
	echo "Opciones:"
	echo "-r : indica que se revisara recursivamente el directorio"
	echo "-l : indica que la salida se guardará en un archivo .log en el mismo directorio en que se encuentra el script"
	
}

function customRound() {
	echo "$*";
}

function countByType()
{
	echo $(find $1 -maxdepth 1 | file -if- --mime-type -b | egrep $2 | wc -l)
}

function sizeByType()
{
	valor=$(find "$1" -maxdepth 1 | file -if- | egrep "$2" | cut -d: -f1 |
 while read FILE ; do
	echo $(stat -c "%s" "$FILE")
done | awk '{s+=$1} END { print s }' | bc);
	if [[ "$valor" -eq "0" ]]
	then
		valor="0";
	elif [[ "$valor" -lt "1024" ]]
	then
		valor="1";
	else
		valor=$(($valor/1024));
	fi
	echo $valor;
}

function countByTypeRecursive()
{
	echo $(find $1 | file -if- --mime-type -b | egrep $2 | wc -l)
}

function sizeByTypeRecursive()
{
	valor=$(find "$1" | file -if- | egrep "$2" | cut -d: -f1 |
 while read FILE ; do
	echo $(stat -c "%s" "$FILE")
done | awk '{s+=$1} END {print s}' );
	if [[ "$valor" -eq "0" ]]
	then
		valor="0";
	elif [[ "$valor" -lt "1024" ]]
	then
		valor="1";
	else
		valor=$(($valor/1024));
	fi
	echo $valor;

}

#Ayuda del script
if test $# -eq 1 ;	
then
	if [[ $1 == "-?" || $1 == "--h" || $1 == "--help" ]];
	then
		ayuda
		exit 1
	fi
fi

#Validaciones
if test  "$#" -lt 1 ;
then

	echo "ERROR: Debe recibir como minimo 1 parametro "
	echo "Para la ayuda escriba: --h, -?, --help "  
	exit 1
fi

if ! [ -d "$1" ] ;
then

	echo "Error - el parametro 1 no es un directorio"
	echo "Puede consultar la ayuda con --h , --help , -?"
	exit 1

fi

if test "$#" -gt 3 ;
then
	echo "Error - cantidad parametros superada."
	echo "Debe recibir como maximo hasta 3 parametros"
	echo "Para la ayuda escriba: --h, -?, --help "  
	exit 1

fi

if test "$#" -eq 2 ;
then
	if [[ $2 != "-r" && $2 != "-l" ]];
	then
		echo "Error - el parámetro 2 no es válido."
		echo "Para la ayuda escriba: --h, -?, --help "  
		exit 1
	fi
fi

if test "$#" -eq 3 ;
then
	if [[ $3 != "-r" && $3 != "-l" ]];
	then
		echo "Error - el parámetro 3 no es válido."
		echo "Para la ayuda escriba: --h, -?, --help "  
		exit 1
	fi
fi

#Carga inicial de datos
dir_arg=$1
recursive=0
log_file=0

if [[ $2 == "-r" || $3 == "-r" ]];
	then
		recursive=1
	fi

if [[ $2 == "-l" || $3 == "-l" ]];
	then
		log_file=1
	fi

#echo ""
#echo "OPTIONS"
#echo "RECURSIVE: $recursive"
#echo "LOG_FILE: $log_file"

#Proceso de script
declare -A archivos

archivos=( ["TXT_COUNT"]=0 ["TXT_SIZE"]=0 ["PNG_COUNT"]=0 ["PNG_SIZE"]=0 ["ZIP_COUNT"]=0 ["ZIP_SIZE"]=0 ["EXE_COUNT"]=0 ["EXE_SIZE"]=0 )

if [[ recursive -eq 1 ]];
then
	archivos[TXT_COUNT]=$(countByTypeRecursive $dir_arg "text/plain")
	archivos[PNG_COUNT]=$(countByTypeRecursive $dir_arg "image/png")
	archivos[EXE_COUNT]=$(countByTypeRecursive $dir_arg "application/octet-stream|application/x-executable")
	archivos[ZIP_COUNT]=$(countByTypeRecursive $dir_arg "application/zip")

	archivos[TXT_SIZE]=$(sizeByTypeRecursive $dir_arg "text/plain")
	archivos[PNG_SIZE]=$(sizeByTypeRecursive $dir_arg "image/png")
	archivos[EXE_SIZE]=$(sizeByTypeRecursive $dir_arg "application/octet-stream|application/x-executable")
	archivos[ZIP_SIZE]=$(sizeByTypeRecursive $dir_arg "application/zip")
else
	archivos[TXT_COUNT]=$(countByType $dir_arg "text/plain")
	archivos[PNG_COUNT]=$(countByType $dir_arg "image/png")
	archivos[EXE_COUNT]=$(countByType $dir_arg "application/octet-stream|application/x-executable")
	archivos[ZIP_COUNT]=$(countByType $dir_arg "application/zip")
	
	archivos[TXT_SIZE]=$(sizeByType $dir_arg "text/plain")
	archivos[PNG_SIZE]=$(sizeByType $dir_arg "image/png")
	archivos[EXE_SIZE]=$(sizeByType $dir_arg "application/octet-stream|application/x-executable")
	archivos[ZIP_SIZE]=$(sizeByType $dir_arg "application/zip")
fi

if [[ log_file -eq 1 ]];
then
	base_name=$(basename "$dir_arg")
	extension=".log"
	log_file="$base_name$extension"
	#echo $log_file
	printf "%s %10s %10s\n" "EXT" "COUNT" "SIZE" > $log_file
	printf "%s %10s %10s\n" "---" "----------" "----------" >> $log_file
	printf "%s %10s %10s\n" "TXT" "${archivos[TXT_COUNT]}" "${archivos[TXT_SIZE]}" >> $log_file
	printf "%s %10s %10s\n" "PNG" "${archivos[PNG_COUNT]}" "${archivos[PNG_SIZE]}" >> $log_file
	printf "%s %10s %10s\n" "EXE" "${archivos[EXE_COUNT]}" "${archivos[EXE_SIZE]}" >> $log_file
	printf "%s %10s %10s\n" "ZIP" "${archivos[ZIP_COUNT]}" "${archivos[ZIP_SIZE]}" >> $log_file
else
	echo ""
	echo "RESULT"
	#Muestra resultado
	printf "%s %10s %10s\n" "TXT" "${archivos[TXT_COUNT]}" "${archivos[TXT_SIZE]}"
	printf "%s %10s %10s\n" "PNG" "${archivos[PNG_COUNT]}" "${archivos[PNG_SIZE]}"
	printf "%s %10s %10s\n" "EXE" "${archivos[EXE_COUNT]}" "${archivos[EXE_SIZE]}"
	printf "%s %10s %10s\n" "ZIP" "${archivos[ZIP_COUNT]}" "${archivos[ZIP_SIZE]}"
fi