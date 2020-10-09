# chmod -R 0755 ./crypto-config
# # Delete existing artifacts
rm -rf ./crypto-config
# rm bankchannel.tx
# rm -rf ../../channel-artifacts/*
rm -rf ./channel/*

#Generate Crypto artifactes for organizations
cryptogen generate --config=./docker/crypto-config.yaml --output=./crypto-config/

# System channel
export SYS_CHANNEL="systemchannel"
# channel name defaults to "mychannel"
export CHANNEL_NAME="landchannel"

# # Generate System Genesis block
echo "#######    Generate System Genesis block  ##########"
configtxgen -profile LandOrdererGenesis -configPath ./config -channelID $SYS_CHANNEL  -outputBlock ./channel/genesis.block

# # # Generate channel configuration block
echo "#######    Generate channel configuration block  ##########"
configtxgen -profile LandChannel -configPath ./config -outputCreateChannelTx ./channel/landchannel.tx -channelID $CHANNEL_NAME

echo "#######    Generating anchor peer update for Org1MSP  ##########"
configtxgen -profile LandChannel -configPath ./config -outputAnchorPeersUpdate ./channel/Org1MSPanchors.tx -channelID $CHANNEL_NAME -asOrg Org1

echo "#######    Generating anchor peer update for Org2MSP  ##########"
configtxgen -profile LandChannel -configPath ./config -outputAnchorPeersUpdate ./channel/Org2MSPanchors.tx -channelID $CHANNEL_NAME -asOrg Org2