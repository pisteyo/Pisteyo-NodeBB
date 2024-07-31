# build nodebb from source and push both it and redis to ACR

# Get the deployment outputs
outputs=$(az deployment group show --resource-group pisteyo-apps --name adoption-app --query properties.outputs)

# Extract the ACR login server, username, and password
acrLoginServer=$(echo $outputs | jq -r '.acrLoginServer.value')
acrAdminUsername=$(echo $outputs | jq -r '.acrAdminUsername.value')
acrAdminPassword=$(echo $outputs | jq -r '.acrAdminPassword.value')

# Output the credentials
echo "ACR Login Server: $acrLoginServer"
echo "ACR Username: $acrAdminUsername"
echo "ACR Password: $acrAdminPassword"

# Login to ACR
echo $acrAdminPassword | docker login $acrLoginServer -u $acrAdminUsername --password-stdin

# Build, tag, and push NodeBB image
docker build -t nodebb:latest .
docker tag nodebb:latest $acrLoginServer/nodebb:latest
docker push $acrLoginServer/nodebb:latest

# Pull, tag, and push Redis image
docker pull redis:7.2.4-alpine
docker tag redis:7.2.4-alpine $acrLoginServer/redis:7.2.4-alpine
docker push $acrLoginServer/redis:7.2.4-alpine
