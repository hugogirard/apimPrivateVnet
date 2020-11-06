param(    
    [string]$location='eastus',
    [string]$resourceGroupName='apimdemo-rg'
)

Get-AzResourceGroup -Name $resourceGroupName -ErrorVariable notPresent -ErrorAction SilentlyContinue

if ($notPresent)
{
    New-AzResourceGroup -n $resourceGroupName -l $location
}

New-AzResourceGroupDeployment -ResourceGroupName $resourceGroupName -TemplateFile .\deploy.json -TemplateParameterFile .\deploy.parameters.json



