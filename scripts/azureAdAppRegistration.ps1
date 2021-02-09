 <#
    Before running this script you need to install the AzureAD cmdlets as an administrator. 
    For this:
    
    1) Run Powershell as an administrator
    2) in the PowerShell window, type: Install-Module AzureAD
#>

[CmdletBinding()]
param(
    [Parameter(Mandatory=$True)]
    [string]$todoWebBaseUrl
)

#Requires -Modules AzureAD

Function ComputePassword
{
    $aesManaged = New-Object "System.Security.Cryptography.AesManaged"
    $aesManaged.Mode = [System.Security.Cryptography.CipherMode]::CBC
    $aesManaged.Padding = [System.Security.Cryptography.PaddingMode]::Zeros
    $aesManaged.BlockSize = 128
    $aesManaged.KeySize = 256
    $aesManaged.GenerateKey()
    return [System.Convert]::ToBase64String($aesManaged.Key)
}

# Create an application key
# See https://www.sabin.io/blog/adding-an-azure-active-directory-application-and-key-using-powershell/
Function CreateAppKey([DateTime] $fromDate, [double] $durationInYears, [string]$pw)
{
    $endDate = $fromDate.AddYears($durationInYears) 
    $keyId = (New-Guid).ToString();
    $key = New-Object Microsoft.Open.AzureAD.Model.PasswordCredential
    $key.StartDate = $fromDate
    $key.EndDate = $endDate
    $key.Value = $pw
    $key.KeyId = $keyId
    return $key
}

<#.Description
   This function creates a new Azure AD scope (OAuth2Permission) with default and provided values
#>  
Function CreateScope( [string] $value, [string] $userConsentDisplayName, [string] $userConsentDescription, [string] $adminConsentDisplayName, [string] $adminConsentDescription)
{
    $scope = New-Object Microsoft.Open.AzureAD.Model.OAuth2Permission
    $scope.Id = New-Guid
    $scope.Value = $value
    $scope.UserConsentDisplayName = $userConsentDisplayName
    $scope.UserConsentDescription = $userConsentDescription
    $scope.AdminConsentDisplayName = $adminConsentDisplayName
    $scope.AdminConsentDescription = $adminConsentDescription
    $scope.IsEnabled = $true
    $scope.Type = "User"
    return $scope
}

Function GetRequiredPermissions([string] $applicationDisplayName, [string] $requiredDelegatedPermissions, [string]$requiredApplicationPermissions, $servicePrincipal)
{
    # If we are passed the service principal we use it directly, otherwise we find it from the display name (which might not be unique)
    if ($servicePrincipal)
    {
        $sp = $servicePrincipal
    }
    else
    {
        $sp = Get-AzureADServicePrincipal -Filter "DisplayName eq '$applicationDisplayName'"
    }
    $appid = $sp.AppId
    $requiredAccess = New-Object Microsoft.Open.AzureAD.Model.RequiredResourceAccess
    $requiredAccess.ResourceAppId = $appid 
    $requiredAccess.ResourceAccess = New-Object System.Collections.Generic.List[Microsoft.Open.AzureAD.Model.ResourceAccess]

    # $sp.Oauth2Permissions | Select Id,AdminConsentDisplayName,Value: To see the list of all the Delegated permissions for the application:
    if ($requiredDelegatedPermissions)
    {
        AddResourcePermission $requiredAccess -exposedPermissions $sp.Oauth2Permissions -requiredAccesses $requiredDelegatedPermissions -permissionType "Scope"
    }
    
    # $sp.AppRoles | Select Id,AdminConsentDisplayName,Value: To see the list of all the Application permissions for the application
    if ($requiredApplicationPermissions)
    {
        AddResourcePermission $requiredAccess -exposedPermissions $sp.AppRoles -requiredAccesses $requiredApplicationPermissions -permissionType "Role"
    }
    return $requiredAccess
}

