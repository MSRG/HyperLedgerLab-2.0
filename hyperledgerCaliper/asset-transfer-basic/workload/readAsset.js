'use strict';

const { WorkloadModuleBase } = require('@hyperledger/caliper-core');

class MyWorkload extends WorkloadModuleBase {
    constructor() {
        super();
    }

    async initializeWorkloadModule(workerIndex, totalWorkers, roundIndex, roundArguments, sutAdapter, sutContext) {
        await super.initializeWorkloadModule(workerIndex, totalWorkers, roundIndex, roundArguments, sutAdapter, sutContext);
        console.log(this.roundIndex);
        console.log(this.roundArguments);
        console.log('start');
        for (let i = 0; i < this.roundArguments.assets; i++) {
            console.log('for loop');
            const assetID = `${this.workerIndex}_${i}`;
            console.log(`Worker ${this.workerIndex}: Creating asset ${assetID}`);
            const request = {
                contractId: this.roundArguments.contractId,
                contractFunction: 'CreateAsset',
                invokerIdentity: 'client0.org1.example.com',
                contractArguments: [assetID, 'blue', '20', 'penguin', '500'],
                readOnly: false
            };

            await this.sutAdapter.sendRequests(request);
        }
    }

    async submitTransaction() {
        // const randomId = Math.floor(Math.random() * this.roundArguments.assets);
        // const myArgs = {
        //     contractId: this.roundArguments.contractId,
        //     contractFunction: 'ReadAsset',
        //     invokerIdentity: 'client0.org1.example.com',
        //     // contractArguments: ['asset1'],
        //     timeout: 30,
        //     contractArguments: [`${this.workerIndex}_${randomId}`],
        //     // targetOrganizations: ["Org1", "Org2"],
        //     readOnly: true
        // };
        // await this.sutAdapter.sendRequests(myArgs);
    }



    async cleanupWorkloadModule() {
        // for (let i = 0; i < this.roundArguments.assets; i++) {
        //     const assetID = `${this.workerIndex}_${i}`;
        //     console.log(`Worker ${this.workerIndex}: Deleting asset ${assetID}`);
        //     const request = {
        //         contractId: this.roundArguments.contractId,
        //         contractFunction: 'DeleteAsset',
        //         invokerIdentity: 'client0.org1.example.com',
        //         contractArguments: [assetID],
        //         readOnly: false
        //     };

        //     await this.sutAdapter.sendRequests(request);
        // }
    }
}

function createWorkloadModule() {
    return new MyWorkload();
}

module.exports.createWorkloadModule = createWorkloadModule;