##
##  Windows Containers

##   ##################
##   Windows Containers 
##   ################## 

docker images
docker run hello-world
docker pull microsoft/nanoserver
docker run -it microsoft/nanoserver powershell

#--> inside the container
get-service

get-process

        Get-ChildItem -Path hkcu:\

Get-Item -Path Registry::HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion


Get-NetIPAddress

exit 
