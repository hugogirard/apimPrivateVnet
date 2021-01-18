# What this github does

N/A

## Prerequisites

First step is to **Fork** this repository.

Here the tool you need installed on your machine.

- [Azure CLI](https://docs.microsoft.com/en-us/cli/azure/install-azure-cli)

- [Powershell](https://docs.microsoft.com/en-us/powershell/scripting/install/installing-powershell?view=powershell-7.1)

- Install the official [Powershell](https://github.com/rmbolger/Posh-ACME) **Let's Encrypt client**

Here the [list](https://letsencrypt.org/docs/client-options/) of all supported clients if you want to implement your own logic.

### Run this step if you don't have a SSL certificate

If you already have a SSL certificate you can just create the **Azure DNS Public Zone** and skip to **Create your Azure KeyVault Step** after.

<ol>
    <li>A domain registered in any domain provider like contoso.com</li>
    <li>A wildcard certificate like *.contoso.com*</li>
    <li>An Azure Keyvault with the certificate in it</li>
</ol>

If you don't have any certificate is possible to generate one using the provided powershell script in this repository.  You will still need the prerequisites **#1** and create an **Azure DNS Public Zone**.

You domain will need to be configured to use custom name servers **(Azure DNS Public zone)** to be able to work with this script.

Here the [Microsoft Doc](https://docs.microsoft.com/en-us/azure/dns/dns-getstarted-portal) that explains how to do this.

Once this is done, you will need to create a **service principal** that have access to your create **Azure DNS Public Zone**.

To create a service principal run the following command.

```Bash
$ az ad sp create-for-rbac --name ServicePrincipalName
```

Take note of the output you will need it later.

### Create your Azure Key Vault

Now is time to create you [Azure KeyVault](https://docs.microsoft.com/en-us/azure/key-vault/general/quick-create-portal).

Once is done upload your certificate into it.