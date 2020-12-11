param adminUsername string {
  secure: true
}
param adminPassword string {
  secure: true
}
param vnetName string
param subnetId string

var suffix = uniqueString(resourceGroup().id)
var name = concat('sqlserver-',suffix)
var dbname = 'tododb'
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