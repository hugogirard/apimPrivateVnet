param subnetId string
@secure()
param adminUsername string
@secure()
param adminPassword string

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
        }
        storageProfile: {
            imageReference: {
                publisher: 'MicrosoftWindowsServer'
                offer: 'WindowsServer'
                sku: '2019-Datacenter'
                version: 'latest'
            }
            osDisk: {
                name: concat('jumpbox','_OSDisk')
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
