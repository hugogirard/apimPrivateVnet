


resource dns 'Microsoft.Network/privateDnsZones@2018-09-01' = {
    name: 'hugirard.com'
    location: resourceGroup().location
}