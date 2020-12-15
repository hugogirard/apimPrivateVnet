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

module onpremise './modules/onprem/onpremise.bicep' = {
    name: 'onpremise'
    // dependsOn: [
    //     network
    //     apim
    // ]
    params: {
        adminPassword: adminPassword
        adminUsername: adminUsername       
        apimPrivateIp: apimPrivateIp
        vnetAddressSpace: onpremVnetAddressSpace
        vpnGwAddressSubnet: onpremGatewayAddressSpace
        winServerAddressSubnet: onpremWebAddressSpace
    }
}