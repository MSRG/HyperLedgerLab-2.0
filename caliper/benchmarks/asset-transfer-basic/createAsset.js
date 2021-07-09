'use strict';

const { WorkloadModuleBase } = require('@hyperledger/caliper-core');

class MyWorkload extends WorkloadModuleBase {

    constructor() {
        super();
        this.txIndex = 0;
        this.chaincodeID = '';
        this.asset = {};
        this.byteSize = 0;
    }

    async initializeWorkloadModule(workerIndex, totalWorkers, roundIndex, roundArguments, sutAdapter, sutContext) {
        await super.initializeWorkloadModule(workerIndex, totalWorkers, roundIndex, roundArguments, sutAdapter, sutContext);
    }

    async submitTransaction() {
        const uuid = 'client' + this.workerIndex + '_' + this.byteSize + '_' + this.txIndex;
        this.asset.uuid = uuid;
        this.txIndex++;
        const args = {
            contractId: "asset-transfer-basic",
            contractFunction: 'CreateAsset',
            contractArguments: [uuid, 'blue', '20', 'penguin', '500'],
            readOnly: false,
            timeout: 60
        };

        await this.sutAdapter.sendRequests(args);
    }
}

function createWorkloadModule() {
    return new MyWorkload();
}

module.exports.createWorkloadModule = createWorkloadModule;