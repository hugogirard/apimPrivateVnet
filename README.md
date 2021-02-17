# What this github does

<img src='https://github.com/hugogirard/apimPrivateVnet/blob/main/diagram/architecture.png?raw=true' />

## Prerequisites

First step is to **Fork** this repository.

Here the tool you need to installe on your machine.

- [Azure CLI](https://docs.microsoft.com/en-us/cli/azure/install-azure-cli)

- [Powershell](https://docs.microsoft.com/en-us/powershell/scripting/install/installing-powershell?view=powershell-7.1)

- Install the official [Powershell](https://github.com/rmbolger/Posh-ACME) **Let's Encrypt client**

- Dotnet 3.1 SDK

Here the [list](https://letsencrypt.org/docs/client-options/) of all supported clients if you want to implement your own logic for the **Let's Encrypt Certificate**.

### Create Azure DNS Public Zone

This demo is using Azure Public DNS Zone, you will need to have a domain that you own from any register.  Once is done you need to configure your DNS in your domain register with Azure DNS Public Zone entry.

It's all explain [here](https://docs.microsoft.com/en-us/azure/dns/dns-getstarted-portal).

### Run this step ONLY if you don't have a SSL certificate

Be sure you already configured your **Azure Public DNS Zone**.

First create a service principal running the following command.

```Bash
$ az ad sp create-for-rbac --name <ServicePrincipalName>
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

# Creating Azure Resources

## Step 1 - Create Github Secrets

To create the architecture and all Azure resources you need to setup some Github Secrets before.

Here the list of all Github secrets that need to create before running the Github Action.

| Secret Name          | Description                                           | Link
| ---------------------| ------------------------------------------------------| ---------
| ADMIN_VAULT_OBJECT_ID| This is the object ID of the super admin that you want to give access to KeyVault |
| PA_TOKEN             | You need to have a personnal access token to write secrets after running the first github action.  You can find the information (here)[https://docs.github.com/en/github/authenticating-to-github/creating-a-personal-access-token].  The PA needs the public_repo scope.  This is needed for this specific (github action)[https://github.com/gliech/create-github-secret-action]. |
| SP_AZURE_CREDENTIALS | Secret that contains the credential to run Az Login.  | (Action)[https://github.com/marketplace/actions/azure-login]
| PUBLISHER_NAME       | The publisher name associated to APIM                 |
| PUBLISHER_EMAIL      | The publisher email associated to APIM                |
| ADMIN_USERNAME_SQL   | The username admin for the SQL Azure Database         |
| ADMIN_PASSWORD_SQL   | The password for the SQL Azure Database               |
| HOSTNAME             | The hostname of your domain like contoso.com          |
| ADMIN_USERNAME       | The admin username of the Jumpbox and on prem VM      |
| ADMIN_PASSWORD       | The password of the Jumpbox and on prem VM            |
| SUBSCRIPTION_ID      | The subscription ID where to deploy the Az Resources  |
| SP_PRINCIPAL_OBJECT_ID | The object ID related to the SP that run the github action |
| SUBSCRIPTION_ID      | The subscription ID where you run the github action |
| SHARED_KEY           | The shared key needed for the VPN connection https://docs.microsoft.com/en-us/azure/vpn-gateway/vpn-gateway-howto-vnet-vnet-resource-manager-portal

## Step 2 - Run Github Action Deploy APIM Infra

Now go in the Actions Tab 

<img src='https://github.com/hugogirard/apimPrivateVnet/blob/main/images/actiontab.png?raw=true' />

Select **Deploy APIM Infra**

<img src='https://github.com/hugogirard/apimPrivateVnet/blob/main/images/deployApimInfra.png?raw=true' />

On the right menu click the **Run workflow** button and click the **Run workflow** green button.

<img src='https://github.com/hugogirard/apimPrivateVnet/blob/main/images/runWorkflow.png?raw=true' />

The Github action will take around 45 minutes to complete.  The Github action will create 3 new Github secrets needed to execute the next pipeline.

## Step 3 - Upload your certificate in Azure Key Vault

Now upload you generated or existing certificate in Azure KeyVault.

Go to the certificates tabs in your Azure KeyVault

<img src="https://github.com/hugogirard/apimPrivateVnet/blob/main/images/certbutton.png?raw=true">

From there click the **Generate/Import** button and import your pfx files from your certificate.

Once the certificate is imported in KeyVault click on it.

You will find a textbox with the label Secret Identifier.

Copy the value from that textbox you will need to create a Github secret.

<img src="https://github.com/hugogirard/apimPrivateVnet/blob/main/images/identifier.png?raw=true" />

Now you need to create a new **Github secrets** with the value copied before.  The name of the secret is **CERT_LINK**.

## Step 4 - Configure the Gateway of APIM

Next go to your API Management and custom domains

<img src='https://github.com/hugogirard/apimPrivateVnet/blob/main/images/domains.png?raw=true' />

Create a new hostname for the API Gateway related to your private DNS zone and select the certificate you uploaded in the KeyVault.

<img src='https://github.com/hugogirard/apimPrivateVnet/blob/main/images/vault.png?raw=true' />

Now retrieve the private IP of the Api Management

Go to your Azure Private DNS Zone and create a new A record entry

<img src='https://github.com/hugogirard/apimPrivateVnet/blob/main/images/privatedns.png?raw=true' />

## Step 5 - Run the next Github Action

Now you are ready to run the next **Github Action**, go back to Github Action and select **Deploy Application Gateway Infra** and run the worflow.

Once the Github Action is executed go to your Application Gateway and in the menu **Backend health**.  Be sure the Application Gateway can reach the APIM Gateway.

<img src='https://github.com/hugogirard/apimPrivateVnet/blob/main/images/backendhealth.png?raw=true' />

## Step 6 - Configure in Azure Public DNS the IP of Application Gateway

Get the public ip of the App GW and add a record in your **Azure Public DNS Zone**.

<img src='https://github.com/hugogirard/apimPrivateVnet/blob/main/images/publicdns.png?raw=true' />

Use the jumpbox to test the nslookup resolution like the example below.

<img src='https://github.com/hugogirard/apimPrivateVnet/blob/main/images/resolutionprivate.png?raw=true' />

Normally this should use the private IP

Now do a nslookup from your computer, this should use the public ip of the Application Gateway (it can take up to 24 hours to work depending of your DNS server).

<img src='https://github.com/hugogirard/apimPrivateVnet/blob/main/images/resolutionpublic.png?raw=true' />

# URL Scheme

Because end-to-end encryption is not done and the SSL stop at AppGW Level, when configure your API be sure to set the URL Scheme to both.

# Error during deploying KeyVault

If an error of Keyvault soft delete occurs when running the Github action this mean you have some keyvault pending because of the soft delete.

<img src='https://github.com/hugogirard/apimPrivateVnet/blob/main/images/errorVault.png?raw=true'/>

In this case you need to run those commands in the proper subscription using **Azure CLI**.

```
$ az keyvault list-deleted
$ az keyvault purge --name <name of the vault> 
```
