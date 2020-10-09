'use strict';

const { Contract } = require('fabric-contract-api');

class Landdata extends Contract {

    async initledger(ctx){
        const landset = [
            {
                owner: "Arijit",
                size: "10",
                area: "Kolkata",
            },
            {
                owner: "Priyata",
                size: "40",
                area: "Berhampore",
            },
            {
                owner: "Uma",
                size: "20",
                area: "Kolaghat",
            },
            {
                owner: "Sitesh",
                size: "50",
                area: "Panskura",
            }
    ];

    for (let i=0; i<landset.length;i++) {
        landset[i].docType = 'land';
        await ctx.stub.putState('LAND'+i, Buffer.from(JSON.stringify(landset[i])));
    }
    console.info('============= END : Initialize Ledger ===========');
    }

    async createland(ctx, landid, owner, size, area) {
        const newlanddata = { owner, docType:'land', size, area };
        await ctx.stub.putState(landid, Buffer.from(JSON.stringify(newlanddata)));
        console.info('============= END : Create land data ===========');
    }

    async queryland(ctx, landid) {
        let landasBytes= await ctx.stub.getState(landid);

        if(!landasBytes || landasBytes.length == 0){
            throw new Error(`${landid} does not exist`);
        }

        console.log(landasBytes.toString());
        return landasBytes.toString();
    }

    async queryallLand(ctx) {
        let startkey = '';
        let endkey = '';
        let totalresult = [];

    for await (const {key, value} of ctx.stub.getStateByRange(startkey,endkey)){
        let result = Buffer.from(value).toString('utf8');
        let record;
        try{
            record = JSON.parse(result);
        }catch(err){
            console.log(err);
            record = result;
        }
        totalresult.push({ Key: key, Record: record });
    }
    console.info(totalresult);
    return JSON.stringify(totalresult);
    }

    async changeOwner(ctx, landid, neowner) {
        let landresult = await ctx.stub.getState(landid);

        if(!landresult || landresult.length === 0){
            throw new Error(`${landid} does not exist`);
        }

        const landdetail = JSON.parse(landresult.toString());
        landdetail.owner = neowner;

        await ctx.stub.putState(landid, Buffer.from(JSON.stringify(landdetail)));
        console.info('============= END : change land Owner ===========');
    }
}

module.exports = Landdata;