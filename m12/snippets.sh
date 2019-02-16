#***********************************************************************************************************
##      Objective: This module demonstrates the Istio, Prometheus, Grafana, Zipkin and Service Graph in AKS. 
#***********************************************************************************************************
##   Prerequisites:
#    - User should be logged in to PowerShell(Cmd: az login)
#    - User should have AKS Cluster created already for this Demo with the below details:
#	   "Resource Group": "ais-aksclass-rg"
#	   "Cluster name":    "aksclass-demo"
#	 Assumptions: 
#	 	Assuming that the same Cluster created in m1 module is going to be shared by all the modules	
#	 	Assuming that helm is installed in the local machine where 'kubectl' commands are being run		
#    - "aksclass-demo" cluster running and kubectl is executing commands against the same
#    - "aksclass-demo" cluster is in East US/Central US/West US 2/West Europe/Canada Central/Canada East region
#    - Visual Studio Code latest version is installed
#    - Azure CLI version 2.0.43 or higher
#    - Istio version "istio-1.0.4" is downloaded from https://github.com/istio/istio/releases/tag/1.0.4
#    - Set the PATH environment variable to path "..\m12\manifests\istio-1.0.4\bin\istioctl.exe"
# 	 - Cleanup: Cleanup has been run in the previous demo and the namespace to be used in this demo is empty

# Set alias(optional)  
Set-Alias k kubectl

kubectl create namespace istio-system

# Set the namespace to istio-system
kubectl config set-context $(kubectl config current-context)  --namespace istio-system

# Use the context
kubectl config use-context $(kubectl config current-context)

#--> Go to m12 module directory
cd .\m12

#--> Use the below steps for creating a Service Account for helm
kubectl create -f manifests/istio-1.0.4/install/kubernetes/helm/helm-service-account.yaml
helm init --upgrade --service-account tiller 

#--> Make sure the tiller pod is running  in kube-system namespace. 
kubectl get pods -o wide --all-namespaces | Select-String -Pattern "tiller"

#--> Use the below steps for installing the Istio, Prometheus, Grafana, Service Graph, Zipkin
helm install manifests/istio-1.0.4/install/kubernetes/helm/istio --name istio --namespace istio-system --set global.controlPlaneSecurityEnabled=true --set grafana.enabled=true --set tracing.enabled=true --set kiali.enabled=true --set servicegraph.enabled=true

#--> Make sure the istio pods are running  in istio-system namespace.  May take few minutes.
kubectl get pods -o wide --namespace istio-system

#--> Make sure that istio-injection is enabled in the default 
kubectl label namespace default istio-injection=enabled 

#--> Create a namespace "bookinfo"
kubectl create namespace bookinfo


#--> Enable Side Car Injection
kubectl label namespace bookinfo istio-injection=enabled

#--> Create a ingress gateway in the "bookinfo" namespace
kubectl apply -f .\manifests\istio-1.0.4\samples\bookinfo\networking\bookinfo-gateway.yaml --namespace=bookinfo

#--> Make sure you have the ingress gateway
kubectl get gateway --namespace=bookinfo

# Get the IP Address of the ingress gateway 
kubectl -n istio-system get service istio-ingressgateway -o jsonpath='{.status.loadBalancer.ingress[0].ip}’
#   '

# Create the booinfo app
kubectl apply -f .\manifests\istio-1.0.4\samples\bookinfo\platform\kube\bookinfo.yaml --namespace=bookinfo

#--> Wait for few minutes and make sure the istio pods are running in bookinfo namespace. 
kubectl get pods -o wide --namespace=bookinfo

# Create default destination rules for the Bookinfo services
kubectl apply -f manifests\istio-1.0.4\samples\bookinfo\networking\destination-rule-all-mtls.yaml --namespace=bookinfo

# Check the default destination rules
kubectl get destinationrules -o yaml --namespace=bookinfo

# Load the product page 
http://<External IP Address>/productpage
                 
#--> Apply rules to send all traffic to v1. Version v1 doesn’t call the ratings service. No stars to be seen.
kubectl apply -f manifests\istio-1.0.4\samples\bookinfo\networking\virtual-service-all-v1.yaml --namespace=bookinfo
# Load the product page  and check no stars are seen.
http://<External IP Address>/productpage

#--> Apply rules to send 50% traffic to v3.Version v3 calls ratings service. Displays each rating as 1 to 5 red stars.
kubectl apply -f manifests\istio-1.0.4\samples\bookinfo\networking\virtual-service-reviews-50-v3.yaml --namespace=bookinfo
# Load the product page. Check no stars are seen 50% times and 5 red stars are seen 50% times
http://<External IP Address>/productpage

#--> Apply rules to send all traffic to v3.Version v3 calls ratings service. Displays each rating as 1 to 5 red stars.
kubectl apply -f manifests\istio-1.0.4\samples\bookinfo\networking\virtual-service-reviews-v3.yaml --namespace=bookinfo
# Load the product page. Check 5 red stars are seen always
http://<External IP Address>/productpage

# Prometheus Dashboard for Querying Metrics:
kubectl -n istio-system port-forward $(kubectl -n istio-system get pod -l app=prometheus -o jsonpath='{.items[0].metadata.name}') 9090:9090
# Load http://localhost:9090/graph . Select "Graph" Tab and "http_requests_total" or "process_resident_memory_bytes" 
# from dropdown list. Refresh the bookinfo web page couple of times and see the updated graphs
http://localhost:9090/graph

# Execute the below command in PS to open the Istio Dashboard via the Grafana UI   
kubectl -n istio-system port-forward $(kubectl -n istio-system get pod -l app=grafana -o jsonpath='{.items[0].metadata.name}') 3000:3000
# Load http://localhost:3000 page and select Istio Workload/Service Dashboard or others and explore
http://localhost:3000

# Load Service Graph 
kubectl port-forward -n istio-system $(kubectl get pod -n istio-system -l app=kiali -o jsonpath='{.items[0].metadata.name}') 20001:20001
# Load http://localhost:20001 page. Log on with id=admin / pwd=admin. Click the "Graph" on left and see the call paths
http://localhost:20001

# Service Graph:
kubectl -n istio-system port-forward $(kubectl -n istio-system get pod -l app=servicegraph -o jsonpath='{.items[0].metadata.name}') 8088:8088
# Load http://localhost:8088/force/forcegraph.html in your web browser. Try clicking on a service to see details on the service. 
# Real time traffic data is shown in a panel below. 
http://localhost:8088/force/forcegraph.html
# Load http://localhost:8088/force/forcegraph.html?time_horizon=15s&filter_empty=true in your web browser. Note the query parameters provided.
http://localhost:8088/force/forcegraph.html?time_horizon=15s&filter_empty=true
# Load http://localhost:8088/dotviz is a static Graphviz visualization.
http://localhost:8088/dotviz

# Collect trace spans from Istio-enabled Apps:
kubectl port-forward -n istio-system $(kubectl get pod -n istio-system -l app=jaeger -o jsonpath='{.items[0].metadata.name}') 16686:16686
# load http://localhost:16686/productpage page and click "Find Traces"
http://localhost:16686/productpage

kubectl delete namespace bookinfo
helm del --purge istio
kubectl delete namespace istio-system


