/**
 * CLP_C_ContractItemCC.
 * @author Mulodo Inc.
 * @version 1.0
 * @Description:
 */
global with sharing class CLP_C_ContractItemCC {
      Private Static Final String LINECODE = '\n';

   public CLP_C_ContractItemCC() {

   }

   @RemoteAction
   webservice static String registerContractItem(List<Id> recordIds){
      CLP_C_JsonResult jsonRes;
      try {
         // Check config
         CLP_C_Common common = new CLP_C_Common();
        common.checkConfigApi();
         //
         List<ObicContractSpecification__c> listContract = getProductRecords(recordIds);
         List<ObicContractSpecification__c> listContractChoosen = new List<ObicContractSpecification__c>();
         List<ObicContractSpecification__c> listFailed = new List<ObicContractSpecification__c>();
         Integer countFailed = 0;

         // Fill error when clicked a product:
         // - already Stop Mikata
         // Not choose a product:
         // - already linked with success to Mikata
         for (ObicContractSpecification__c ctr : listContract) {
            if (ctr.IsIntegrated__c && ctr.ManipulateStatus__c == CLP_C_Common.DEMAND_LINK_SUCCESS) { 
               continue;

            } else {
               ctr.ManipulateStatus__c = CLP_C_Common.DEMAND_LINK_AWAITING;
               ctr.ErrorMessage__c = '';
               listContractChoosen.add(ctr);
            }
         }

         // update status before run batch
         String[] listField = new String[]{'ErrorMessage__c', 'ManipulateStatus__c'};
         if(CLP_C_Common.checkFLS(CLP_C_Common.SOBJECT_OBICCONTRACT, listField, CLP_C_Common.FLSType.UPDATE_OBJECT)
         && CLP_C_Common.checkFLS(CLP_C_Common.SOBJECT_OBICCONTRACT, listField, CLP_C_Common.FLSType.CREATE_OBJECT)){
            Savepoint sp ;
            if (!Test.isRunningTest()) {
               sp = Database.setSavepoint();
            }
            Database.SaveResult[] saveResults = Database.update(listContractChoosen, false);
            for (Integer i=0; i<saveResults.size(); i++){
               if (!saveResults[i].isSuccess()) {
                  String totalErrorMsg = getErrorValidationMessage(saveResults[i].getErrors());
                  listContractChoosen[i].ErrorMessage__c = totalErrorMsg;
                  listContractChoosen[i].ManipulateStatus__c = CLP_C_Common.DEMAND_DATA_DEFECT;
                  listFailed.add(listContractChoosen[i]);
                  countFailed++;
               }
            }
            if (!listFailed.isEmpty()) {
               try {
                  update listFailed;

               } catch (DmlException dmlEx) {
                  if (!Test.isRunningTest()) {
                     Database.rollback(sp);
                  }
                  throw dmlEx;
               }
            }
         }

         Id jobId = null;
         jobId = CLP_C_ContractItemBulkUpsertBatch.startBatch(true);
         if (jobId == null) {
            //jsonRes = new CLP_JSONResult(false, null, 'エラー：他のプロセスが実施されていますので、本プロセスは待機状態になります。');
            jsonRes = new CLP_C_JsonResult(true, null, null);
            return JSON.serialize(jsonRes);

         } else {
            if (countFailed > 0) {     // show list of product error (cannot call to Mikata)
               String alertMessage = buildAlertMessage(countFailed);
               jsonRes = new CLP_C_JsonResult(true, null, alertMessage);
               return JSON.serialize(jsonRes);
            }
            jsonRes = new CLP_C_JsonResult(true, null, null);
            return JSON.serialize(jsonRes);
         }

      } catch(Exception ex){
         System.debug('CLP_C_ContractItemCC.registerContractItem.ex= ' + ex.getMessage());
         jsonRes = new CLP_C_JsonResult(false, null, ex.getMessage());
         return JSON.serialize(jsonRes);
      }
   }
    private static List<ObicContractSpecification__c> getProductRecords(List<Id> recordIds){
      try {
         List<ObicContractSpecification__c> ocs = [
            Select Id,
                IsIntegrated__c,
                ManipulateStatus__c,
                ErrorMessage__c,
                InfoSyncFlag__c
            From ObicContractSpecification__c
            Where Id In :recordIds
         ];
         if (ocs != null && !ocs.isEmpty()){
            return ocs;
         }
         return null;

      }
      catch(Exception ex){
         System.debug('CLP_SyncProductCC.getProductRecords.ex= ' + ex.getMessage());
         return null;
      }
   }

    private static String getErrorValidationMessage(List<Database.Error> listErr) {
      String msg = '';
      Integer count = 0;
      for (Database.Error err : listErr) {
         count++;
         msg += err.getMessage() + (count == listErr.size() ? '' : '\n');
      }
      return msg;
   }
    private static String buildAlertMessage(Integer countError) {
      return 'エラー：計 ' + countError + ' 件の入力不備があります。';
   }
   class CLP_C_JsonResult {
	public CLP_C_JsonResult() {
	}
	public CLP_C_JsonResult(Boolean suc, Object res, String err) {
		success = suc;
		response = res;
		errorMessage = err;
	}
	public Boolean success {get;set;}
	public Object response {get;set;}
	public String errorMessage {get;set;}
}
}