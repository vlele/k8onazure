# ***************************************************************************************
#     Objective: This module demonstrates the SIDECAR PATTERN in Kubernetes in Azure.
# ***************************************************************************************
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

#--> Create namespace 'concepts' dev spaces if already not created
kubectl create namespace concepts

# Set context to "concepts"
kubectl config set-context $(kubectl config current-context) --namespace=concepts

# Use the context
kubectl config use-context $(kubectl config current-context)

# Cleanup
# run cleanup at the bottom of this file

 # *****************************
 #   SIDECAR PATTERN
 # *****************************

#--> Create a pod with side car
kubectl apply -f .\manifests\side-car.yaml  --namespace=concepts

#--> Describe
kubectl describe pod pod-with-sidecar

#--> Port forward to Pod port 
# http://localhost:8080/app.txt 
kubectl port-forward pod-with-sidecar 8080:80

# Connect to side-car pod
kubectl exec pod-with-sidecar -c sidecar-container -it bash

# Clean up 
kubectl delete namespace concepts

