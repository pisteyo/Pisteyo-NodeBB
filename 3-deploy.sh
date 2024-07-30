# deploy from my container registry using docker compose

source ./.env

az containerapp up --name $APP \
    --resource-group $GROUP \
    --environment $APP \
    --registry-login-server $REGISTRY.azurecr.io \
    --registry-username $(az acr credential show --name $REGISTRY --query "username" -o tsv) \
    --registry-password $(az acr credential show --name $REGISTRY --query "passwords[0].value" -o tsv) \
    --compose-file docker-compose-azure.yml
