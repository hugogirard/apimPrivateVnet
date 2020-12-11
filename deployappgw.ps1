param(        
    [string]$resourceGroupName='apimdemo-rg'
)

New-AzResourceGroupDeployment -ResourceGroupName $resourceGroupName -TemplateFile .\appgw.json -TemplateParameterFile .\appgw.parameters.json
