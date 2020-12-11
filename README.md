# Create Azure AD application

To be able to run this demo you need to create 4 applications in Azure AD.

The first application is the WebApp client

The important files are **deployBase.ps1**, **deployappgwps1** and the two parameters files (json).

First enter all the proper values in deploy.parameters.json and run the script **deployBase.ps1** (the script has defaulted values for the parameters but they can be overwritten).

This should take around 45 minutes.

Once it is done, you will have a VNET, APIM, KeyVault, Private DNS Zone, Managed User Identity and a Linux Jumpbox.

Take note of the two outputs returned by the script.

Now connect to the Azure Portal

Go and upload your SSL certificate in the Azure KeyVault (you will need to give yourself the proper access policies).

![system schema](https://github.com/hugogirard/apimPrivateVnet/blob/main/images/policies.png)

Next go to your API Management and custom domains

![system schema](https://github.com/hugogirard/apimPrivateVnet/blob/main/images/domains.png)

Create a new hostname for the API Gateway related to your private DNS zone and select the certificate you uploaded in the KeyVault.

![system schema](https://github.com/hugogirard/apimPrivateVnet/blob/main/images/vault.png)

Now retrieve the private IP of the Api Management

Go to your Azure Private DNS Zone and create a new A record entry

![system schema](https://github.com/hugogirard/apimPrivateVnet/blob/main/images/privatedns.png)

Now fill all the parameters in the file appgw.parameters.json with the two values returned previously and the URL of your certificate (parameter certLink).

To find this go to your certificate in the keyvault and check the value of Secret Identifier.

![system schema](https://github.com/hugogirard/apimPrivateVnet/blob/main/images/secrets.png)

Now execute the script **deployappgw.ps1** passing the resource group as a parameter

Once it is done get the public ip of the App GW and add a record in your public DNS server.

![system schema](https://github.com/hugogirard/apimPrivateVnet/blob/main/images/publicdns.png)

Use the jumpbox to test the nslookup resolution like the example below.

![system schema](https://github.com/hugogirard/apimPrivateVnet/blob/main/images/resolutionprivate.png)

Normally this should use the private IP

Now do a nslookup from your computer, this should use the public ip of the Application Gateway (it can take up to 24 hours to work depending of your DNS server).

![system schema](https://github.com/hugogirard/apimPrivateVnet/blob/main/images/resolutionpublic.png)

** BE SURE WHEN YOU CONFIGURE API DEFINITION IN APIM TO SET THE URL SCHEME TO BOTH, RIGHT NOW NO END TO END SSL IS DONE AND THIS STOP AT APP GATEWAY. **


