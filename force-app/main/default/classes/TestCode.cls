public with sharing class TestCode {
	
	public void insertMethod(){
	
	Position__c c = new Position__c ();

    c.Name = 'ssh1';
    c.Min_Pay__c = 1234;
    c.Max_Pay__c = 5555;
    
    insert c;
    
   Position__c c2 = new Position__c ();

    c2.Name = 'ssh2';
    c2.Min_Pay__c = 1234;
    c2.Max_Pay__c = 5555;
    
   Position__c c3 = new Position__c ();

    c3.Name = 'ssh3';
    c3.Min_Pay__c = 1234;
    c3.Max_Pay__c = 5555;
    
    Position__c c4 = new Position__c ();

    c4.Name = 'ssh4';
    c4.Min_Pay__c = 1234;
    c4.Max_Pay__c = 5555;
    
    list <Position__c> listc = new list<Position__c> ();
    listc.add(c2);
    listc.add(c3);
    listc.add(c4);
 Database.SaveResult[] save =   Database.insert(listc,false);
 system.debug(save);
	
	}
	
    public void updateMethod(){
	String strVal = 'i';
    String result = strVal.leftPad(3, '0');
	Position__c c = new Position__c ();

    c.Name = 'ssh1';
    c.Min_Pay__c = 6667;
    c.Max_Pay__c = 8887;
    
    update c;
	
	}
	
	public void serach(){
	  list<Job_Application__c> job = [select Candidate__c ,(select Name from Review__r) from Job_Application__c  where Name = 'JA-00001'];
	  system.debug(job);
	  system.debug(job[0].Candidate__c);
	  list<Review__c> review = job[0].Review__r;
	  system.debug(review);
	}
	
	public void froclcye(){
		
		list<Position__c> listPos = [select ID,Name,Status__c from Position__c];
		
	
	for(Position__c c:listPos){
		
	ID id = c.ID;
	system.debug(id);
	system.debug(c.ID);
	system.debug(c.Name);
	system.debug(c.Status__c);
	
	
	list<Position__c> post = new list<Position__c>();
	Position__c c2 = new Position__c(Name='ttt4');
	Position__c c3 = new Position__c(Name='ttt5');
	Position__c c4 = new Position__c(Name='ttt6');
	post.add(c2);
	post.add(c3);
	post.add(c4);
	
    list<Database.SaveResult> saveres =  Database.insert(post,false);
    system.debug(saveres);
	
    list<Position__c> post2 = [select ID,Name,Min_Pay__c from Position__c ];
    post2[0].Min_Pay__c = 6666;
    system.debug(post2[0].Name);
    
    list<Database.SaveResult> saveres2 = Database.update(post2);
    system.debug(saveres2);
  
  //insert  
    Position__c c22 = new Position__c(Name='SSS',Min_Pay__c=1234,Max_Pay__c=6666);
    
    insert c22;
    
    Position__c c9 = new Position__c(Name='SSS2',Min_Pay__c=3234,Max_Pay__c=6666);
    
    upsert c9;
  
  //update
  
     Candidate__c c77 = new Candidate__c(Post__c ='123-1234',Last_Name__c= 'HUI',Email__c='755317695@qq.com',First_Name__c ='SONGSHU');
    
    insert c77;
    
    Candidate__c c8 = new Candidate__c(Post__c ='123-1239',Last_Name__c= 'HUI',Email__c='755317699@qq.com',First_Name__c ='SONGSHU');
    
    upsert c8 Candidate__c.Fields.First_Name__c; 
    
    
    Position__c c222 = [select ID,Name from Position__c where Name = '11122333'];
    
    c222.Name='AAABBB';
    
    update c222;
    
    //获取父记录里的字段值
    list<Review__c> job = [select Job_Application__r.Name from Review__c  where Name = 'R-000003'];
	  system.debug(job);
	  system.debug(job[0].Job_Application__r.Name);
	
 
  //SOSL语句查询
  List<List<SObject>> resultList = [find 'AAA' IN NAME FIELDS returning Position__c(Name),aaaaaa__c(Name)];
  system.debug(resultList);
  system.debug(resultList[0]);
  system.debug(resultList[1]);
  
  //删除语句
    Position__c c29 = [select ID,Name from Position__c where Name = 'xiaohuangren2'];
    
    delete c29;
    undelete c29;
    
    
    
      
    
    
    
    
    
    
    
	
	}
	
	}
    
}