# Description

Docker image with a lot of binaries and tools needed for the development of the project


# Make this work

```bash
DOCKER_BUILDKIT=1 docker build -t google-cli:v0 .
docker run -it google-cli:v0
docker run --mount type=bind,source="$(pwd)",target=/home/gcp-ansible-demo -p 8080:8080 --name google-docker-bins -h rafa-adorna-docker --rm -it google-cli:v0
```
