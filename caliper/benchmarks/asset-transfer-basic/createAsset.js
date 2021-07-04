'use strict';

const { WorkloadModuleBase } = require('@hyperledger/caliper-core');

class MyWorkload extends WorkloadModuleBase {
    constructor() {
        super();
    }

    async initializeWorkloadModule(workerIndex, totalWorkers, roundIndex, roundArguments, sutAdapter, sutContext) {
        await super.initializeWorkloadModule(workerIndex, totalWorkers, roundIndex, roundArguments, sutAdapter, sutContext);
    }

    async submitTransaction() {
        const randomId = Math.floor(Math.random() * this.roundArguments.assets);
        const assetID = `${this.workerIndex}_${randomId}`;
        let args = {
            contractId: this.roundArguments.contractId,
            contractFunction: 'CreateAsset',
            contractArguments: [assetID, 'blue', '20', 'penguin', '500'],
            readOnly: false,
            timeout: 30
        };

        await this.sutAdapter.sendRequests(args);
    }

    async cleanupWorkloadModule() {
        for (let i = 0; i < this.roundArguments.assets; i++) {
            const assetID = `${this.workerIndex}_${i}`;
            console.log(`Worker ${this.workerIndex}: Deleting asset ${assetID}`);
            const request = {
                contractId: this.roundArguments.contractId,
                contractFunction: 'DeleteAsset',
                contractArguments: [assetID],
                readOnly: false
            };

            await this.sutAdapter.sendRequests(request);
        }
    }
}

function createWorkloadModule() {
    return new MyWorkload();
}

module.exports.createWorkloadModule = createWorkloadModule;