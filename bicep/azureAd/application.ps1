# This powershell script create application in Azure AD
# All credit from this script is from this article
# https://damienbod.com/2020/06/22/using-azure-cli-to-create-azure-app-registrations/
# https://github.com/damienbod/AzureAD-Auth-MyUI-with-MyAPI/tree/main/CreateAppRegistrations

Param(
    [Parameter(Mandatory=$true)]
    [string]$appname,    
    [string]$scopes
)

$bodyApi = '{
    "signInAudience" : "AzureADandPersonalMicrosoftAccount", 
    "groupMembershipClaims": "None"    
}' | ConvertTo-Json | ConvertFrom-Json

if ($scopes -eq "") {
    Write-Host "In the if"
    $scopes = '{
        "lang": null,
        "origin": "Application",        
        "adminConsentDescription": "Allow access to the API",
        "adminConsentDisplayName": "mi-api-access",
        "id": "--- replaced in scripts ---",
        "isEnabled": true,
        "type": "User",
        "userConsentDescription": "Allow access to mi-api access_as_user",
        "userConsentDisplayName": "Allow access to mi-api",
        "value": "access_as_user"
    }' | ConvertTo-Json | ConvertFrom-Json
}

Write-Host "Begin API Azure App Registration"

try {
    ##################################
    ### Create Azure App Registration
    ##################################

    $identifierApi = New-Guid
    $identifierUrlApi = "api://" + $identifierApi

    $myApiAppRegistration = az ad app create `
                                --display-name $appname `
                                --available-to-other-tenants false `
                                --oauth2-allow-implicit-flow  false `
                                --identifier-uris $identifierUrlApi

    $myApiAppRegistrationResult = ($myApiAppRegistration | ConvertFrom-Json)
    $myApiAppRegistrationResultAppId = $myApiAppRegistrationResult.appId
    Write-Host " - Created API $displayNameApi with myApiAppRegistrationResultAppId: $myApiAppRegistrationResultAppId"

    ##################################
    ###  Add scopes (oauth2Permissions)
    ##################################
    
    # 1. read oauth2Permissions
    $oauth2PermissionsApi = $myApiAppRegistrationResult.oauth2Permissions
    
    # 2. set to enabled to false from the defualt scope, because we want to remove this
    $oauth2PermissionsApi[0].isEnabled = 'false'
    $oauth2PermissionsApi = ConvertTo-Json -InputObject @($oauth2PermissionsApi) 
    # Write-Host "$oauth2PermissionsApi" 
    # disable oauth2Permission in Azure App Registration
    $oauth2PermissionsApi | Out-File -FilePath .\oauth2Permissionsold.json
    az ad app update --id $myApiAppRegistrationResultAppId --set oauth2Permissions=`@oauth2Permissionsold.json
    
    # 3. delete the default oauth2Permission
    az ad app update --id $myApiAppRegistrationResultAppId --set oauth2Permissions='[]'
    
    # 4. add the new scope required add the new oauth2Permissions values
    $oauth2PermissionsApiNew += (ConvertFrom-Json -InputObject $scopes)
    $oauth2PermissionsApiNew[0].id = $identifierApi
    $oauth2PermissionsApiNew = ConvertTo-Json -InputObject @($oauth2PermissionsApiNew) 
    # Write-Host "$oauth2PermissionsApiNew" 
    $oauth2PermissionsApiNew | Out-File -FilePath .\oauth2Permissionsnew.json
    az ad app update --id $myApiAppRegistrationResultAppId --set oauth2Permissions=`@oauth2Permissionsnew.json
    Write-Host " - Updated scopes (oauth2Permissions) for App Registration: $myApiAppRegistrationResultAppId"

    ##################################
    ###  Create a ServicePrincipal for the API App Registration
    ##################################
    
    az ad sp create --id $myApiAppRegistrationResultAppId | Out-String | ConvertFrom-Json
    Write-Host " - Created Service Principal for API App registration"    
}
catch {
    $ErrorMessage = $_.Exception.Message
    Write-Host "Error message was $ErrorMessage"
    Break    
}

return $myApiAppRegistrationResultAppId

