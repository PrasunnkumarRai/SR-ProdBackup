public class AccountMergeService {

    
    public AccountMergeService(){}


 /*  SRSF-2140  -- removal of Box-related code
    @future (callout=true)
    Public static void MoveFolder(ID AccountId, ID delAccountId){

        	box.Toolkit boxToolkit = new box.Toolkit();
        
        
        	String newparentaccountFolderId = boxToolkit.getFolderIdByRecordId(AccountId);
        	String delaccountFolderId = boxToolkit.getFolderIdByRecordId(delAccountId);
            //System.debug('New Parent Box Folder Id: '+newparentaccountFolderId +'\n Deleted Account Folder Id: '+delaccountFolderId);
            
            boolean movedFolder = boxToolkit.moveFolder(delaccountFolderId,newparentaccountFolderId, null);
        	boxToolkit.commitChanges();
           // System.debug('Folder Moved?: '+ movedFolder);
           // system.debug('most recent error: ' + boxToolkit.mostRecentError);
          
    }
    */
}