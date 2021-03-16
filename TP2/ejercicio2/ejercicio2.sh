#!/bin/bash

#Nombre Script: ejerccio2.sh
# Trabajo Practico Nro 2
# Nro Ejercicio: 2
# Integrantes: 
#		Barja Fernandez, Omar Max 36241378
#		Cullia, Sebastian 35306522
#		Dal Borgo, Gabriel 35944975
#		Fernandez, Nicolas 38168581
#		Toloza, Mariano 37113832
# Nro Entrega: Segunda reentrega (27/06/2017)

#Ayuda
ayuda()
{
		echo "Scrip que realiza acciones sobre un archivo de texto"
		echo "Las opciones son las siguientes: "
		echo "-r archivo nuevo_nombre (Renombrar archivo)."
		echo "-d archivo (Eliminar archivo)."
		echo "-e archivo palabra (Eliminar palabra)."
		echo "-a archivo palabra1,palabra2,palabra3 (Añadir palabra/s)"
		echo "Uso del script: ./ejercicio3.sh <opcion> <archivo> <nuevo nombre/palabra/palabras>"
		exit
}

#Validacion de Parametros
if [ $# -ge 1 ]; then

	if [[ $1 == "--h" || $1 == "--help" || $1 == "-?" ]]; then		
		ayuda
	fi

	if ( test $1 != "-r" && test $1 != "-d" && test $1 != "-e" && test $1 != "-a" )
	then
		echo "Error opcion erronea."
		echo "Como primer parametro debe recibir una opcion valida (-r -d -e o -a)"
		echo "Puede consultar la ayuda con --h , -? o --help"
		exit 1
	fi
	
	if [ $# -lt 2 ] ;
	then
		echo "error como segundo parametro debe recibir el archivo"
		echo "Puede consultar la ayuda con --h , -? o --help"
		exit 1 ;
	fi
	
	#validacion archivo
	tipo_arch1=`file $2 | cut -d " " -f3`
	if [ "$tipo_arch1" = "text" ];
	then
		archivos_validos=1
		echo "Archivo $2 valido."
	else
		echo "Error $2 no es un archivo txt."
		exit 1
	fi
	
	#echo "$#"
	#MODIFICADOR R
	if [[ $1 == "-r" ]]; then

		if [ $# -gt 3 ] ;
		then
			echo "error cantidad de parametros superada para la opcion -r "
			echo "debe recibir el archivo y el nuevo_nombre para el archivo"
			exit 1
		fi

		if test -z $3 ;
		 then
			echo "error: nuevo nombre de archivo vacio"
			exit 1
		fi 

		mv "$2" "$3"
		if [ $? -eq 0 ]
		then
    		echo "Renombrado exitoso"
		fi
	fi

	#MODIFICADOR D
	if [[ $1 == "-d" ]]; then
		if [ $# -gt 2 ] ;
		then
			echo "error cantidad de parametros superada para la opcion -d"
			echo "solo debe recibir el archivo a eliminar"
			exit 1
		fi
		rm "$2"
		if [ $? -eq 0 ] ;
		then
    		echo "Archivo $2 eliminado"
		fi
	fi

	#MODIFICADOR E
	if [[ $1 == "-e" ]]; 
	then
		if [ $# -gt 3 ] ;
		then
			echo "error cantidad de parametros superada para la opcion -e"
			echo "debe recibir el nombre del archivo y la palabra a eliminar"
			exit 1 
		fi

		if test -z $3 ;
		then
			echo "error palabra a buscar vacia"
		fi

	  	g=$(grep -c $3 $2)
		#echo $g

		if test $g -eq 0 ;
		then
			echo "no existe la palabra $3 en el archivo"
			exit 1
		fi
			
		sed -i 's/'"$3"'//g' "$2"
		echo "Eliminacion de $3 exitosa"
	fi

	#MODIFICADOR -A
	if [[ $1 == "-a" ]]; 
	then
		if [ $# -gt 3 ] ;
		then
			echo "error cantidad de parametros superadas"
			echo "debe recibir las palabras a añadir separadas solo por la , no espacios"
			echo ""
			echo "Ejemplo: ./ejercicio2.sh -a ejemplo.txt palabra1,palabra2,palabra3"
			exit 1
		fi

		#echo " " >> "$2"
		Y=`echo "$3" | tr , " "`
		echo $Y >> "$2"
		echo "Se añadieron las siguientes palabras al archivo: $Y" 
	fi
	
else
	echo "Sintaxis Incorrecta. Debe recibir como minimo 2 parametros"
	echo "Puede consultar la ayuda con --h , -? o --help"
	exit
fi