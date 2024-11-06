trigger AccountMergeLog on Account_Merge_Log__c (after insert) {
    
/* SRSF-2140 -- removal of Box-related code

if(!System.IsBatch())
    {
        for(Account_Merge_Log__c triggeraml : Trigger.new){
         AccountMergeService.MoveFolder(triggeraml.Account__c, triggeraml.Merged_Account_ID__c);
        }
    }
*/
}