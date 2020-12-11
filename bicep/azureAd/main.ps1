# Main scripts that create all the application in Azure AD
param(
    [Parameter(Mandatory=$true)]
    [string]$secret
)

$todoApiScopes = '{
    "lang": null,
    "origin": "Application",        
    "adminConsentDescription": "Allow access to all methods Todo API",
    "adminConsentDisplayName": "todo-api-access",
    "id": "--- replaced in scripts ---",
    "isEnabled": true,
    "type": "User",
    "userConsentDescription": "Give access to your profile for todo api",
    "userConsentDisplayName": "Allow access to todo-api",
    "value": "todo_api_all_access"
}' | ConvertTo-Json | ConvertFrom-Json

$weatherApiScopes = '{
    "lang": null,
    "origin": "Application",        
    "adminConsentDescription": "Allow access to all methods Weather API",
    "adminConsentDisplayName": "weather-api-access",
    "id": "--- replaced in scripts ---",
    "isEnabled": true,
    "type": "User",
    "userConsentDescription": "Give access to your profile for weather api",
    "userConsentDisplayName": "Allow access to weather-api",
    "value": "weather_api_all_access"
}' | ConvertTo-Json | ConvertFrom-Json

$todoApiAppId = &".\application.ps1" 'todoapi' $todoApiScopes | Select-Object -Last 1
$weatherApiAppId = &".\application.ps1" 'weatherapi' $weatherApiScopes | Select-Object -Last 1

$webAppId = &".\webClient.ps1" $todoApiAppId 'todoWeb' $secret | Select-Object -Last 1

Write-Host $todoApiAppId
Write-Host $webAppId