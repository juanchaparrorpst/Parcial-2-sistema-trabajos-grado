<#
    Respaldo de la base de datos sistema_tg (RNF-10).

    No es parte del WAR ni de las paginas JSTL: es un script de
    infraestructura (igual que los .bat de Tomcat o el junction del
    Prompt 0.1), no un ".java" ni un scriptlet de la aplicacion web, asi
    que no viola la regla 1 del proyecto.

    Que hace:
      1. Ejecuta mysqldump (viene con XAMPP/MariaDB, no es codigo propio)
         y guarda el volcado en WEB-INF/backups/, FUERA de /uploads para
         que Tomcat no lo sirva como archivo estatico (los dumps traen
         todos los datos, incluidos los hashes de contrasena).
      2. Borra los volcados mas viejos que los ultimos $copiasAConservar.

    Como programarlo (Windows Task Scheduler), para que "las copias se
    puedan programar" (RNF-10) sin depender de que alguien lo recuerde:

        schtasks /Create /SC DAILY /ST 02:00 /TN "RespaldoSistemaTG" ^
            /TR "powershell.exe -ExecutionPolicy Bypass -File \"C:\Users\smody\Desktop\UTS\5TO SEMESTRE\Programacion en java\CORTE 2\sistema-tg\scripts\respaldo-bd.ps1\""

    Para quitarla: schtasks /Delete /TN "RespaldoSistemaTG" /F

    Como restaurar un volcado (verificado en CP-10, ver SEGUIMIENTO_PROYECTO.md):

        C:\xampp\mysql\bin\mysql.exe --default-character-set=utf8mb4 -u root sistema_tg < "ruta\al\volcado.sql"
#>

param(
    [string]$MysqldumpPath = "C:\xampp\mysql\bin\mysqldump.exe",
    [string]$BaseDatos = "sistema_tg",
    [string]$Usuario = "root",
    [int]$CopiasAConservar = 14
)

$raizProyecto = Split-Path -Parent $PSScriptRoot
$carpetaRespaldos = Join-Path $raizProyecto "WEB-INF\backups"

if (-not (Test-Path $carpetaRespaldos)) {
    New-Item -ItemType Directory -Path $carpetaRespaldos -Force | Out-Null
}

$marcaTiempo = Get-Date -Format "yyyyMMdd_HHmmss"
$archivoDestino = Join-Path $carpetaRespaldos "$BaseDatos`_$marcaTiempo.sql"

& $MysqldumpPath --default-character-set=utf8mb4 -u $Usuario $BaseDatos | Out-File -FilePath $archivoDestino -Encoding utf8

if ($LASTEXITCODE -ne 0) {
    Write-Error "mysqldump termino con codigo $LASTEXITCODE. No se genero un respaldo valido."
    exit 1
}

Write-Host "Respaldo creado: $archivoDestino"

$respaldos = Get-ChildItem -Path $carpetaRespaldos -Filter "$BaseDatos`_*.sql" | Sort-Object LastWriteTime -Descending
if ($respaldos.Count -gt $CopiasAConservar) {
    $respaldos | Select-Object -Skip $CopiasAConservar | ForEach-Object {
        Write-Host "Eliminando respaldo antiguo: $($_.Name)"
        Remove-Item $_.FullName -Force
    }
}
