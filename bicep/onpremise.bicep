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