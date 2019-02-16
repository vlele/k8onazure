# k8onazure
There are 12 modules in this series of demos for AKS. The folder structure is given below:
"aks-class"
	|- Readme.txt  <-- This file provides the folder & file details
	|- az-basic-cmd.bat <-- This batch file is used for setting up PowerShell environment. 
	        [Step1: Execute above batch file with arg1=<subscription id>, arg2= eastus
			        arg1 - is the subscription id where AKS Cluster is created
					arg2 - is the location in Azure where AKS Cluster is created]
			[Note: Some lines(commented) are used for checking regions which supports 'Microsoft.ContainerService']
	|- create-aksclass-demo-cluster.ps1	<-- This PowerShell script file is used for creating AKS Cluster 
	        [Step2: Execute above batch file with arg1=eastus, arg2= 1.11.5
			        arg1 - is the location in Azure where AKS Cluster is created
					arg2 - is the version of Kubernetes in AKS Cluster ]			
	|- m1  - Build the Task API sample and deploy to the cluster
	|- m2  - core concepts (part 1)
	|- m3  - core concepts (part 2)
	|- m4  - workloads
	|- m5  - DeamonSets
	|- m6  - Mongo DB - Statefulset
	|- m7  - Side car pattern
	|- m8  - Windows Containers 
	|- m9  - Dev Spaces
	|- m10 - ACI, SVCCAT
	|- m11 - Azure AKS demos
	|- m12 - Istio,Prometheus,Grafana...
