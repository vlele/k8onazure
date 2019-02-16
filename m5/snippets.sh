# ************************************************************************************************************
#    Objective: This module demonstrates the concepts DEAMONSETS, STATEFULSET  of Kubernetes in Azure.
# ************************************************************************************************************
# @@ NOTES @@   
# Summary: DaemonSets are usually used for important cluster-wide support services such as Pod Networking, 
# Additional Items
# Logging, or Monitoring. They differ from other workloads in that their scheduling bypasses normal mechanisms, and is centered around node placement. Like Deployments, they have their own pod-template-hash in the form of controller-revision-hash used for keeping track of Pod Template revisions and enabling rollback functionality.
# Taint and tolerations
# Kured  

 # *****************************
 #   DEAMONSETS
 # *****************************
##   Prerequisites:
#         	login.sh for getting the credentials 
#			"Subscription id": "<use-correct-subscription-id>"
#	   		"Resource Group": use "ais-aksclass-rg"
#			"Cluster name": use "aksclass-demo"
#	 Assumption: Assuming that the same Cluster created in m1 module is going to be shared by all the modules	
# 	 Cleanup: Make sure cleanup has been run
#    Set subscription, start cluster, get cluster credentials 

# Create namespace "concepts" if not already existing
kubectl create namespace concepts

 # Set Alias(optional) 
Set-Alias k kubectl

# Set subscription, start cluster, get cluster credentials 

# Set context to "concepts"
kubectl config set-context $(kubectl config current-context) --namespace=concepts

# Use the context
kubectl config use-context $(kubectl config current-context)

# Cleanup
# run cleanup at the bottom of this file

#--> Set the label to Edge 
kubectl label nodes <use-your-aks-node-name> --overwrite nodeType=Edge

#--> Get nodes (point out nodeType=Edge)
k get nodes --show-labels

#--> Change the label nodeType=test
kubectl label nodes <use-your-aks-node-name> --overwrite nodeType=test
k get nodes --show-labels

#--> Show ds-example.yaml and node selector 
kubectl create -f manifests/ds-example.yaml --record

#--> Show that no pods were created 
k get pods

#--> Change the node label and get pods agains
kubectl label nodes <use-your-aks-node-name> --overwrite nodeType=Edge

#--> Get nodes - pod should now be created
k get nodes

# Note that the deployed Pod has a controller-revision-hash label. This is used like the pod-template-hash in a Deployment to track and allow for rollback functionality.
kubectl get pods --show-labels

#--> Walk through the poperties of describe command 
kubectl describe ds ds-example

# Clean Up Command
kubectl delete ds ds-example


 # *****************************
 #   STATEFULSET
 # *****************************

#--> Create statefulset with update strategy onDelete
kubectl create -f manifests/sts-example.yaml

#--> Notice the pods being created in sequence
kubectl get pods --show-labels --watch

#--> Notice the persistent volume claims
k describe pvc

#--> Describe the statefulset
kubectl describe statefulset sts-example

#--> Change the label with OnDelete strategy
#-->update the labels 
#--> note that lable needs to be applied under template
# template:
#    metadata:
#      labels:
#        app: stateful
#        env: foo

kubectl edit sts sts-example --record

# Update the pod labels
       labels:
        app: stateful
        foo: bar 

#--> notice the labels are not changed
kubectl get pods --show-labels

#@@ NOTES @@
# The OnDelete Update Strategy will not spawn a new iteration of the Pod until the previous one was deleted. 
# This allows for manual gating the update process for the StatefulSet.
 
#-->Now delete one of the pod
# The new sts-example-2 Pod should be created with the new additional labels. 

kubectl delete pod sts-example-0
k get pod sts-example-0 --show-labels

#-->Delete the StatefulSet sts-example
kubectl delete statefulset sts-example

#-->View the Persistent Volume Claims.
# Created PVCs are NOT garbage collected automatically when a StatefulSet is deleted. They must be reclaimed independently of the StatefulSet itself.

kubectl get pvc


#-->in fact, Recreate the StatefulSet using the same manifest.
#-->Note that new PVCs were NOT provisioned. 
#-->The StatefulSet controller assumes if the matching name is present, that PVC is intended to be used for the associated Pod.

kubectl create -f manifests/sts-example.yaml --record

#View the Persistent Volume Claims again.
kubectl get pvc

 # *****************************
 #   HEADLESS SERVICE
 # *****************************

#--> Create a headless service in front of the STS
#-->Notice that it does not have a clusterIP, 
#-->but does have the Pod Endpoints listed. 
#-->Headless services are unique in this behavior.

kubectl apply -f manifests/service-sts-example.yaml

kubectl describe svc app


#--> Query the DNS entry for the app service. We will see three addresses 
kubectl exec sts-example-0 
#-->  Above command will give shell promt. Execute "nslookup" inside it as below,
~ $ nslookup sts-example-0.app.concepts.svc.cluster.local
~ $ exit
#--> Query one of instances directly. This is a unique feature to StatefulSets. This allows for services to directly 
#--> interact with a specific instance of a Pod. If the Pod is updated and obtains a new IP, the DNS record will 
#--> immediately point to it enabling consistent service discovery.
kubectl exec sts-example-0 nslookup sts-example-1.app.concepts.svc.cluster.local

#--> cleanup resurces 
kubectl delete svc app
kubectl delete statefulset sts-example
kubectl delete pvc www-sts-example-0 www-sts-example-1 www-sts-example-2


 # *****************************
 #   JOBS and CRONJOBS
 # *****************************

#--> create a job object and wacth the jobs being created
kubectl create -f manifests/job-example.yaml
kubectl get pods --show-labels --watch

## @@ NOTES @@ ##
# Only two Pods are being provisioned at a time; adhering to the parallelism attribute. 
# This is done until the total number of completions is satisfied. 
# Additionally, the Pods are labeled with controller-uid, this acts as a unique ID for that specific Job.
#When done, the Pods persist in a Completed state. They are not deleted after the Job is completed or failed. This is intentional to better support troubleshooting.

#--> describe the job object
kubectl describe job job-example

#-->Delete the job.
kubectl delete job job-example

#-->Create CronJob cronjob-example 
#--> It is configured to run the Job from the earlier example every minute, 
#--> using the cron schedule "*/1 * * * *". This schedule is UTC ONLY.

kubectl create -f manifests/cronjob-example.yaml

#-->Give it some time to run, and then list the Jobs.
kubectl get jobs

#-->The CronJob controller will purge Jobs according to the successfulJobHistoryLimit and failedJobHistoryLimit attributes. 

kubectl get cronjob cronjob-example
kubectl describe cronjob cronjob-example -v=8
#--> delete the cron job
kubectl delete cronjob cronjob-example

# Clean up
kubectl delete namespace concepts
