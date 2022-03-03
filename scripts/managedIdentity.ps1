
# Reference https://docs.microsoft.com/en-us/azure/active-directory/managed-identities-azure-resources/how-to-assign-app-role-managed-identity-powershell?WT.mc_id=AZ-MVP-5002438
param(
    # Your tenant ID (in the Azure portal, under Azure Active Directory > Overview).
    [Parameter(Mandatory = $true)]
    [string]$tenantId,    
    # The name of your app, which has a managed identity that should be assigned to the server app's app role.
    [Parameter(Mandatory = $true)]
    [string]$appName ,    
    # Resource group containing the app
    [Parameter(Mandatory = $true)]    
    [string]$resourceGroupName, 
    # The name of the server app (In Azure AD) that exposes the app role.
    [Parameter(Mandatory = $true)]    
    [string]$serverApplicationName,
    # The name of the app role that the managed identity should be assigned to.
    [Parameter(Mandatory = $true)]
    [string]$appRoleName             
)

 # Look up the web app's managed identity's object ID.
$managedIdentityObjectId = (Get-AzWebApp -ResourceGroupName $resourceGroupName -Name $appName).identity.principalid

Connect-AzureAD -TenantId $tenantID


# Look up the details about the server app's service principal and app role.
$serverServicePrincipal = (Get-AzureADServicePrincipal -Filter "DisplayName eq '$serverApplicationName'")
$serverServicePrincipalObjectId = $serverServicePrincipal.ObjectId
$appRoleId = ($serverServicePrincipal.AppRoles | Where-Object {$_.Value -eq $appRoleName }).Id

# Assign the managed identity access to the app role.
New-AzureADServiceAppRoleAssignment `
    -ObjectId $managedIdentityObjectId `
    -Id $appRoleId `
    -PrincipalId $managedIdentityObjectId `
    -ResourceId $serverServicePrincipalObjectId