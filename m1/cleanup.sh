..\util\stop-containers.bat
..\util\docker-clear.bat
kubectl delete deployment,services,configmap,pods -l app=demo-taskapi
docker image rm -f <>