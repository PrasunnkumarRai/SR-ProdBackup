/*
    Author : MAndS 
    Date   : 27/04/2017
    Description : Controller for custom lead conversion lightning component
    Modification History : 
*/
public with sharing class LeadConversionLCCC {
    private final static string EXISTING = 'Attach to existing: ';  // prefix for the label of existing accounts
    
    @AuraEnabled
    public static Wrapper getLeadDetails(string strRecId)
    {
        Lead objLead = [SELECT Id, Status, OwnerId, Name, FirstName, LastName, Email, Company, Owner.Name, Commodity_Codes__c FROM Lead WHERE Id = :strRecId];
        
        Wrapper objWrapper = new Wrapper ();
        objWrapper.objLead = objLead;
        objWrapper.lstStatus = getLeadStatus();
        objWrapper.lstAccounts = getAccounts(objLead);
        objWrapper.strCompany = objLead.Company;
        objWrapper.recordOwnerId = objLead.OwnerId;
        objWrapper.recordOwnerProfileName = getRecordOwnerProfileName(objLead.OwnerId);
        objWrapper.recordOwnerTeamRole = getRecordOwnerTeamRole(objLead.OwnerId);
        
        return objWrapper;
    }
    
    /*  Method: LeadStatus
        Description: set up the Lead Status picklist
    */
    private static list<string> getLeadStatus () {
        list<string> LeadStatus = new List<string>();
        //get the lead statuses
        list<LeadStatus> lstStatus = [select MasterLabel from LeadStatus where IsConverted=true order by SortOrder];
        // if there is more than 1 lead status option, add a NONE option  
        if (!lstStatus.isEmpty() && lstStatus.size() > 1) {
            LeadStatus.add('-None-');
        }
        // add the rest of the lead status options
        for (LeadStatus convertStatus : lstStatus){
            LeadStatus.add(convertStatus.MasterLabel);
        } 
        return LeadStatus;
    }
    
    /*  Method: populateAccounts
        Description: populate the list of Accounts in the dropdown
    */
    private static list<string> getAccounts(Lead objLead) 
    {
        if (objLead != null) {
            string strCompany = objLead.Company;
            // find any accounts that match the SOSL query in the findCompany() method  
            list<Account> lstAccFound = findCompany(strCompany + '*');
            list<string> lstAccounts = new list<string>();
            if (lstAccFound != null && lstAccFound.size() > 0) {
              // if there is at least 1 account found add a NONE option and a Create New Account option
                lstAccounts.add('NONE#$#-None-');
                lstAccounts.add('NEW#$#Create New Account: ' + strCompany);
                // for each account found, add an option to attach to the existing account
                for (Account a : lstAccFound) {
                    lstAccounts.add(a.Id+'#$#'+ EXISTING + a.Name);
                }
            }
            else {
                //if no accounts matched then simply add a Create New Account option
                lstAccounts.add('NEW#$#Create New Account: ' + strCompany);
                system.debug('no account matches on company ' + strCompany);
            }
            return lstAccounts;
        }
        return null;
    }
    
    /*  Method: findCompany
        Description: Find an Account using SOSL based on the given company name
    */
    private static list<Account> findCompany (string strCompanyName) {
        //perform the SOSL query
        List<List<SObject>> lstResults = [
            FIND :strCompanyName 
            IN NAME FIELDS 
            RETURNING 
            Account(
                Id, 
                Name limit 2000
            )
        ];
        List <Account> lstAccFound = new List<Account>();
        for (List <sobject> sObjs : lstResults) {
            for (sObject s : sObjs) {
              //add the account that was found to the list of found accounts
                lstAccFound.add((Account) s);
            }   
        }
        return lstAccFound;
    }
    
    /*  Method: getLookedUpAccount
        Description: this gets called when an existing accout gets looked up via the lookup magnifying glass 
    */
    @AuraEnabled
    public static string getLookedUpAccount(string strAccId) {
        string strOptn;
        //find the Id and Name of the Account that was looked up        
        list<Account> lstAcc = [SELECT Id, Name FROM Account WHERE Id = :strAccId];
        if (!lstAcc.isEmpty() && lstAcc.size() > 0) {
            // add the locked up account to the slect list
            strOptn = lstAcc[0].Id+'#$#'+ EXISTING + lstAcc[0].Name;
        }
        return strOptn;
    }
    
    /*  Method: convertLead
        Description: This method is called when the user clicks the Convert button on the VF Page
    */
    @AuraEnabled
    public static string convertLead(Lead objLead, string strSelectedAccount, boolean doNotCreateOppty, string strOppName, string strOwnerId) 
    {
        system.debug('===========>> in convertLead!!!');
        string strAccId;
        string strError ='';
        Boolean createAccount = false;
		System.debug('Lead '+ objLead);
		System.debug('Selected Accounts  '+ strSelectedAccount);
		System.debug('doNotCreateOppty  '+ doNotCreateOppty);
		System.debug('Opportunity Name '+ strOppName);
		System.debug('strOwnerId    '+ strOwnerId);
        
        try{
            //to prevent any workflows or approval processes from firing
            Lead objLeadToUpdate = new Lead ();
            if(objLead != null)
            {
                objLeadToUpdate = [SELECT Id, Status, OwnerId, Name, FirstName, LastName, Email, Company, Owner.Name, Street, City, State, Country, PostalCode, Commodity_Codes__c
                                        FROM Lead WHERE Id = :objLead.Id];
                objLeadToUpdate.Exclude_Flows__c = true;
                if(objLeadToUpdate.Commodity_Codes__c == null) {
                    strError = 'You must set Commodity Codes on the Lead before converting.';
                    throw new AuraHandledException(strError);
                    //throw new System.DmlException('You must set Commodity Codes on the Lead before converting.');
                }
                Database.SaveResult acc = Database.update(objLeadToUpdate, false);
                for(Database.Error err : acc.getErrors())
                    strError += err.getMessage()+'</br>';
                if(!acc.isSuccess())
                    throw new System.DmlException(strError);
            }
            
            //if user selects to create new account
            if(strSelectedAccount == 'NEW')
            {
                system.debug('--------------objLead------------------'+ objLeadToUpdate);
                Account objAccount = new Account ();
                objAccount.Name = objLeadToUpdate.Company;
                objAccount.BillingStreet = objLeadToUpdate.Street;
                objAccount.BillingCity = objLeadToUpdate.City;
                objAccount.BillingState = objLeadToUpdate.State;
                objAccount.BillingCountry = objLeadToUpdate.Country;
                objAccount.BillingPostalCode = objLeadToUpdate.PostalCode;
                objAccount.Skip_Address_Validation__c = true;
             
                Database.DMLOptions dml = new Database.DMLOptions();
                dml.DuplicateRuleHeader.AllowSave = true; 
                Database.SaveResult acc = Database.insert(objAccount, dml);
                for(Database.Error err : acc.getErrors())
                    strError += err.getMessage()+'</br>';
                system.debug(loggingLevel.WARN, '$$$$$$$$$$$---->> strError = ' + strError);
                if(!acc.isSuccess())
                    throw new System.DmlException(strError);
                strSelectedAccount = acc.getId();
                system.debug(loggingLevel.WARN, '$$$$$$$$$$$---->> acc = ' + acc);
                system.debug(loggingLevel.WARN, '$$$$$$$$$$$---->> strSelectedAccount = ' + strSelectedAccount);
                createAccount = true;
            }
        
            // This is the lead convert object that will convert the lead 
            Database.LeadConvert objLeadConvert = new database.LeadConvert();

            system.debug(loggingLevel.WARN, '===========>> strSelectedAccount = ' + strSelectedAccount);
            
            objLeadConvert.setLeadId(objLead.Id);   //set lead ID   
            objLeadConvert.setAccountId(strSelectedAccount);
            objLeadConvert.setConvertedStatus(objLead.Status);  //set the lead convert status
            objLeadConvert.setDoNotCreateOpportunity(doNotCreateOppty); //set the variable to create or not create an opportunity
            system.debug('--------------strError------------------'+ strError);
            system.debug('===========================>> oppty name = ' + strOppName);
            objLeadConvert.setOpportunityName(((doNotCreateOppty) ? null : strOppName));    //set the Opportunity name
            system.debug('--------------strError------------------'+ strError);
            objLeadConvert.setOwnerId(strOwnerId);  //set the owner id
            system.debug('objLeadConvert --> ' + objLeadConvert);
        
            //convert the lead

            Database.DMLOptions dml = new Database.DMLOptions();
            dml.DuplicateRuleHeader.AllowSave = true; 
            Database.LeadConvertResult leadConvertResult = Database.convertLead(objLeadConvert,dml);
            system.debug(loggingLevel.WARN, '=============>> leadConvertResult = ' + leadConvertResult);
            for(Database.Error err : leadConvertResult.getErrors()){
                    //Commentted by Madhusudhan to handle System.TypeCast Exception on 14 Jun-17
                    //Datacloud.DuplicateResult dupRes = ((Database.DuplicateError) err).getDuplicateResult();
                    //System.debug(LoggingLevel.WARN, '===============>> duplicate error rule = ' + dupRes.getDuplicateRule());
                    strError += err.getMessage()+'</br>';
                    //system.debug('--------------strError------------------'+ strError);
             }
             system.debug('--------------strError------------------'+ strError);
            if(!leadConvertResult.isSuccess())

                throw new System.DmlException(strError);

            system.debug('--------------strError------------------'+ strError);
            system.debug('%%%%%%%%%%%%%%%--->> leadConvertResult = ' + leadConvertResult);
            // if the lead converting was a success 
            if (leadConvertResult.isSuccess())
            //// BAB    strAccId = strSelectedAccount;
           ////     if (!createAccount)
           ////         strAccId = strSelectedAccount;
           ////     else
                    strAccId = leadConvertResult.getAccountId();
        }
        catch(exception ex)
        {
            system.debug('Exception..'+ex);
            throw new AuraHandledException(strError);
        }
        return strAccId;
    }
    
    @AuraEnabled
    public static String getRecordOwnerTeamRole(Id OwnerId)
    {
        if(OwnerId == null) {
            OwnerId = UserInfo.getUserId();
        }
        User recordOwner = [SELECT Team_Role__c FROM User WHERE Id = :OwnerId ];
        return recordOwner.Team_Role__c;
    }
    
    @AuraEnabled
    public static String getRecordOwnerProfileName(Id OwnerId)
    {
        if(OwnerId == null) {
            OwnerId = UserInfo.getUserId();
        }
        User recordOwner = [SELECT Profile.Name FROM User WHERE Id = :OwnerId ];
        return recordOwner.Profile.Name;
    }
    
    public class Wrapper
    {
        @AuraEnabled
        public Lead objLead;
        @AuraEnabled
        public list<string> lstStatus;
        @AuraEnabled
        public list<string> lstAccounts;
        @AuraEnabled
        public string strCompany;
        @AuraEnabled
        public string recordOwnerId;
        @AuraEnabled
        public string recordOwnerTeamRole;
        @AuraEnabled
        public string recordOwnerProfileName;
    }
}