public class MyContact {
    
    public list<Contact> listTable{
        set;
        get;
        
        }
    
    public MyContact(){
        
        listTable = [select MobilePhone,Email,Birthdate from Contact];
            
    }

}