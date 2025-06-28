[CmdletBinding(DefaultParameterSetName = "no-arguments")]
Param (
    [Parameter(HelpMessage = "Alternative login using app client.",
        ParameterSetName = "by-pass")]
    [bool]$ByPass = $false,
    [Parameter(Mandatory = $false,
        HelpMessage = "Sets the instance topology",
        ParameterSetName = "env-init")]
    [ValidateSet("xp0","xp1","xm0","xm1")]
    [string]$Topology1 = "xp0"    
)   

$topologyArray = "xp0", "xp1", "xm0", "xm1";

$ErrorActionPreference = "Stop";
$startDirectory = ".\run\sitecore-";
$workingDirectoryPath;
$envCheck;
# Double check whether init has been run
$envCheckVariable = "HOST_LICENSE_FOLDER";

Write-Host "Topology parameter passed from start-clean-install => " $Topology1 -ForegroundColor Yellow
foreach ($topology in $topologyArray) {
    $envCheck = Get-Content (Join-Path -Path ($startDirectory + $topology) -ChildPath .env) -Encoding UTF8 | Where-Object { $_ -imatch "^$envCheckVariable=.+" }
    if ($envCheck  -and -not $Topology1) {
        #$workingDirectoryPath = $startDirectory + $topology;
        #$topology = "xp1"
        Write-Host "Topology found in env variable => " $topology -ForegroundColor Yellow
        $workingDirectoryPath = $startDirectory + $topology;
        break
    }
}

if ($Topology1) {
    $workingDirectoryPath = $startDirectory + $Topology1;
        Write-Host "Topoloby Directory Path => " $workingDirectoryPath -ForegroundColor Yellow
    $envCheck = "found topology"
}

if (-not $envCheck) {
    throw "$envCheckVariable does not have a value. Did you run 'init.ps1 -InitEnv'?"
}


Write-Host "`n`n Run npm ci command on rendering" -ForegroundColor Cyan
Push-Location src\rendering\
npm install --silent
npm ci --silent
Pop-Location

Push-Location $workingDirectoryPath


# Build all containers in the Sitecore instance, forcing a pull of latest base containers
Write-Host "Building containers..." -ForegroundColor Green
docker-compose build
if ($LASTEXITCODE -ne 0) {
    Write-Error "Container build failed, see errors above."
}

# Start the Sitecore instance
Write-Host "Starting Sitecore environment..." -ForegroundColor Green
docker-compose up -d

Pop-Location

# Wait for Traefik to expose CM route
Write-Host "Waiting for CM to become available..." -ForegroundColor Green
$startTime = Get-Date
do {
    Start-Sleep -Milliseconds 100
    try {
        $status = Invoke-RestMethod "http://localhost:8079/api/http/routers/cm-secure@docker"
    } catch {
        if ($_.Exception.Response.StatusCode.value__ -ne "404") {
            throw
        }
    }
} while ($status.status -ne "enabled" -and $startTime.AddSeconds(15) -gt (Get-Date))
if (-not $status.status -eq "enabled") {
    $status
    Write-Error "Timeout waiting for Sitecore CM to become available via Traefik proxy. Check CM container logs."
}

# Execute the Sitecore Identity Server 8 upgrade script after the environment is up
.\execute-mssql-script.ps1 -filePath $workingDirectoryPath"\.env"

# Log into Sitecore using the CLI
if ($ByPass) {
  dotnet sitecore login --cm https://cm.contosoproject.localhost/ --auth https://id.contosoproject.localhost/ --allow-write true --client-id "SitecoreCLIServer" --client-secret "testsecret" --client-credentials true
}else {
  dotnet sitecore login --cm https://cm.contosoproject.localhost/ --auth https://id.contosoproject.localhost/ --allow-write true
}

if ($LASTEXITCODE -ne 0) {
    Write-Error "Unable to log into Sitecore, did the Sitecore environment start correctly? See logs above."
}

# Populate Solr managed schemas to avoid errors during item deploy
Write-Host "Populating Solr managed schema..." -ForegroundColor Green
dotnet sitecore index schema-populate

Write-Host "Rebuilding indexes..." -ForegroundColor Green
dotnet sitecore index rebuild

##
## This script will sync the JSS sample site on first run, and then serialize it.
## Subsequent executions will only push the serialized site. You may wish to remove /
## simplify this logic if using this starter for your own development.
##

# JSS sample has already been deployed and serialized, push the serialized items
if (Test-Path .\src\items\content) {

    Write-Host "Pushing items to Sitecore..." -ForegroundColor Green
    dotnet sitecore ser push --publish
    if ($LASTEXITCODE -ne 0) {
        Write-Error "Serialization push failed, see errors above."
    }

# JSS sample has not been deployed yet. Use its deployment process to initialize.
} else {

    # Some items are needed for JSS to be able to deploy.
    Write-Host "Pushing init items to Sitecore..." -ForegroundColor Green
    dotnet sitecore ser push --include InitItems
    if ($LASTEXITCODE -ne 0) {
        Write-Error "Serialization push failed, see errors above."
    }

    Write-Host "Deploying JSS application..." -ForegroundColor Green
    Push-Location src\rendering
    try {
        jss deploy items -c -d
    } finally {
        Pop-Location
    }
    if ($LASTEXITCODE -ne 0) {
        Write-Error "JSS deploy failed, see errors above."
    }
    dotnet sitecore publish
    if ($LASTEXITCODE -ne 0) {
        Write-Error "Item publish failed, see errors above."
    }

    Write-Host "Pulling JSS deployed items..." -ForegroundColor Green
    dotnet sitecore ser pull
}

Write-Host "Opening site..." -ForegroundColor Green

Start-Process https://cm.contosoproject.localhost/sitecore/
Start-Process https://www.contosoproject.localhost/

Write-Host ""
Write-Host "Use the following command to monitor your Rendering Host:" -ForegroundColor Green
Write-Host "docker-compose logs -f rendering"
Write-Host ""
