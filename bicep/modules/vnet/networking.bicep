param vnetName string
param vnetAddressSpace string
param appgwSubnet string
param apimSubnet string
param jumpboxSubnet string
param webServerSubnet string
param gwSubnet string

var location = resourceGroup().location
var appgwSubnetName = 'appgwSubnet'
var apimSubnetName = 'apimSubnet'
var jumpboxSubnetName = 'jumpboxSubnet'
var webServerSubnetName = 'webWorkloadSubnet'
var gwSubnetName = 'gatewaySubnet'

resource nsg 'Microsoft.Network/networkSecurityGroups@2020-05-01' = {
    name: 'nsg-jumpbox'
    location: location
    properties: {
        securityRules: []
    }
}

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
                    networkSecurityGroup: {
                        id: nsg.id
                    }
                }
            }
            {
                name: webServerSubnetName
                properties: {
                    addressPrefix: webServerSubnet
                    serviceEndpoints: [
                        {
                            service: 'Microsoft.Sql'
                        }
                    ]
                    delegations: [ 
                        {
                            name: 'delegation'
                            properties: {
                                serviceName: 'Microsoft.Web/serverFarms' 
                            }
                        }
                        
                    ]
                }
            }
            {
                name: gwSubnetName
                properties: {
                    addressPrefix: gwSubnet
                }
            }
        ]
    }
}

output vnetId string = vnet.id
output vnetname string = vnet.name
output webServerSubnetId string = vnet.properties.subnets[3].id
output subnetJumpbox string = vnet.properties.subnets[2].id
output subnetApim string = vnet.properties.subnets[1].id
output subnetAppGw string = vnet.properties.subnets[0].id
output subnetGw string = vnet.properties.subnets[4].id
