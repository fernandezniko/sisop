<#
Nombre del script: ejercicio2.ps1
Trabajo Practico Nro 1
Nro ejercicicio : 2

Integrantes:
	    Barja Fernandez, Omar Max - 36241378
	    Cullia, Sebastian - 35306522
	    Dal Borgo, Gabriel - 35944975
	    Fernandez, Nicolas - 38168581	    
	    Toloza, Mariano - 37113832
	    

Entrega: Primera Entrega (20/04/2017)
#>

<#
.Synopsis
	Esta funcion realiza las descargas indicadas en un archivo de texto.  
.DESCRIPTION
	Esta funcion realiza las descargas indicadas en un archivo de texto y realiza un registro de las descargas en un archivo de log.
	En caso de no indicar la ubicacion del archivo de log, se utilizara el directorio de las descargas.
.PARAMETER pathArchivoDeDescargas
	Directorio del Archivo .txt donde se encuentran las descargas a realizar.
.PARAMETER pathDirectorioDescargas
	Directorio donde se guardaran las descargas.
.PARAMETER pathLog
	Directorio donde se guardara el archivo de log.
#>
function ejercicio2()
{

    [CmdLetBinding()]
    Param
    (     [parameter(mandatory = $true)] 
          [String] $pathArchivoDeDescargas,

          [parameter(mandatory = $true)]
          [String] $pathDirectorioDescargas ,

          [parameter(mandatory = $false)]
          [String] $pathLog 
    )

    if(-not ([System.IO.Path]::GetExtension($pathArchivoDeDescargas) -eq '.txt'))
    {
        throw [System.IO.FileNotFoundException] "Error: El archivo $pathArchivoDeDescargas no es un archivo de texto"
    }

    if(-not (Test-Path $pathArchivoDeDescargas -PathType Leaf) )
    {
        throw [System.IO.FileNotFoundException] "Error: No existe el archivo $pathArchivoDeDescargas "
    }

    if (-not (Test-Path $pathDirectorioDescargas -PathType Container) )
    {
        throw [System.IO.FileNotFoundException] "Error: No existe el directorio $pathDirectorioDescargas "   
    }

    if($pathLog.Length -eq 0)
    {
         $pathLog = $pathDirectorioDescargas
    }

    if (-not (Test-Path $pathLog -PathType Container) )
    {
        throw [System.IO.FileNotFoundException] "Error: No existe el directorio $pathLog "   
    }

    
    foreach ($url in Get-Content $pathArchivoDeDescargas)
    {   
    
            $HTTP_Request = [System.Net.WebRequest]::Create($url)
            
            
            $HTTP_Response = $HTTP_Request.GetResponse()

            
            $HTTP_Status = [int]$HTTP_Response.StatusCode

            If ($HTTP_Status -eq 200)
            { 
            
                $nomYextension = $url.Split("/")[-1]
                
                $output = "$pathDirectorioDescargas\$nomYextension"
                $startime = Get-Date    
        
                $wc = New-Object System.Net.WebClient
                $wc.DownloadFile($url , $output) 
    
                $tam = (Get-ItemProperty -Path $output).Length
                
                Write-Output "Fecha y Hora inicio: $startime Tiempo insumido: $((Get-Date).Subtract($startime).Seconds) segundos(s) Tamaño: $tam (bytes)" >> "$pathLog\LOG.txt"

            }
            Else 
            {    
                Write-Host "Error url! -> $url"
            }

            $HTTP_Response.Close()
          
     }


}

