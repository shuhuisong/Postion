trigger myHelloWorld on Position__c (before insert) {
	
	list<Position__c> listPost = Trigger.new;
	
	MyHelloWorld.addHelloWorld(listPost);
    
}