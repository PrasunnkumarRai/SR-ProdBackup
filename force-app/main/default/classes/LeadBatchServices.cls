public with sharing class LeadBatchServices {
	
	public LeadBatchServices(){}


	public void LeadMessageService(){
		List <Lead> lList;
        Set <Id> lqueue = new Set<Id>();
		List <String> mList = new List<String>();
		List <String> LOList = new List<String>();
		List <EmailTemplate> eId;
        String lName;
        String lCompany;
        
		List<Messaging.SingleEmailMessage> mails = new List<Messaging.SingleEmailMessage>();
		
		
		lList = [Select Id, name, OwnerId, Owner_Manager__c, of_days_since_Activity__c, Rating, Company, Description, LastTransferDate, LastActivityDate, Owner.Name from Lead where of_days_since_Activity__c > 7 AND Status != 'Closed'];
		if(Test.isRunningTest()) lList = [Select Id, name, OwnerId, Owner_Manager__c, of_days_since_Activity__c, Rating, Company, Description, LastTransferDate, LastActivityDate, Owner.Name from Lead where Status != 'Closed'];
        eId = [Select Id, Subject, HTMLValue, Body from EmailTemplate where name = 'No Activity 7 Days +'];
        
        for(Group g : [Select Id from Group where Type = 'Queue']){
            
            lqueue.add(g.Id);
        }
		
		system.debug('Lead List BEFORE: '+lList);
		
		for(Lead l: lList){
            if(!lqueue.contains(l.OwnerId)){
				if(l.Owner_Manager__c != null && mList.size() < 25){  // <--- SFDC CCAddress limit is 25
					mList.add(l.Owner_Manager__c);
							
				}
	
	            if(!Test.isRunningTest()){
					mails.add(EmailHelper.sendEmail(l.OwnerId, mList, eId[0].Id, eId[0].Subject, eId[0].HTMLValue, eId[0].Body, lList));
	            }
            }
		
		}
		if(mails.size()>0){
			if(!Test.isRunningTest())
				Messaging.sendEmail(mails);
		}
		
	}

}