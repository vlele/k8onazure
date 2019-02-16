 
##
##   Invoking the API using postman 
##
##   Prerequisites
#                  login.sh for getting the credentials 
##

# any request sent to localhost:8000 will be forwarded to the Kubernetes API server.
kubectl proxy --port=8000

http://localhost:8000/api/v1/pods