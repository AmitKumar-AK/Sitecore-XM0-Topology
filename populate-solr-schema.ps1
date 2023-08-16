
# Wait for Traefik to expose CM route
Write-Host "Waiting for CM to become available..." -ForegroundColor Green
$startTime = Get-Date
do {
    Start-Sleep -Milliseconds 200
    try {
        $status = Invoke-RestMethod "http://localhost:8079/api/http/routers/cm-secure@docker"
    }
    catch {
        if ($_.Exception.Response.StatusCode.value__ -ne "404") {
            throw
        }
    }
} while ($status.status -ne "enabled" -and $startTime.AddSeconds(15) -gt (Get-Date))
if (-not $status.status -eq "enabled") {
    $status
    Write-Error "Timeout waiting for Sitecore CM to become available via Traefik proxy. Check CM container logs."
}

if ($ByPass) {
    dotnet sitecore login --cm https://cm.contosoproject.localhost/ --auth https://id.contosoproject.localhost/ --allow-write true --client-id "SitecoreCLIServer" --client-secret "testsecret" --client-credentials true
}
else {
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

Write-Host "Opening Solr Admin Site..." -ForegroundColor Green

Start-Process http://localhost:8984/solr

Write-Host ""
Write-Host "Solr managed schema populated" -ForegroundColor Green
Write-Host ""
