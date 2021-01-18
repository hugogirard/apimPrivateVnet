# What this github does

N/A

## Prerequisites

First step is to **Fork** this repository.

Here the tool you need to installe on your machine.

- [Azure CLI](https://docs.microsoft.com/en-us/cli/azure/install-azure-cli)

- [Powershell](https://docs.microsoft.com/en-us/powershell/scripting/install/installing-powershell?view=powershell-7.1)

- Install the official [Powershell](https://github.com/rmbolger/Posh-ACME) **Let's Encrypt client**

Here the [list](https://letsencrypt.org/docs/client-options/) of all supported clients if you want to implement your own logic.

### Create an Azure Key Vault ###

If you don't have an Azure Key Vault this is the first step, refer to the [Microsoft Doc](https://docs.microsoft.com/en-us/azure/key-vault/general/quick-create-portal) to create one.

### Create Azure DNS Public Zone

This demo is using Azure Public DNS Zone, you will need to have a domain that you own from any register.  Once is done you need to configure your DNS in your domain register with Azure DNS Public Zone entry.

It's all explain [here](https://docs.microsoft.com/en-us/azure/dns/dns-getstarted-portal).

### Run this step ONLY if you don't have a SSL certificate

Be sure you already configured **Azure Key Vault** and your **Azure Public DNS Zone**.

First create a service principal running the following command.

```Bash
$ az ad sp create-for-rbac --name ServicePrincipalName
```

Take note of the output you will need it to create Github Secrets.

Now go to 

### Create your Azure Key Vault

Now is time to create you [Azure KeyVault](https://docs.microsoft.com/en-us/azure/key-vault/general/quick-create-portal).

Once is done upload your certificate into it.