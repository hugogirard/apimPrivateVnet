param onpremVnetAddressSpace string
param onpremGatewayAddressSpace string
param onpremWebAddressSpace string
param apimSubnetCIDR string

@secure()
param adminUsername string

@secure()
param adminPassword string


module network './modules/vnet/onpremise.bicep' = {
    name: 'network'
    params: {     
        apimSubnetCIDR: apimSubnetCIDR
        vnetAddressSpace: onpremVnetAddressSpace
        vpnGwAddressSubnet: onpremGatewayAddressSpace
        winServerAddressSubnet: onpremWebAddressSpace
    }
}

module webServer './modules/compute/webserver.bicep' = {
  name: 'webServer'
  dependsOn: [
    network
  ]
  params: {
    adminPassword: adminPassword
    adminUsername: adminUsername    
    webSubnetId: network.outputs.webSubnetId
  }
}

module vpn './modules/gateway/vpn.bicep' = {
  name: 'vpn'
  params: {
      location: resourceGroup().location
      name: 'vpn-prem-${uniqueString(resourceGroup().id)}'
      subnetId: network.outputs.subnetGw
      publicIpName: 'pip-gw-prem'
  }
}

output vpnOnPremId string = vpn.outputs.vpnId
