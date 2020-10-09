export CORE_PEER_TLS_ENABLED=true
export ORDERER_CA=${PWD}/crypto-config/ordererOrganizations/land.com/orderers/orderer.land.com/msp/tlscacerts/tlsca.land.com-cert.pem
export PEER0_ORG1_CA=${PWD}/crypto-config/peerOrganizations/org1.land.com/peers/peer0.org1.land.com/tls/ca.crt
export PEER0_ORG2_CA=${PWD}/crypto-config/peerOrganizations/org2.land.com/peers/peer0.org2.land.com/tls/ca.crt
export PEER0_ORG3_CA=${PWD}/crypto-config/peerOrganizations/org3.land.com/peers/peer0.org3.land.com/tls/ca.crt
export FABRIC_CFG_PATH=${PWD}/config/

export CHANNEL_NAME="landchannel"
export CC_RUNTIME_LANGUAGE="node"
export VERSION="2"
export CC_SRC_PATH="./chaincode/"
export CC_NAME="landdata"

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

setGlobalsForPeer0Org2(){
    export CORE_PEER_LOCALMSPID="Org2MSP"
    export CORE_PEER_TLS_ROOTCERT_FILE=$PEER0_ORG2_CA
    export CORE_PEER_MSPCONFIGPATH=${PWD}/crypto-config/peerOrganizations/org2.land.com/users/Admin@org2.land.com/msp
    export CORE_PEER_ADDRESS=localhost:8051   
}

setGlobalsForPeer0Org3(){
    export CORE_PEER_LOCALMSPID="Org3MSP"
    export CORE_PEER_TLS_ROOTCERT_FILE=$PEER0_ORG3_CA
    export CORE_PEER_MSPCONFIGPATH=${PWD}/crypto-config/peerOrganizations/org3.land.com/users/Admin@org3.land.com/msp
    export CORE_PEER_ADDRESS=localhost:10051
}

packageChaincode(){
    rm -rf ${CC_NAME}.tar.gz
    setGlobalsForPeer0Org1
    peer lifecycle chaincode package ${CC_NAME}.tar.gz --path ${CC_SRC_PATH} --lang ${CC_RUNTIME_LANGUAGE} --label ${CC_NAME}_${VERSION}
    echo "===================== Chaincode is packaged on peer0.org1 ===================== "
}

installChaincode(){

    setGlobalsForPeer0Org1
    peer lifecycle chaincode install ${CC_NAME}.tar.gz
    echo "===================== Chaincode is installed on peer0.org1 ===================== "
    
    setGlobalsForPeer0Org2
    peer lifecycle chaincode install ${CC_NAME}.tar.gz
    echo "===================== Chaincode is installed on peer0.org2 ===================== "

    setGlobalsForPeer0Org3
    peer lifecycle chaincode install ${CC_NAME}.tar.gz
    echo "===================== Chaincode is installed on peer0.org3 ===================== "

}

queryInstalled(){
    setGlobalsForPeer0Org1
    peer lifecycle chaincode queryinstalled >&log.txt
    cat log.txt
    PACKAGE_ID=$(sed -n "/${CC_NAME}_${VERSION}/{s/^Package ID: //; s/, Label:.*$//; p;}" log.txt)
    echo PackageID is ${PACKAGE_ID}
    echo "===================== Query installed successful on peer0.org1 on channel ===================== "
}

approveForMyOrg1(){
    setGlobalsForPeer0Org1

    peer lifecycle chaincode approveformyorg -o localhost:7050  \
    --ordererTLSHostnameOverride orderer.land.com \
    --tls $CORE_PEER_TLS_ENABLED --cafile $ORDERER_CA \
    --channelID $CHANNEL_NAME --name ${CC_NAME} \
    --version ${VERSION} --init-required --package-id ${PACKAGE_ID} --sequence ${VERSION}

    echo "===================== chaincode approved from org 1 ===================== "
}

checkCommitReadyness(){
    setGlobalsForPeer0Org1

    peer lifecycle chaincode checkcommitreadiness --channelID $CHANNEL_NAME \
    --name ${CC_NAME} --version ${VERSION} --sequence ${VERSION} --output json --init-required

    echo "===================== checking commit readyness from org 1 ===================== "
}

approveForMyOrg2() {
    setGlobalsForPeer0Org2

    peer lifecycle chaincode approveformyorg -o localhost:7050 \
    --ordererTLSHostnameOverride orderer.land.com \
    --tls $CORE_PEER_TLS_ENABLED --cafile $ORDERER_CA \
    --channelID $CHANNEL_NAME --name ${CC_NAME} \
    --version ${VERSION} --init-required --package-id ${PACKAGE_ID} --sequence ${VERSION}

    echo "===================== chaincode approved from org 2 ===================== "
}

checkCommitReadyness(){
    
    setGlobalsForPeer0Org2

    peer lifecycle chaincode checkcommitreadiness --channelID $CHANNEL_NAME \
    --peerAddresses localhost:7051 --tlsRootCertFiles $PEER0_ORG1_CA \
    --name ${CC_NAME} --version ${VERSION} \
    --sequence ${VERSION} --output json --init-required

    echo "===================== checking commit readyness from org 2 ===================== "
}

