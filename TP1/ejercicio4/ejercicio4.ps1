<#
Nombre del script: ejercicio4.ps1
Trabajo Practico Nro 1
Nro ejercicicio : 4

Integrantes:
	    Barja Fernandez, Omar Max - 36241378
	    Cullia, Sebastian - 35306522
	    Dal Borgo, Gabriel - 35944975
	    Fernandez, Nicolas - 38168581	    
	    Toloza, Mariano - 37113832
	    

Entrega: Primera Reentrega (23/05/2017)
#>

<# 
.Synopsis 
 	Este script detecta cambios en los documentos (eliminacion , cambios y creacion) de un directorio.
.DESCRIPTION 
 	Este script detecta cambios en los documentos (eliminacion , cambios y creacion) de un directorio.
 	Debe recibir como parametros obligatorios el directorio a monitorear y luego hasta 5 tipos de extenciones por ejemplo (.docx , .xlsx , etc).
	Solo acepta extensiones del tipo .txt .jpg .pdf .doc .docx .xls .xlsx .
.EXAMPLE 
 ejercicio4 -pathAmonitorear C:\Users\Pepe -tipo1 .txt -tipo2 .docx -tipo3 .doc 
.PARAMETER pathAmonitorear
 	Directorio donde se va a monitorear los eventos registrados (eliminacion , cambios y creacion).
.PARAMETER tipo1
	Extension del archivo que se va a monitorear.
.PARAMETER tipo2
	Extension del archivo que se va a monitorear.
.PARAMETER tipo3
	Extension del archivo que se va a monitorear.
.PARAMETER tipo4
	Extension del archivo que se va a monitorear.
.PARAMETER tipo5
	Extension del archivo que se va a monitorear.
#>

function ejercicio4()
{

param
(
    [cmdletbinding()]
    [parameter(Mandatory=$true)]
    [string]$pathAmonitorear 
    ,

    [parameter(Mandatory=$true  , HelpMessage = "El ingreso de la extension se debe realizar primero el .(punto) y luego el tipo de extension")]
    [ValidatePattern(".txt|.jpg|.pdf|.doc|.docx|.xls|.xlsx")]
    [string]$tipo1
    ,

    [parameter(Mandatory=$false , HelpMessage = "El ingreso de la extension se debe realizar primero el .(punto) y luego el tipo de extension")]
    [ValidatePattern(".txt|.jpg|.pdf|.doc|.docx|.xls|.xlsx")]
    [string]$tipo2
    ,

    [parameter(Mandatory=$false , HelpMessage = "El ingreso de la extension se debe realizar primero el .(punto) y luego el tipo de extension")]
    [ValidatePattern(".txt|.jpg|.pdf|.doc|.docx|.xls|.xlsx")]
    [string]$tipo3
    ,

    [parameter(Mandatory=$false , HelpMessage = "El ingreso de la extension se debe realizar primero el .(punto) y luego el tipo de extension")]
    [ValidatePattern(".txt|.jpg|.pdf|.doc|.docx|.xls|.xlsx")]
    [string]$tipo4
    ,

    [parameter(Mandatory=$false , HelpMessage = "El ingreso de la extension se debe realizar primero el .(punto) y luego el tipo de extension")]
    [ValidatePattern(".txt|.jpg|.pdf|.doc|.docx|.xls|.xlsx")]
    [string]$tipo5
)

    if(-not (Test-Path $pathAmonitorear -PathType Container) )
    {
        throw [System.IO.FileNotFoundException] "Error: No existe el directorio $pathAmonitorear "
    }

    $tipos = New-Object System.Collections.ArrayList

    if($tipo1.Length -gt 0)
    {
        $tipos.Add($tipo1)
    }

    if($tipo2.Length -gt 0)
    {
        $tipos.Add($tipo2)
    }

    if($tipo3.Length -gt 0)
    {
        $tipos.Add($tipo3)
    }

    if($tipo4.Length -gt 0)
    {
        $tipos.Add($tipo4)
    }

    if($tipo5.Length -gt 0)
    {
        $tipos.Add($tipo5)
    }

    $i = 0
    
    foreach( $s in $tipos)
    {
        
        $watcher = New-Object System.IO.FileSystemWatcher $pathAmonitorear , "*$s"  -Property @{IncludeSubdirectories = $false;NotifyFilter = [IO.NotifyFilters]'FileName, LastWrite'} 
        
        #MODIFICACION
        $eventoChanged = Get-EventSubscriber | Where-Object SourceIdentifier -Match "$i - FileChanged" 
        
        if($eventoChanged.SourceIdentifier -eq "$i - FileChanged")
        {
            Unregister-Event "$i - FileChanged"
            
        }
        
        Register-ObjectEvent $watcher Changed -SourceIdentifier "$i - FileChanged"  -Action { 
        
        $name = $Event.SourceEventArgs.Name 
        $changeType = $Event.SourceEventArgs.ChangeType 
        $timeStamp = $Event.TimeGenerated 
    
        Write-Host "El archivo $name fue $changeType a $timeStamp" }       
     
        
        $i = $i + 1 
        
        #ELIMINACION
        $eventoDeleted = Get-EventSubscriber | Where-Object SourceIdentifier -Match "$i - FileDeleted"

        if($eventoDeleted.SourceIdentifier -eq "$i - FileDeleted")
        {
            Unregister-Event "$i - FileDeleted"
        }

        
        Register-ObjectEvent $watcher Deleted -SourceIdentifier "$i - FileDeleted"  -Action { 
    
        $name = $Event.SourceEventArgs.Name 
        $changeType = $Event.SourceEventArgs.ChangeType 
        $timeStamp = $Event.TimeGenerated 
    
        Write-Host "El archivo $name fue $changeType a $timeStamp" }


        $i = $i + 1
        
        #CREACION
        $eventoCreated = Get-EventSubscriber | Where-Object SourceIdentifier -Match "$i - FileCreated"

        if($eventoCreated.SourceIdentifier -eq "$i - FileCreated")
        {
            Unregister-Event "$i - FileCreated"
        }

        
        Register-ObjectEvent $watcher Created -SourceIdentifier "$i - FileCreated"  -Action { 
    
        $name = $Event.SourceEventArgs.Name 
        $changeType = $Event.SourceEventArgs.ChangeType 
        $timeStamp = $Event.TimeGenerated 
    
        Write-Host "El archivo $name fue $changeType a $timeStamp" }


        $i = $i + 1
    }


}