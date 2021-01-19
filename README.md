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

Now go to the folder scripts, there you have a powershell called **letsEncrypt.ps1**.

This script will connect to your Azure Subscription passed in parameters and create a **TXT** challenge in your **Azure DNS Public Zone**.  

First run this command

```bash
$ Set-PAServer LE_PROD
```

Now with the information retrieved when you created the **service principal** you can create your certificate.

Be sure your **Service Principal** have access to modify your Azure Public DNS Zone.  If you want to use least priviledge refer to this [doc](https://github.com/rmbolger/Posh-ACME/blob/main/Posh-ACME/Plugins/Azure-Readme.md#create-a-custom-role).

```bash
$ .\letsEncrypt.ps1 -certNames *.contoso.com -acmeContact john@contoso.com -aZSubscriptionId <subId> -aZTenantId <tenantId> -aZAppUsername <sp_username> -aZAppPassword <sp_password> -pfxPassword <pfxPassword>
```

When the command is finished, a new folder called **pa** will be created inside the scripts folder.

If you browse in it inside the last child folder of **acme-v02.api.letsencrypt.org** you will see those files.

<img src="https://raw.githubusercontent.com/hugogirard/apimPrivateVnet/main/images/certificate.png">

### Upload your certificate in Azure Key Vault

Now upload you generated or existing certificate in Azure KeyVault.

Go to the certificates tabs in your Azure KeyVault

<img src="https://github.com/hugogirard/apimPrivateVnet/blob/main/images/certbutton.png?raw=true">

From there click the **Generate/Import** button and import your pfx files from your certificate.

Once the certificate is imported in KeyVault click on it.

You will find a textbox with the label Secret Identifier.

Copy the value from that textbox you will need to create a Github secret.

<img src="https://github.com/hugogirard/apimPrivateVnet/blob/main/images/identifier.png?raw=true" />


