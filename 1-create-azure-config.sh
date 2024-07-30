# script to bootstrap the Azure resources necessary for the Pisteyo Adoption app

source ./.env

# Create a resource group
az group create --name $GROUP --location $LOCATION

az storage account create --name $STORAGE --resource-group $GROUP --location $LOCATION --sku Standard_LRS
az storage share create --account-name $STORAGE --name redisdata
az storage share create --account-name $STORAGE --name nodebbbuild
az storage share create --account-name $STORAGE --name nodebbuploads
az storage share create --account-name $STORAGE --name nodebbconfig

# Create an Azure Container Registry
az acr create --resource-group $GROUP --name $REGISTRY --sku Basic

# Create a Azure Container Environment
az containerapp env create --name $APP --resource-group $GROUP --location $LOCATION

# Get ACR credentials
acr_username=$(az acr credential show --name $REGISTRY --query "username" -o tsv)
acr_password=$(az acr credential show --name $REGISTRY --query "passwords[0].value" -o tsv)

# Output the credentials
echo "ACR Username: $acr_username"
echo "ACR Password: $acr_password"
