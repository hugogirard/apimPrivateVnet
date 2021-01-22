
var apimManagedIdentity = 'apimIdentity'
var location = resourceGroup().location

resource apimIdentity 'Microsoft.ManagedIdentity/userAssignedIdentities@2018-11-30' = {
  name: apimManagedIdentity
  location: location
}

output apimManagedIdenity string = apimIdentity.id