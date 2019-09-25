trigger afterUpdate on Position__c (after update) {
   
    list<Position__c>  listP = Trigger.new;
 
    for(Position__c c: listP){
        
        if(c.Status__c=='承認'){
            
            Position__c c2 = new Position__c(Name = '556677');
            insert  c2;
        
        }
    
    
    }
    
}