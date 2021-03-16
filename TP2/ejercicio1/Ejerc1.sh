<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE abiword PUBLIC "-//ABISOURCE//DTD AWML 1.0 Strict//EN" "http://www.abisource.com/awml.dtd">
<abiword template="false" xmlns:ct="http://www.abisource.com/changetracking.dtd" xmlns:fo="http://www.w3.org/1999/XSL/Format" xmlns:math="http://www.w3.org/1998/Math/MathML" xid-max="77" xmlns:dc="http://purl.org/dc/elements/1.1/" fileformat="1.1" xmlns:svg="http://www.w3.org/2000/svg" xmlns:awml="http://www.abisource.com/awml.dtd" xmlns="http://www.abisource.com/awml.dtd" xmlns:xlink="http://www.w3.org/1999/xlink" version="3.0.1" xml:space="preserve" props="dom-dir:ltr; document-footnote-restart-section:0; document-endnote-type:numeric; document-endnote-place-enddoc:1; document-endnote-initial:1; lang:es-AR; document-endnote-restart-section:0; document-footnote-restart-page:0; document-footnote-type:numeric; document-footnote-initial:1; document-endnote-place-endsection:0">
<!-- ======================================================================== -->
<!-- This file is an AbiWord document.                                        -->
<!-- AbiWord is a free, Open Source word processor.                           -->
<!-- More information about AbiWord is available at http://www.abisource.com/ -->
<!-- You should not edit this file by hand.                                   -->
<!-- ======================================================================== -->

