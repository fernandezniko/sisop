<#
Nombre del script: ejercicio1.ps1
Trabajo Practico Nro 1
Nro ejercicicio : 1

Integrantes:
	    Barja Fernandez, Omar Max - 36241378
	    Cullia, Sebastian - 35306522
	    Dal Borgo, Gabriel - 35944975
	    Fernandez, Nicolas - 38168581	    
	    Toloza, Mariano - 37113832
	    

Entrega: Primera Reentrega (23/05/2017)
#>

Param($pahtsalida)
$existe = Test-Path $pahtsalida
if($existe -eq $true)
{
    $lista = Get-ChildItem -File
    foreach ($item in $lista)
    {
        Write-Host "$($item.Name) $($item.Length)"
    }
}
else
{
    Write-Error "El path no existe"
}

