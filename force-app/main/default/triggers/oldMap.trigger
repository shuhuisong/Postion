trigger oldMap on Position__c (after update) {
	
    list<Position__c>  listP = Trigger.new;
    list<Position__c> listP2 = new list<Position__c>();
    for(Position__c c: listP){
    	
    	if(c.Status__c=='承認' && trigger.oldMap.get(c.Id).Status__c=='承認待ち'){
    		  		
            Position__c c2 = new Position__c(Name = 'FDFDFDF');
            listP2.add(c2);
    	
    	}
    
}
   insert  listP2;
}