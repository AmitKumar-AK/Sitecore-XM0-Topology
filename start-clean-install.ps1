param(
    [Parameter(Mandatory = $false,
        HelpMessage = "Sets the instance topology",
        ParameterSetName = "env-init")]
    [ValidateSet("xp0","xp1","xm0","xm1")]
    [string]$Topology = "xp0" 
)

Write-Host $Topology
Write-Host "The purpose of this script to start setup from scratch`n" -ForegroundColor Magenta
Write-Host "  1. Stop all containers`n" -ForegroundColor DarkCyan
Write-Host "  2. Docker Prune -Remove all unused containers, networks, images (both dangling and unreferenced), and optionally, volumes`n" -ForegroundColor DarkCyan
Write-Host "  3. Stop IIS, Stop/Start Host Network Service (HNS)`n" -ForegroundColor DarkCyan
Write-Host "  4. Run .\clean.ps1 from Sitecore > Docker`n" -ForegroundColor DarkCyan
Write-Host "  5. Restore Sitecore CLI Tool`n" -ForegroundColor DarkCyan
Write-Host "  6. Run .\up.ps1 from Sitecore`n" -ForegroundColor DarkCyan

Write-Host "`n`n1. Stop all containers..." -ForegroundColor Cyan
if ($Topology -eq "XP1") {
    Write-Host "Stop all containers for XP1......" -ForegroundColor Cyan
    Push-Location run\sitecore-xp1
}
elseif ($Topology -eq "XM0")
{
    Write-Host "Stop all containers for XM0......" -ForegroundColor Cyan
    Push-Location run\sitecore-xm0
} 
elseif ($Topology -eq "XM1")
{
    Write-Host "Stop all containers for XM1......" -ForegroundColor Cyan
    Push-Location run\sitecore-xm1
} 
else {
    Write-Host "Stop all containers for XP0......" -ForegroundColor Cyan
    Push-Location run\sitecore-xp0
}

docker-compose stop; docker-compose down

Write-Host "`n`n Remove Orphan Containers" -ForegroundColor Cyan
docker-compose down --remove-orphans


Write-Host "`n`n2. Docker Prune" -ForegroundColor Cyan
docker system prune
docker rmi $(docker images --format "{{.Repository}}:{{.Tag}}" | findstr "contosoproject")
docker rmi $(docker images --format "{{.Repository}}:{{.Tag}}" | findstr "nonproduction-api")

if ($Topology -ieq 'XP0') {
    docker container rm "contosoproject_xconnect_1"
    docker rmi $(docker images --format "{{.Repository}}:{{.Tag}}" | findstr "contosoproject-xp0")
}
Pop-Location

Write-Host "`n`n3. Stop IIS, Stop/Start Host Network Service (HNS)" -ForegroundColor Cyan
iisreset /stop; net stop hns; net start hns

Write-Host "`n`n4. Clean all previous build artifacts" -ForegroundColor Cyan
Push-Location docker
.\clean.ps1

Write-Host "`n`n5. Restore Sitecore CLI tool" -ForegroundColor Cyan
#Pop-Location
dotnet tool restore

Write-Host "`n`n6. Build/Compose Docker" -ForegroundColor Cyan
Pop-Location


if ($Topology) {
    Write-Host "Start UP script for "$Topology  -ForegroundColor Cyan
    .\up.ps1 -Topology1 $Topology
}
else {
    Write-Host "Start UP script for XP0......" -ForegroundColor Cyan
    .\up.ps1 -Topology1 "XP0"
}

Write-Host "***Setup completed successfully***" -ForegroundColor Green