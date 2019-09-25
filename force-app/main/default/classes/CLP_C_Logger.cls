public with sharing class CLP_C_Logger {
    public static final String L_ACCESS ='ACCESS' ;
    public static final String L_OUTBOUND ='OUTBOUND' ;  
    public static final String L_EXCEPTION ='EXCEPTION' ;  
    public static final String L_SUCCESS ='SUCCESS' ;
    public static final String L_VALIDATION ='VALIDATION' ;
    
    public static List<Logger__c> logs = new List<Logger__c>();
    /*
        Log any actions 
        Operation:L_ACCESS,L_OUTBOUND,L_EXCEPTION
    */
    
    public static void log(String message,String operation, String origin) {
        //Boolean cumstomLogOn = Settings__c.getOrgDefaults().CMN_Logger_ActiveOrNot__c;
        //System.debug('logOn:' + cumstomLogOn);
        //if (cumstomLogOn) {
            logs.add(new Logger__c(Content__c = message, Operation__c = operation, Origin__c = origin,LK_RelatedUser__c  = UserInfo.getUserId()));
        //}
    }

    public static void log(Logger__c item) {
        logs.add(item);
    }

    public static void log(String e,String origin) {     
        log(e,L_EXCEPTION, origin);
    }

    public static void flush() {
        try {
            system.debug('@@@@logs= ' + logs);
            if(logs.size()>0){
                /*if(!CLP_MikataConstant.mikataConfig.DebugLogFlag__c)
                {*/
                    for(Integer i=0;i<logs.size();i++){
                        system.debug('logs[i].Operation__c= ' + i + ' ' + logs[i].Operation__c);
                        if(logs[i].Operation__c == L_SUCCESS)
                            logs.remove(i);
                    }
                /*}*/
                system.debug('@@@@logs222= ' + logs);
                String[] listField = new String[]
                                {'Content__c', 'Operation__c', 'Origin__c','Request__c','Response__c'
                                ,'LK_RelatedUser__c','LK_Account__c','LK_Product__c','LK_PaymentMethod__c','LK_BillingDoc__c'
                                ,'LK_DemandDetail__c','LK_BillingIndividual__c','LK_MikataInteBuffer__c'};
               
                if(CLP_C_Common.checkFLS(CLP_C_Common.SOBJECT_LOGGER,listField, CLP_C_Common.FLSType.CREATE_OBJECT)){      
                    insert logs; 
                }              
                logs.clear();    
            }    

        } catch (Exception ex) {
            system.debug('CLP_Logger.flush.ex= ' + ex);     
        }       
    }
}