/*
###########################################################################
# File..................: AccountBillingSync.cls
# Version...............: 1
# Created by............: Ankit Bhatia   
# Created Date..........: 17 May 2017
# Last Modified by......: 
# Last Modified Date....: 
# Description...........: This class contains methods for Account Synchronization to TIM page
# TAO Ref#..............: 
# Change Log:               
#
#
############################################################################*/
global without sharing class AccountBillingSync {
    public Account acc{get; set;}

    
    public AccountBillingSync(ApexPages.StandardController std)
    {
        List<string> fieldList = new List<string>();
        fieldList.add('RecordType.Name');
        fieldList.add('Billing_Change_Status__c');
        //addFields.add('RecordTypeID');
        //Code changes Aditi : 7/7/2017
        if(!Test.isRunningTest()){
            std.addFields(fieldList);
        }
        //Code changes ends
        acc = (Account) std.getRecord();
        //syncAccounts(acc);
    }
    
    /*
    This is a future call that will be called from the trigger to sync change in account billing address to TIM.
    @parameter : Account ID
    @return void
    */
    @future(callout=true)
    public static void syncAccounts(List<Id> accIds)
    {   
      for(Id id:accIds){
        /*custom settings map variable*/
        Map<String,TIMIntegration__c> custSettMap = new Map<String,TIMIntegration__c>();
          string accountID = '';
          Boolean isSuccess = false; 
          List<AccountConnection__c> accConList = new List<AccountConnection__c>();
          Account acc = [Select ID,Name, Billing_Change_Status__c,RecordType.Name,BillingStreet, Phone,Owner.email, BillingCity, BillingState,BillingPostalCode,Agency__c,Account_Tim_Name__c from Account where ID=: id ];
          List<TIMIntegration__c> tims = TIMIntegration__c.getall().values();
          custSettMap = TIMIntegration__c.getAll();
          accConList = [Select ID,Name, Tim_ID__c,TIM_System__c,AgencyTIMID__c from AccountConnection__c where Account__r.ID = : id];    
          if(acc.Billing_Change_Status__c == System.Label.TimBillingSyncApproval_Status && accConList.size() > 0)
          {
              
              //acc.Billing_Change_Status__c = System.Label.TimBillingSyncPending_Status;
              BoomiWebServiceHelper boomi =  new BoomiWebServiceHelper();
              for(AccountConnection__c con : accConList)
              {
                  if(custSettMap.containsKey(con.TIM_System__c))
                  {
                    //custSettMap.get(con.TIM_System__c).boomi_Endpoint__c;
                      if(acc.RecordType.Name == 'Advertiser Account')
                      {
                          System.debug('acc.Name>>>>>'+acc.Name);
                          System.debug('acc.RecordType.Name>>>>>'+acc.RecordType.Name);
                          accountID = boomi.syncAccountBilling(custSettMap.get(con.TIM_System__c).boomi_Endpoint__c,'Advertiser',acc,con.TIM_ID__c,con.AgencyTIMID__c);
                      }
                      //tim.Save_Advertiser_4_2(); 
                      else
                      {
                          System.debug('acc Name>>>>>'+acc.Name);
                          System.debug('acc.Agency.Name>>>>>'+acc.RecordType.Name);
                          accountID = boomi.syncAccountBilling(custSettMap.get(con.TIM_System__c).boomi_Endpoint__c,'Agency',acc,'',con.AgencyTIMID__c);
                          System.debug('Save_Agency' + acc.RecordType.Name + acc.owner.email);
                      //tim.Save_Agency_4_2();
                      }
             if(accountID == 'Exception') 
             {
                Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                String[] toAddresses = new String[] {acc.owner.email};
                mail.setToAddresses(toAddresses);
               // mail.setToAddress(acc.owner.email);
                    mail.setSubject('Exception in Account Billing Sync: ' + acc.name);
                    mail.setPlainTextBody('Your changes to Account have not been Synchronized with TIM.\n' + 
                                          '\nAccount Name: ' + acc.name);
                if (!Test.isRunningTest()) {
                  Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
                }
                
             }
                  }
              }
              
          }
      }   
    }
}