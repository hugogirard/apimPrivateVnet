

var suffix = uniqueString(resourceGroup().id)
var appServiceApiName = concat('appsrvapi',suffix)
var appServiceWebName = concat('appsrvweb',suffix)
var location = resourceGroup().location
var webapiName = concat('todoapi-',suffix)
var webAppWeb = concat('todoweb-',suffix)
var wcfApp = concat('wcfapp-',suffix)

resource appserviceAPi 'Microsoft.Web/serverfarms@2019-08-01' = {
  name: appServiceApiName
  location: location
  sku: {
    name: 'S1'
    capacity: 1
  }
}

resource appserviceWeb 'Microsoft.Web/serverfarms@2019-08-01' = {
  name: appServiceWebName
  location: location
  sku: {
    name: 'S1'
    capacity: 1
  }
}

resource api 'Microsoft.Web/sites@2019-08-01' = {
  name: webapiName
  location: location
  dependsOn: [
    appserviceAPi
  ]
  properties: {
    serverFarmId: appserviceAPi.id
  }
}

resource web 'Microsoft.Web/sites@2019-08-01' = {
  name: webAppWeb
  location: location
  dependsOn: [
    appserviceWeb
  ]
  properties: {
    serverFarmId: appserviceWeb.id
  }
}

resource wcf 'Microsoft.Web/sites@2019-08-01' = {
  name: wcfApp
  location: location
  dependsOn: [
    appserviceWeb
  ]
  properties: {
    serverFarmId: appserviceWeb.id
  }  
}

output todoWebUrl string = 'https://${web.properties.hostNames[0]}'
output webName string = web.name
output todoApiName string = api.name