param vaultName string

var identityName = 'apggwuseridentity'
var apimManagedIdentity = 'apimIdentity'
var location = resourceGroup().location

// Identity used in Application Gateway
resource identity 'Microsoft.ManagedIdentity/userAssignedIdentities@2018-11-30' = {
  name: identityName
  location: location
}


resource apimIdentity 'Microsoft.ManagedIdentity/userAssignedIdentities@2018-11-30' = {
  name: apimManagedIdentity
  location: location
}

resource accessPolicies 'Microsoft.KeyVault/vaults/accessPolicies@2019-09-01' = { 
  name: any('${vaultName}/add')
  properties: {
    accessPolicies: [
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
      {
        tenantId: subscription().tenantId
        objectId: reference(apimIdentity.id).principalId
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