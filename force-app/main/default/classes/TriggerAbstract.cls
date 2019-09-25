public abstract with sharing class TriggerAbstract {
	
	 protected Map<Id,sObject> oldMap{get;set;}
     
     protected Map<Id,sObject> newMap{get;set;}
   
     protected List<sObject> listNew{get;set;}
     
     protected List<sObject> listOld{get;set;}
     
      public interface MyTrigger {
     
         void beforeInsert(SObject currentObject);
     
         void beforeUpdate(SObject oldSobject, SObject currentObject);
     
         void beforeDelete(SObject currentObject);
     
         void afterInsert(SObject currentObject);
     
         void afterUpdate(SObject oldSobject, SObject currentObject);
     
         void afterDelete(SObject currentObject);
         
         Boolean skipExecution();
   }
    
}