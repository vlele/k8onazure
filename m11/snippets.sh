

 # *****************************
 #   AKS and RBAC
 # *****************************

# alias 
Set-Alias k kubectl 

# Set subscription, start cluster, get cluster credentials 
# Goto AIS Susbcription
 
# open a **WSL*** session
#TBD
kubectl config set-context $(kubectl config current-context) --namespace=istio-system

#use the context
kubectl config use-context $(kubectl config current-context)

#cleanup
# run cleanup at the bottom of this file
#-->get cluster credentials (** logon as admin)
##-->  Logon to AIS subsciption
##-->   PowerShell  cd C:\Users\vishw\OneDrive\code\aks-class\m11



#--> get pods
kubectl get pods

# Logon with podreader@appliedazure.onmicrosoft.com (pwm)

#-->  the following will fail 
kubectl get nodes 



 