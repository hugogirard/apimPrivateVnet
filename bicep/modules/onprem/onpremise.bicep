
param vnetAddressSpace string
param vpnGwAddressSubnet string
param winServerAddressSubnet string
param apimPrivateIp string
param adminUsername string
param adminPassword string

var suffix = uniqueString(resourceGroup().id)
var nicName = concat('nic-',suffix)
var vnetName = 'onprem-vnet'
var vpnGatewaySubnet = 'gatewaySubnet'
var winServerSubnet = 'webSubnet'
var location = resourceGroup().location
var vmName = 'win1api'



resource nsg 'Microsoft.Network/networkSecurityGroups@2020-05-01' = {
  name: 'nsg-webapi'
  location: location
  properties: {
    securityRules: [
      {
        name: 'default-allow-80'
        properties: {
          priority: 1000
          access: 'Allow'
          direction: 'Inbound'
          destinationPortRange: '80'
          protocol: 'Tcp'
          sourceAddressPrefix: apimPrivateIp
          sourcePortRange: '*'
          destinationAddressPrefix: '*'
        }        
      }
    ]
  }
}

resource vnet 'Microsoft.Network/virtualNetworks@2020-06-01' = {
  name: vnetName
  location: location
  dependsOn: [
    nsg
  ]
  properties: {
      addressSpace: {
          addressPrefixes: [
              vnetAddressSpace
          ]
      }
      subnets: [
          {
              name: vpnGatewaySubnet
              properties: {
                  addressPrefix: vpnGwAddressSubnet
              }
          }
          {
              name: winServerSubnet
              properties: {
                  addressPrefix: winServerAddressSubnet
                  networkSecurityGroup: {
                    id: nsg.id
                  }
              }
          }
      ]
  }
}

resource nic 'Microsoft.Network/networkInterfaces@2020-05-01' = {
  name: nicName
  location: location
  dependsOn: [
    vnet
  ]
  properties: {
    ipConfigurations: [
      {
        name: 'webipconfig'
        properties: {
          privateIPAllocationMethod: 'Dynamic'
          subnet: {
            id: vnet.properties.subnets[1].id
          }
        }
      }
    ]
  }
}

resource vm 'Microsoft.Compute/virtualMachines@2019-12-01' = {
  name: vmName
  location: location
  dependsOn: [
    nic
  ]
  properties: {
    hardwareProfile: {
      vmSize: 'Standard_D2s_v3'
    }
    osProfile: {
      computerName: vmName
      adminUsername: adminUsername
      adminPassword: adminPassword
    }
    storageProfile: {
      imageReference: {
        publisher: 'MicrosoftWindowsServer'
        offer: 'WindowsServer'
        sku: '2019-Datacenter'
        version: 'latest'
      }
      osDisk: {
        name: concat(vmName,'_OSDisk')
        caching: 'ReadWrite'
        createOption: 'FromImage'
        managedDisk: {
          storageAccountType: 'Premium_LRS'
        }
      }
    } 
    networkProfile: {
      networkInterfaces: [
        {
          id: nic.id
        }
      ]
    }  
  }
}

// resource extension 'Microsoft.Compute/virtualMachines/extensions@2019-12-01' = {
//   name: concat(vmName,'/','dscExtension')
//   location: location
//   dependsOn: [
//     vm
//   ]
//   properties: {
//     publisher: 'Microsoft.Powershell'
//     type: 'DSC'
//     typeHandlerVersion: '2.19'
//     autoUpgradeMinorVersion: true
//     settings: {
//       ModulesUrl: 'ContosoWebsite.ps1.zip'
//       ConfigurationFunction: 'ContosoWebsite.ps1\\ContosoWebsite'
//       Properties: {
//         MachineName: vmName
//       }
//     }
//   }
//}