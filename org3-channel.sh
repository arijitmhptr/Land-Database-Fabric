export CORE_PEER_TLS_ENABLED=true
export ORDERER_CA=${PWD}/crypto-config/ordererOrganizations/land.com/orderers/orderer.land.com/msp/tlscacerts/tlsca.land.com-cert.pem
export PEER0_ORG1_CA=${PWD}/crypto-config/peerOrganizations/org1.land.com/peers/peer0.org1.land.com/tls/ca.crt
export PEER0_ORG3_CA=${PWD}/crypto-config/peerOrganizations/org3.land.com/peers/peer0.org3.land.com/tls/ca.crt
export FABRIC_CFG_PATH=${PWD}/config/

export CHANNEL_NAME="newchannel"


setGlobalsForPeer0Org1(){
    export CORE_PEER_LOCALMSPID="Org1MSP"
    export CORE_PEER_TLS_ROOTCERT_FILE=$PEER0_ORG1_CA
    export CORE_PEER_MSPCONFIGPATH=${PWD}/crypto-config/peerOrganizations/org1.land.com/users/Admin@org1.land.com/msp
    export CORE_PEER_ADDRESS=localhost:7051
}

setGlobalsForPeer0org3(){
    export CORE_PEER_LOCALMSPID="Org3MSP"
    export CORE_PEER_TLS_ROOTCERT_FILE=$PEER0_ORG3_CA
    export CORE_PEER_MSPCONFIGPATH=${PWD}/crypto-config/peerOrganizations/org3.land.com/users/Admin@org3.land.com/msp
    export CORE_PEER_ADDRESS=localhost:10051
    
}

createChannel(){
    # rm -rf ./channel-artifacts/*
    setGlobalsForPeer0Org1
    
   peer channel create -o localhost:7050 -c newchannel --ordererTLSHostnameOverride orderer.land.com -f ./channel/newchannel.tx --outputBlock ./channel/newchannel.block --tls --cafile $ORDERER_CA
}

joinChannel(){
    setGlobalsForPeer0Org1
    peer channel join -b ./channel/$CHANNEL_NAME.block
    
    setGlobalsForPeer0org3
    peer channel join -b ./channel/$CHANNEL_NAME.block
}

updateAnchorPeers(){
    setGlobalsForPeer0Org1
    peer channel update -o localhost:7050 --ordererTLSHostnameOverride orderer.land.com -c $CHANNEL_NAME -f ./channel/${CORE_PEER_LOCALMSPID}anchors.tx --tls $CORE_PEER_TLS_ENABLED --cafile $ORDERER_CA
    
    setGlobalsForPeer0org3
    peer channel update -o localhost:7050 --ordererTLSHostnameOverride orderer.land.com -c $CHANNEL_NAME -f ./channel/${CORE_PEER_LOCALMSPID}anchors.tx --tls $CORE_PEER_TLS_ENABLED --cafile $ORDERER_CA
    
    echo "------------------------- Channel created, joined and updated -------"
}

# # # Generate channel configuration block
# echo "#######    Generate channel configuration block  ##########"
# configtxgen -profile NewChannel -configPath ./config -outputCreateChannelTx ./channel/$CHANNEL_NAME.tx -channelID $CHANNEL_NAME

# echo "#######    Generating anchor peer update for Org1MSP  ##########"
# configtxgen -profile NewChannel -configPath ./config -outputAnchorPeersUpdate ./channel/Org1newMSPanchors.tx -channelID $CHANNEL_NAME -asOrg Org1

# echo "#######    Generating anchor peer update for Org2MSP  ##########"
# configtxgen -profile NewChannel -configPath ./config -outputAnchorPeersUpdate ./channel/Org3newMSPanchors.tx -channelID $CHANNEL_NAME -asOrg Org3

createChannel
# joinChannel
# updateAnchorPeers