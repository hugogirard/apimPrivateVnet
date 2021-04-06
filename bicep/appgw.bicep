param gwSubnetId string
param certLink string
param apiGwHostname string
param devPortalFqdn string
param identityId string

var suffix = uniqueString(resourceGroup().id)
var location = resourceGroup().location
var appgwName = concat('appgwprv-',suffix)

resource pip 'Microsoft.Network/publicIPAddresses@2020-06-01' = {
    name: 'gwpip'
    location: location
    sku: {
        name: 'Standard'
    }
    properties: {
        publicIPAddressVersion: 'IPv4'
        publicIPAllocationMethod: 'Static'
        idleTimeoutInMinutes: 4
    }
}

resource appgw 'Microsoft.Network/ApplicationGateways@2020-06-01' = {
    name: appgwName
    location: location
    dependsOn: [
        pip
    ]
    identity: {
        type: 'UserAssigned'
        userAssignedIdentities: {
            '${identityId}': {}
        }
    }
    properties: {
        sku: {
            name: 'WAF_v2'
            tier: 'WAF_v2'
            capacity: 2            
        }
        gatewayIPConfigurations: [
            {
                name: 'appGatewayConfig'
                properties: {
                    subnet: {
                        id: gwSubnetId
                    }
                }
            }
        ]
        sslCertificates: [
            {
                name: 'httpListener'
                properties: {
                    keyVaultSecretId: certLink
                }
            }
        ]
        trustedRootCertificates: []
        frontendIPConfigurations: [
            {
                name: 'appGwPublicFrontendIp'
                properties: {
                    privateIPAllocationMethod: 'Dynamic'
                    publicIPAddress: {
                        id: pip.id
                    }
                }
            }
        ]
        frontendPorts: [
            {
                name: 'port_443'
                properties: {
                    port: 443
                }
            }
        ]
        backendAddressPools: [
            {
                name: 'apiGatewayPool'
                properties: {
                    backendAddresses: [
                        {
                            fqdn: apiGwHostname
                        }
                    ]
                }
            }
            {
                name: 'devPortalPool'
                properties: {
                    backendAddresses: [
                        {
                            fqdn: devPortalFqdn
                        }
                    ]
                }
            }
        ]
        backendHttpSettingsCollection: [
            {
                name: 'apiGWHttpsSettings'
                properties: {
                    port: 443
                    protocol: 'Https'
                    cookieBasedAffinity: 'Disabled'
                    pickHostNameFromBackendAddress: false
                    requestTimeout: 20
                    probe: {
                        id: resourceId('Microsoft.Network/applicationGateways/probes',appgwName,'appGwProbe')
                    }
                }
            }
            {
                name: 'devPortalHttpsSettings'
                properties: {
                    port: 443
                    protocol: 'Https'
                    cookieBasedAffinity: 'Disabled'
                    pickHostNameFromBackendAddress: false
                    requestTimeout: 20
                    probe: {
                        id: resourceId('Microsoft.Network/applicationGateways/probes',appgwName,'devPortalProbe')
                    }
                }
            }            
        ]
        httpListeners: [
            {
                name: 'httpListener'
                properties: {
                    frontendIPConfiguration: {
                        id: resourceId('Microsoft.Network/applicationGateways/frontendIPConfigurations', appgwName, 'appGwPublicFrontendIp')
                    }
                    frontendPort: {
                        id: resourceId('Microsoft.Network/applicationGateways/frontendPorts',appgwName,'port_443')
                    }
                    sslCertificate: {
                        id: resourceId('Microsoft.Network/applicationGateways/sslCertificates',appgwName,'httpListener')
                    }
                    hostName: apiGwHostname
                    protocol: 'Https'
                    requireServerNameIndication: true
                }
            }
            {
                name: 'portalListener'
                properties: {
                    frontendIPConfiguration: {
                        id: resourceId('Microsoft.Network/applicationGateways/frontendIPConfigurations', appgwName, 'appGwPublicFrontendIp')
                    }
                    frontendPort: {
                        id: resourceId('Microsoft.Network/applicationGateways/frontendPorts',appgwName,'port_443')
                    }
                    sslCertificate: {
                        id: resourceId('Microsoft.Network/applicationGateways/sslCertificates',appgwName,'httpListener')
                    }
                    hostName: devPortalFqdn
                    protocol: 'Https'
                    requireServerNameIndication: true
                }
            }            
        ]
        requestRoutingRules: [
            {
                name: 'gatewayRule'
                properties: {
                    ruleType: 'Basic'
                    httpListener: {
                        id: resourceId('Microsoft.Network/applicationGateways/httpListeners',appgwName,'httpListener')
                    }
                    backendAddressPool: {
                        id: resourceId('Microsoft.Network/applicationGateways/backendAddressPools',appgwName,'apiGatewayPool')
                    }
                    backendHttpSettings: {
                        id: resourceId('Microsoft.Network/applicationGateways/backendHttpSettingsCollection',appgwName,'apiGWHttpsSettings')
                    }
                }
            }
            {
                name: 'devPortalRule'
                properties: {
                    ruleType: 'Basic'
                    httpListener: {
                        id: resourceId('Microsoft.Network/applicationGateways/httpListeners',appgwName,'portalListener')
                    }
                    backendAddressPool: {
                        id: resourceId('Microsoft.Network/applicationGateways/backendAddressPools',appgwName,'devPortalPool')
                    }
                    backendHttpSettings: {
                        id: resourceId('Microsoft.Network/applicationGateways/backendHttpSettingsCollection',appgwName,'devPortalHttpsSettings')
                    }
                }
            }                     
        ]
        probes: [
            {
                name: 'appGwProbe'
                properties: {
                    protocol: 'Https'
                    host: apiGwHostname
                    path: '/status-0123456789abcdef'
                    interval: 30
                    timeout: 30
                    unhealthyThreshold: 3
                    pickHostNameFromBackendHttpSettings: false
                    minServers: 0
                    match: {}
                }
            }
            {
                name: 'devPortalProbe'
                properties: {
                    protocol: 'Https'
                    host: devPortalFqdn
                    path: '/internal-status-0123456789abcdef'
                    interval: 30
                    timeout: 30
                    unhealthyThreshold: 3
                    pickHostNameFromBackendHttpSettings: false
                    minServers: 0
                    match: {}
                }
            }            
        ]
        enableHttp2: false
        webApplicationFirewallConfiguration: {
            enabled: true
            firewallMode: 'Prevention'
            ruleSetType: 'OWASP'
            ruleSetVersion: '3.1'
            requestBodyCheck: true
            maxRequestBodySizeInKb: 128
            fileUploadLimitInMb: 100
            disabledRuleGroups: [
                {
                    ruleGroupName: 'REQUEST-942-APPLICATION-ATTACK-SQLI'
                    rules: [                        
                        942200
                        942100
                        942110
                        942180
                        942260
                        942340
                        942370
                        942430
                        942440                        
                    ]
                }
                {
                    ruleGroupName: 'REQUEST-920-PROTOCOL-ENFORCEMENT'
                    rules: [                        
                        920300
                        920330                     
                    ]
                }   
                {
                    ruleGroupName: 'REQUEST-931-APPLICATION-ATTACK-RFI'
                    rules: [                        
                        931130                                             
                    ]
                }                                    
            ]
        }
    }
}
