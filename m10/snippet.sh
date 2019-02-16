#***************************************************************************************
#      Objective: This module demonstrates the VIRTUAL KUBELET ACI in AKS. 
#***************************************************************************************
##   Prerequisites:
#         	login.sh for getting the credentials 
#			"Subscription id": "<use-correct-subscription-id>"
#	   		"Resource Group": use "ais-aksclass-rg"
#			"Cluster name": use "aksclass-demo"
#	 Assumptions: 
#	 	Assuming that the same Cluster created in m1 module is going to be shared by all the modules	
#	 	Assuming that helm 1.11.0 is installed in the local machine where 'kubectl' commands are being run	
# 	 Cleanup: Make sure cleanup has been run
#    Set subscription, start cluster, get cluster credentials 

#--> Set Alias(optional)  
Set-Alias k kubectl

#--> Go to m10 module directory
cd ..
cd .\m10
az aks get-credentials --resource-group ais-aksclass-rg --name aksclass-demo  --overwrite

#--> View Dashboard
kubectl create clusterrolebinding kubernetes-dashboard --clusterrole=cluster-admin --serviceaccount=kube-system:kubernetes-dashboard

az aks browse --resource-group ais-aksclass-rg --name aksclass-demo

#--> Create namespace "osba"
kubectl create namespace osba

#-->Set context to "osba"
kubectl config set-context $(kubectl config current-context) --namespace=osba

#-->Use the context
kubectl config use-context $(kubectl config current-context)

#--> Cleanup
# run cleanup at the bottom of this file

#--> Register providers needed for AKS cluster
az provider register -n Microsoft.ContainerInstance
az provider register -n Microsoft.ContainerService

#--> AKS cluster is RBAC-enabled, we must create a service account and role binding for use with Tiller. 
kubectl apply -f manifests\rbac-virtual-kubelet.yaml

#--> Check all pods in AKS cluster 
kubectl get pods -o wide --all-namespaces 

#--> Check that we have a Service Account("tiller") in the cluster. 
kubectl get serviceAccounts --all-namespaces

#--> Configure Helm to use the tiller service account 
helm init --upgrade --service-account tiller

#--> Update Helm repo
helm repo update

#-->Install the ACI connector for both OS types 
az aks install-connector -g ais-aksclass-rg -n aksclass-demo --connector-name virtual-kubelet --os-type both      

#--> Check all pods again and see that two pods with names starting with "virtual-kubelet-..." exists in AKS cluster 
kubectl get pods -o wide --all-namespaces

#--> List all nodes (notice the ACI nodes)
kubectl get nodes 

#--> Note down virtual ACI nodes and edit the below node in the following files in "..\aks-class\m6\manifests\" folder ,
#-->   nodeSelector:
#-->         kubernetes.io/hostname: 
#--> File1: "virtual-kubelet-linux-nginx.yaml" <-- virtual-kubelet-virtual-kubelet-linux-eastus  
#--> File2: "virtual-kubelet-windows-phpiis-ltsc2016.yaml" <-- virtual-kubelet-virtual-kubelet-windows-eastus 

#--> Deploy pods 
kubectl create -f manifests/virtual-kubelet-windows-phpiis-ltsc2016.yaml
kubectl create -f manifests/virtual-kubelet-linux-nginx.yaml

#--> Check all pods again and see that two pods with names starting with "nginx-deployment-..."
#--> and "php-iislatest2-6..." are created in the cluster 
kubectl get pods -o wide --all-namespaces

#--> Clean up
kubectl delete -f manifests/virtual-kubelet-windows-phpiis-ltsc2016.yaml
kubectl delete -f manifests/virtual-kubelet-linux-nginx.yaml
kubectl delete -f manifests\rbac-virtual-kubelet.yaml

#--> Remove connector 
az aks remove-connector --resource-group ais-aksclass-rg --name aksclass-demo --connector-name virtual-kubelet --os-type windows 
az aks remove-connector --resource-group ais-aksclass-rg --name aksclass-demo --connector-name virtual-kubelet --os-type linux

##
##   Open Service Broker
##
#--> Get service principal that has rights on the subscription we want to create resources
az ad sp create-for-rbac --name osba-quickstart -o table
#-->Sample output: 
#--> Changing "osba-quickstart" to a valid URI of "http://osba-quickstart", which is the required format ...
#-->  AppId    DisplayName             Name            Password    Tenant
#--> -------- ---------------  ----------------------  --------  -----------
#--> <sp-id>  osba-quickstart  http://osba-quickstart  <sp-pwd>  <tenant-id>

