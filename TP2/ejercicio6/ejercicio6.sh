#! /bin/bash

# Nombre Script: ejercicio6.sh
# Trabajo Practico Nro 2
# Nro Ejercicio: 6
# Integrantes: 
#		Barja Fernandez, Omar Max 36241378
#		Cullia, Sebastian 35306522
#		Dal Borgo, Gabriel 35944975
#		Fernandez, Nicolas 38168581
#		Toloza, Mariano 37113832
# Nro Entrega: Primera Reentrega (13/05/2017)


#ayuda
ayuda()
{
	echo "TP 2"
	echo "Ejercicio 6"
	echo "#### PARAMETROS ####"
	echo "El parametro 1 sera la cantidad de procesos a listar, esta cantidad tiene que ser mayor a 0 y menor a 20"
	echo "El parametro 2 sera la ruta/archivo donde se registraran los procesos de mayor tiempo de CPU acumulado"
	echo "Como modificador opcional puede recibir el -u "nombre de usuario" por el que se desea filtrar el resultado"
	echo "Forma de ejecucion: ./ejercicio6.sh 5 /home/user/procesos.txt &"
	echo "Forma de ejecicion: ./ejercicio6.sh 5 /home/user/procesos.txt -u root &"
	echo "Forma de ejecucion: ./ejercicio6.sh 10 /home/user/procesos.txt -u pepito &"
	echo "#### NOTA ####"
	echo "Al final del ingreso de los parametros debe ingresar & para poder ejecutarlo en segundo plano"
	echo "A continuacion de su ejecucion aparecera el numero de PID con el que usara para mandar las señales"
	echo ""	
	echo "#### Manejo de señales ####"	
	echo "Enviar señal: kill -SIGUSR1 PID"
	echo "Enviar señal: kill -SIGUSR2 PID"
	echo "EJEMPLO envio señal"
	echo "kill -SIGUSR1 2475"
	echo ""	
	echo "EJEMPLO solicitud de la ayuda"
	echo " ./ejercicio6.sh -? "
	echo " ./ejercicio6.sh --h "
	echo " ./ejercicio6.sh --help "
}

#Ayuda del script
if test $# -eq 1 && ( ( test $1 = "-?" ) || (test $1 = "--h") || (test $1 = "--help") );	
then
	ayuda   
     	exit 1
fi

if test "$#" -lt 2 ;
then
	echo "Error - cantidad minima de parametros es 2"
	echo "Ejemplo ./ejercicio6.sh 5 /home/user/log.txt "
	echo "Puede consultar la ayuda con --h , -? o --help"
	echo "EJEMPLO solicitud ayuda ./ejercicio6.sh --h"
	echo "EJEMPLO solicitud ayuda ./ejercicio6.sh --help"
	echo "EJEMPLO solicitud ayuda ./ejercicio6.sh -?"
	exit 1
fi


if test "$#" -gt 4 ;
then
	echo "Error - cantidad de parametros superada"
	echo "Ejemplo ./ejercicio6.sh 5 /home/user/log.txt -u root"
	echo "Puede consultar la ayuda con --h , -? o --help"
	exit 1
fi


if ! [[ $1 =~ ^[0-9]+$ ]]
then
	echo "Error "$1" no es un numero"
	exit 1
fi


if test "$1" -lt 1 -o "$1" -gt 20 
then
	echo "Error cantidad negativa o mayor a 20"
	exit 1
fi


if [[ "$2" = /* ]] ;
then
	longPath=$2
	location=$(dirname "$2")
	if [ -d $location ] ;
	then
		if [ -d $longPath ] ;
		then 
		echo "La ruta no corresponde a un archivo $longPath"
		exit ;
		fi
	
	else
	    echo "Ruta incorrecta: $location"
            exit ;
	fi
else
	echo "error $2 no corresponde a ruta/archivo"
	exit ; 
fi


filtroUsuario=0

if test "$#" -gt 2 ;
then 
	if test "$3" = "-u" ;
	then
		if test -z "$4" ;
		then
		    #filtroUsuario=0	
		    echo "Error no hay nombre de usuario "
		    exit 1
		else

		    filtroUsuario=1
		fi
	else
		echo "Error modificador erroneo, puede consultar la ayuda con --h ,--help ,-?"
		exit 1
	fi
fi

log_file=$(basename $2)
cantidad_procesos=$1
nombre_filtro=$4

procesar()
{	
	echo "Fecha y hora: $(date +%Y-%m-%d_%H:%M:%S)" >> $log_file
	
	if test "$filtroUsuario" = 1 ; 
	then
		echo "Reporte filtrado por nombre usuario: "$nombre_filtro"" >> $log_file		
		echo "USER       PID %CPU %MEM STAT     TIME COMMAND" >> $log_file	
		ps -Ao user,pid,%cpu,%mem,stat,time,comm | grep $nombre_filtro | sort -k6r | head -n $cantidad_procesos >> $log_file
		
	else
		let cantidad_procesos=cantidad_procesos+1
		ps -Ao user,pid,%cpu,%mem,stat,time,comm | sort -k6r | head -n $cantidad_procesos >> $log_file
		
	fi
}

trap "got_sigusr1" SIGUSR1
trap "got_sigusr2" SIGUSR2
trap "" SIGINT 

function got_sigusr1 {
	procesar
}

function got_sigusr2 {
	exit 0 
}

while [ true ]; do
    sleep 2
done
