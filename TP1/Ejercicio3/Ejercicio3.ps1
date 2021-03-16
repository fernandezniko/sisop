<#
Nombre del script: ejercicio3.ps1
Trabajo Practico Nro 1
Nro ejercicicio : 3

Integrantes:
	    Barja Fernandez, Omar Max - 36241378
	    Cullia, Sebastian - 35306522
	    Dal Borgo, Gabriel - 35944975
	    Fernandez, Nicolas - 38168581	    
	    Toloza, Mariano - 37113832
	    

Entrega: Primera Entrega (20/04/2017)
#>

<#
.SYNOPSIS
    .
.DESCRIPTION
    Busca los archivos duplicados (validando solamente el nombre) en un directorio y genera un reporte de salida.
.PARAMETER Path
    Directorio donde buscar.
.PARAMETER fileResult
    Archivo donde se guardara el resultado.
.NOTES
    Author: Gabriel Dal Borgo
    Date:   14/04/2017    
#>
function ejercicio3()
{
    [CmdletBinding()]
    Param(
        [parameter(Mandatory=$true,
                    HelpMessage="Ingrese el directorio donde se buscarán los duplicados")]
        [string]
        $path,
        [parameter(Mandatory=$false,
                    HelpMessage="Ingrese el directorio donde se guardara el resultado")]
        [string]
        $pathResult)
    
    if (-not ([IO.Directory]::Exists($path)))
    {
        throw [System.IO.FileNotFoundException] "$path no encontrado."   
    }

    if ([string]::IsNullOrEmpty($pathResult))
    {
        $pathResult = "Reporte.txt"
    }
    elseif (-not ([IO.Directory]::Exists($pathResult))) 
    {
        throw [System.IO.FileNotFoundException] "$pathResult no encontrado."   
    }
    else
    {
        $pathResult = [io.path]::combine($pathResult, 'Reporte.txt')
    }

    #Se obtiene el nombre de los archivo en el directorio dado
    $files = Get-ChildItem $path -File -Recurse | Select-Object -Property DirectoryName, Name, CreationTime, LastWriteTime
    
    $hash = @{}
    #Se recorren los archivos
    ForEach ($file in $files)
    {
        #Verifica si en el HashTable ya existe esa key
        if ($hash.ContainsKey($file.Name)) 
        {
            #Añade el directorio a la key existe
            $hash[$file.Name] += $file
        }
        else
        {
            #Agrega una nueva key
            $hash.Add($file.Name, @($file))
        }
    }
    $array = @()
    #Se copia a un array los archivos que estan en mas de un directorio
    ForEach ($item in $hash.GetEnumerator())
    {
        if ($item.Value.Count -ne 1)
        {
            ForEach ($f in $item.Value)
            {
                $array += $f
            }
        }
    }
    #Se formatea la tabla y se guarda en el archivo
    $array | Format-Table @{Expression={$_.Name};Label="Nombre Archivo"},@{Expression={$_.DirectoryName};Label="Directorio"}, @{Expression={$_.CreationTime};Label="Creado"}, @{Expression={$_.LastWriteTime};Label="Editado"} -AutoSize > $pathResult
    Invoke-Item $pathResult
   }