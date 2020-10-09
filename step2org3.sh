# This script is designed to be run in the org3cli container as the
# second step of the EYFN tutorial. It joins the org3 peers to the
# channel previously setup in the BYFN tutorial and install the
# chaincode as version 2.0 on peer0.org3.

echo "========= Getting Org3 on to your test network ========= "

export CORE_PEER_TLS_ENABLED=true
export ORDERER_CA=${PWD}/crypto-config/ordererOrganizations/land.com/orderers/orderer.land.com/msp/tlscacerts/tlsca.land.com-cert.pem
export PEER0_ORG1_CA=${PWD}/crypto-config/peerOrganizations/org1.land.com/peers/peer0.org1.land.com/tls/ca.crt
export PEER0_ORG3_CA=${PWD}/crypto-config/peerOrganizations/org3.land.com/peers/peer0.org3.land.com/tls/ca.crt
export FABRIC_CFG_PATH=${PWD}/config/
export CHANNEL_NAME="landchannel"

setGlobalsForOrderer(){
    export CORE_PEER_LOCALMSPID="OrdererMSP"
    export CORE_PEER_TLS_ROOTCERT_FILE=${PWD}/crypto-config/ordererOrganizations/land.com/orderers/orderer.land.com/msp/tlscacerts/tlsca.land.com-cert.pem
    export CORE_PEER_MSPCONFIGPATH=${PWD}/crypto-config/ordererOrganizations/land.com/users/Admin@land.com/msp
}

setGlobalsForPeer0Org1(){
    export CORE_PEER_LOCALMSPID="Org1MSP"
    export CORE_PEER_TLS_ROOTCERT_FILE=$PEER0_ORG1_CA
    export CORE_PEER_MSPCONFIGPATH=${PWD}/crypto-config/peerOrganizations/org1.land.com/users/Admin@org1.land.com/msp
    export CORE_PEER_ADDRESS=localhost:7051
}

setGlobalsForPeer0Org3(){
    export CORE_PEER_LOCALMSPID="Org3MSP"
    export CORE_PEER_TLS_ROOTCERT_FILE=$PEER0_ORG3_CA
    export CORE_PEER_MSPCONFIGPATH=${PWD}/crypto-config/peerOrganizations/org3.land.com/users/Admin@org3.land.com/msp
    export CORE_PEER_ADDRESS=localhost:10051
}

# import environment variables
# . scripts/org3-scripts/envVarCLI.sh

## Sometimes Join takes time hence RETRY at least 5 times
joinChannelWithRetry() {

  setGlobalsForPeer0Org3

  peer channel join -b ./channel/$CHANNEL_NAME.block >&log.txt
  
}

echo "Fetching channel config block from orderer..."
setGlobalsForPeer0Org1
peer channel fetch 0 ./channel/$CHANNEL_NAME.block -o localhost:7050 --ordererTLSHostnameOverride orderer.land.com -c $CHANNEL_NAME --tls --cafile $ORDERER_CA
# cat log.txt
# verifyResult $res "Fetching config block from orderer has Failed"

joinChannelWithRetry
echo "===================== peer0.org3 joined channel '$CHANNEL_NAME' ===================== "

echo "========= Finished adding Org3 to your test network! ========= "