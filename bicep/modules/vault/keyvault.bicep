param principalIdApim string

var suffix = uniqueString(resourceGroup().id)
var defaultCertName = 'certificateSecret'
var identityName = 'apggwuseridentity'
var location = resourceGroup().location
var vaultName = concat('vault',suffix)

resource identity 'Microsoft.ManagedIdentity/userAssignedIdentities@2018-11-30' = {
    name: identityName
    location: location
}

resource vault 'Microsoft.KeyVault/vaults@2019-09-01' = {
    name: vaultName
    location: resourceGroup().location
    dependsOn: [
        identity
    ]
    properties: {
        tenantId: subscription().tenantId
        sku: {
            family: 'A'
            name: 'standard'
        }
        accessPolicies: [
            {
                tenantId: subscription().tenantId
                objectId: principalIdApim
                permissions: {
                    secrets: [
                        'get'
                        'list'
                    ]
                }
            }
            {
                tenantId: subscription().tenantId
                objectId: reference(identity.id).principalId
                permissions: {
                    secrets: [
                        'get'
                        'list'
                    ]
                }
            }            
        ]        
    }
}

output userIdentityId string = identity.id