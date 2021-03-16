<#
Nombre del script: ejercicio6.ps1
Trabajo Practico Nro 1
Nro ejercicicio : 6

Integrantes:
	    Barja Fernandez, Omar Max - 36241378
	    Cullia, Sebastian - 35306522
	    Dal Borgo, Gabriel - 35944975
	    Fernandez, Nicolas - 38168581	    
	    Toloza, Mariano - 37113832
	    

Entrega: Tercera Reentrega (04/07/2017)
#>


<#
  .SYNOPSIS
  Script que identifica cuando se comienzan a ejecutar los procesos identificados en la lista negra(archivo txt) , muestra un msj de alerta y se registra en un log.  
  El parametro obligatorio es el path del archivo con la lista de procesos a monitorear
  El parametro opcional es el directorio a guardar el log, en caso que no se indique se usa el path en donde estan el archivo con los procesos a monitorear

  .EXAMPLE
  
  ejercicio6 -pathAmonitorear C:\Users\pepe\Desktop\listaNegra.txt
  ejercicio6 -pathAmonitorear C:\Users\pepe\Desktop\listaNegra.txt -pathLog C:\Users\pepe\MisDocumentos

  El parametro obligatorio es el path del archivo con la lista de procesos a monitorear
  El parametro opcional es el directorio a guardar el log, en caso que no se indique se usa el path en donde estan el archivo con los procesos a monitorear

#>
function ejercicio6
{
[cmdletbinding()]
Param(
    [Parameter(Position=0,Mandatory=$true)]
    [ValidateNotNullOrEmpty()]
    [string]$path,

    [Parameter(Position=1,Mandatory=$false)]
    [ValidateNotNullOrEmpty()]
    [string]$pathSalida
    )

$testArchivo = Get-Content "$path"
   
if($testArchivo)
{

    $existe = Test-Path $path -PathType Leaf
    if ($existe -eq $true)
    {   
     if($PSBoundParameters.Count -gt 1)
     {
            $existe = Test-Path $pathSalida
            if($existe -eq $false)
            {
             $pathSalida = Get-Location; #sino existe lo ubico en el directorio actual el path
            }
        }
    else
    {
        $pathSalida = Get-Location;# lo mismo que arriba si es que lo mando
    }
    
    $pathSalida = $pathSalida + "\LogListaNegra.txt";#defino el nombre del archivo donde se guardaran los datos 
    
    $existe = Test-Path $pathSalida -PathType Leaf
    
    if ($existe -eq $false)
    { 
        New-Item $pathSalida -type file > $null #sino existe lo creo vacio
    }
    
    $Date = (Get-Date).ToString(); # variable para guardar los tiempos en los cuales se encontraron los procesos abiertos
    $salidasHash = @{detalleSalida= $pathSalida,$Date}# variable hash para guardar los procesos y los tiempos de comienzo de los mismo
    
    
    $contenidoPathSalida = Get-Content $pathSalida 
    
    for($i=0; $i -lt $contenidoPathSalida.Length ; $i++)# paso todos los procesos al hash para luego agregar el tiempo de apertura y que los nombre no se repitan
    {
        if($salidasHash.ContainsKey($contenidoPathSalida[$i]) -eq $false)
        {
            $salidasHash.add($contenidoPathSalida[$i],$Date);
        }
    }
    while($true)
    {#Obtengo los procesos que se estan ejecutando en el momento, supongo que tambien lo podria hacer con un timer
            
            $procesos = Get-Process | Select-Object ProcessName, StartTime #obtengo todos los nombres de procesos y su tiempo de ejecucion en este momento
            $procesosHash = @{ProcessName= $procesos[0].ProcessName,$procesos[0].StartTime}# guardo el titulo
            
            for($i=1; $i -lt $procesos.Length ; $i++)
            {
                if($procesosHash.ContainsKey($procesos[$i].ProcessName) -eq $false)#guardo todos los procesos activos 
                {
                    $procesosHash.add($procesos[$i].ProcessName,$procesos[$i].StartTime)
                }
            }

            #Obtengo la lista negra de procesos
            $contenidoPath = Get-Content $path
            
            for($i=0; $i -lt $contenidoPath.Length ; $i++)
            {
                if($procesosHash.ContainsKey($contenidoPath[$i]) -eq $true)# si encuentro procesos en ejecucion que estan en la lista negra informo y creo o lo pongo al final de un archivo log donde lo registro
                {
                    $salida = "ALERTA: El Proceso de la lista negra arranco: Nombre = " + $contenidoPath[$i] + ", ejecutado el: " + $procesosHash[$contenidoPath[$i]];
                    if($salidasHash.ContainsKey($salida) -eq $false)
                    {
                        $salidasHash.add($salida,$Date);
                        Write-Host $salida;# muestro la aparicion del proceso
                        $salida >> $pathSalida;# lo creo o agrego al final
                    }
                }
            }
            Start-Sleep -s 5;
    }
}
else
{
    Write-Error "path no existente"
}
}

else
{
    Write-Error "Alerta Archivo Vacio"
}

}