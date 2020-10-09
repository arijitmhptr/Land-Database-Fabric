#Run all the containers--command
docker-compose -f ./docker/docker-compose-newpeer.yaml down
docker-compose -f ./docker/docker-compose-org3.yaml down
docker-compose -f ./docker/docker-compose.yaml down
echo "========== All containers are DOWN ================="

# delete stopped containers
docker rm -v $(docker ps -a -q -f status=exited)

# Delete all docker volumes
docker volume prune