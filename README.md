# Java SE on Azure App Service

This repository contains Docker images for Java SE for running on Azure App Service.

## Build
```
./setup.sh
cd jr8-alpine
docker build -t javase .
```

## Run

```
docker run javase
```

## SSH to the Docker container

```
container_ip=IP_OF_THE_DOCKER_CONTAINER
ssh root@$container_ip -p 2222
```

The username is `root` and password is `Docker!`. For detailed documentation, refer https://docs.microsoft.com/en-us/azure/app-service/containers/tutorial-custom-docker-image.

## Known issues
Currently, due to line ending issues, building and running on a Windows machine causes issues during the container startup. This will be fixed soon.