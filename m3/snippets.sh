 # ***********************************************************************************************
 #   Objective: This module provides the core concepts(API, multi-container) of Kubernetes in Azure. 
 # ***********************************************************************************************
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

 
#--> Create a single and multi container pod
kubectl create -f manifests/pod-example.yaml
kubectl create -f manifests/pod-multi-container-example.yaml

#--> View the labels with kubectl, there are no labels for pod-example 
kubectl get pods --show-labels

#--> Select pods based on labels  using equality and set based selectors 
kubectl get pods --selector environment=prod
kubectl get pods -l 'app in (nginx), environment in (prod)'

#--> Let us add labels 
kubectl label pod pod-example app=kuard environment=dev --overwrite
kubectl label pod multi-container-example app=nginx environment=staging --overwrite

 # *****************************
 #   SERVICE
 # *****************************

#-> Create a service based on the equality operator 
kubectl create -f manifests/service-clusterip.yaml

#-->Describe the newly created service. Note the IP and the Endpoints fields.
kubectl describe service clusterip

#-->Port foreward to pod-example and do a lookup for name "clusterip" 
#--> kubectl port-forward pod-example 8080:8080
kubectl get all

#--> Add a load balancer  ( this creates an Azure Lod Balancer)
#--> note Ensuring load balancer, Ensured load balancer
kubectl create -f manifests/service-loadbalancer.yaml

#--> Describe the load balancer service ( note the load balancer Ingress)
kubectl describe service nginx 

#-->Load the Ingres IP in browser http://<IP> (explain the output)

#-->Create an ExternalName service called externalname that points to google.com

kubectl create service externalname externalname --external-name=google.com

#--> Look at the generated DNS record has been created 
kubectl exec pod-example nslookup externalname.concepts.svc.cluster.local
#-->  If above command gives "nslookup: can't resolve '(null)': Name does not resolve"  do as shown below,
kubectl exec -it pod-example ash
#-->  Above command will give shell promt. Execute "nslookup" inside it as below,
~ $ nslookup externalname.concepts.svc.cluster.local
~ $ exit
#-->  command terminated with exit code 1

#  Call kubectl port-forward pod-example 8080:8080 and lookup DNS externalname

# Clean up
kubectl delete pod,svc --all
kubectl delete namespace concepts
# Verify
kubectl get all 
