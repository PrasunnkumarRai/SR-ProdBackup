/**
###########################################################################
# Author ...............: Rajeswari
# Created Date..........: 19-Feb-24
# Ticket ...............: SRSF-4729
# Description...........: Batch class to Send Email Notification to Interim AE's with the Accounts assigned.
# Test Class............: SendEmailToInterimAE_BatchTest
# Change Log:
# Date              User        Requested By (Optional)      Description  

############################################################################
*/

global class SendEmailToInterimAE_Batch implements Database.Batchable<sObject>, Database.stateful
{    
    Map<String, List<Interim_AE_Account__c>> interimAEMap =  new Map<String, List<Interim_AE_Account__c>>();

    global Database.QueryLocator start(Database.BatchableContext BC) 
    {        
        String query = 'SELECT Id, Name, Account__r.Id, Account__r.Name, Interim_AE__r.Name, Interim_AE__r.Email, StartDate__c, EndDate__c FROM Interim_AE_Account__c WHERE Status__c=\'Approved\' AND EndDate__c>TODAY';
        System.debug('query------->'+query);

        return Database.getQueryLocator(query);
    }
    
    global void execute(Database.BatchableContext BC, List<Sobject> scope)
    {        
        System.debug('In execute method, scope-->' + scope);
        for (sObject so: scope) 
        {
            Interim_AE_Account__c interimAcct = (Interim_AE_Account__c) so;
            if(!interimAEMap.containsKey(interimAcct.Interim_AE__r.Email))
            {
                interimAEMap.put(interimAcct.Interim_AE__r.Email, new List<Interim_AE_Account__c>());
            }                
            
            interimAEMap.get(interimAcct.Interim_AE__r.Email).add(interimAcct);
        } 
    }
    
    global void finish(Database.BatchableContext BC)
    {
        List<Messaging.SingleEmailMessage> mailList = new List<Messaging.SingleEmailMessage>();
        System.debug('interimAEMap-->'+interimAEMap);

        String body = System.Label.InterimAE_Notification_Body;               
                
        for(String interimAEEmail : interimAEMap.keyset())
        {  
            List<Interim_AE_Account__c> lstInterimAEs = interimAEMap.get(interimAEEmail);
            System.debug('lstInterimAEs--->'+ lstInterimAEs);
            
            String interimAEName = lstInterimAEs[0].Interim_AE__r.Name;        
           
            String emailBody = '<html><body><p> Hi '+ interimAEName +',<br/>'+body+'</p><table border="1"><tr><th>Account Name</th><th>Start Date</th><th>End Date</th></tr>';
            
            for(Interim_AE_Account__c rec: lstInterimAEs)
            {
                String acctLink = URL.getOrgDomainUrl().toExternalForm() +'/'+ rec.Account__r.Id;
                emailBody += '<tr><td><a href="'+ acctLink + '">' + rec.Account__r.Name + '</td>' +'<td>' + rec.StartDate__c + '</td>' + '<td>' + rec.EndDate__c + '</td></tr>';
            }                
            emailBody += '</table></body></html>';

            Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
            email.setToAddresses(new String[]{interimAEEmail});                
            email.setSubject(System.Label.InterimAE_Notification_Title);
            email.setHtmlBody(emailBody);
            
            mailList.add(email); 
        }

        System.debug('mailList------->'+mailList);
        
        if(mailList.size()>0)
        {
            if(!Test.isRunningTest()){
                Messaging.SendEmailResult[] results = Messaging.sendEmail(mailList);
                System.debug('result---'+ results);
                for(Messaging.SendEmailResult res : results)
                {
                    if(!res.isSuccess())
                        System.debug('Error occured while sending Email::'+ res.getErrors());
                }
            }    
        }    
    }
}