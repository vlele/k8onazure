#******************************************************************************************
##     Objective: This module demonstrates the Azure Dev Spaces in Kubernetes in AKS. 
#******************************************************************************************
##   Prerequisites:
#    - User should be logged in to Azure CLI(Use Cmd: az login)
#    - User should have a AKS Cluster created already for this Demo with the below details:
#		"Subscription id": "<use-correct-subscription-id>"
#	   	"Resource Group": use "ais-aksclass-rg"
#		"Cluster name": use "aksclass-demo"
#	    [Assumptions: Assuming that the same Cluster created in m1 module is going to be shared by all the modules]	
#    - "aksclass-demo" cluster running and kubectl is executing commands against the same
#    - "aksclass-demo" cluster is  in East US/Central US/West US 2/West Europe/Canada Central/Canada East region
#    - Visual Studio Code latest version is installed
#    - Azure CLI version 2.0.43 or higher
# 	 - Cleanup: Make sure cleanup has been run in the previous demo and the namespace to be used in this is empty

# Set alias(optional)  
Set-Alias k kubectl

#--> Register DevSpace provider for Azure Dev Spaces 
az provider register --namespace Microsoft.DevSpaces

#--> Get credentials 
az aks get-credentials -g ais-aksclass-rg -n aksclass-demo   --overwrite

#--> Create 'azdevspace-dev-int' namespace for "Dev Integration Env". This will be used as parent namespace
kubectl create namespace azds-dev-int

#--> Use dev spaces
az aks use-dev-spaces -g ais-aksclass-rg -n aksclass-demo
#--> Azure Dev Spaces Controller' is created that targets 'aksclass-demo' in resource group 'ais-aksclass-rg'. 
#--> Continue? (y/N): y
#--> Creating and selecting Azure Dev Spaces Controller 'aksclass-demo' in resource group 'ais-aksclass-rg' that targets resource 'aksclass-demo' in resource group 'ais-aksclass-rg'...1m 40s
#--> Select a dev space or Kubernetes namespace to use as a dev space.
#-->  [1] default
#--> Type a number or a new name: azds-dev-int
#--> Dev space 'azds-dev-int' does not exist and will be created.
#--> Select a parent dev space or Kubernetes namespace to use as a parent dev space.
#-->  [0] <none>
#-->  [1] default
#--> Type a number: 0

# Note: After installing azds please close the PowerShell window and reopen the same as admin

#--> Check the dev spaces and make sure above selection is true
azds space list

#--> Optional: If 'azds-dev-int' dev spaces is not already selected select it as shown below:
azds space select --name azds-dev-int
#--> Kubernetes namespace 'azds-dev-int' will be configured as a dev space. This will enable Azure Dev Spaces 
#--> instrumentation for new workloads in the namespace. Continue? (Y/n): y

#--> Change directory to the 'webfrontend' code folder
cd .\m9\dev-spaces-master\samples\dotnetcore\getting-started\webfrontend

#--> Preapare the Charts, docker files ... for "webfrontend"
azds prep --public

#--> Build source code files, docker image and upload files for "webfrontend" into 'azds-dev-int'
azds up 
#--> Browse the given URL http://webfrontend.<xxx>.eastus2.aksapp.io/

#--> Change directory to the 'mywebapi' code folder
cd .\m9\dev-spaces-master\samples\dotnetcore\getting-started\mywebapi
azds prep --public
azds up 
#--> Browse the URL http://mywebapi.<yyy>.eastus2.aksapp.io/api/values/1

##
##  Dev Spaces Team Development Demo
##

#--> Check the dev spaces and make sure above selection is true
azds space list

#--> Use dev spaces for Team Development Demo:
az aks use-dev-spaces -g ais-aksclass-rg -n aksclass-demo
#--> Selecting Azure Dev Spaces Controller 'aksclass-demo' in resource group 'ais-aksclass-rg' that targets resource 
#--> 'aksclass-demo' in resource group 'ais-aksclass-rg'...<1s

#--> Select a dev space or Kubernetes namespace to use as a dev space.
#-->  [1] azds-dev-int
#-->  [2] default
#--> ...
#--> Type a number or a new name: azds-dev-int-me
#--> Dev space 'azds-dev-int-me' does not exist and will be created.
#--> Select a parent dev space or Kubernetes namespace to use as a parent dev space.
#-->  [0] <none>
#-->  [1] azds-dev-int
#-->  [2] default
#--> ...
#--> Type a number: 1

#--> Check the dev spaces and make sure above selection is true
azds space list

#--> Edit the file 'ValuesController.cs' in '...\mywebapi\Controllers' folder. Uncomment the code line for 
#--> 'Team Development Demo' and comment the one for 'Individual Development Demo'
#--> Build source code files, docker image and upload files for "webfrontend" into 'azds-dev-int-me' dev space
azds up -d
#--> Note down the URL (looks like 'http://azds-dev-int-me.s.mywebapi.<yyy>.eastus2.aksapp.io/') 
#--> from console output , append  '/api/values/1' to the URL, wait 2 mins, browse and check the response.

#--> Edit the file 'HomeController.cs' in '...\webfrontend\Controllers'. Uncomment the one for 'Team Development Demo'
#--> and comment the one for 'Individual Development Demo' and update the URL from previous step
azds up -d
#--> Note down the URL (looks like 'http://azds-dev-int-me.s.webfrontend.<xxx>.eastus.aksapp.io/') 
#--> from console output, wait 2 mins, browse and check the response.

#--> Delete the dev spaces
azds remove -g ais-aksclass-rg -n aksclass-demo
kubectl delete namespace azds-dev-int-me
kubectl delete namespace azds-dev-int