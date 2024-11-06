global class BatchUnmerge implements Database.Batchable<String>, Database.Stateful {
    
    private List<String> accMLIds;
    private List<String> success;
    private List<String> fail;
    private List<String> alreadyUnmerge;
    private List<String> unableToUnmerge;
    

    public BatchUnmerge(List<String> accMLIds) {
        this.accMLIds = accMLIds;
        this.success = new List<String>();
        this.fail = new List<String>();
    	this.alreadyUnmerge = new List<String>();
    	this.unableToUnmerge = new List<String>();
    }

    global Iterable<String> start(Database.BatchableContext BC) {
        return accMLIds;
    }

    global void execute(Database.BatchableContext BC, List<String> accMLIds) {
        
        for (String accMLId : accMLIds) {
            System.debug('accMLId@@@'+accMLId);
            String s = AccountMergeUpdate.unmergeAccountMergeLog(accMLId);
            if (s == 'Success') {
                success.add(accMLId);
            } else if (s == 'Error') {
                fail.add(accMLId);
            } else if (s == 'Account unmerged') {
                alreadyUnmerge.add(accMLId);
            } else if (s == 'Account deleted') {
                unableToUnmerge.add(accMLId);
            }
        }
    }

    global void finish(Database.BatchableContext BC) {
        String csvFile;
        String csvColumnHeader1 = 'Success,\nParent ID,Child Account ID\n';
        String csvColumnHeader2 = 'Failure,\nParent ID,Child Account ID\n';
        String csvColumnHeader3 = 'Child record already unmerged,\nParent ID,Child Account ID\n';
        String csvColumnHeader4 = 'Child record not in recycle bin,\nParent ID,Child Account ID\n';
        
        String csvBody1 = '';
        List<Account_Merge_Log__c> successLog = [SELECT Id, Account__c, Merged_Account_ID__c FROM Account_Merge_Log__c WHERE Id IN :success];
        for (Account_Merge_Log__c log : successLog) {
            csvBody1 += String.valueOf(log.Account__c) + ',' + String.valueOf(log.Merged_Account_ID__c) + '\n';
        }
        String csvBody2 = '';
        List<Account_Merge_Log__c> failLog = [SELECT Id, Account__c, Merged_Account_ID__c FROM Account_Merge_Log__c WHERE Id IN :fail];
        for (Account_Merge_Log__c log : failLog) {
            csvBody2 += String.valueOf(log.Account__c) + ',' + String.valueOf(log.Merged_Account_ID__c) + '\n';
        }
        String csvBody3 = '';
        List<Account_Merge_Log__c> alreadyUnmergeLog = [SELECT Id, Account__c, Merged_Account_ID__c FROM Account_Merge_Log__c WHERE Id IN :alreadyUnmerge];
        for (Account_Merge_Log__c log : alreadyUnmergeLog) {
            csvBody3 += String.valueOf(log.Account__c) + ',' + String.valueOf(log.Merged_Account_ID__c) + '\n';
        }
        String csvBody4 = '';
        List<Account_Merge_Log__c> unableToUnmergeLog = [SELECT Id, Account__c, Merged_Account_ID__c FROM Account_Merge_Log__c WHERE Id IN :unableToUnmerge];
        for (Account_Merge_Log__c log : unableToUnmergeLog) {
            csvBody4 += String.valueOf(log.Account__c) + ',' + String.valueOf(log.Merged_Account_ID__c) + '\n';
        }
        
        csvFile = csvColumnHeader1 + csvBody1 + csvColumnHeader2 + csvBody2 + csvColumnHeader3 + csvBody3 + csvColumnHeader4 + csvBody4;
            
        Messaging.SingleEmailMessage message = new Messaging.SingleEmailMessage();
        message.toAddresses = new String[] {
            userinfo.getUserEmail(), 'shubham.gupta@mandsconsulting.com'
                };
                    
        message.subject = 'Account Unmerge Status';
        String messageBody = 'Unmerge process completed!';
        message.setHtmlBody(messageBody);
        
        // Create the attachment
        Messaging.EmailFileAttachment csvAttachment = new Messaging.EmailFileAttachment();
        csvAttachment.setFileName('UnmergedRecords.csv');
        csvAttachment.setBody(Blob.valueOf(csvFile));
        csvAttachment.setContentType('text/csv');
        
        // Attach the file to the email
        
        message.setFileAttachments(new Messaging.EmailFileAttachment[] {csvAttachment });
        
        
        Messaging.sendEmail(new Messaging.SingleEmailMessage[] { message });
    }
}