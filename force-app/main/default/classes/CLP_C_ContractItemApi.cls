public with sharing class CLP_C_ContractItemApi {
    public CLP_C_ContractItemApi() {

    }
    // call product bulk upsert api
    public static CLP_C_BulkContractItemWrapper contractBulkUpsert(List<ObicContractSpecification__c> contractList) {
        String request = '';
        String response = '';
        try {
            CLP_C_Common common = new CLP_C_Common();
            common.checkConfigApi();
            CLP_C_BulkContractItemWrapper contractWrapper = new CLP_C_BulkContractItemWrapper(common.userId, common.accessKey, common.taxRate, contractList);
            String endpoint = common.getEndpoint(CLP_C_Common.GOODS_BULK_UPSERT_PATH);
            request = JSON.serialize(contractWrapper);
            system.debug('@@@@@contractBulkUpsert.request= ' + request);
            response = common.runApi(endpoint, request);
            system.debug('@@@@@contractBulkUpsert.response= ' + response);
           
            CLP_C_BulkContractItemWrapper obj = (CLP_C_BulkContractItemWrapper)JSON.deserialize(response, CLP_C_BulkContractItemWrapper.class);
            obj.success = true;
            return obj;

        } catch(Exception ex){
            CLP_C_BulkContractItemWrapper obj = new CLP_C_BulkContractItemWrapper();
            obj.success = false;
            obj.error_message = ex.getMessage();
            system.debug('CLP_C_ContractItemApi.contractBulkUpsert.obj exception= ' + obj);
            return obj;
        }
    }
}