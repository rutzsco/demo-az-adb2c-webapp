param location string = resourceGroup().location
param envName string
param appName string
param containerImage string
param containerPort int = 80
@secure()
param acrPassword string
param acrUsername string
param acrName string
param azureAdClientId string
param azureAdSignUpSignInPolicyId string
var stackname = '${appName}-${envName}'
var containerImageParts = split(containerImage, ':')

module law 'log-analytics.bicep' = {
	name: 'log-analytics-workspace'
	params: {
      location: location
      name: '${stackname}-law'
	}
}

module containerAppEnvironment 'aca-environment.bicep' = {
  name: 'container-app-environment'
  params: {
    name: stackname
    location: location
    
    lawClientId:law.outputs.clientId
    lawClientSecret: law.outputs.clientSecret
  }
}

module containerApp 'aca.bicep' = {
  name: 'container-app'
  params: {
    name: stackname
    location: location
    containerAppEnvironmentId: containerAppEnvironment.outputs.id
    containerImage: containerImage
    envVars: [
      {
        name: 'AzureAd__ClientId'
        value: azureAdClientId
      }
      {
        name: 'AzureAd__SignUpSignInPolicyId'
        value: azureAdSignUpSignInPolicyId
      }
      {
        name: 'APPLICATION_VERSION'
        value: containerImageParts[1]
      }
    ]
    useExternalIngress: true
    containerPort: containerPort
    acrPassword: acrPassword
    acrUsername: acrUsername
    acrName: acrName
  }
}

output fqdn string = containerApp.outputs.fqdn
