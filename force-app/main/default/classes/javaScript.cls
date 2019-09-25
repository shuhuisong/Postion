public with sharing class javaScript {
	
	    public String myString {get; set;}

    public javaScript(){
        myString = '';
    }

    public PageReference myMethod(){
        System.debug('myString: ' + myString);
        return null;
    }
    
}