
Get docker container start time:
--------------------------------
docker inspect --format='{{.State.StartedAt}}' <CONTAINERID>


Free space management:
----------------------

docker volume rm $(docker volume ls -qf dangling=true) ;\
docker rmi $(docker images --filter "dangling=true" -q --no-trunc) ;\
docker rm $(docker ps -qa --no-trunc --filter "status=exited") ;\
docker network prune


Get parent container:
---------------------
docker inspect --format='{{.Id}} {{.Parent}}' $(docker images --filter since=80026c142312 -q) |  awk '{print substr($0,0,19)}'


Execute shell inside a container:
---------------------------------
docker exec -it mycontainer /bin/bash

List all tags of image on dockerhub:
-----------------------------------

wget -q https://registry.hub.docker.com/v1/repositories/debian/tags -O -  | sed -e 's/[][]//g' -e 's/"//g' -e 's/ //g' | tr '}' '\n'  | awk -F: '{print $3}'
