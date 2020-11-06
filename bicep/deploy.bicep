param vnetName string = 'apimdemo-vnet'
param vnetAddressSpace string = '10.1.0.0/16'
param appgwSubnet string = '10.1.1.0/24'
param apimSubnet string = '10.1.2.0/24'
param jumpboxSubnet string = '10.1.3.0/24'
param publisherName string = 'Hugo Girard'
param publisherEmail string = 'hugirard@microsoft.com'
param adminUsername string {
  secure: true
}
param adminPassword string {
  secure: true
}

module network './networking.bicep' = {
    name: 'network'
    params: {
        vnetName: vnetName
        vnetAddressSpace: vnetAddressSpace
        appgwSubnet: appgwSubnet
        apimSubnet: apimSubnet
        jumpboxSubnet: jumpboxSubnet
    }
}

module apim './apim.bicep' = {
    name: 'apim'
    dependsOn: [
        network
    ]
    params: {
        publisherName: publisherName
        publisherEmail: publisherEmail
        subnetResourceId: network.outputs.subnetApim
    }
}

module vault './keyvault.bicep' = {
    name: 'vault'
    dependsOn: [
        apim
    ]
    params: {
        principalIdApim: apim.outputs.apimIdentity
    }
}

module jumpbox './jumpbox.bicep' = {
    name: 'jumpbox'
    dependsOn: [
        network
    ]
    params: {
        adminUsername: adminUsername
        adminPassword: adminPassword
        subnetId: network.outputs.subnetJumpbox
    }
}

module dns './dnsZone.bicep' = {
    name: 'dns'    
}