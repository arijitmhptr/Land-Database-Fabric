#Generate Crypto artifactes for new peer of an existing organization
# cryptogen extend --config=./docker/crypto-config.yaml

#Run all the containers--command
docker-compose -f ./docker/docker-compose-newpeer.yaml up -d
sleep 20
echo "========== All containers are UP ================="
# docker-compose -f ../docker/docker-compose-newpeer.yaml down

# set needed environment variables
export CORE_PEER_TLS_ENABLED=true
export CHANNEL_NAME="landchannel"
export CC_NAME="landdata"
export FABRIC_CFG_PATH=${PWD}/config/
export CORE_PEER_LOCALMSPID="Org1MSP"
export CORE_PEER_MSPCONFIGPATH=${PWD}/crypto-config/peerOrganizations/org1.land.com/users/Admin@org1.land.com/msp
export CORE_PEER_ADDRESS=localhost:9051
export CORE_PEER_TLS_ROOTCERT_FILE=${PWD}/crypto-config/peerOrganizations/org1.land.com/peers/peer1.org1.land.com/tls/ca.crt

# join the channel
peer channel join -b ./channel/${CHANNEL_NAME}.block
echo "========== Channel joined successfully ================="

# install the chaincode
peer lifecycle chaincode install ${CC_NAME}.tar.gz
echo "========== chaincode deployed successfully ================="

# query the chaincode
peer chaincode query -C $CHANNEL_NAME -n ${CC_NAME} -c '{"function":"queryland","Args":["LAND3"]}'