###
###  Install the Service Broker and OSBA
###

# check if healthy
svcat get brokers

# purge the catalog 
helm delete catalog --purge

#purge the osba 
helm delete osba --purge 

#install the svc-catalog 
helm install svc-cat/catalog --name catalog --namespace catalog --set rbacEnable=false --set controllerManager.healthcheck.enabled=false

# Ceate a new Service Principal 
az ad sp create-for-rbac

#Note the ClientId, Password and Tenant Id from the output of this command
 
helm install azure/open-service-broker-azure --name osba --namespace osba --set azure.subscriptionId=0d4f44f5-e032-49de-ba6c-86dcf4201a31 --set azure.tenantId=f32b97f0-efb8-4bc3-91ee-18a6e5f635c9 --set azure.clientId=<CLIENTID_FROM_ABOVE_JSON_OUTPUT> --set azure.clientSecret=<PASSWORD_FROM_ABOVE_JSON_OUTPUT>
