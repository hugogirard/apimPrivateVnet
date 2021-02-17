param vpn1Id string
param vpn2Id string
param sharedKey string {
  secure: true
}

var location = resourceGroup().location

resource connectionCloudToPrem 'Microsoft.Network/connections@2020-05-01' = {
  name: 'cloudToPrem'
  location: location
  properties: {
    virtualNetworkGateway1: {
      id: vpn1Id
    }
    virtualNetworkGateway2: {
      id: vpn2Id
    }
    connectionType: 'Vnet2Vnet'
    connectionProtocol: 'IKEv2'
    sharedKey: sharedKey
    enableBgp: false    
  }
}

resource connectionPremToCloud 'Microsoft.Network/connections@2020-05-01' = {
  name: 'PremToCloud'
  location: location
  properties: {
    virtualNetworkGateway1: {
      id: vpn2Id
    }
    virtualNetworkGateway2: {
      id: vpn1Id
    }
    connectionType: 'Vnet2Vnet'
    connectionProtocol: 'IKEv2'
    sharedKey: sharedKey
    enableBgp: false    
  }
}