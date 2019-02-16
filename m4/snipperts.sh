 # *****************************************************************************************************
 #   Objective: This module demonstrates the concept of REPLICASETS of Kubernetes in Azure.   
 # *****************************************************************************************************
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
 
# Set alias(optional) 
Set-Alias k kubectl

# Set context to "concepts"
kubectl config set-context $(kubectl config current-context) --namespace=concepts

# Use the context
kubectl config use-context $(kubectl config current-context)

# Cleanup
# run cleanup at the bottom of this file


#--> Create a replica set (in another window watch pods)
kubectl create -f manifests/rs-example.yaml
k get rs example-rs --watch

#--> Describe the pod and point out "Controlled By:  ReplicaSet/example-rs"
k get pods
k describe pod <pod-name>

#--> Delete a pod and see it recreated
k delete pod <pod-name>

#--> Scale up the replica count to 5
kubectl scale replicaset example-rs --replicas=5

#--> Describe the rs / point out the selector 
k describe rs example-rs

#--> Now if create a new pod (with the matching label) - this pod will be deleted 
kubectl create -f manifests/pod-rs-example.yaml

#--> Cleanup 
kubectl delete rs example-rs

 # *****************************
 #   DEPLOYMENTS
 # *****************************

#-->  Create a deployment (this will create deployment, replicaset and pods)
#-->  the --record flag saves the command as an annotation, and it can be thought of similar to a git commit message.
kubectl create -f manifests/deployment-example.yaml --record


#--> Describe the underlying rs (point out the controlled by field(
kubectl get rs 
kubectl describe rs deploy-example-<pod-template-hash>

#--> Scale the deployment (show the rollout status)
k scale deployments deploy-example --replicas=5

#-> Notice that rs is also scaled
kubectl describe rs deploy-example-<pod-template-hash>
 
#--> However scaling the rs does *not* have the same beahvior 
k scale rs deploy-example-<pod-template-hash> --replicas=7
k scale rs deploy-example-76f5db74bc --replicas=7

#-> Describe the deployment - show the two updates, show old and new replicasets
k describe deployments

#--> Show the deployment history
kubectl rollout history deployment deploy-example 

#--> Update a container image (revision 2)
kubectl apply -f manifests/rev1.yaml --record
kubectl rollout history deployment deploy-example

#--> Update a container image (revision 3)
kubectl apply -f manifests/rev2.yaml --record
kubectl rollout history deployment deploy-example

# Undo deployment ( rolling back to version=2)

# @@ NOTES @@   
# you can also pause and resume deployments
# caution - undo can out out of sync with the repo (this is why it may be better to apply a change rather than undo)

#--> Undo revision 
kubectl rollout undo deployments deploy-example --to-revision=2     

#--> Check the hisotry again (notice #2 is now #4 - renumbers to the latest version)
kubectl rollout history deployment deploy-example 

# @@ NOTES @@  Talk about 
      type: RollingUpdate | Recreate
      rollingUpdate:
      maxSurge: 1  #go beyond 100%)
      maxUnavailable: # max # of pods that can be impacted 
      minReadySeconds: 60   # must wait for 60 seconds before the next update
      progressDeadlineSeconds: 600 # deadline for timeout out deployment 

# Clean up
k delete deploy deploy-example
k delete namespace concepts













