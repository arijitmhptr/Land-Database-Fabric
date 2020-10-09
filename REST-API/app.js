'use strict';
const log4js = require('log4js');
const logger = log4js.getLogger('BasicNetwork');
const bodyParser = require('body-parser');
const util = require('util');
const express = require('express')
const app = express();
const expressJWT = require('express-jwt');
const jwt = require('jsonwebtoken');
const bearerToken = require('express-bearer-token');
const cors = require('cors');
const constants = require('./config/constants.json');
require('dotenv/config');

const host = process.env.HOST || constants.host;
const port = process.env.PORT || constants.port;

//Connect to Server
app.listen(port, () => console.log(`Server listening on Port.. ${port}`));
// server.timeout = 240000;

//Import middleware
const helper = require('./controller/helper');
const invoke = require('./controller/invoke');
const query = require('./controller/query');

app.options('*', cors());
app.use(cors());
app.use(bodyParser.json());
app.use(bodyParser.urlencoded({extended: false}));

// set secret variable
app.set('secret', process.env.TOKEN_SECRET);
app.use(expressJWT({
    secret: process.env.TOKEN_SECRET
}).unless({
    path: ['/api/users']
}));
app.use(bearerToken());

function getErrorMessage(field) {
    var response = {
        success: false,
        message: field + ' field is missing or Invalid in the request'
    };
    return response;
}

app.use((req, res, next) => {
    logger.debug('New req for %s', req.originalUrl);
    if (req.originalUrl.indexOf('/users') >= 0) {
        return next();
    }
    var token = req.token;
    jwt.verify(token, app.get('secret'), (err, decoded) => {
        if (err) {
            res.send({
                success: false,
                message: 'Failed to authenticate token. Make sure to include the ' +
                    'token returned from /users call in the authorization header ' +
                    ' as a Bearer token'
            });
            return;
        } else {
            req.username = decoded.username;
            req.orgname = decoded.orgName;
            logger.debug(util.format('Decoded from JWT token: username - %s, orgname - %s', decoded.username, decoded.orgName));
            return next();
        }
    });
});

// Register and enroll user
app.post('/api/users', async function (req, res) {
    var username = req.body.username;
    var orgName = req.body.orgName;
    logger.debug('End point : /users');
    logger.debug('User name : ' + username);
    logger.debug('Org name  : ' + orgName);
    if (!username) {
        res.json(getErrorMessage('\'username\''));
        return;
    }
    if (!orgName) {
        res.json(getErrorMessage('\'orgName\''));
        return;
    }

    var token = jwt.sign({
        exp: Math.floor(Date.now() / 1000) + parseInt(constants.jwt_expiretime),
        username: username,
        orgName: orgName
    }, app.get('secret'));

    let response = await helper.getRegisteredUser(username, orgName, true);

    logger.debug('-- returned from registering the username %s for organization %s', username, orgName);
    if (response && typeof response !== 'string') {
        logger.debug('Successfully registered the username %s for organization %s', username, orgName);
        response.token = token;
        res.json(response);
    } else {
        logger.debug('Failed to register the username %s for organization %s with::%s', username, orgName, response);
        res.json({ success: false, message: response });
    }

});

// Invoke transaction on chaincode on target peers
app.post('/channel/:channelName/chaincode/:chaincodeName', async function (req, res) {
    try {
        logger.debug('==================== INVOKE ON CHAINCODE ==================');
        var peers = req.body.peers;
        var chaincodeName = req.params.chaincodeName;
        var channelName = req.params.channelName;
        var fcn = req.body.fcn;
        var args = req.body.args;
        var transient = req.body.transient;
        logger.debug('channelName  : ' + channelName);
        logger.debug('chaincodeName : ' + chaincodeName);
        logger.debug('fcn  : ' + fcn);
        logger.debug('args  : ' + args);
        if (!chaincodeName) {
            res.json(getErrorMessage('\'chaincodeName\''));
            return;
        }
        if (!channelName) {
            res.json(getErrorMessage('\'channelName\''));
            return;
        }
        if (!fcn) {
            res.json(getErrorMessage('\'fcn\''));
            return;
        }
        if (!args) {
            res.json(getErrorMessage('\'args\''));
            return;
        }

        let message = await invoke.invokeTransaction(channelName, chaincodeName, fcn, args, req.username, req.orgname, transient);

        const response_payload = {
            result: message,
            error: null,
            errorData: null
        }
        res.send(response_payload);
    } catch (error) {
        const response_payload = {
            result: null,
            error: error.name,
            errorData: error.message
        }
        res.send(response_payload);
    }
});

// Query transactions
app.get('/channel/:channelName/chaincode/:chaincodeName', async function (req, res) {
        try {   
            var channelName = req.params.channelName;
            var chaincodeName = req.params.chaincodeName;
            let args = req.query.args;
            let fcn = req.query.fcn;
            let peer = req.query.peer;

            if (!chaincodeName) {
                res.json(getErrorMessage('\'chaincodeName\''));
                return;
            }
            if (!channelName) {
                res.json(getErrorMessage('\'channelName\''));
                return;
            }
            if (!fcn) {
                res.json(getErrorMessage('\'fcn\''));
                return;
            }
            if (fcn != "queryallLand")
            {
            if (!args) {
                res.json(getErrorMessage('\'args\''));
                return;
            }
            // args = args.replace(/'/g, '"');
            // console.log(`Argument all: ${args}`);
            // args = JSON.parse(args[0]);
            logger.debug(args);
            }

            let message = await query.query(channelName, chaincodeName, args, fcn, req.username, req.orgname);
    
            const response_payload = {
                result: message,
                error: null,
                errorData: null
            }
            res.send(response_payload);
        } catch (error) {
            const response_payload = {
                result: null,
                error: error.name,
                errorData: error.message
            }
            res.send(response_payload)
        }
});



