createcertificatesForOrg1() {

  echo "Enroll the CA admin"
  echo
  mkdir -p crypto-config-ca/peerOrganizations/org1.land.com/
  export FABRIC_CA_CLIENT_HOME=${PWD}/crypto-config-ca/peerOrganizations/org1.land.com/

  fabric-ca-client enroll -u https://admin:adminpw@localhost:7054 --caname ca-org1 --tls.certfiles ${PWD}/fabric-ca/org1/tls-cert.pem
   

  echo 'NodeOUs:
  Enable: true
  ClientOUIdentifier:
    Certificate: cacerts/localhost-7054-ca-org1.pem
    OrganizationalUnitIdentifier: client
  PeerOUIdentifier:
    Certificate: cacerts/localhost-7054-ca-org1.pem
    OrganizationalUnitIdentifier: peer
  AdminOUIdentifier:
    Certificate: cacerts/localhost-7054-ca-org1.pem
    OrganizationalUnitIdentifier: admin
  OrdererOUIdentifier:
    Certificate: cacerts/localhost-7054-ca-org1.pem
    OrganizationalUnitIdentifier: orderer' >${PWD}/crypto-config-ca/peerOrganizations/org1.land.com/msp/config.yaml

  echo
  echo "Register peer0"
  echo
  fabric-ca-client register --caname ca-org1 --id.name peer0 --id.secret peer0pw --id.type peer --tls.certfiles ${PWD}/fabric-ca/org1/tls-cert.pem

  echo
  echo "Register user"
  echo
  fabric-ca-client register --caname ca-org1 --id.name user1 --id.secret user1pw --id.type client --tls.certfiles ${PWD}/fabric-ca/org1/tls-cert.pem

  echo
  echo "Register the org admin"
  echo
  fabric-ca-client register --caname ca-org1 --id.name org1admin --id.secret org1adminpw --id.type admin --tls.certfiles ${PWD}/fabric-ca/org1/tls-cert.pem

  mkdir -p crypto-config-ca/peerOrganizations/org1.land.com/peers

  # # -----------------------------------------------------------------------------------
  # #  Peer 0
  mkdir -p crypto-config-ca/peerOrganizations/org1.land.com/peers/peer0.org1.land.com

  echo
  echo "## Generate the peer0 msp"
  echo
  fabric-ca-client enroll -u https://peer0:peer0pw@localhost:7054 --caname ca-org1 -M ${PWD}/crypto-config-ca/peerOrganizations/org1.land.com/peers/peer0.org1.land.com/msp --csr.hosts peer0.org1.land.com --tls.certfiles ${PWD}/fabric-ca/org1/tls-cert.pem

  cp ${PWD}/crypto-config-ca/peerOrganizations/org1.land.com/msp/config.yaml ${PWD}/crypto-config-ca/peerOrganizations/org1.land.com/peers/peer0.org1.land.com/msp/config.yaml

  echo
  echo "## Generate the peer0-tls certificates"
  echo
  fabric-ca-client enroll -u https://peer0:peer0pw@localhost:7054 --caname ca-org1 -M ${PWD}/crypto-config-ca/peerOrganizations/org1.land.com/peers/peer0.org1.land.com/tls --enrollment.profile tls --csr.hosts peer0.org1.land.com --csr.hosts localhost --tls.certfiles ${PWD}/fabric-ca/org1/tls-cert.pem

  cp ${PWD}/crypto-config-ca/peerOrganizations/org1.land.com/peers/peer0.org1.land.com/tls/tlscacerts/* ${PWD}/crypto-config-ca/peerOrganizations/org1.land.com/peers/peer0.org1.land.com/tls/ca.crt
  cp ${PWD}/crypto-config-ca/peerOrganizations/org1.land.com/peers/peer0.org1.land.com/tls/signcerts/* ${PWD}/crypto-config-ca/peerOrganizations/org1.land.com/peers/peer0.org1.land.com/tls/server.crt
  cp ${PWD}/crypto-config-ca/peerOrganizations/org1.land.com/peers/peer0.org1.land.com/tls/keystore/* ${PWD}/crypto-config-ca/peerOrganizations/org1.land.com/peers/peer0.org1.land.com/tls/server.key

  mkdir ${PWD}/crypto-config-ca/peerOrganizations/org1.land.com/msp/tlscacerts
  cp ${PWD}/crypto-config-ca/peerOrganizations/org1.land.com/peers/peer0.org1.land.com/tls/tlscacerts/* ${PWD}/crypto-config-ca/peerOrganizations/org1.land.com/msp/tlscacerts/ca.crt

  mkdir ${PWD}/crypto-config-ca/peerOrganizations/org1.land.com/tlsca
  cp ${PWD}/crypto-config-ca/peerOrganizations/org1.land.com/peers/peer0.org1.land.com/tls/tlscacerts/* ${PWD}/crypto-config-ca/peerOrganizations/org1.land.com/tlsca/tlsca.org1.land.com-cert.pem

  mkdir ${PWD}/crypto-config-ca/peerOrganizations/org1.land.com/ca
  cp ${PWD}/crypto-config-ca/peerOrganizations/org1.land.com/peers/peer0.org1.land.com/msp/cacerts/* ${PWD}/crypto-config-ca/peerOrganizations/org1.land.com/ca/ca.org1.land.com-cert.pem

  # # ------------------------------------------------------------------------------------------------

  # # Peer1

  # mkdir -p crypto-config-ca/peerOrganizations/org1.land.com/peers/peer1.org1.land.com

  # echo
  # echo "## Generate the peer1 msp"
  # echo
  # fabric-ca-client enroll -u https://peer1:peer1pw@localhost:7054 --caname ca-org1 -M ${PWD}/crypto-config-ca/peerOrganizations/org1.land.com/peers/peer1.org1.land.com/msp --csr.hosts peer1.org1.land.com --tls.certfiles ${PWD}/fabric-ca/org1/tls-cert.pem

  # cp ${PWD}/crypto-config-ca/peerOrganizations/org1.land.com/msp/config.yaml ${PWD}/crypto-config-ca/peerOrganizations/org1.land.com/peers/peer1.org1.land.com/msp/config.yaml

  # echo
  # echo "## Generate the peer1-tls certificates"
  # echo
  # fabric-ca-client enroll -u https://peer1:peer1pw@localhost:7054 --caname ca-org1 -M ${PWD}/crypto-config-ca/peerOrganizations/org1.land.com/peers/peer1.org1.land.com/tls --enrollment.profile tls --csr.hosts peer1.org1.land.com --csr.hosts localhost --tls.certfiles ${PWD}/fabric-ca/org1/tls-cert.pem

  # cp ${PWD}/crypto-config-ca/peerOrganizations/org1.land.com/peers/peer1.org1.land.com/tls/tlscacerts/* ${PWD}/crypto-config-ca/peerOrganizations/org1.land.com/peers/peer1.org1.land.com/tls/ca.crt
  # cp ${PWD}/crypto-config-ca/peerOrganizations/org1.land.com/peers/peer1.org1.land.com/tls/signcerts/* ${PWD}/crypto-config-ca/peerOrganizations/org1.land.com/peers/peer1.org1.land.com/tls/server.crt
  # cp ${PWD}/crypto-config-ca/peerOrganizations/org1.land.com/peers/peer1.org1.land.com/tls/keystore/* ${PWD}/crypto-config-ca/peerOrganizations/org1.land.com/peers/peer1.org1.land.com/tls/server.key

  # # # --------------------------------------------------------------------------------------------------

  mkdir -p crypto-config-ca/peerOrganizations/org1.land.com/users
  mkdir -p crypto-config-ca/peerOrganizations/org1.land.com/users/User1@org1.land.com

  echo
  echo "## Generate the user msp"
  echo
  fabric-ca-client enroll -u https://user1:user1pw@localhost:7054 --caname ca-org1 -M ${PWD}/crypto-config-ca/peerOrganizations/org1.land.com/users/User1@org1.land.com/msp --tls.certfiles ${PWD}/fabric-ca/org1/tls-cert.pem

  mkdir -p crypto-config-ca/peerOrganizations/org1.land.com/users/Admin@org1.land.com

  echo
  echo "## Generate the org admin msp"
  echo
  fabric-ca-client enroll -u https://org1admin:org1adminpw@localhost:7054 --caname ca-org1 -M ${PWD}/crypto-config-ca/peerOrganizations/org1.land.com/users/Admin@org1.land.com/msp --tls.certfiles ${PWD}/fabric-ca/org1/tls-cert.pem

  cp ${PWD}/crypto-config-ca/peerOrganizations/org1.land.com/msp/config.yaml ${PWD}/crypto-config-ca/peerOrganizations/org1.land.com/users/Admin@org1.land.com/msp/config.yaml

}

createCertificateForOrg2() {
  echo
  echo "Enroll the CA admin"
  echo
  mkdir -p /crypto-config-ca/peerOrganizations/org2.land.com/

  export FABRIC_CA_CLIENT_HOME=${PWD}//crypto-config-ca/peerOrganizations/org2.land.com/

   
  fabric-ca-client enroll -u https://admin:adminpw@localhost:8054 --caname ca-org2 --tls.certfiles ${PWD}/fabric-ca/org2/tls-cert.pem
   

  echo 'NodeOUs:
  Enable: true
  ClientOUIdentifier:
    Certificate: cacerts/localhost-8054-ca-org2.pem
    OrganizationalUnitIdentifier: client
  PeerOUIdentifier:
    Certificate: cacerts/localhost-8054-ca-org2.pem
    OrganizationalUnitIdentifier: peer
  AdminOUIdentifier:
    Certificate: cacerts/localhost-8054-ca-org2.pem
    OrganizationalUnitIdentifier: admin
  OrdererOUIdentifier:
    Certificate: cacerts/localhost-8054-ca-org2.pem
    OrganizationalUnitIdentifier: orderer' >${PWD}/crypto-config-ca/peerOrganizations/org2.land.com/msp/config.yaml

  echo
  echo "Register peer0"
  echo
   
  fabric-ca-client register --caname ca-org2 --id.name peer0 --id.secret peer0pw --id.type peer --tls.certfiles ${PWD}/fabric-ca/org2/tls-cert.pem
  
  echo
  echo "Register user"
  echo
   
  fabric-ca-client register --caname ca-org2 --id.name user1 --id.secret user1pw --id.type client --tls.certfiles ${PWD}/fabric-ca/org2/tls-cert.pem
   

  echo
  echo "Register the org admin"
  echo
   
  fabric-ca-client register --caname ca-org2 --id.name org2admin --id.secret org2adminpw --id.type admin --tls.certfiles ${PWD}/fabric-ca/org2/tls-cert.pem
   

  mkdir -p crypto-config-ca/peerOrganizations/org2.land.com/peers
  mkdir -p crypto-config-ca/peerOrganizations/org2.land.com/peers/peer0.org2.land.com

  # --------------------------------------------------------------
  # Peer 0
  echo
  echo "## Generate the peer0 msp"
  echo
   
  fabric-ca-client enroll -u https://peer0:peer0pw@localhost:8054 --caname ca-org2 -M ${PWD}/crypto-config-ca/peerOrganizations/org2.land.com/peers/peer0.org2.land.com/msp --csr.hosts peer0.org2.land.com --tls.certfiles ${PWD}/fabric-ca/org2/tls-cert.pem
   

  cp ${PWD}/crypto-config-ca/peerOrganizations/org2.land.com/msp/config.yaml ${PWD}/crypto-config-ca/peerOrganizations/org2.land.com/peers/peer0.org2.land.com/msp/config.yaml

  echo
  echo "## Generate the peer0-tls certificates"
  echo
   
  fabric-ca-client enroll -u https://peer0:peer0pw@localhost:8054 --caname ca-org2 -M ${PWD}/crypto-config-ca/peerOrganizations/org2.land.com/peers/peer0.org2.land.com/tls --enrollment.profile tls --csr.hosts peer0.org2.land.com --csr.hosts localhost --tls.certfiles ${PWD}/fabric-ca/org2/tls-cert.pem
   

  cp ${PWD}/crypto-config-ca/peerOrganizations/org2.land.com/peers/peer0.org2.land.com/tls/tlscacerts/* ${PWD}/crypto-config-ca/peerOrganizations/org2.land.com/peers/peer0.org2.land.com/tls/ca.crt
  cp ${PWD}/crypto-config-ca/peerOrganizations/org2.land.com/peers/peer0.org2.land.com/tls/signcerts/* ${PWD}/crypto-config-ca/peerOrganizations/org2.land.com/peers/peer0.org2.land.com/tls/server.crt
  cp ${PWD}/crypto-config-ca/peerOrganizations/org2.land.com/peers/peer0.org2.land.com/tls/keystore/* ${PWD}/crypto-config-ca/peerOrganizations/org2.land.com/peers/peer0.org2.land.com/tls/server.key

  mkdir ${PWD}/crypto-config-ca/peerOrganizations/org2.land.com/msp/tlscacerts
  cp ${PWD}/crypto-config-ca/peerOrganizations/org2.land.com/peers/peer0.org2.land.com/tls/tlscacerts/* ${PWD}/crypto-config-ca/peerOrganizations/org2.land.com/msp/tlscacerts/ca.crt

  mkdir ${PWD}/crypto-config-ca/peerOrganizations/org2.land.com/tlsca
  cp ${PWD}/crypto-config-ca/peerOrganizations/org2.land.com/peers/peer0.org2.land.com/tls/tlscacerts/* ${PWD}/crypto-config-ca/peerOrganizations/org2.land.com/tlsca/tlsca.org2.land.com-cert.pem

  mkdir ${PWD}/crypto-config-ca/peerOrganizations/org2.land.com/ca
  cp ${PWD}/crypto-config-ca/peerOrganizations/org2.land.com/peers/peer0.org2.land.com/msp/cacerts/* ${PWD}/crypto-config-ca/peerOrganizations/org2.land.com/ca/ca.org2.land.com-cert.pem

  # --------------------------------------------------------------------------------
  #  Peer 1
  # echo
  # echo "## Generate the peer1 msp"
  # echo
   
  # fabric-ca-client enroll -u https://peer1:peer1pw@localhost:8054 --caname ca-org2 -M ${PWD}/crypto-config-ca/peerOrganizations/org2.land.com/peers/peer1.org2.land.com/msp --csr.hosts peer1.org2.land.com --tls.certfiles ${PWD}/fabric-ca/org2/tls-cert.pem
   

  # cp ${PWD}/crypto-config-ca/peerOrganizations/org2.land.com/msp/config.yaml ${PWD}/crypto-config-ca/peerOrganizations/org2.land.com/peers/peer1.org2.land.com/msp/config.yaml

  # echo
  # echo "## Generate the peer1-tls certificates"
  # echo
   
  # fabric-ca-client enroll -u https://peer1:peer1pw@localhost:8054 --caname ca-org2 -M ${PWD}/crypto-config-ca/peerOrganizations/org2.land.com/peers/peer1.org2.land.com/tls --enrollment.profile tls --csr.hosts peer1.org2.land.com --csr.hosts localhost --tls.certfiles ${PWD}/fabric-ca/org2/tls-cert.pem
   

  # cp ${PWD}/crypto-config-ca/peerOrganizations/org2.land.com/peers/peer1.org2.land.com/tls/tlscacerts/* ${PWD}/crypto-config-ca/peerOrganizations/org2.land.com/peers/peer1.org2.land.com/tls/ca.crt
  # cp ${PWD}/crypto-config-ca/peerOrganizations/org2.land.com/peers/peer1.org2.land.com/tls/signcerts/* ${PWD}/crypto-config-ca/peerOrganizations/org2.land.com/peers/peer1.org2.land.com/tls/server.crt
  # cp ${PWD}/crypto-config-ca/peerOrganizations/org2.land.com/peers/peer1.org2.land.com/tls/keystore/* ${PWD}/crypto-config-ca/peerOrganizations/org2.land.com/peers/peer1.org2.land.com/tls/server.key
  # -----------------------------------------------------------------------------------

  mkdir -p crypto-config-ca/peerOrganizations/org2.land.com/users
  mkdir -p crypto-config-ca/peerOrganizations/org2.land.com/users/User1@org2.land.com

  echo
  echo "## Generate the user msp"
  echo
   
  fabric-ca-client enroll -u https://user1:user1pw@localhost:8054 --caname ca-org2 -M ${PWD}/crypto-config-ca/peerOrganizations/org2.land.com/users/User1@org2.land.com/msp --tls.certfiles ${PWD}/fabric-ca/org2/tls-cert.pem
   

  mkdir -p crypto-config-ca/peerOrganizations/org2.land.com/users/Admin@org2.land.com

  echo
  echo "## Generate the org admin msp"
  echo
   
  fabric-ca-client enroll -u https://org2admin:org2adminpw@localhost:8054 --caname ca-org2 -M ${PWD}/crypto-config-ca/peerOrganizations/org2.land.com/users/Admin@org2.land.com/msp --tls.certfiles ${PWD}/fabric-ca/org2/tls-cert.pem
   

  cp ${PWD}/crypto-config-ca/peerOrganizations/org2.land.com/msp/config.yaml ${PWD}/crypto-config-ca/peerOrganizations/org2.land.com/users/Admin@org2.land.com/msp/config.yaml

}

createCretificateForOrderer() {
  echo
  echo "Enroll the CA admin"
  echo
  mkdir -p crypto-config-ca/ordererOrganizations/land.com

  export FABRIC_CA_CLIENT_HOME=${PWD}/crypto-config-ca/ordererOrganizations/land.com

   
  fabric-ca-client enroll -u https://admin:adminpw@localhost:9054 --caname ca-orderer --tls.certfiles ${PWD}/fabric-ca/orderer/tls-cert.pem
   

  echo 'NodeOUs:
  Enable: true
  ClientOUIdentifier:
    Certificate: cacerts/localhost-9054-ca-orderer.pem
    OrganizationalUnitIdentifier: client
  PeerOUIdentifier:
    Certificate: cacerts/localhost-9054-ca-orderer.pem
    OrganizationalUnitIdentifier: peer
  AdminOUIdentifier:
    Certificate: cacerts/localhost-9054-ca-orderer.pem
    OrganizationalUnitIdentifier: admin
  OrdererOUIdentifier:
    Certificate: cacerts/localhost-9054-ca-orderer.pem
    OrganizationalUnitIdentifier: orderer' >${PWD}/crypto-config-ca/ordererOrganizations/land.com/msp/config.yaml

  echo
  echo "Register orderer"
  echo
   
  fabric-ca-client register --caname ca-orderer --id.name orderer --id.secret ordererpw --id.type orderer --tls.certfiles ${PWD}/fabric-ca/orderer/tls-cert.pem

  echo
  echo "Register the orderer admin"
  echo
   
  fabric-ca-client register --caname ca-orderer --id.name ordererAdmin --id.secret ordererAdminpw --id.type admin --tls.certfiles ${PWD}/fabric-ca/orderer/tls-cert.pem
   

  mkdir -p crypto-config-ca/ordererOrganizations/land.com/orderers
  # mkdir -p crypto-config-ca/ordererOrganizations/land.com/orderers/land.com

  # ---------------------------------------------------------------------------
  #  Orderer

  mkdir -p crypto-config-ca/ordererOrganizations/land.com/orderers/orderer.land.com

  echo
  echo "## Generate the orderer msp"
  echo
   
  fabric-ca-client enroll -u https://orderer:ordererpw@localhost:9054 --caname ca-orderer -M ${PWD}/crypto-config-ca/ordererOrganizations/land.com/orderers/orderer.land.com/msp --csr.hosts orderer.land.com --csr.hosts localhost --tls.certfiles ${PWD}/fabric-ca/orderer/tls-cert.pem
   

  cp ${PWD}/crypto-config-ca/ordererOrganizations/land.com/msp/config.yaml ${PWD}/crypto-config-ca/ordererOrganizations/land.com/orderers/orderer.land.com/msp/config.yaml

  echo
  echo "## Generate the orderer-tls certificates"
  echo
   
  fabric-ca-client enroll -u https://orderer:ordererpw@localhost:9054 --caname ca-orderer -M ${PWD}/crypto-config-ca/ordererOrganizations/land.com/orderers/orderer.land.com/tls --enrollment.profile tls --csr.hosts orderer.land.com --csr.hosts localhost --tls.certfiles ${PWD}/fabric-ca/orderer/tls-cert.pem
   

  cp ${PWD}/crypto-config-ca/ordererOrganizations/land.com/orderers/orderer.land.com/tls/tlscacerts/* ${PWD}/crypto-config-ca/ordererOrganizations/land.com/orderers/orderer.land.com/tls/ca.crt
  cp ${PWD}/crypto-config-ca/ordererOrganizations/land.com/orderers/orderer.land.com/tls/signcerts/* ${PWD}/crypto-config-ca/ordererOrganizations/land.com/orderers/orderer.land.com/tls/server.crt
  cp ${PWD}/crypto-config-ca/ordererOrganizations/land.com/orderers/orderer.land.com/tls/keystore/* ${PWD}/crypto-config-ca/ordererOrganizations/land.com/orderers/orderer.land.com/tls/server.key

  mkdir ${PWD}/crypto-config-ca/ordererOrganizations/land.com/orderers/orderer.land.com/msp/tlscacerts
  cp ${PWD}/crypto-config-ca/ordererOrganizations/land.com/orderers/orderer.land.com/tls/tlscacerts/* ${PWD}/crypto-config-ca/ordererOrganizations/land.com/orderers/orderer.land.com/msp/tlscacerts/tlsca.land.com-cert.pem

  mkdir ${PWD}/crypto-config-ca/ordererOrganizations/land.com/msp/tlscacerts
  cp ${PWD}/crypto-config-ca/ordererOrganizations/land.com/orderers/orderer.land.com/tls/tlscacerts/* ${PWD}/crypto-config-ca/ordererOrganizations/land.com/msp/tlscacerts/tlsca.land.com-cert.pem

  mkdir -p crypto-config-ca/ordererOrganizations/land.com/users
  mkdir -p crypto-config-ca/ordererOrganizations/land.com/users/Admin@land.com

  echo
  echo "## Generate the admin msp"
  echo
   
  fabric-ca-client enroll -u https://ordererAdmin:ordererAdminpw@localhost:9054 --caname ca-orderer -M ${PWD}/crypto-config-ca/ordererOrganizations/land.com/users/Admin@land.com/msp --tls.certfiles ${PWD}/fabric-ca/orderer/tls-cert.pem
  
  cp ${PWD}/crypto-config-ca/ordererOrganizations/land.com/msp/config.yaml ${PWD}/crypto-config-ca/ordererOrganizations/land.com/users/Admin@land.com/msp/config.yaml
  
  mkdir ${PWD}/crypto-config-ca/ordererOrganizations/land.com/tlsca
  cp ${PWD}/crypto-config-ca/ordererOrganizations/land.com/orderers/orderer.land.com/tls/tlscacerts/* ${PWD}/crypto-config-ca/ordererOrganizations/land.com/tlsca/tlsca.orderer.land.com-cert.pem

  mkdir ${PWD}/crypto-config-ca/ordererOrganizations/land.com/ca
  cp ${PWD}/crypto-config-ca/ordererOrganizations/land.com/orderers/orderer.land.com/msp/cacerts/* ${PWD}/crypto-config-ca/ordererOrganizations/land.com/ca/ca.orderer.land.com-cert.pem

}

# sudo rm -rf crypto-config-ca/*
# sudo rm -rf fabric-ca/*

# createcertificatesForOrg1
# createCertificateForOrg2
createCretificateForOrderer