helm repo add svc-cat https://svc-catalog-charts.storage.googleapis.com

#--> Install svc-cat/catalog
helm install svc-cat/catalog --name catalog --namespace catalog --set apiserver.storage.etcd.persistence.enabled=true --set apiserver.healthcheck.enabled=false --set controllerManager.healthcheck.enabled=false --set apiserver.verbosity=2 --set controllerManager.verbosity=2

#--> Check the catalog installation
kubectl get pods --namespace catalog

#--> Deploy Open Service Broker for Azure. First, we need to add the repo
helm repo add azure https://kubernetescharts.blob.core.windows.net/azure

#--> Second, assign the env variables values received in the output of line no. 91
$env:AZURE_TENANT_ID = "<tenant-id>"
$env:AZURE_CLIENT_ID = "<sp-id>"
$env:AZURE_CLIENT_SECRET = "<sp-pwd>"
$env:AZURE_SUBSCRIPTION_ID = "<subscription-id>"

#--> third, install service broker
helm install azure/open-service-broker-azure --name osba --namespace osba --set azure.subscriptionId=$env:AZURE_SUBSCRIPTION_ID --set azure.tenantId=$env:AZURE_TENANT_ID --set azure.clientId=$env:AZURE_CLIENT_ID --set azure.clientSecret=$env:AZURE_CLIENT_SECRET

#--> Check the catalog installation. This is going to take "2-3" mins time
kubectl get pods --namespace osba

#--> Now we have a cluster with Open Service Broker for Azure, we can deploy WordPress to Kubernetes and OSBA will 
#--> handle provisioning an Azure Database for MariaDB and binding it to our WordPress installation

#--> Create namespace for  WordPress installation
kubectl create namespace osba-quickstart

#--> Install WordPress in osba-quickstart namespace
helm install stable/wordpress --name osba-quickstart --namespace osba-quickstart

#--> Get deployments
kubectl  get deployments

#--> Use the following command to tell when WordPress is ready. This step will take 40 mins
kubectl get deploy osba-quickstart-wordpress -n osba-quickstart -w

#--> List plans available
.\svcat.exe get plans 

#--> List classes available
.\svcat.exe get classes 

#--> List the binding configured for the namespace wordpress
.\svcat.exe get bindings -n wordpress

#--> List the brokers available
.\svcat.exe get brokers

#--> Check the services of wordpress and get IP Address of the WordPress Server
kubectl get svc -n osba-quickstart

#--> Create URL and browse, "http://<ip-wordPress-server>/admin" after replacing the IP from above step

#--> Get Password for the WordPress Server
kubectl get secret osba-quickstart-wordpress -n osba-quickstart -o jsonpath="{.data.wordpress-password}"

#--> Decode Password @URL:"https://www.base64decode.org/".Paste the encoded string and choose UTF-8 as Source charset
#--> Log into URL , "http://<ip-wordPress-server>/admin"  using Id: "user" and Password: "<decoded-string>"

#--> Cleanup  osba-quickstart
helm delete osba-quickstart --purge

#--> Azure Identity 
#--> Set context to "default"
kubectl config set-context $(kubectl config current-context) --namespace=default

#--> Use the context
kubectl config use-context $(kubectl config current-context)


#--> Deploy components in default
kubectl create -f manifests\component-deployment.yaml

#--> 
kubectl create -f manifests\aadpodidentity.yaml

#-->
kubectl create -f manifests\aadpodidentitybinding.yaml

#-->
kubectl create -f manifests\deployment.yaml 

#--> Get the logs (ARM call succeeds)
kubectl create -f manifests\deployment_Fail.yaml

#--> Get the logs will fail. Check the Logs for demo1. The log entries will be like below:
#--> forbidden: User \"system:serviceaccount:default:default\" cannot list pods at the cluster scope\n"...

# Delete objects created in default
kubectl delete -f manifests\aadpodidentity.yaml
kubectl delete -f manifests\component-deployment.yaml
kubectl delete -f manifests\deployment.yaml 
kubectl delete -f manifests\deployment_Fail.yaml
kubectl delete namespace osba
kubectl delete namespace osba-quickstart

 



