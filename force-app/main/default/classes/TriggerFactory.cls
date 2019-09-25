public with sharing class TriggerFactory {

     public static void instanceHandler(Schema.SObjectType objectToken) {
         TriggerAbstract.MyTrigger myTriggerHandler = getTriggerByObjectToken(objectToken);
         if(myTriggerHandler == null) {
             throw new MyException('fsdfsfdsfsf');
         }
         if(!myTriggerHandler.skipExecution()) {
            executeTrigger(myTriggerHandler);         
            }
     }
     
     public static void executeTrigger(TriggerAbstract.MyTrigger myTriggerHandler) {
     	
     	
         if(Trigger.isBefore) {
             if(Trigger.isInsert) {
                 for (SObject currentObject : Trigger.new)
                 {
                     myTriggerHandler.beforeInsert(currentObject);
                 } 
             }else if(Trigger.isUpdate) {
                 for (SObject oldObject : Trigger.old)
                 {
                     myTriggerHandler.beforeUpdate(oldObject, Trigger.newMap.get(oldObject.Id));
                 }
             }else if(Trigger.isDelete) {
                 for (SObject currentObject : Trigger.old)
                 {
                     myTriggerHandler.beforeDelete(currentObject);
                 }
             }
         } else {
              if (Trigger.isInsert) {
                 for (SObject currentObject : Trigger.new) {
                     myTriggerHandler.afterInsert(currentObject);
                 }   
              } else if (Trigger.isUpdate) {
                 for (SObject oldObject : Trigger.old) {
                     myTriggerHandler.afterUpdate(oldObject, Trigger.newMap.get(oldObject.Id));
                 }   
              } else if (Trigger.isDelete){
                 for (SObject currentObject : Trigger.old) {
                     myTriggerHandler.afterDelete(currentObject);
                 }   
              }
         }
     }
     
   
     public static TriggerAbstract.MyTrigger getTriggerByObjectToken(Schema.SObjectType objectToken) {
         if(objectToken == Position__c.sObjectType) {
             return new PositionHandler();
         }
         
         return null;
     }
}