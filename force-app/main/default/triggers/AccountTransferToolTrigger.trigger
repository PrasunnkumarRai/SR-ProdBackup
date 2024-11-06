trigger AccountTransferToolTrigger on Account_Transfer_Tool__c (after update, after delete) {
	
	if(Trigger.IsUpdate){
		List<Account_Transfer_Tool__c> attList = new List<Account_Transfer_Tool__c>();
		for(Account_Transfer_Tool__c att : Trigger.New){
					
			if(att.All_Transfer_Logs_Created__c == true){
				Account_Transfer_Tool__c oldAtt = Trigger.OldMap.get(att.Id);
				//&& att.Status__c == 'Transfer In Progress' && oldAtt.Status__c != 'Transfer In Progress'
				if(!oldAtt.All_Transfer_Logs_Created__c && att.Status__c == 'Transfer In Progress'){
					attList.add(att);
				}
			}
		}
		if(attList.size() >0){
			New_AETransferToolController.initiateTransfer(attList);
		}
	}
	
	if(Trigger.IsDelete){
		for(Account_Transfer_Tool__c att : Trigger.Old){
			if(!Label.AccountTransferDeleteStatus.contains(att.status__c)){
				att.addError('You can only delete Account Transfer Simulation records with '+ Label.AccountTransferDeleteStatus +' Status.');
			}
		}
					
	}
}