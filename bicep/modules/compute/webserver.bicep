param adminUsername string
param adminPassword string
param webSubnetId string

var suffix = uniqueString(resourceGroup().id)
var nicName = concat('nic-',suffix)
var vnetName = 'onprem-vnet'
var location = resourceGroup().location
var vmName = 'win1api'

resource pip 'Microsoft.Network/publicIPAddresses@2020-06-01' = {
  name: 'webserver-pip'
  location: location
  properties: {
      publicIPAllocationMethod: 'Dynamic'
  }
  sku: {
      name: 'Basic'
  }
}

resource nic 'Microsoft.Network/networkInterfaces@2020-05-01' = {
  name: nicName
  location: location
  dependsOn: [
    pip
  ]
  properties: {
    ipConfigurations: [
      {
        name: 'webipconfig'
        properties: {
          privateIPAllocationMethod: 'Dynamic'
          publicIPAddress: {
            id: pip.id
          }
          subnet: {
            id: webSubnetId
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