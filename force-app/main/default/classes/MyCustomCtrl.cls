public class MyCustomCtrl {

    public List<Position__c > acts{
        
        get;
        set;
    }
    
        public List<Position__c > listTable{
        
        get;
        set;
    }
    public MyCustomCtrl(){
        acts = new List<Position__c >();
        for(Integer i = 0; i<3; i++){
            
            acts.add(new Position__c());
        }
        
        listTable = [select ID,Name,Status__c from Position__c];
        
    }
    
 
    public Pagereference save(){
    	
        insert acts;
        return Page.messagePage;
    
    }
}