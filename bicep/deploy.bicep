param vnetName string
param vnetAddressSpace string
param appgwSubnet string
param apimSubnet string
param jumpboxSubnet string
param webServerSubnet string
param gwSubnet string
param environment string

param principalAdminObjectId string
param spIdentity string

param onpremVnetAddressSpace string
param onpremGatewayAddressSpace string
param onpremWebAddressSpace string

param publisherName string
param publisherEmail string
@secure()
param adminUsernameSql string

@secure()
param adminPasswordSql string

param hostname string

@secure()
param adminUsername string

@secure()
param adminPassword string

module network './modules/vnet/networking.bicep' = {
    name: 'network'
    params: {
        vnetName: vnetName
        vnetAddressSpace: vnetAddressSpace
        appgwSubnet: appgwSubnet
        apimSubnet: apimSubnet        
        jumpboxSubnet: jumpboxSubnet
        webServerSubnet: webServerSubnet
        gwSubnet: gwSubnet
        environment: environment
    }
}

module vpn './modules/gateway/vpn.bicep' = {
    name: 'vpn'
    params: {        
        location: resourceGroup().location
        name: concat('vpn-cloud-',environment,uniqueString(resourceGroup().id))
        subnetId: network.outputs.subnetGw
        publicIpName: 'pip-gw-cloud'
    }
}

module web './modules/webapp/webapp.bicep' = {
    name: 'web'
    dependsOn: [
        network
    ]
    params: {
        subnetId: network.outputs.webServerSubnetId
        environment: environment
    }    
}

module sql './modules/sql/sql.bicep' = {
    name: 'sql'
    params: {
        adminUsername: adminUsernameSql
        adminPassword: adminPasswordSql
        subnetId: network.outputs.webServerSubnetId
        vnetName: network.outputs.vnetname
        environment: environment
    }
}

module apim './modules/apim/apim.bicep' = {
    name: 'apim'
    dependsOn: [
        network  
    ]
    params: {
        publisherName: publisherName
        publisherEmail: publisherEmail
        subnetResourceId: network.outputs.subnetApim
        environment: environment
    }
}

// module apis './modules/apim/apis.bicep' = {
//     name: 'apis'
//     dependsOn: [
//         apim
//     ]
//     params: {
//         apimName: apim.name
//     }
// }

module dns './modules/dns/dns.bicep' = {
    name: 'dns'
    dependsOn: [
        apim
        network
    ]
    params: {
        dnsZoneName: hostname
        apimIpAddress: apim.outputs.apimPrivateIp
        vnetId: network.outputs.vnetId
        vnetName: vnetName
    }
}

module vault './modules/vault/keyvault.bicep' = {
    name: 'vault'
    dependsOn: [
        apim
    ]
    params: {
        principalAdminObjectId: principalAdminObjectId
        spIdentity: spIdentity
        apimIdentity: apim.outputs.apimIdentity
    }
}

module jumpbox './modules/compute/jumpbox.bicep' = {
    name: 'jumpbox'
    dependsOn: [
        network
    ]
    params: {
        adminUsername: adminUsername
        adminPassword: adminPassword
        subnetId: network.outputs.subnetJumpbox
    }
}

output gwSubnetId string = network.outputs.subnetAppGw
output apimSubnetCIDR string =  apimSubnet
output apiHostname string = 'api.${hostname}'
output identityId string = vault.outputs.userIdentityId
output vpnCloudId string = vpn.outputs.vpnId