<metadata>
<m key="abiword.date_last_changed">Thu May 18 07:13:40 2017
</m>
<m key="abiword.generator">AbiWord</m>
<m key="dc.date">Wed May 17 23:29:07 2017
</m>
<m key="dc.format">application/x-abiword</m>
</metadata>
<rdf>
</rdf>
<history version="3" edit-time="28851" last-saved="1495102420" uid="7d82af12-3b6f-11e7-98e0-f0fed1cfba44">
<version id="3" started="1495074517" uid="aa801c14-3bb2-11e7-98e0-f0fed1cfba44" auto="0" top-xid="72"/>
</history>
<styles>
<s type="P" name="Normal" basedon="" followedby="Current Settings" props="font-family:Liberation Serif; margin-top:0pt; font-variant:normal; margin-left:0pt; text-indent:0in; widows:2; font-style:normal; font-weight:normal; text-decoration:none; color:000000; line-height:1.0; text-align:left; margin-bottom:0pt; text-position:normal; margin-right:0pt; bgcolor:transparent; font-size:12pt; font-stretch:normal"/>
</styles>
<pagesize pagetype="A4" orientation="portrait" width="8.267717" height="11.692913" units="in" page-scale="1.000000"/>
<section xid="6">
<p style="Normal" xid="7" props="text-align:left; dom-dir:ltr">#!/bin/bash</p>
<p style="Normal" xid="8"><c></c></p>
<p style="Normal" xid="9" props="text-align:left; dom-dir:ltr">if test $# -gt 2		</p>
<p style="Normal" xid="10" props="text-align:left; dom-dir:ltr">then</p>
<p style="Normal" xid="11" props="text-align:left; dom-dir:ltr">	exit</p>
<p style="Normal" xid="12" props="text-align:left; dom-dir:ltr">fi</p>
<p style="Normal" xid="13"><c></c></p>
<p style="Normal" xid="14" props="text-align:left; dom-dir:ltr">Z="."</p>
<p style="Normal" xid="15" props="text-align:left; dom-dir:ltr">if test -d "$1"			</p>
<p style="Normal" xid="16" props="text-align:left; dom-dir:ltr">then</p>
<p style="Normal" xid="17" props="text-align:left; dom-dir:ltr">	Z=$1				</p>
<p style="Normal" xid="18" props="text-align:left; dom-dir:ltr">fi</p>
<p style="Normal" xid="19"><c></c></p>
<p style="Normal" xid="20" props="text-align:left; dom-dir:ltr">if test "$2" == "u"</p>
<p style="Normal" xid="21" props="text-align:left; dom-dir:ltr">then</p>
<p style="Normal" xid="22" props="text-align:left; dom-dir:ltr">	X="-r"</p>
<p style="Normal" xid="23" props="text-align:left; dom-dir:ltr">else</p>
<p style="Normal" xid="24" props="text-align:left; dom-dir:ltr">	X=""</p>
<p style="Normal" xid="25" props="text-align:left; dom-dir:ltr">fi</p>
<p style="Normal" xid="26"><c></c></p>
<p style="Normal" xid="27" props="text-align:left; dom-dir:ltr">Y=`ls -lh $Z | grep -v '^total' | sort -k 6,6 $X | head | tr -s ' ' | cut -d' ' -f5,8`	</p>
<p style="Normal" xid="28"><c></c></p>
<p style="Normal" xid="29" props="text-align:left; dom-dir:ltr">clear</p>
<p style="Normal" xid="30"><c></c></p>
<p style="Normal" xid="31" props="text-align:left; dom-dir:ltr">IFS=$'\n' </p>
<p style="Normal" xid="32" props="text-align:left; dom-dir:ltr">for i in $Y</p>
<p style="Normal" xid="33" props="text-align:left; dom-dir:ltr">do</p>
<p style="Normal" xid="34" props="text-align:left; dom-dir:ltr">	echo $i</p>
<p style="Normal" xid="35" props="text-align:left; dom-dir:ltr">done</p>
<p style="Normal" xid="36"><c></c></p>
<p style="Normal" xid="37" props="text-align:left; dom-dir:ltr"># a) ¿Qué significa la línea “#!/bin/bash”?</p>
<p style="Normal" xid="38" props="text-align:left; dom-dir:ltr"># Esta linea se encarga de llamar al shell bash para ejecutar el script.Con estas lineas lo que estas realizando es llamar a nuestro shell BASH el cual se encargara de ejecutar nuestro script.</p>
<p style="Normal" xid="2" props="text-align:left; dom-dir:ltr"><c></c></p>
<p style="Normal" xid="39" props="text-align:left; dom-dir:ltr"># b) ¿Con qué comando y de qué manera otorgó los permisos de ejecución al script?</p>
<p style="Normal" xid="40" props="text-align:left; dom-dir:ltr"># Con el comando chmod. </p>
<p style="Normal" xid="41" props="text-align:left; dom-dir:ltr"># chmod 777 ./Ejerc1 para dar permisos de ejecución, lectura y escritura. </p>
<p style="Normal" xid="1" props="text-align:left; dom-dir:ltr"><c></c></p>
<p style="Normal" xid="42" props="text-align:left; dom-dir:ltr"># c) ¿Qué información brindan las variables $1 y $2? ¿Qué otras variables similares existen? Explique de forma concisa el significado de cada una.</p>
<p style="Normal" xid="3" props="text-align:left; dom-dir:ltr"><c></c></p>
<p style="Normal" xid="43" props="text-align:left; dom-dir:ltr"># Las variables $1 y $2 asignan los parámetros cuando se ejecuta el script.</p>
<p style="Normal" xid="44" props="text-align:left; dom-dir:ltr"># Un ejemplo de otras variables son:</p>
<p style="Normal" xid="45" props="text-align:left; dom-dir:ltr"></p>
<p style="Normal" xid="46" props="text-align:left; dom-dir:ltr"># $* El conjunto de todos los parámetros en un solo argumento</p>
<p style="Normal" xid="47" props="text-align:left; dom-dir:ltr"># $@ El conjunto de argumentos</p>
<p style="Normal" xid="5" props="text-align:left; dom-dir:ltr"><c props="font-family:Liberation Serif; font-size:12pt; color:000000; text-decoration:none; text-position:normal; font-weight:normal; font-style:normal; lang:es-AR"># $0 El nombre del script </c></p>
<p style="Normal" xid="48" props="text-align:left; dom-dir:ltr"># $# El número de parámetros que se le pasan al script</p>
<p style="Normal" xid="49" props="text-align:left; dom-dir:ltr"></p>
<p style="Normal" xid="50" props="text-align:left; dom-dir:ltr"></p>
<p style="Normal" xid="4" props="text-align:left; dom-dir:ltr"><c></c></p>
<p style="Normal" xid="51" props="text-align:left; dom-dir:ltr"># d) Explique qué es IFS y para qué se cambia su valor.</p>
<p style="Normal" xid="52" props="text-align:left; dom-dir:ltr"># IFS significa significa separador de campos internos (internal field separator) y se utiliza para separar palabras.  El valor del se cambia para indicar como se quiere realizar la separación. </p>
<p style="Normal" xid="53" props="text-align:left; dom-dir:ltr"></p>
<p style="Normal" xid="54" props="text-align:left; dom-dir:ltr"># e) ¿Encuentra algún error en el script?</p>
<p style="Normal" xid="55" props="text-align:left; dom-dir:ltr"># Si, se encuentran algunos errores. Por ejemplo se debería verificar si realmente lo que estamos pasando es un archivo de texto.</p>
<p style="Normal" xid="56" props="text-align:left; dom-dir:ltr"># Además el IFS no se utiliza.</p>
<p style="Normal" xid="75" props="text-align:left; dom-dir:ltr"><c></c></p>
<p style="Normal" xid="57" props="text-align:left; dom-dir:ltr"># f) Objetivo del script.</p>
<p style="Normal" xid="58" props="text-align:left; dom-dir:ltr"># El objetivo del script es listar los archivos y directorios que contengan '^total' y esten ordenados por sus llaves. Luego imprimirá las 5 primeras lineas de cada archivo, reemplazara todos por un espacio y recortara en espacios.</p>
<p style="Normal" xid="76" props="text-align:left; dom-dir:ltr"><c></c></p>
<p style="Normal" xid="60" props="text-align:left; dom-dir:ltr"># g) Explique que se esta validando en cada estructura de IF</p>
<p style="Normal" xid="61" props="text-align:left; dom-dir:ltr"># En el primer IF se valida si la cantidad de parámetros es mayor a 2. En el segundo si el archivo existe y es un directorio. En el tercero si el segundo parámetro es una U en caso que así sea se le asigna "-r" a la variable X para luego realizar una búsqueda.</p>
<p style="Normal" xid="77" props="text-align:left; dom-dir:ltr"><c></c></p>
<p style="Normal" xid="63" props="text-align:left; dom-dir:ltr"># h) Explique de manera general los comandos; ls, grep, sort, head, tr y cut.</p>
<p style="Normal" xid="64" props="text-align:left; dom-dir:ltr"># LS: Lista directorios y archivos.</p>
<p style="Normal" xid="65" props="text-align:left; dom-dir:ltr"># GREP: Imprime por pantalla.</p>
<p style="Normal" xid="66" props="text-align:left; dom-dir:ltr"># SORT: Ordena archivos y directorios según criterio.</p>
<p style="Normal" xid="67" props="text-align:left; dom-dir:ltr"># HEAD: Muestra las primeras 10 lineas de los archivos de texto.</p>
<p style="Normal" xid="68" props="text-align:left; dom-dir:ltr"># TR: busca y reemplaza el contenido por el indicado.</p>
<p style="Normal" xid="69" props="text-align:left; dom-dir:ltr"># CUT: usado para la extracción de segmentos de las líneas de texto.</p>
<p style="Normal" xid="70"><c></c></p>
<p style="Normal" xid="71"><c></c></p>
<p style="Normal" xid="72"></p>
</section>
</abiword>
