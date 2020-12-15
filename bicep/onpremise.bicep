param onpremVnetAddressSpace string
param onpremGatewayAddressSpace string
param onpremWebAddressSpace string
param apimPrivateIp string

param adminUsername string {
  secure: true
}
param adminPassword string {
  secure: true
}

module network './modules/vnet/onpremise.bicep' = {
    name: 'network'
    params: {
        adminPassword: adminPassword
        adminUsername: adminUsername       
        apimPrivateIp: apimPrivateIp
        vnetAddressSpace: onpremVnetAddressSpace
        vpnGwAddressSubnet: onpremGatewayAddressSpace
        winServerAddressSubnet: onpremWebAddressSpace
    }
}

module vpn './modules/gateway/vpn.bicep' = {
  name: 'vpn'
  params: {
      location: resourceGroup().location
      name: concat('vpn-prem-',uniqueString(resourceGroup().id))
      subnetId: network.outputs.subnetGw
      publicIpName: 'pip-gw-prem'
  }
}