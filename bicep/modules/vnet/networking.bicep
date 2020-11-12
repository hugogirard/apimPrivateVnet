param vnetName string
param vnetAddressSpace string
param appgwSubnet string
param apimSubnet string
param jumpboxSubnet string

var location = resourceGroup().location
var appgwSubnetName = 'appgwSubnet'
var apimSubnetName = 'apimSubnet'
var jumpboxSubnetName = 'jumpboxSubnet'

resource vnet 'Microsoft.Network/virtualNetworks@2020-06-01' = {
    name: vnetName
    location: location
    properties: {
        addressSpace: {
            addressPrefixes: [
                vnetAddressSpace
            ]
        }
        subnets: [
            {
                name: appgwSubnetName
                properties: {
                    addressPrefix: appgwSubnet
                }
            }
            {
                name: apimSubnetName
                properties: {
                    addressPrefix: apimSubnet
                }
            }
            {
                name: jumpboxSubnetName
                properties: {
                    addressPrefix: jumpboxSubnet
                }
            }
        ]
    }
}

output vnetId string = vnet.id
output subnetJumpbox string = vnet.properties.subnets[2].id
output subnetApim string = vnet.properties.subnets[1].id
output subnetAppGw string = vnet.properties.subnets[0].id