approveForMyOrg3(){
    setGlobalsForPeer0Org3

    peer lifecycle chaincode approveformyorg -o localhost:7050  \
    --ordererTLSHostnameOverride orderer.land.com \
    --tls $CORE_PEER_TLS_ENABLED --cafile $ORDERER_CA \
    --channelID $CHANNEL_NAME --name ${CC_NAME} \
    --version ${VERSION} --init-required --package-id ${PACKAGE_ID} --sequence ${VERSION}

    echo "===================== chaincode approved from org 1 ===================== "
}

checkCommitReadyness(){
    
    setGlobalsForPeer0Org3

    peer lifecycle chaincode checkcommitreadiness --channelID $CHANNEL_NAME \
    --peerAddresses localhost:7051 --tlsRootCertFiles $PEER0_ORG1_CA \
    --name ${CC_NAME} --version ${VERSION} \
    --sequence ${VERSION} --output json --init-required

    echo "===================== checking commit readyness from org 2 ===================== "
}

commitChaincodeDefination(){
    setGlobalsForPeer0Org1

    peer lifecycle chaincode commit -o localhost:7050 \
    --ordererTLSHostnameOverride orderer.land.com \
    --tls $CORE_PEER_TLS_ENABLED  --cafile $ORDERER_CA \
    --channelID $CHANNEL_NAME --name ${CC_NAME} \
    --peerAddresses localhost:7051 --tlsRootCertFiles $PEER0_ORG1_CA \
    --peerAddresses localhost:8051 --tlsRootCertFiles $PEER0_ORG2_CA \
    --peerAddresses localhost:10051 --tlsRootCertFiles $PEER0_ORG3_CA \
    --version ${VERSION} --sequence ${VERSION} \
    --init-required
   
   echo "===================== Chaincode Defination commited on peer0-org 1 and peer0-org2 ===================== "
}

queryCommitted(){
    setGlobalsForPeer0Org1

    peer lifecycle chaincode querycommitted --channelID $CHANNEL_NAME --name ${CC_NAME}
   
}

chaincodeInvokeInit(){
    setGlobalsForPeer0Org1

    peer chaincode invoke -o localhost:7050 --ordererTLSHostnameOverride orderer.land.com \
    --tls $CORE_PEER_TLS_ENABLED --cafile $ORDERER_CA -C $CHANNEL_NAME -n ${CC_NAME} \
    --peerAddresses localhost:7051 --tlsRootCertFiles $PEER0_ORG1_CA \
    --peerAddresses localhost:8051 --tlsRootCertFiles $PEER0_ORG2_CA \
    --peerAddresses localhost:10051 --tlsRootCertFiles $PEER0_ORG3_CA \
    --isInit -c '{"function":"initledger","Args":[]}'
    
}

chaincodeInvoke(){   

    setGlobalsForPeer0Org1

    ## Create Car
    # peer chaincode invoke -o localhost:7050 \
    #     --ordererTLSHostnameOverride orderer.land.com \
    #     --tls $CORE_PEER_TLS_ENABLED \
    #     --cafile $ORDERER_CA \
    #     -C $CHANNEL_NAME -n ${CC_NAME}  \
    #     --peerAddresses localhost:7051 \
    #     --tlsRootCertFiles $PEER0_ORG1_CA \
    #     --peerAddresses localhost:9051 --tlsRootCertFiles $PEER0_ORG2_CA $PEER_CONN_PARMS  \
    #     -c '{"function": "CreateCar","Args":["Car-ABCDEEE", "Audi", "R8", "Red", "Pavan"]}'
    
    ## Change land owner
    peer chaincode invoke -o localhost:7050 \
        --ordererTLSHostnameOverride orderer.land.com \
        --tls $CORE_PEER_TLS_ENABLED \
        --cafile $ORDERER_CA \
        -C $CHANNEL_NAME -n ${CC_NAME}  \
        --peerAddresses localhost:7051 --tlsRootCertFiles $PEER0_ORG1_CA \
        --peerAddresses localhost:8051 --tlsRootCertFiles $PEER0_ORG2_CA  \
        --peerAddresses localhost:10051 --tlsRootCertFiles $PEER0_ORG3_CA  \
        -c '{"function": "changeOwner","Args":["LAND3", "Sandip"]}'

    echo "===================== Chaincode Invoke ===================== "
}

chaincodeQuery(){

    setGlobalsForPeer0Org3

    # Query all Cars
    # peer chaincode query -C $CHANNEL_NAME -n ${CC_NAME} -c '{"function":"queryallLand","Args":[]}'
    peer chaincode query -C $CHANNEL_NAME -n ${CC_NAME} -c '{"function":"queryland","Args":["LAND3"]}'
}

packageChaincode
installChaincode
queryInstalled
approveForMyOrg1
checkCommitReadyness
approveForMyOrg2
checkCommitReadyness
approveForMyOrg3
checkCommitReadyness
commitChaincodeDefination
queryCommitted
chaincodeInvokeInit
# chaincodeInvoke
# chaincodeQuery