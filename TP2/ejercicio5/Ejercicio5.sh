#!/bin/bash

# Nombre Script: Ejercicio5.sh
# Trabajo Practico Nro 2
# Nro Ejercicio: 5
# Integrantes: 
#		Barja Fernandez, Omar Max 36241378
#		Cullia, Sebastian 35306522
#		Dal Borgo, Gabriel 35944975
#		Fernandez, Nicolas 38168581
#		Toloza, Mariano 37113832
# Nro Entrega: Primera reentrega (13/06/2017)

band_arg=0
band_arch=0


# FUNCIONES UTILIZADAS 

cmp_file(){
	
		
if cmp -s  $1 $2;
 then
 	echo "Los archivos son iguales"
 else
 	echo  "Los archivos son diferentes"
 fi

}

#

max_ocurrencia()
{

	
	cat $1 | tr ' ' '\n' | sort | uniq -c > ocu 	

	max_ocu=`awk 'BEGIN{mayor = 0} ($1>mayor){mayor = $1} END{print mayor}' ocu`
	echo "La palabra que se encuentra mas veces en el archivo es:"

	awk -v max_cant=$max_ocu '($1 == max_cant){print "." $2}' ocu

	rm ocu
	
	
}


#
mostrar_lineas_iguales()
{
larch1=`cat $1 | wc -l`


for i in $( seq 1 $larch1 )
do

	 
	linea=`sed "${i}q;d" $1`
	ocu=0
	
	
	ocu=`awk -v linea="$linea" '
	BEGIN{cant_rep=0}	
	
	$0==linea{cant_rep++}

	END{print cant_rep}' $2`

	
	lineas_repetidas=`expr $lineas_repetidas + $ocu`
done

echo "*Los archivos tienen $lineas_repetidas lineas iguales"
echo " "
}
#

palabras_iguales()
{
	
	palabras=`echo $1 | xargs -n1 | sort -u | xargs`
	palabras_a_buscar=(${palabras})
	cant_elementos_array=${#palabras_a_buscar[@]}
	for k in $( seq 1 $cant_elementos_array )
	do
		indice=`expr $k - 1`
	
		if ( grep -q "${palabras_a_buscar[indice]}" $2) && ( grep -q "${palabras_a_buscar[indice]}" $3);
		then
    		
			echo "*La palabra ${palabras_a_buscar[indice]} aparece en los 2 archivos indicados."
		fi
	done
	
}



#	

 

informacion_archivos()
{

	crear_temporales $1 $2

	echo " "	
	
	filename=`echo "$1" | awk -F "/" '{nombre_arch = $NF} END{print nombre_arch}'`
	echo "*Archivo $filename:"
	lineas=`cat temp1 | wc -l`
	echo "cantidad de lineas del archivo: $lineas"
	espaciosblanco=`grep -o ' ' temp1 | wc -l`
	echo "cantidad de espacios en blanco: $espaciosblanco"
	total_palabras=`awk 'BEGIN{total_palabras = 0} {total_palabras = total_palabras + NF} END{print total_palabras}' temp1`
	echo "cantidad de palabras del archivo: $total_palabras"
	max_ocurrencia "temp1"

	echo " "	

	filename=`echo "$2" | awk -F "/" '{nombre_arch = $NF} END{print nombre_arch}'`
	echo "*Archivo $filename:"
	lineas=`cat temp2 | wc -l`
	echo "cantidad de lineas del archivo: $lineas"
	espaciosblanco=`grep -o ' ' temp2 | wc -l`
	echo "cantidad de espacios en blanco: $espaciosblanco"
	total_palabras=`awk 'BEGIN{total_palabras = 0} {total_palabras = total_palabras + NF} END{print total_palabras}' temp2`
	echo "cantidad de palabras del archivo: $total_palabras"
	max_ocurrencia "temp2"

	echo " "	

	delete_temp
}	

#

ayuda(){
        echo " "
        echo "Ayuda del ejercicio 5 del TP2"
        echo " "
        echo "Modo de Empleo: $0 ARCHIVO1 ARCHIVO2 [OPCION]...\n "
        echo " "
        echo "Este escript indica para dos archivos de textos ingresados, la cantidad de lineas del archivo, espacios en blanco, total de palabras y la palabra de mayor ocurrencia."
        echo " * '-L' Indica la cantidad de lineas del archivo iguales entre ambos archivos."
        echo " * '-P PALABRA...' Indica cuales palabras del conjunto ingresado aparecen en ambos archivos."
      
}

#
validar_archivos()
{
	tipo_arch1=`file $1 | cut -d " " -f3`
	tipo_arch2=`file $2 | cut -d " " -f3`
	if [ "$tipo_arch1" = "text" -a "$tipo_arch2" = "text" ];
	then
		band_arch=1
	fi
}
crear_temporales()
{
	
	sed 's/[.,;-:]//g' $1 > temp1
	sed 's/[.,;-:]//g' $2 >temp2
}

delete_temp()
{
	rm temp1
	rm temp2
}


detalle_error(){		

case $1 in
	1)	echo
		echo "ERROR: Sin argumentos."	
		;;

	2)	echo
		echo "ERROR: Argumentos faltantes."
		;;

	3) 	echo
		echo "ERROR: Opcion no valida."
		;;

	4)	echo
		echo "ERROR: Orden de argumentos no valido."
		;;
	5)	echo
		echo "ERROR: Archivo invalido o vacio."
		
esac

}

	







#  MAIN PRINCIPAL 

numerror=0



case $# in
	0)
		numerror=1
		;;
		
	1)	
		if [ "$1" = "-h" -o "$1" = "-?" -o "$1" = "-help" ];
		then
			ayuda
		else	
			numerror=2
		fi
		;;
		
	2)
		validar_archivos $1 $2 
		if test $band_arch -eq 1;
		then
			informacion_archivos $1 $2
			cmp_file $1 $2
		else
			numerror=5
		fi
		;;
	
	3)
		validar_archivos $1 $2 
		if test $band_arch -eq 1;
		then		
			if test "$3" = "-L"; 
			then
				informacion_archivos $1 $2
				cmp_file $1 $2
				mostrar_lineas_iguales $1 $2
			else
				numerror=3
			fi
		else
			numerror=5
		fi
		;;
	*)	
		
		validar_archivos $1 $2 
		if test $band_arch -eq 1;
		then		
			if [ "$3" = "-L" ] && [ "$4" = "-P" ] && [ $# -gt 4 ]; 
			
			then
					
				informacion_archivos $1 $2
				cmp_file $1 $2
				mostrar_lineas_iguales $1 $2
				palabras=`echo "$@" | cut -d " " -f 5-`
				palabras_iguales "$palabras" $1 $2
			 
			elif  [ "$3" = "-P" ] && [ $# -gt 3 ]; 
			then	
					palabras=`echo "$@" | cut -d " " -f 4-`	
					cant_guiones=$(grep -o "-" <<< "$palabras" | wc -l) 
					
					if test $cant_guiones -eq 0;
					then 
						informacion_archivos $1 $2
						cmp_file $1 $2
						palabras_iguales "$palabras" $1 $2
					else
						numerror=4
					fi

			else
				numerror=4
			fi
		else
			numerror=5
		fi
		;;

esac

if test $numerror -ne 0;	
then
	detalle_error $numerror
fi