Function ConfigureApplications([string]$appName,[string]$scopeName)
{

    # Get the user running the script to add the user as the app owner
    $user = Get-AzureADUser -ObjectId $creds.Account.Id    
    
   # Create the service AAD application
   Write-Host "Creating the AAD application $appName"
   
   # Get a 2 years application key for the service Application
   $pw = ComputePassword
   $fromDate = [DateTime]::Now;   

   $key = CreateAppKey -fromDate $fromDate -durationInYears 2 -pw $pw

   $serviceAadApplication = New-AzureADApplication -DisplayName $appName `
                                                   -AvailableToOtherTenants $False `
                                                   -PasswordCredentials $key `
                                                   -PublicClient $False   

   $serviceIdentifierUri = 'api://'+$serviceAadApplication.AppId
   Set-AzureADApplication -ObjectId $serviceAadApplication.ObjectId -IdentifierUris $serviceIdentifierUri

   # create the service principal of the newly created application 
   $currentAppId = $serviceAadApplication.AppId
  
    Add-AzureADApplicationOwner -ObjectId $serviceAadApplication.ObjectId -RefObjectId $user.ObjectId

    # rename the user_impersonation scope if it exists to match the readme steps or add a new scope
    $scopes = New-Object System.Collections.Generic.List[Microsoft.Open.AzureAD.Model.OAuth2Permission]

    if ($scopes.Count -ge 0) 
    {
        # add all existing scopes first
        $serviceAadApplication.Oauth2Permissions | foreach-object { $scopes.Add($_) }

        # Add scope
        $scope = CreateScope -value $scopeName  `
                            -adminConsentDisplayName "To All Action in $appName"  `
                            -adminConsentDescription "To All Action in $appName"
        
        $scopes.Add($scope)        
    }

    # add/update scopes
    Set-AzureADApplication -ObjectId $serviceAadApplication.ObjectId -OAuth2Permission $scopes    

    Write-Host "Done creating the service application $appName"
    Write-Host "$appName ClientId $currentAppId"
    Write-Host "$appName Scope $serviceIdentifierUri/$scopeName"

}

Function ConfigureTodoWeb([string]$todoWebBaseUrl)
{
   # Get a 2 years application key for the client Application
   $pw = ComputePassword
   $fromDate = [DateTime]::Now;
   $key = CreateAppKey -fromDate $fromDate -durationInYears 2 -pw $pw
   $user = Get-AzureADUser -ObjectId $creds.Account.Id 

   $tenant = Get-AzureADTenantDetail
   $tenantName =  ($tenant.VerifiedDomains | Where { $_._Default -eq $True }).Name

   $clientAadApplication = New-AzureADApplication -DisplayName "TodoWeb" `
                                                  -HomePage $todoWebBaseUrl `
                                                  -LogoutUrl "$todoWebBaseUrl/signout-oidc" `
                                                  -ReplyUrls "$todoWebBaseUrl/signin-oidc" `
                                                  -IdentifierUris "https://$tenantName/TodoWeb" `
                                                  -AvailableToOtherTenants $False `
                                                  -PasswordCredentials $key `
                                                  -PublicClient $False   
   
   Add-AzureADApplicationOwner -ObjectId $clientAadApplication.ObjectId -RefObjectId $user.ObjectId

   
#    $requiredResourcesAccess = New-Object System.Collections.Generic.List[Microsoft.Open.AzureAD.Model.RequiredResourceAccess]

#    $requiredPermissions = GetRequiredPermissions -applicationDisplayName "TodoWeb" `
#                                                  -requiredDelegatedPermissions "Todo.Api.All" `

#    $requiredResourcesAccess.Add($requiredPermissions)   
   
#    Set-AzureADApplication -ObjectId $clientAadApplication.ObjectId -RequiredResourceAccess $requiredResourcesAccess   
}

$creds = Connect-AzureAD

Write-Host "TenantId: $creds.Tenant.Id"


ConfigureApplications 'TodoApi' 'Todo.Api.All'
ConfigureApplications 'WeatherApi' 'Weather.Get.All'
ConfigureTodoWeb $todoWebBaseUrl