global class CustomerProessingBatch implements Database.Batchable<sobject>, Schedulable{

global String [] email = new String[] {'755317695@qq.com'};
  
//开始
global Database.Querylocator start (Database.BatchableContext BC) {

    return Database.getQueryLocator('SELECT Id,Name,Status__c FROM Position__c ');
}

//执行
global void execute (Database.BatchableContext BC, List<sobject> scope) {
    List<Position__c> customerList = new List<Position__c>();
    List<Position__c> updtaedCustomerList = new List<Position__c>();
    for (sObject objScope: scope) {

        Position__c newObjScope = (Position__c)objScope ;
        newObjScope.Status__c = '承認';
        updtaedCustomerList.add(newObjScope);
    } 	
    
    if (updtaedCustomerList != null && updtaedCustomerList.size()>0) {
        Database.update(updtaedCustomerList); System.debug('List Size '+updtaedCustomerList.size());
    }
}

//结束
global void finish(Database.BatchableContext BC){
    Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
   
    AsyncApexJob a = [Select a.TotalJobItems, a.Status, a.NumberOfErrors, a.JobType, a.JobItemsProcessed, a.ExtendedStatus, a.CreatedById, a.CompletedDate From AsyncApexJob a WHERE id = :BC.getJobId()];
    System.debug('$$$ Jobid is'+BC.getJobId());
    
    mail.setToAddresses(email);
    
    //添加邮件信息
    mail.setReplyTo('755317695@qq.com');
    mail.setSenderDisplayName('Apex Batch Processing Module');
    mail.setSubject('Batch Processing '+a.Status);
    mail.setPlainTextBody('The Batch Apex job processed  '+a.TotalJobItems+'batches with  '+a.NumberOfErrors+'failures'+'Job Item processed are'+a.JobItemsProcessed);
  
    Messaging.sendEmail(new Messaging.Singleemailmessage [] {mail});
}

//设置处理件数
global void execute(SchedulableContext sc){
    CustomerProessingBatch conInstance = new CustomerProessingBatch();
    database.executebatch(conInstance,100);
}
}