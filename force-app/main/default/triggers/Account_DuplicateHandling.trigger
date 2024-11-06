trigger Account_DuplicateHandling on DuplicateRecordItem (after insert) {
    
    System.debug('In Account_DuplicateHandling trigger');
    //create new mail message
    Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
    mail.setToAddresses(new String[] {'ssinghal@osius.com'});
    mail.setSubject('Duplicate Account Detected!');
    mail.setHTMLBody('Hi\n\n A new duplicate account has been created. Please review at: ' + Trigger.new[0].id);

    //send mail
    Messaging.sendEmail(new Messaging.SingleEmailMessage[]{ mail });

}