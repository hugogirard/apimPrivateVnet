param location string
param vnetAddressSpace string = '10.0.0.0/16'
param subnetAddressSpace string = '10.0.0.0/24'

var suffix = uniqueString(resourceGroup().id)
var appplan = concat('appplan-',suffix)
var webAppName = {
  front: concat('frontweb-',suffix)
  back: concat('backend-',suffix)
}
var vnetName = concat('vnet-app-',suffix)
var vaultName = concat('vault-',suffix)


// resource vault 'Microsoft.KeyVault/vaults@2019-09-01' = {
//   name: vaultName
//   location: location  
//   properties: {
//     sku: {
//       family: 'A'
//       name: 'standard'
//     }
//     tenantId: subscription().tenantId
//   }
// }

resource vnet 'Microsoft.Network/virtualNetworks@2020-06-01' = {
  name: vnetName
  location: location
  dependsOn: [
    //vault
  ]
  properties: {
    addressSpace: {
      addressPrefixes: [
        vnetAddressSpace
      ]      
    }   
    subnets: [
      {
        name: 'webappSubnet'
        properties: {
          addressPrefix: subnetAddressSpace          
          serviceEndpoints: [
            {
              service: 'Microsoft.KeyVault'
              locations: [
                location
              ]
            }
          ]
          delegations: [
            {
              name: 'webAppDelegation'
              properties: {
                serviceName: 'Microsoft.Web/serverfarms'
              }
            }
          ]
        }                
      }
    ] 
  }
}

resource appServicePlan 'Microsoft.Web/serverfarms@2019-08-01' = {
  name: appplan
  location: location
  dependsOn: [
    vnet
  ]
  sku: {
    size: 'S1'
    family: 'S'
    tier: 'Standard'
    capacity: 1
  }
  kind: 'app'
}

resource webappFront 'Microsoft.Web/sites@2019-08-01' = {
  name: webAppName.front
  location: location
  dependsOn: [
    appServicePlan
  ]
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    serverFarmId: appServicePlan.id
  }
}

resource frontvnetConnection 'Microsoft.Web/sites/networkConfig@2019-08-01' = {
  name: concat(webappFront.name,'/VirtualNetwork')
  dependsOn: [
    webappFront
  ]
  properties: {
    subnetResourceId: vnet.properties.subnets[0].id
  }
}