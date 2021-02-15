param vnetName string
param vnetAddressSpace string
param appgwSubnet string
param apimSubnet string
param jumpboxSubnet string
param webServerSubnet string
param gwSubnet string

param principalAdminObjectId string
param spIdentity string

param onpremVnetAddressSpace string
param onpremGatewayAddressSpace string
param onpremWebAddressSpace string

param publisherName string
param publisherEmail string
param adminUsernameSql string {
    secure: true
}
param adminPasswordSql string {
    secure: true
}

param hostname string

param adminUsername string {
  secure: true
}
param adminPassword string {
  secure: true
}

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
    }
}

module vpn './modules/gateway/vpn.bicep' = {
    name: 'vpn'
    params: {
        location: resourceGroup().location
        name: concat('vpn-cloud-',uniqueString(resourceGroup().id))
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
    }    
}

module sql './modules/sql/sql.bicep' = {
    name: 'sql'
    params: {
        adminUsername: adminUsernameSql
        adminPassword: adminPasswordSql
        subnetId: network.outputs.webServerSubnetId
        vnetName: network.outputs.vnetname
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
    }
}

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
output webAppName string = web.outputs.webName
output todoWebUrl string = web.outputs.todoWebUrl
output todoApiName string = web.outputs.todoApiName