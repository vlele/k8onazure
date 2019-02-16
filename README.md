# k8onazure
# There are 12 modules in this series of demos for AKS. The folder structure is given below:
## "aks-class"
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

	
# "az-basic-cmd.bat" file
It is executed in a powershell window in admin mode. It is used to login to azure and register necessary providers for AKS Cluster creation. Execute above batch file as below:
"Example: .\az-basic-cmd.bat <subscription id>, <location>"
> Note: 
* Please use location as 'East US'/'Central US'/'West US 2'/'West Europe'/'Canada Central'/'Canada East region'

# "create-aksclass-demo-cluster.ps1" file
This PS Script file is used for for creating an AKS Cluster.Execute '.\az-basic-cmd.bat' batch file first.
Example: .\create-aksclass-demo-cluster.ps1 <location>, <version>
> Notes:
* Allowed locations are 'East US'/'Central US'/'West US 2'/'West Europe'/'Canada Central'/'Canada East region'
* Please use version > 1.11.x"
