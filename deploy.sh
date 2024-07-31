# deploy from my container registry using docker compose

az containerapp compose create --resource-group pisteyo-apps \
    --environment pisteyocontainerappenv \
    --registry-server pisteyoacr.azurecr.io \
    --registry-username $(az acr credential show --name pisteyoacr.azurecr.io --query "username" -o tsv) \
    --registry-password $(az acr credential show --name pisteyoacr.azurecr.io --query "passwords[0].value" -o tsv) \
    --compose-file docker-compose-azure.yml
