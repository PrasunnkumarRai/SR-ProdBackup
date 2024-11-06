Global class EmailHelper {
    
    public emailHelper(){}
    
    
    public static Messaging.SingleEmailMessage sendEmail(ID LOwnerId, List<String> manager,ID emailtemplate, String ETsubject, String EThtmlValue, String ETbody, List<Lead> lead) {
            String sLastTransferDate;
            String sLastActivityDate;
            String lName;
            String lCompany;
            String lRating;
            String lDescription;
            String lOwner;
        
            String fullRecordURL = URL.getSalesforceBaseUrl().toExternalForm() + '/' + lead[0].Id;
        
            if(lead[0].LastTransferDate != null){
                sLastTransferDate = lead[0].LastTransferDate.format();
            }
        
            if(lead[0].LastActivityDate != null){
                sLastActivityDate = lead[0].LastActivityDate.format();
            }else{
                sLastActivityDate = 'None';
            }
        
            if(lead[0].Name != null){
                lName = lead[0].Name;
            }else{
                lName = 'None';
            }
        
            if(lead[0].Company != null){
                lCompany = lead[0].Company;
            }else{
                lCompany = 'None';
            }
        
            if(lead[0].Rating != null){
                lRating = lead[0].Rating;
            }else{
                lRating = '';
            }
        
            if(lead[0].Description != null){
                lDescription = lead[0].Description;
            }else{
                lDescription = 'None';
            }
            if(lead[0].Owner.Name != null){
                lOwner = lead[0].Owner.Name;
            }else{
                lOwner = 'None';
            }
        
                // process the merge fields
                String subject = ETsubject;
                subject = subject.replace('{!Lead.Name}', lName);
                subject = subject.replace('{!Lead.Company}', lCompany);
        
                String htmlBody = EThtmlValue;
                htmlBody = htmlBody.replace('{!Lead.Rating}', lRating);
                htmlBody = htmlBody.replace('{!Lead.Name}', lName);
                htmlBody = htmlBody.replace('{!Lead.Company}', lCompany);
                htmlBody = htmlBody.replace('{!Lead.Description}', lDescription);
                htmlBody = htmlBody.replace('{!Lead.LastTransferDate}', sLastTransferDate);             
                htmlBody = htmlBody.replace('{!Lead.LastActivityDate}', sLastActivityDate);
                htmlBody = htmlBody.replace('{!Lead.OwnerFullName}', lOwner);
                htmlBody = htmlBody.replace('{!Lead.Link}', fullRecordURL);
                htmlBody = htmlBody.replace(']]>', '');
        
                String plainBody = ETbody;
                plainBody = plainBody.replace('{!Lead.Rating}', lRating);
                plainBody = plainBody.replace('{!Lead.Name}', lName);
                plainBody = plainBody.replace('{!Lead.Company}', lCompany);
                plainBody = plainBody.replace('{!Lead.Description}', lDescription);
                plainBody = plainBody.replace('{!Lead.LastTransferDate}', sLastTransferDate);           
                plainBody = plainBody.replace('{!Lead.LastActivityDate}', sLastActivityDate);
                plainBody = plainBody.replace('{!Lead.OwnerFullName}', lOwner);
                plainBody = plainBody.replace('{!Lead.Link}', fullRecordURL);
                plainBody = plainBody.replace(']]>', '');
        
                //New instance of a single email message
                Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
 
                // Who you are sending the email to(binding object - User)
                mail.setTargetObjectId(LOwnerId);
                mail.setCcAddresses(manager);

                // The email template ID used for the email
                 mail.setTemplateId(emailtemplate);
                    
                //Not required
                //mail.setWhatId('0054B000000s54WQAQ'); 
                mail.setSubject(subject); 
                mail.setHtmlBody(htmlBody);
                mail.setPlainTextBody(plainBody);
                mail.setBccSender(false);
                mail.setUseSignature(false);
                mail.setReplyTo('no-reply@spectrumreach.com');
                mail.setSenderDisplayName('SR');
                mail.setSaveAsActivity(false);  
        
        
                        
                return mail;
    } 
    
    /*
        Author : MAndS 
        Date   : 09/05/2017
        Description : to send emails to opp owner and to users above him in role hierarchy,if forecast amount on user is greater than or equal to threshold on opportunity
        Modification History : 
    */
    public static Messaging.SingleEmailMessage sendEmailToUsers(string strUserId, string strOppId, EmailTemplate template, string strObjectType)
    {
        //to get parsed template body
        string strEmailBody;
        try{
            strEmailBody = EmailTemplateMergeFieldParserUtil.ParseEmailTemplate(strOppId, template, strObjectType);
            String baseUrl = URL.getSalesforceBaseUrl().toExternalForm()+'/'+strOppId;
            strEmailBody+=' <a href=\''+baseUrl+'\'>'+baseUrl+'</a>';
        }
        catch(exception ex)
        {
            system.debug('Exception in parsing....'+ex);
            strEmailBody = template.Body;
        }
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        mail.setTargetObjectId(strUserId);
        mail.setTemplateId(template.Id);
        mail.setSubject(template.subject);
        mail.setHtmlBody(strEmailBody);
        mail.setBccSender(false);
        mail.setUseSignature(false);
        mail.setReplyTo('no-reply@spectrumreach.com');
        mail.setSenderDisplayName('SR');
        mail.setSaveAsActivity(false);
        return mail;
    }
    
    /*
        Author : MAndS 
        Date   : 01/23/2019
        Description : to send emails to any SF user
        Modification History : 
    */
    public static Messaging.SingleEmailMessage sendEmailToUser(string strUserId, string subject, string body)
    {
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        mail.setTargetObjectId(strUserId);
        mail.setToAddresses(new List<String>{UserInfo.getUserEmail()});
        mail.setSubject(subject);
        mail.setPlainTextBody(body);
        mail.setReplyTo('no-reply@spectrumreach.com');
        mail.setSenderDisplayName('SR');
        mail.setSaveAsActivity(false);
        
        //send mail
        Messaging.sendEmail(new Messaging.SingleEmailMessage[]{ mail });
        return mail;
    }
    
    
    /*
        Author : Jose Calicdan 
        Date   : 01/23/2019
        Description : to send emails to any SF user
        Modification History : 
    */
    public static Messaging.SingleEmailMessage sendEmailToListOfUsers(List<string> emailAddress, string subject, string body)
    {
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        mail.setToAddresses(emailAddress);
        mail.setSubject(subject);
        mail.setPlainTextBody(body);
        mail.setReplyTo('no-reply@spectrumreach.com');
        mail.setSenderDisplayName('SR');
        mail.setSaveAsActivity(false);
        
        //send mail
        Messaging.sendEmail(new Messaging.SingleEmailMessage[]{ mail });
        return mail;
    }

	 /*
        Author : Jose Calicdan 
        Date   : 01/23/2019
        Description : to send emails to any SF user
        Modification History : 
    */
    public static Messaging.SingleEmailMessage sendEmailHTMLToListOfUsers(List<string> emailAddress, string subject, string body)
    {
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        mail.setToAddresses(emailAddress);
        mail.setSubject(subject);
        mail.setHtmlBody(body);
        mail.setReplyTo('no-reply@spectrumreach.com');
        mail.setSenderDisplayName('SR');
        mail.setSaveAsActivity(false);
        
        //send mail
        Messaging.sendEmail(new Messaging.SingleEmailMessage[]{ mail });
        return mail;
    }
    
    
    /*
        Author : MAndS 
        Date   : 07/23/2019
        Description : to get emails of BAT team public group
        Modification History : 
    */
    public static List<String> getDevTeamEmails()
    {
        List<String> mailToAddresses = new List<String>();
        List<Id> idList = new List<Id>();
        Group g = [SELECT (select userOrGroupId from groupMembers) FROM group WHERE name ='Dev Team' ];
		for (GroupMember gm : g.groupMembers) {			
			idList.add(gm.userOrGroupId);			
		}
		
		User[] usr = [SELECT email FROM user WHERE id IN :idList];			
		for(User u : usr) {			
			mailToAddresses.add(u.email);			
		}
		
		mailToAddresses.add('SRDevMonitoring@charter.com');
			
        return mailToAddresses;
    }

}