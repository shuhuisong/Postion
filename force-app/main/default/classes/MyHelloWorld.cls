public with sharing class MyHelloWorld {
	
	public static void addHelloWorld(Position__c[] accs){

    for (Position__c a:accs){
    	
         system.debug('aaaa:' + a.Max_Pay__c);
         a.Min_Pay__c = 1234;

        }

    }
	
}