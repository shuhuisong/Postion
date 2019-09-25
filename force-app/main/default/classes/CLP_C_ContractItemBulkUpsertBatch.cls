global with sharing class CLP_C_ContractItemBulkUpsertBatch implements Database.Batchable<sObject>, Database.Stateful, Database.AllowsCallouts{
    
    global Boolean shouldStop = false;
    global Boolean raiseError = false;
    global String sql;
    global String cntsql;

    global CLP_C_ContractItemBulkUpsertBatch() {

    }
    // start batch with check duplicate running
    public static Id startBatch(Boolean checkRunning) {
        if (checkRunning) {
            List<AsyncApexJob> aajList = [select Id from AsyncApexJob where CompletedDate = null and JobType = 'BatchApex'
                                          and ApexClass.Name = 'CLP_C_ContractItemBulkUpsertBatch'
                                          and (Status = 'Queued' or Status = 'Processing' or Status = 'Preparing' or Status = 'Holding')
                                          limit 1];
            //system.debug('CLP_ProductBulkUpsertBatch.startBatch.aajList= ' + aajList);
            if (aajList.size() != 0) {
                return null;
            }
        }

        CLP_C_ContractItemBulkUpsertBatch processor = new CLP_C_ContractItemBulkUpsertBatch();
        return Database.executeBatch(processor, Integer.valueOf(Label.CLP_BatchSizeLabel));
    }
    global Database.QueryLocator start(Database.BatchableContext BC) {
        // Don't use field Item_Number__c
        String[] fieldsArray = new String[]{
            'ProductCode', 'Item_Code__c', 'Name', 'DemandType__c', 'Unit__c', 'TaxCategory__c', 'SalesAccountTitleCode__c',
            'SalesSubAccountTitleCode__c', 'AccountReceivableSubAccountTitleCode__c', 'AdvanceReceivedSubAccountTitleCode__c',
            'LastModifiedById', 'Id', 'ErrorMessage__c', 'IsIntegrated__c', 'IsStop__c', 'ManipulateStatus__c', 'StopFlg__c'
        };

        String fields = String.join(fieldsArray, ',');
        this.sql = String.format('Select {0} from contractList where ManipulateStatus__c = \'\'{1}\'\'  order by LastModifiedDate asc'
                , new String[]{ String.escapeSingleQuotes(fields),
                                String.escapeSingleQuotes(CLP_C_Common.DEMAND_LINK_AWAITING) });

        //In case there are many same batch run at same times reject all
        Integer cntJob = [select count() from AsyncApexJob where CompletedDate = null and JobType = 'BatchApex'
                                          and ApexClass.Name = 'CLP_C_ContractItemBulkUpsertBatch'
                                          and (Status = 'Queued' or Status = 'Processing' or Status = 'Preparing' or Status = 'Holding') ];
        if(cntJob>=2){
            this.sql = this.sql + ' LIMIT 0';
            shouldStop=true;
        }
        return Database.getQueryLocator(this.sql);
    }

    global void execute(Database.BatchableContext BC, List<sObject> scope){

        List<ObicContractSpecification__c> contractList = (List<ObicContractSpecification__c>) scope;

            try {
            //  call to api upsert
            CLP_C_BulkContractItemWrapper result = CLP_C_ContractItemApi.contractBulkUpsert(contractList);
            //system.debug('CLP_ProductBulkUpsertBatch.execute.result= ' + result);

            if(result.success) {
                // loop Goods(product_linked) and update Product2 to success
                for(CLP_C_BulkContractItemWrapper.Goods p : result.goods) {
                    for(ObicContractSpecification__c pp : contractList) {
                        // check is exist product in reponse
                        if(p.item_code == pp.Item_Code__c) {
                            if(String.isBlank(p.error_message)) {
                                pp.ErrorMessage__c = null;
                                pp.ManipulateStatus__c = CLP_C_Common.DEMAND_LINK_SUCCESS;
                                pp.InfoSyncFlag__c = CLP_C_Common.FLG_SYNCING;
                                pp.IsIntegrated__c = true;

                            } else if(p.error_message.toLowerCase().contains(CLP_C_Common.HTTP_CONNECTION_ERROR)) {
                                pp.ErrorMessage__c = null;
                                pp.ManipulateStatus__c = CLP_C_Common.DEMAND_FAILED_INTERFACE;
                                pp.InfoSyncFlag__c = CLP_C_Common.FLG_UNSYNC;

                            } else {
                                pp.ErrorMessage__c = null;
                                pp.ManipulateStatus__c = CLP_C_Common.DEMAND_FAILED_DATA_DEFECT;
                                pp.InfoSyncFlag__c = CLP_C_Common.FLG_UNSYNC;
                                pp.ErrorMessage__c = p.error_code;
                            }
                            break;
                        }
                    }
                }

            // if not (result.success)
            } else {
                for(ObicContractSpecification__c pp : contractList) {
                    pp.ErrorMessage__c = null;
                    pp.ManipulateStatus__c = CLP_C_Common.DEMAND_FAILED_INTERFACE;
                    pp.InfoSyncFlag__c = CLP_C_Common.FLG_UNSYNC;
                }
            }

            // update products
            updateContract(contractList);

        } catch(Exception ex){
            this.raiseError = true;
            CLP_C_Logger.log(ex.getMessage(), Label.CLP_C_ContractItemBulkUpsertBatchLabel);
       }
        CLP_C_Logger.flush();
    }
    // finish this batch recall batch if was exist batch in queue
    global void finish(Database.BatchableContext BC) {
        if(this.raiseError){
            return;
        }
        // if more than 2 job started at the same time ==> abort all job
        if(shouldStop){
            for(AsyncApexJob aaj : [select Id from AsyncApexJob where CompletedDate = null and JobType = 'BatchApex'
                                          and ApexClass.Name = 'CLP_C_ContractItemBulkUpsertBatch'
                                          and (Status = 'Queued' or Status = 'Processing' or Status = 'Preparing' or Status = 'Holding')]
                                          ){
                                            System.abortJob(aaj.id);
                                        }
                startBatch(true);
        }
    }
    @TestVisible
    private void updateContract(List<ObicContractSpecification__c> contractList) {
        String[] listField = new String[]{'ErrorMessage__c', 'ManipulateStatus__c', 'IsIntegrated__c'};
        if(CLP_C_Common.checkFLS(CLP_C_Common.SOBJECT_OBICCONTRACT, listField, CLP_C_Common.FLSType.UPDATE_OBJECT)
        && CLP_C_Common.checkFLS(CLP_C_Common.SOBJECT_OBICCONTRACT, listField, CLP_C_Common.FLSType.CREATE_OBJECT)){
            Database.SaveResult[] saveResults = Database.update(contractList, false);
            for (Integer i=0; i<saveResults.size(); i++){
            }

        } else {
            this.raiseError = true;
        }
    }
}