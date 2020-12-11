param subnetId string
param adminUsername string {
  secure: true
}
param adminPassword string {
  secure: true
}

var location = resourceGroup().location

resource pip 'Microsoft.Network/publicIPAddresses@2020-06-01' = {
    name: 'jumpboxpip'
    location: location
    properties: {
        publicIPAllocationMethod: 'Dynamic'
    }
    sku: {
        name: 'Basic'
    }
}

resource nic 'Microsoft.Network/networkInterfaces@2020-06-01' = {
    name: 'jumpnic'
    location: location
    dependsOn: [
        pip
    ]
    properties: {
        ipConfigurations: [
            {
                name: 'ipconfig'
                properties: {
                    privateIPAllocationMethod: 'Dynamic'
                    publicIPAddress: {
                        id: pip.id
                    }
                    subnet:{
                        id: subnetId
                    }
                }
            }
        ]
    }
}

resource jumpbox 'Microsoft.Compute/virtualMachines@2020-06-01' = {
    name: 'jumpbox'
    location: location
    dependsOn: [
        pip
        nic
    ]
    properties: {
        hardwareProfile: {
            vmSize: 'Standard_B1ms'
        }
        osProfile: {
            computerName: 'jumpbox'
            adminUsername: adminUsername
            adminPassword: adminPassword
            linuxConfiguration: {
                disablePasswordAuthentication: false
            }            
        }
        storageProfile: {
            imageReference: {
                publisher: 'Canonical'
                offer: 'UbuntuServer'
                sku: '18.04-LTS'
                version: 'latest'
            }
            osDisk: {
                createOption: 'FromImage'
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