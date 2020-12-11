param(    
    [string]$location='eastus',
    [string]$resourceGroupName='apimdemo-rg'
)

Get-AzResourceGroup -Name $resourceGroupName -ErrorVariable notPresent -ErrorAction SilentlyContinue

if ($notPresent)
{
    New-AzResourceGroup -n $resourceGroupName -l $location
}

$outputs = New-AzResourceGroupDeployment -ResourceGroupName $resourceGroupName -TemplateFile .\deploy.json -TemplateParameterFile .\deploy.parameters.json


# Print output variable
foreach ($key in $outputs.Outputs.keys) {
    Write-Output "Key $key"
    $outputs.Outputs[$key].value
}
