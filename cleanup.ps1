param(
    [string]$resourceGroup='apimdemo-rg'
)

try {
    # Delete the Application in Azure AD

    $appId = az ad app list --display-name 'todoapi' --query [0].appId
    Write-Host 'Deleting TodoApi'
    az ad app delete --id $appId  

    $appId = az ad app list --display-name 'weatherapi' --query [0].appId
    Write-Host 'Deleting WeatherApi'
    az ad app delete --id $appId  
    
    $appId = az ad app list --display-name 'todoWeb' --query [0].appId
    Write-Host 'Deleting todoWeb'
    az ad app delete --id $appId  

}
catch {
    $ErrorMessage = $_.Exception.Message
    Write-Host "Error message was $ErrorMessage"
    Break      
}