trigger PositionTrigger on Position__c (after delete, after undelete, before delete, before insert, before update) {
    
    TriggerFactory.instanceHandler(Position__c.sObjectType);
    
}