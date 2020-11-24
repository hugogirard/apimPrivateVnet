// https://github.com/shibayan/keyvault-acmebot

param location string

var suffix = uniqueString(resourceGroup().id)
var strname = concat('st',uniqueString(resourceGroup().id,deployment().name),'func')
var applanName = concat('funcplan',suffix)
var funcname = concat('funcssl',suffix)
var appInsightname = concat('insight',suffix)

resource str 'Microsoft.Storage/storageAccounts@2019-06-01' = {
  name: strname
  location: location
  kind: 'Storage'
  sku: {
    name: 'Standard_LRS'
  }
  properties: {
    supportsHttpsTrafficOnly: true
    allowBlobPublicAccess: false
  }
}

resource appplan 'Microsoft.Web/serverfarms@2020-06-01' = {
  name: applanName
  location: location
  sku: {
    name: 'Y1'
    tier: 'Dynamic'
    size: 'Y1'
    family: 'Y'
  }
}

resource appinsight 'Microsoft.Insights/components@2015-05-01' = {
  name: appInsightname
  location: location
  kind: 'web'
  properties: {
    Application_Type: 'web'    
  }
}

resource function 'Microsoft.Web/sites@2020-06-01' = {
  name: funcname
  location: location
  kind: 'functionapp'
  identity: {
    type: 'SystemAssigned'
  }
  dependsOn: [
    appplan
    str
    appinsight
  ]
  properties: {
    serverFarmId: appplan.id
    siteConfig: {
      appSettings: [
        {
          name: 'APPLICATIONINSIGHTS_CONNECTION_STRING'
          value: concat('InstrumentationKey=',appinsight.properties.InstrumentationKey,';EndpointSuffix=applicationinsights.azure.com')
        }
        {
          name: 'AzureWebJobsStorage'
          value: concat('DefaultEndpointsProtocol=https;AccountName=',strname,';AccountKey=',listKey(str.id,'2018-11-01').keys[0].value,';EndpointSuffix=',environment().suffixes.storage)
        }
        {
          name: 'WEBSITE_CONTENTAZUREFILECONNECTIONSTRING'
          value: concat('DefaultEndpointsProtocol=https;AccountName=', strname,';AccountKey=', listKeys(str.id, '2018-11-01').keys[0].value,';EndpointSuffix=',environment().suffixes.storage)
        }
        {
          name: 'WEBSITE_CONTENTSHARE'
          value: toLower(funcname)
        }
        {
          name: 'WEBSITE_RUN_FROM_PACKAGE'
          value: 'https://shibayan.blob.core.windows.net/azure-keyvault-letsencrypt/v3/latest.zip'
        }
      ]
    }
  }
}