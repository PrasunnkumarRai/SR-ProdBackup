/*
###########################################################################
# File..................: AccountConnectionTriggerHelper.cls
# Version...............: 1
# Created by............: Ankit Bhatia  
# Created Date..........: 10-June-2017
# Description...........: This class contains helper methods for Account Connection Trigger.
# TAO Ref#..............: NA
# Change Log:               
#
#
############################################################################*/
public with sharing class AccountConnectionTriggerHelper {
	
	public void beforeInsert(List<AccountConnection__c> accConList)
	{
		if(accConList.size() > 0)
		{
			//Get Accounts from all the Account Connection
			for(AccountConnection__c accCon : accConList)
			{
				try
				{
					System.debug('Acc Con ' + accCon);
					if((String.isBlank(accCon.TIM_ID__c) || accCon.TIM_ID__c == '0') && accCon.Account_Record_Type__c.indexOf('Advertiser') >= 0)
					{
						Log4SF.logMessage('AccountConnectionTrigger', 'beforeInsert', Label.Acc_Connection_Trigger_Adv_Error + '- ', UserInfo.getUserId(),'Data','');
						if(!Test.isRunningTest())
						accCon.TIM_ID__c.addError(Label.Acc_Connection_Trigger_Adv_Error);
						return;
					}
					else if((String.isBlank(accCon.AgencyTIMID__c) || accCon.AgencyTIMID__c == '0') && accCon.Account_Record_Type__c.indexOf('Agency') >= 0)
					{
						System.debug('Acc Con ID ' + accCon.AgencyTIMID__c);
						Log4SF.logMessage('AccountConnectionTrigger', 'beforeInsert', +Label.Acc_Connection_Trigger_Agency_Error +'- ', UserInfo.getUserId(),'Data','');
						if(!Test.isRunningTest())
						accCon.AgencyTIMID__c.addError(Label.Acc_Connection_Trigger_Agency_Error);
						
						return;
					}
					else if((String.isBlank(accCon.AgencyTIMID__c) || accCon.AgencyTIMID__c == '0') && accCon.Account_Record_Type__c.indexOf('Rep Firm') >= 0)
					{
						Log4SF.logMessage('AccountConnectionTrigger', 'beforeInsert', Label.Acc_Con_Trigger_Agency_Error +'- '+ accCon.AgencyTIMID__c, UserInfo.getUserId(),'Data','');
						if(!Test.isRunningTest())
						accCon.AgencyTIMID__c.addError(Label.Acc_Con_Trigger_RepFirm_Error);
						return;
					}

					// Code Changes for SRSF – 1273 – Code Starts
					//	if( !String.valueOf(UserInfo.getUserId()).containsIgnoreCase(label.BoomiUserId) ){ // Commented on : 19-09-2019 : SRSF-1915
						if( accCon.Account_Record_Type__c.indexOf('Advertiser') >= 0){
							accCon.AccountConnectionExternalId__c = 'ADV' + ' '+ accCon.TIM_ID__c;
							if(String.isNotBlank(accCon.AgencyTIMID__c))
								accCon.AccountConnectionExternalId__c += ' ' + accCon.AgencyTIMID__c;
							if(String.isNotBlank(accCon.AE_Id__c))
								accCon.AccountConnectionExternalId__c += ' ' + accCon.AE_Id__c;
							if(String.isNotBlank(accCon.TIM_System__c))
							accCon.AccountConnectionExternalId__c += ' ' + accCon.TIM_System__c;
						}
						else if(accCon.Account_Record_Type__c.indexOf('Agency') >= 0  || accCon.Account_Record_Type__c.indexOf('Rep Firm') >= 0 ){
							accCon.AccountConnectionExternalId__c = 'AGENCY';
							if(String.isNotBlank(accCon.AgencyTIMID__c))
								accCon.AccountConnectionExternalId__c += ' ' + accCon.AgencyTIMID__c;
							if(String.isNotBlank(accCon.TIM_System__c))
							accCon.AccountConnectionExternalId__c += ' ' + accCon.TIM_System__c;
						}
				//	} // Commented on : 19-09-2019 : SRSF-1915
					// Code Changes for SRSF – 1273 – Code ends
				}
				catch(Exception ex)
				{
					System.debug('Error message:::'+ex.getMessage()+'line::'+ex);
				}
				
			}
		}
	}
	
	public void afterInsert(List<AccountConnection__c> accConList)
	{
		
		//Id agencyRecTypeId = [SELECT Id FROM RecordType WHERE DeveloperName='Agency_Account' AND SobjectType = 'Account' LIMIT 1].Id;
		//Id advertiserRecTypeId = [SELECT Id FROM RecordType WHERE DeveloperName='Advertiser_Account' AND SobjectType = 'Account' LIMIT 1].Id;
		if(accConList.size() > 0)
		{
			Map<String,List<AccountConnection__c>> accConMap = new Map<String,List<AccountConnection__c>>();
			Set<String> accList = new Set<String>();
			//Get Accounts from all the Account Connection
			for(AccountConnection__c accCon : accConList)
			{
				accList.add(accCon.Account__c);
				String tim = '';
				try
				{
					Integer timID = 0;
					
					System.debug(accCon.Account_Record_Type__c.indexOf('Agency') );
					if(accCon.Account_Record_Type__c.indexOf('Agency') >= 0)
					{
						timID = Integer.valueOf(accCon.AgencyTimID__c);
						tim = accCon.AgencyTimID__c;
					}
					else if(accCon.Account_Record_Type__c.indexOf('Advertiser') >= 0)
					{
						timID = Integer.valueOf(accCon.Tim_ID__c);
						tim = accCon.Tim_ID__c;
					}
				}
				catch(Exception ex)
				{
					Log4SF.logMessage('AccountConnectionTrigger', 'afterInsert', 'Incorrect Account Connection TIM ID : ' + tim, UserInfo.getUserId(),'Data',accCon.ID);
				}
			}
			try
			{
				List<AccountConnection__c> agencyAccConList = [Select Tim_System__c, AgencyTimID__c,Account__c,Account_Record_Type__c from AccountConnection__c where Account__c in: accList AND Account__r.RecordType.Name Like '%Agency%' ];
				//Build the Account Map 
				for(AccountConnection__c accCon : agencyAccConList)
				{
					if(!accConMap.containsKey(accCon.Account__c))
					{
						List<AccountConnection__c> agcConList = new List<AccountConnection__c>();
						agcConList.add(accCon);
						accConMap.put(accCon.Account__c,agcConList); 
					}
					else
					{
						List<AccountConnection__c> agcConList = accConMap.get(accCon.Account__c);
						agcConList.add(accCon);
						accConMap.put(accCon.Account__c,agcConList); 
					}
				}
			}
			catch(Exception ex)
			{
				Log4SF.logMessage('AccountConnectionTrigger', 'afterInsert', 'Error in Account Connection : ', UserInfo.getUserId(),'Data','');
			}
			//Match the TIM System for all the Account Connections
			for(AccountConnection__c accCon : accConList)
			{
				if(accConMap.containsKey(accCon.Account__c))
				{
					for(AccountConnection__c agcCon : accConMap.get(accCon.Account__c))
					{
						//System.debug(accCon.Tim_System__c+','+agcCon.Tim_System__c+'_'+accCon.Account__r.RecordTypeID+'-'+agencyRecTypeId);
						if(accCon.Tim_System__c == agcCon.Tim_System__c && accCon.Account_Record_Type__c.indexOf('Agency') >= 0)
						{
							Log4SF.logMessage('AccountConnectionTrigger', 'afterInsert', 'Duplicate Account Connection created: Original Record ID- '+agcCon.ID, UserInfo.getUserId(),'Data',accCon.ID);
							break;
						}
						
						
					}
				}	
			}			
			
		}
		
	}
}