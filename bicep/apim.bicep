param publisherName string
param publisherEmail string
param subnetResourceId string

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
    }
    identity: {
        type: 'SystemAssigned'
    }
    sku: {
        name: 'Developer'
        capacity: 1
    }
}

output apimIdentity string = apim.identity.principalId