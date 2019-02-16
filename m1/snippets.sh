##***************************************************************************************
##  Objective: This module builds the Task API sample and deploys it to the AKS cluster
##***************************************************************************************
##   Prerequisites:
#         	login.sh for getting the credentials 
#			"Subscription id": "<use-correct-subscription-id>"
#	   		"Resource Group": use "ais-aksclass-rg"
#			"Cluster name": use "aksclass-demo"
#			Make sure to create a Azure Container Registry(ACR) and use the registry as username, admin user access #           key as pwd to docker login to your registry
#			Make sure the nodes are running 
#			Make sure docker deamon is running
#			Switch to Linux containers 
#	 Assumption: Assuming that the same Cluster is going to be shared by all the modules		
# 	 Cleanup: Make sure cleanup is steps are run after the demo
#    Set subscription, start cluster, get cluster credentials 

# Set Alias(optional)
Set-Alias k kubectl

# Set context to "prod"
kubectl create namespace prod
kubectl config set-context $(kubectl config current-context) --namespace=prod

# Use the context
kubectl config use-context $(kubectl config current-context)

#--> Go to m1 module directory
cd .\m1

# Create a scratch directory under m1 
mkdir scratch
cd scratch 

# Clone
git clone https://github.com/vlele/aks
cd aks\aisazdevops-taskapi 

# Build the project
Open Visual Studio 2017 and build the solution and make sure the version is set to 1.0 (appsettings.json)
Build the project

# Clean up images
cd ..\aks-class
.\util\docker-clear.bat
docker images 

# Clean up images if some are still left e.g.,
docker image rm -f 48a877223f12 c43bd18d920e

# Build the docker image
# Make sure linux containers are selected 
cd .\m1\scratch\aks\aisazdevops-taskapi 
docker build -t taskapi-aspnetcore-v1.0.0 .

# Browse to Azure container registry  and delete any image with the "taskapi-aspnetcore:v1" name 
https://portal.azure.com/#@appliedis.com/resource/subscriptions/<subscription-id>/resourceGroups/<your-rg> /providers/Microsoft.ContainerRegistry/registries/<your-acr>/repository
# repository taskapi-aspnetcore 
# delete v1 

# Tag the image 
docker tag taskapi-aspnetcore-v1.0.0 <Log-in-server>/taskapi-aspnetcore:v1

# Logon to acr
az acr login --name <your-acr> 


# Show repositories and tags
az acr repository list --name <your-acr> --output table
az acr repository show-tags --name <your-acr> --repository taskapi-aspnetcore --output table

# Push the acr (created using the DevOps project)
docker push <Log-in-server>/taskapi-aspnetcore:v1

# Create a Kube secret
kubectl create secret docker-registry taskapiacrsecret --docker-server <Log-in-server> --docker-email <your-e-mail> --docker-username=<your-username> --docker-password <your-pwd> --namespace prod

# Go to m1 folder ..\m1 and edit pod.yaml at image: <Log-in-server>/taskapi-aspnetcore:v1
# Deploy a pod (directory to m1)
kubectl create -f pod.yml

# Port forard local 8080 to port 80 on the pod (via the master)
kubectl port-forward m1pod 8080:80

# Bring up the swagger file 
http://localhost:8080/swagger


# Cleanup 
# Clean all kube objects 
kubectl delete deployment,services,configmap,pods,secrets -l app=demo-taskapi;
kubectl delete secret taskapiacrsecret;
kubectl delete namespace prod
# kubectl delete configmap taskapi-aspnetcore-config-v1;
# kubectl delete pod m1pod