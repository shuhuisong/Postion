@isTest

public with sharing class MyHelloWorldTest {
	
	static testMethod void testPosition(){
		
	Position__c c = new Position__c();
	
	system.debug('bbbbb' +c.Max_Pay__c);
	
	insert c;
	
	Position__c updatedPosi = [select Min_Pay__c from Position__c where Id=:c.Id];
	
	system.assertEquals(1234,updatedPosi.Min_Pay__c);
	}
    
}