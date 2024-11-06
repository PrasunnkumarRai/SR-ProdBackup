public class AccountMergeRetryAndEmailBatch implements Database.Batchable<SObject> {
    private String trxnId;

    public AccountMergeRetryAndEmailBatch(String trxnId) {
        this.trxnId = trxnId;
    }

    public Database.QueryLocator start(Database.BatchableContext BC) {
        return Database.getQueryLocator([SELECT Id, Account__c, Merged_Account_ID__c 
            FROM Account_Merge_Log__c 
            WHERE TransactionId__c =: trxnId 
            AND (isRowLock__c = true OR isACR__c = true)
        ]);
    }

    public void execute(Database.BatchableContext BC, List<SObject> scope) {
        List<Account_Merge_Log__c> mergeLogs = (List<Account_Merge_Log__c>) scope;
        // Perform merging logic here
        for (Account_Merge_Log__c mergeLog : mergeLogs) {
            mergeLog.isRowLock__c = false;
            mergeLog.isACR__c = false;
            update mergeLog;

            AccountMergeUpdate.mergeAccounts(mergeLog.Id, mergeLog.Account__c, mergeLog.Merged_Account_ID__c, 'Merging');

        }
    }

    public void finish(Database.BatchableContext BC) {
        Integer successCount = 0;
        Integer failCount = 0;
        String csvBody = '';
        List<Account_Merge_Log__c> allMergeLogs = [SELECT Id, Account__c, Merged_Account_ID__c, TransactionId__c, Error_Description__c FROM Account_Merge_Log__c WHERE TransactionId__c =: trxnId];
        for (Account_Merge_Log__c log : allMergeLogs) {
            if (log.Error_Description__c == null) {
                successCount++;
                csvBody += String.valueOf(log.Account__c) + ',' + String.valueOf(log.Merged_Account_ID__c) + '\n';
            }
            else {
                failCount++;
            }
        }
        
        
        // Create CSV file content
        String csvFile;
        String csvColumnHeader = 'Parent ID,Child Account ID\n';
        // Combine header and body to form complete CSV file content
        csvFile = csvColumnHeader + csvBody;
        
        
        Integer totalAccounts = successCount + failCount;
        String urlSF = URL.getOrgDomainUrl().toExternalForm();
        Messaging.SingleEmailMessage message = new Messaging.SingleEmailMessage();
        message.toAddresses = new String[] {
            userinfo.getUserEmail(), 'shubham.gupta@mandsconsulting.com'
                };
                    
        message.subject = 'Account Bulk Merge Status';
        String messageBody = '<html><body>Hi ' + userinfo.getName() +
            ', <br/>Please review the error records HERE: <a href="' +
            urlSF +
            '/lightning/o/Account_Bulk_Merge__c/list?filterName=All">Click here</a> <br/><br/> Following are the details of Bulk Account Merge<br/><br/><table border="1"><thead><tr><th>Object Name</th><th>Total Count</th><th>No of Success</th><th>No of Error</th></tr></thead>';
        messageBody += '<tbody><tr><td>Account Bulk Merge</td><td>' +
            totalAccounts + '</td><td style="color:green;">' +
            successCount + '</td><td style="color:red;">' +
            failCount + '</td></tr>';
        messageBody += '</tbody></table></body></html><br/><br/>Thanks';
        message.setHtmlBody(messageBody);
        
        // Create the attachment
        Messaging.EmailFileAttachment csvAttachment = new Messaging.EmailFileAttachment();
        csvAttachment.setFileName('MergedRecords.csv');
        csvAttachment.setBody(Blob.valueOf(csvFile));
        csvAttachment.setContentType('text/csv');
        
        // Attach the file to the email
        
        message.setFileAttachments(new Messaging.EmailFileAttachment[] {csvAttachment });
        
        
        Messaging.sendEmail(new Messaging.SingleEmailMessage[] { message });
    }
    
}