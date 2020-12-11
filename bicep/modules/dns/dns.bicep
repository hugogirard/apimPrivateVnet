param dnsZoneName string
param apimIpAddress string
param vnetName string
param vnetId string

resource dns 'Microsoft.Network/privateDnsZones@2018-09-01' = {
    name: dnsZoneName
    location: 'global'
    properties: {
    }
}

resource soa 'Microsoft.Network/privateDnsZones/SOA@2018-09-01' = {
    name: concat(dnsZoneName,'/@')
    dependsOn: [
        dns
    ]
    properties: {}
}

resource networkLink 'Microsoft.Network/privateDnsZones/virtualNetworkLinks@2018-09-01' = {
    name: concat(dnsZoneName,'/',vnetName)
    location: 'global'
    dependsOn: [
        dns
    ]
    properties: {
        registrationEnabled: true
        virtualNetwork: {
            id: vnetId
        }
    }
}