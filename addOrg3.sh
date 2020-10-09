export FABRIC_CFG_PATH=${PWD}/config/org3

#Generate Crypto artifactes for organizations
# cryptogen generate --config=./addOrg3/org3-crypto.yaml --output=./crypto-config/
# echo "========== Certificates for Org3 generated ================="

# echo "#######  Generating Org3 organization definition #########"
configtxgen -printOrg Org3 > ./channel/org3.json

# echo "#######  start org3 nodes #########"
docker-compose -f ./docker/docker-compose-org3.yaml up -d
# docker-compose -f ./docker/docker-compose-org3.yaml down

./step1org3.sh
# echo "========== Step-1 completed ================="

./step2org3.sh
# echo "========== Step-2 completed ================="

./Org3Chaincode.sh
echo "========== Chaincode deployed successfully ================="