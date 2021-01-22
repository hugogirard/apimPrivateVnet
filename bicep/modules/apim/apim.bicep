param publisherName string
param publisherEmail string
param subnetResourceId string
param apiHostname string
param keyVaultName string
param secretName string
param managedIdentityId string

var suffix = uniqueString(resourceGroup().id)
var apimName = concat('apim-',suffix)
var location = resourceGroup().location

resource apim 'Microsoft.ApiManagement/service@2019-12-01' = {
    name: apimName
    location: location
    properties: {
        virtualNetworkConfiguration: {
            subnetResourceId: subnetResourceId
        }
        virtualNetworkType: 'Internal'
        publisherEmail: publisherEmail
        publisherName: publisherName
        hostnameConfigurations: [
            {
                type: 'Proxy'
                hostName: apiHostname
                keyVaultId: concat(reference(keyVaultName).vaultUri,'secrets/${secretName}')
                identityClientId: reference(managedIdentityId).clientId
                negotiateClientCertificate: false
                defaultSslBinding: true
            }
        ]
    }
    identity: {
        type: 'UserAssigned'
        userAssignedIdentities: {
            '${managedIdentityId}': {
                
            }
        }
    }
    sku: {
        name: 'Developer'
        capacity: 1
    }
}

output apimhostname string = concat(apimName,'.net')
output apimPrivateIp string = apim.properties.privateIPAddresses[0]