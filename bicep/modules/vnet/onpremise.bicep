param vnetAddressSpace string
param vpnGwAddressSubnet string
param winServerAddressSubnet string
param apimSubnetCIDR string

var vnetName = 'onprem-vnet'
var vpnGatewaySubnet = 'gatewaySubnet'
var winServerSubnet = 'webSubnet'
var location = resourceGroup().location

resource nsg 'Microsoft.Network/networkSecurityGroups@2020-05-01' = {
  name: 'nsg-webapi'
  location: location
  properties: {
    securityRules: [
      {
        name: 'default-allow-80'
        properties: {
          priority: 1000
          access: 'Allow'
          direction: 'Inbound'
          destinationPortRange: '80'
          protocol: 'Tcp'
          sourceAddressPrefix: apimSubnetCIDR
          sourcePortRange: '*'
          destinationAddressPrefix: '*'
        }        
      }
    ]
  }
}

resource vnet 'Microsoft.Network/virtualNetworks@2020-06-01' = {
  name: vnetName
  location: location
  dependsOn: [
    
  ]
  properties: {
      addressSpace: {
          addressPrefixes: [
              vnetAddressSpace
          ]
      }
      subnets: [
          {
              name: vpnGatewaySubnet
              properties: {
                  addressPrefix: vpnGwAddressSubnet
              }
          }
          {
              name: winServerSubnet
              properties: {
                  addressPrefix: winServerAddressSubnet
                  networkSecurityGroup: {
                    id: nsg.id
                  }
              }
          }
      ]
  }
}


output subnetGw string = vnet.properties.subnets[0].id
output webSubnetId string = vnet.properties.subnets[1].id