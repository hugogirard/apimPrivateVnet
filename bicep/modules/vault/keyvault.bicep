param principalAdminObjectId string
param spIdentity string

var location = resourceGroup().location
var vaultName = concat('vault',uniqueString(resourceGroup().id))
var identityName = 'apggwuseridentity'

resource identity 'Microsoft.ManagedIdentity/userAssignedIdentities@2018-11-30' = {
  name: identityName
  location: location
}

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
            {
              tenantId: subscription().tenantId
              objectId: reference(identity.id).principalId
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

output vaultGeneratedName string = vaultName