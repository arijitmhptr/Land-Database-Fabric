export CORE_PEER_TLS_ENABLED=true
export ORDERER_CA=${PWD}/crypto-config/ordererOrganizations/land.com/orderers/orderer.land.com/msp/tlscacerts/tlsca.land.com-cert.pem
export PEER0_ORG1_CA=${PWD}/crypto-config/peerOrganizations/org1.land.com/peers/peer0.org1.land.com/tls/ca.crt
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

setGlobalsForPeer0Org2(){
    export CORE_PEER_LOCALMSPID="Org2MSP"
    export CORE_PEER_TLS_ROOTCERT_FILE=$PEER0_ORG2_CA
    export CORE_PEER_MSPCONFIGPATH=${PWD}/crypto-config/peerOrganizations/org2.land.com/users/Admin@org2.land.com/msp
    export CORE_PEER_ADDRESS=localhost:8051   
}

# fetchChannelConfig <channel_id> <output_json>
# Writes the current channel config for a given channel to a JSON file
fetchChannelConfig() {

  echo "========= Creating config transaction to add org3 to network =========== "

  setGlobalsForPeer0Org1

  echo "Fetching the most recent configuration block for the channel"
  peer channel fetch config config_block.pb -o localhost:7050 --ordererTLSHostnameOverride orderer.land.com -c $CHANNEL_NAME --tls --cafile $ORDERER_CA

  echo "Decoding config block to JSON and isolating config to config3.json"
  configtxlator proto_decode --input config_block.pb --type common.Block | jq .data.data[0].payload.data.config > ./channel/config3.json
}

# createConfigUpdate <channel_id> <original_config.json> <modified_config.json> <output.pb>
# Takes an original and modified config, and produces the config update tx
# which transitions between the two
createConfigUpdate() {

  configtxlator proto_encode --input ./channel/config3.json --type common.Config >./channel/original_config.pb
  configtxlator proto_encode --input ./channel/modified_config3.json --type common.Config >./channel/modified_config.pb
  
  configtxlator compute_update --channel_id ${CHANNEL_NAME} --original ./channel/original_config.pb --updated ./channel/modified_config.pb >./channel/config_update.pb
  
  configtxlator proto_decode --input ./channel/config_update.pb --type common.ConfigUpdate >./channel/config_update.json
  echo '{"payload":{"header":{"channel_header":{"channel_id":"'$CHANNEL_NAME'", "type":2}},"data":{"config_update":'$(cat ./channel/config_update.json)'}}}' | jq . >./channel/config_update_in_envelope.json
  configtxlator proto_encode --input ./channel/config_update_in_envelope.json --type common.Envelope >./channel/org3_update_in_envelope.pb

}

# signConfigtxAsPeerOrg <org> <configtx.pb>
# Set the peerOrg admin of an org and signing the config update
signConfigtxAsPeerOrg() {

  echo "Signing config transaction"

  setGlobalsForPeer0Org1
  peer channel signconfigtx -f ./channel/org3_update_in_envelope.pb

  setGlobalsForPeer0Org2
  peer channel signconfigtx -f ./channel/org3_update_in_envelope.pb

}

# Fetch the config for the channel, writing it to config.json
fetchChannelConfig

# Modify the configuration to append the new org
jq -s '.[0] * {"channel_group":{"groups":{"Application":{"groups": {"Org3MSP":.[1]}}}}}' ./channel/config3.json ./channel/org3.json > ./channel/modified_config3.json

# Compute a config update, based on the differences between config.json and modified_config.json, write it as a transaction to org3_update_in_envelope.pb
createConfigUpdate
echo "========= Config transaction to add org3 to network created ===== "

signConfigtxAsPeerOrg

peer channel update -f ./channel/org3_update_in_envelope.pb -c ${CHANNEL_NAME} -o localhost:7050 --ordererTLSHostnameOverride orderer.land.com --tls --cafile ${ORDERER_CA}

echo "========= Config transaction to add org3 to network submitted! =========== "