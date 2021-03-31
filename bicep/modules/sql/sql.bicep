@secure()
param adminUsername string

@secure()  
param adminPassword string

param vnetName string
param subnetId string
param environment string

var suffix = uniqueString(resourceGroup().id)
var name = concat('sqlserver-',environment,'-',suffix)
var dbname = 'tododb-${environment}'
var location = resourceGroup().location

resource server 'Microsoft.Sql/servers@2019-06-01-preview' = {
  name: name
  location: location
  properties: {
    administratorLogin: adminUsername
    administratorLoginPassword: adminPassword
  }
}

resource database 'Microsoft.Sql/servers/databases@2019-06-01-preview' = {
  name: concat(server.name,'/',dbname)
  dependsOn: [
    server
  ]
  location: location
  sku: {
    name: 'Basic'
    tier: 'Basic'
  }
}

resource networkRule 'Microsoft.Sql/servers/virtualNetworkRules@2015-05-01-preview' = {
  name: concat(server.name,'/',vnetName)
  properties: {
    virtualNetworkSubnetId: subnetId
    ignoreMissingVnetServiceEndpoint: false
  }
}
