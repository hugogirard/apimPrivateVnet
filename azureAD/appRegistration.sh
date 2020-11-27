#!/bin/bash
#!/bin/bash

# Create all the app in Azure AD
API_TODO=$(az add app create --display-name todoapi --identifier-uris https://todoapi)

# Get the app id
APP_ID=$(echo $API_TODO | jq -r '.appId')

# Create new scopes from file 'oath2-permissions'
az ad app update --id $APP_ID --set oauth2Permissions=@todoApi.json





