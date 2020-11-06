param principalIdApim string

var suffix = uniqueString(resourceGroup().id)
var vaultName = concat('vault-',suffix)

resource vault 'Microsoft.KeyVault/vaults@2019-09-01' = {
    name: vaultName
    location: resourceGroup().location
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
        ]        
    }
}