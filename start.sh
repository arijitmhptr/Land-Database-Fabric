#Run all the containers--command
docker-compose -f ./docker/docker-compose.yaml up -d
echo "========== All containers are UP ================="

# Create channel--command
sleep 20
./createChannel.sh
echo "========== Channel created successfully ================="

#Deploy chaincode--command
sleep 10
./deployChaincode.sh
echo "========== Chaincode deployed successfully ================="