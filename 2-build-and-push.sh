# build nodebb from source and push both it and redis to ACR

source ./.env

# Log in to the ACR
az acr login --name $REGISTRY

# Build, tag, and push NodeBB image
docker build -t nodebb:latest .
docker tag nodebb:latest $REGISTRY.azurecr.io/nodebb:latest
docker push $REGISTRY.azurecr.io/nodebb:latest

# Pull, tag, and push Redis image
docker pull redis:7.2.4-alpine
docker tag redis:7.2.4-alpine $REGISTRY.azurecr.io/redis:7.2.4-alpine
docker push $REGISTRY.azurecr.io/redis:7.2.4-alpine