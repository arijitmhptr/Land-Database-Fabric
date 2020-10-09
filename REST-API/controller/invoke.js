const { Gateway, Wallets, TxEventHandler, GatewayOptions, DefaultEventHandlerStrategies, TxEventHandlerFactory } = require('fabric-network');
const fs = require('fs');
const path = require("path")
const log4js = require('log4js');
const logger = log4js.getLogger('BankNetwork');
const util = require('util')
const helper = require('./helper')


const invokeTransaction = async (channelName, chaincodeName, fcn, args, username, org_name, transientData) => {
    try {
        logger.debug(util.format('\n============ invoke transaction on channel %s ============\n', channelName));

        const ccp = await helper.getCCP(org_name);

        // Create a new file system based wallet for managing identities.
        const walletPath = await helper.getWalletPath(org_name);
        const wallet = await Wallets.newFileSystemWallet(walletPath);

        // Check to see if we've already enrolled the user.
        let identity = await wallet.get(username);
        if (!identity) {
            console.log(`An identity for the user ${username} does not exist in the wallet, so registering user`);
            await helper.getRegisteredUser(username, org_name, true)
            identity = await wallet.get(username);
            console.log('Run the registerUser.js application before retrying');
            return;
        }

        const connectOptions = {
            wallet, identity: username, discovery: { enabled: true, asLocalhost: true },
            eventHandlerOptions: {
                commitTimeout: 100,
                strategy: DefaultEventHandlerStrategies.NETWORK_SCOPE_ALLFORTX
            },
        }

        // Create a new gateway for connecting to our peer node.
        const gateway = new Gateway();
        await gateway.connect(ccp, connectOptions);

        // Get the network (channel) our contract is deployed to.
        const network = await gateway.getNetwork(channelName);
        const contract = network.getContract(chaincodeName);

        let result;
        let message;
        if (fcn === "createland" || fcn === "createPrivateCarImplicitForOrg1"
            || fcn == "createPrivateCarImplicitForOrg2") {
            result = await contract.submitTransaction(fcn, args[0], args[1], args[2], args[3]);
            message = `Successfully added the land asset with key ${args[0]}`;
        } 
        else if (fcn == "changeOwner") {
            result = await contract.submitTransaction(fcn, args[0], args[1]);
            message = `Successfully changed the land id-${args[0]} with new owner-${args[1]}`;
        } 
        else if (fcn == "createPrivateCar") {

            let carData = JSON.parse(transientData)
            let key = Object.keys(carData)[0]
            const transientDataBuffer = {}
            // const transientDataBuffer = {
            //     `car`: Buffer.from(JSON.stringify(carData.car))
            // };
            transientDataBuffer[key] = Buffer.from(JSON.stringify(carData.car))

            console.log(`before sending===============================================================`)
            result = await contract.createTransaction(fcn)
                .setTransient(transientDataBuffer)
                .submit()
            console.log(`result is ====================: ${result}`)
            // contract.setTransient(transientData)
            // result = await contract.submitTransaction(fcn);
            message = `Successfully submitter transient data}`
        }
        else {
            return `Invocation require either createCar or changeCarOwner as function but got ${fcn}`
        }
        await gateway.disconnect();
        // result = JSON.parse(result.toString());
        
        let response = { message: message};
        return response;
    } 
    catch (error) {
        console.log(`Getting error: ${error}`);
        return error.message;
    }
}

exports.invokeTransaction = invokeTransaction;