 # *******************************************************************************************
 #    Objective: This module demonstrates the MONGO DB as a STATEFULSET in Kubernetes in Azure.
 # *******************************************************************************************
 ##   Prerequisites:
#         	login.sh for getting the credentials 
#			"Subscription id": "<use-correct-subscription-id>"
#	   		"Resource Group": use "ais-aksclass-rg"
#			"Cluster name": use "aksclass-demo"
#	 Assumption: Assuming that the same Cluster created in m1 module is going to be shared by all the modules	
# 	 Cleanup: Make sure cleanup has been run
#    Set subscription, start cluster, get cluster credentials 

# Set alias(optional) 
Set-Alias k kubectl

# Create namespace "concepts" if not already existing
kubectl create namespace concepts

# Set context to "concepts"
kubectl config set-context $(kubectl config current-context) --namespace=concepts

# Use the context
kubectl config use-context $(kubectl config current-context)

# Cleanup
# run cleanup at the bottom of this file

kubectl apply -f manifests/mongo-configmap.yaml 
kubectl apply -f manifests/mongo-service.yaml 
kubectl apply -f manifests/mongo.yaml

#--> Browse Dashboard 
az aks browse --resource-group ais-aksclass-rg --name aksclass-demo

#--> Execute a shell command inside mongo-0 pod
kubectl exec -it mongo-0 ls

kubectl describe pod/mongo-0 -n concepts

kubectl cluster-info 

# Clean up (takes a while)
kubectl delete namespace concepts
