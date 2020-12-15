param location string
param name string
param subnetId string
param publicIpName string

var sku = 'VpnGw1'
var gatewayType = 'Vpn'
var vpnGatewayGeneration = 'Generation1'
var vpnType = 'RouteBased'

resource pip 'Microsoft.Network/publicIPAddresses@2019-02-01' = {
  name: publicIpName
  location: location
  properties: {
    publicIPAllocationMethod: 'Dynamic'
  }
}

resource vpn 'Microsoft.Network/virtualNetworkGateways@2019-04-01' = {
  name: name
  location: location
  dependsOn: [
    pip
  ]
  properties: {
    gatewayType: gatewayType
    ipConfigurations: [
      {
        name: 'default'
        properties: {
          privateIPAllocationMethod: 'Dynamic'
          subnet: {
            id: subnetId
          }
          publicIPAddress: {
            id: pip.id
          }
        }
      }
    ]
    vpnType: vpnType
    vpnGatewayGeneration: vpnGatewayGeneration
    sku: {
      name: sku
      tier: sku
    }
  }
}