@description('Location for all resources.')
param location string = 'eastus'

@description('The name of the Azure Container Registry.')
param acrName string

@description('The SKU of the Azure Container Registry.')
@allowed([
  'Basic'
  'Standard'
  'Premium'
])
param acrSku string = 'Basic'

@description('The name of the Storage Account.')
param storageAccountName string

@description('The name of the Redis file share.')
param redisShareName string = 'redisdata'

@description('The name of the NodeBB build file share.')
param nodebbBuildShareName string = 'nodebbbuild'

@description('The name of the NodeBB uploads file share.')
param nodebbUploadsShareName string = 'nodebbuploads'

@description('The name of the NodeBB config file share.')
param nodebbConfigShareName string = 'nodebbconfig'

@description('The name of the Azure Container App environment.')
param containerAppEnvName string

resource acr 'Microsoft.ContainerRegistry/registries@2019-12-01-preview' = {
  name: acrName
  location: location
  sku: {
    name: acrSku
  }
  properties: {
    adminUserEnabled: true
  }
}

resource storageAccount 'Microsoft.Storage/storageAccounts@2019-06-01' = {
  name: storageAccountName
  location: location
  sku: {
    name: 'Standard_LRS'
  }
  kind: 'StorageV2'
  properties: {}
}

resource storageAccountName_default_redisShare 'Microsoft.Storage/storageAccounts/fileServices/shares@2019-06-01' = {
  name: '${storageAccountName}/default/${redisShareName}'
  properties: {
    shareQuota: 100
  }
  dependsOn: [
    storageAccount
  ]
}

resource storageAccountName_default_nodebbBuildShare 'Microsoft.Storage/storageAccounts/fileServices/shares@2019-06-01' = {
  name: '${storageAccountName}/default/${nodebbBuildShareName}'
  properties: {
    shareQuota: 100
  }
  dependsOn: [
    storageAccount
  ]
}

resource storageAccountName_default_nodebbUploadsShare 'Microsoft.Storage/storageAccounts/fileServices/shares@2019-06-01' = {
  name: '${storageAccountName}/default/${nodebbUploadsShareName}'
  properties: {
    shareQuota: 100
  }
  dependsOn: [
    storageAccount
  ]
}

resource storageAccountName_default_nodebbConfigShare 'Microsoft.Storage/storageAccounts/fileServices/shares@2019-06-01' = {
  name: '${storageAccountName}/default/${nodebbConfigShareName}'
  properties: {
    shareQuota: 100
  }
  dependsOn: [
    storageAccount
  ]
}

resource containerAppEnv 'Microsoft.App/managedEnvironments@2023-11-02-preview' = {
  name: containerAppEnvName
  location: location
  properties: {}
}

output acrLoginServer string = acr.properties.loginServer
output acrAdminUsername string = listCredentials(acr.id, '2019-12-01-preview').username
output acrAdminPassword string = listCredentials(acr.id, '2019-12-01-preview').passwords[0].value
