trigger Review on Review__c (after insert) {
    
    list<Review__c> listPost = Trigger.new;
    Decimal aaa=1.0;
    system.debug((aaa+1).intValue());
    String result = String.valueOf((aaa+1).intValue()).leftPad(2, '0');
    system.debug(result);
    for (Review__c tp: listPost) {
    	        system.debug('test');
    	        system.debug(tp);
    	        String ID = tp.Job_Application__c;
                        system.debug(tp.Job_Application__c);
                        system.debug(String.valueOf(tp.getSObjectType()).subString(0,3));
                    
     list<Review__c> listPost = [select Name,Job_Application__c,ssh__r.Name from Review__c where Name = :tp.Name];

     listPost[0].ssh__r.Name = 'www565';
      system.debug(listPost[0].ssh__r);
      system.debug(String.valueOf(2));
            }
}