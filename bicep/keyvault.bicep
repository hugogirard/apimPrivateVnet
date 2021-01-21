param principalAdminObjectId string
param vaultName string
param spIdentity string

var location = resourceGroup().location

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
                objectId: principalAdminObjectId
                permissions: {
                    secrets: [
                        'all'                      
                    ]
                }
            }
            {
                tenantId: subscription().tenantId
                objectId: spIdentity
                permissions: {
                  secrets: [
                    'all'
                  ]
                  certificates: [
                    'all'
                  ]
                  keys: [
                    'all'            
                  ]
                }
            }                       
        ]        
    }
}