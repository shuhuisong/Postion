public with sharing class OpportunityMapController {
	public String oppId{GET;SET;}
	public Candidate__c opp{GET;SET;}
	public String InsJson{GET;SET;}

public OpportunityMapController(ApexPages.StandardController con) 
{
   oppId = con.getId();
    opp = [select Address__c from Candidate__c where Id =:oppId];
    InsJson = JSON.serializePretty(opp);
}
}