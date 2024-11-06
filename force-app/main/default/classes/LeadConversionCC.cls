/*
    Author : MAndS 
    Date   : 26/04/2017
    Description : Extension for custom lead conversion
    Modification History : 
*/
public with sharing class LeadConversionCC {
    public  Lead objLead {get; set;}    // This is the lead that is to be converted
    public Task objTask {get; set;}     // The Task object the component will interact with
    public boolean sendOwnerEmail {get; set;}   // checkbox on the component indicating if there will be an email sent to the owner 
    public Boolean doNotCreateOppty {get; set;} // Checkbox on the component indicating if an Opportunity should be created
    public Opportunity objOpportunity {get; set;}   // This will hold the Opportunity for the Opportunity name on the comonent 
    public List<SelectOption> lstAccounts {get; set;}   // the list of lstAccounts in the select list
    private final string EXISTING = 'Attach to existing: '; // prefix for the label of existing accounts
    public string strSelectedAccount {get; set;}    // the selected account in the select list of accounts
    public Boolean reminder {get; set;}
    
    // task priorities and statuses 
    private transient List<Schema.PicklistEntry> lstTaskStatuses = Task.Status.getDescribe().getPicklistValues();
    private transient List<Schema.PicklistEntry> lstTaskPriorities = Task.Priority.getDescribe().getPicklistValues();
    
    /* This will hold the owner of Lead */
    public Contact objContact {
        get {
            if (objContact == null) {
                objContact = new Contact(OwnerId = objLead.ownerId);
            }
            return objContact;
        }
        set;
    }
    /* Extension */
    public LeadConversionCC(ApexPages.StandardController stdController) {
        objOpportunity = new Opportunity(); //new opportunity
        
        //create the Task that will hold information gathered on the component 
        objTask = new Task();
        
        //the reminder is set to true
        objTask.IsReminderSet = true;
        reminder = true;
        
        // set the default values for the status and priority fields
        objTask.Status = TaskDefaulValue(lstTaskStatuses);
        objTask.Priority = TaskDefaulValue(lstTaskPriorities);
        
        //the reminder date will be set to now by default
        objTask.ReminderDateTime = datetime.now();
        
        //get the ID to query for the Lead fields
        Id leadId = stdController.getId();
        
        objLead = [SELECT Id, Status, OwnerId, Name, Company FROM Lead WHERE Id = :leadId];
        // set the selected Account to NONE by default
        strSelectedAccount = 'NONE';
        populateAccounts();
    }
    
    /*  Method: populateAccounts
        Description: populate the list of Accounts in the dropdown
    */
    private void populateAccounts() 
    {
        if (objLead != null) {
            string strCompany = objLead.Company;
            // find any accounts that match the SOSL query in the findCompany() method  
            list<Account> lstAccFound = findCompany(strCompany + '*');
            lstAccounts = new List<selectOption>();
            if (lstAccFound != null && lstAccFound.size() > 0) {
              // if there is at least 1 account found add a NONE option and a Create New Account option
                lstAccounts.add(new SelectOption('NONE', '-None-'));
                lstAccounts.add(new SelectOption('NEW', 'Create New Account: ' + strCompany ));
                // for each account found, add an option to attach to the existing account
                for (Account a : lstAccFound) {
                    lstAccounts.add(new SelectOption(a.Id, EXISTING + a.Name));
                }
            }
            else {
                //if no accounts matched then simply add a Create New Account option
                lstAccounts.add(new SelectOption('NEW', 'Create New Account: ' + strCompany ));
                system.debug('no account matches on company ' + strCompany);
            }
            //the default opportunity name will be the lead's company
            objOpportunity.Name = strCompany + '-';
        }
        else system.debug('leadConvert = null');
    }
    
    /*  Method: findCompany
        Description: Find an Account using SOSL based on the given company name
    */
    private list<Account> findCompany (string strCompanyName) {
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
    
    /*  Method: getChangedAccount
        Description: when the selected account in the select list of accounts changes this method is called 
    */
    public PageReference getChangedAccount() {
        // if either the NONE option or the Create New Account option is selected, the Opportuniy Name is set to the lead's company
        if (strSelectedAccount == 'NEW' || strSelectedAccount == 'NONE') {
            objOpportunity.Name = objLead.Company  + '-';
        }
        else {
            // otherwise find the account's Id and Name that was selected and set the Opportuity name to that Account
            list<Account> lstAcc = [SELECT Id, Name FROM Account WHERE Id = :strSelectedAccount];
            if (!lstAcc.isEmpty() && lstAcc.size() > 0) {
                objOpportunity.Name = lstAcc[0].Name + '-';
            }
        }
        return null;
    }
    
    /*  Method: getLookedUpAccount
        Description: this gets called when an existing accout gets looked up via the lookup magnifying glass 
    */
    public PageReference getLookedUpAccount() {
        system.debug('!!! Account looked up --> ' + objContact.AccountId );
        //find the Id and Name of the Account that was looked up        
        list<Account> lstAcc = [SELECT Id, Name FROM Account WHERE Id = :objContact.AccountId];
        if (!lstAcc.isEmpty() && lstAcc.size() > 0) {
            // add the locked up account to the slect list
            lstAccounts.add(new SelectOption(lstAcc[0].Id, EXISTING + lstAcc[0].Name));
            // set the selected account to the one that was just looked up by default
            strSelectedAccount = lstAcc[0].Id;
            // set the Opportunity name to the account's name that was looked up
            objOpportunity.Name = lstAcc[0].Name + '-';
            system.debug('lstAccounts --> ' + lstAccounts);
        }
        return null;
    }
    
    /*  Method: LeadStatus
        Description: set up the Lead Status picklist
    */
    public List<SelectOption> LeadStatus {
        get {
            if(LeadStatus == null) {
                LeadStatus = new List<SelectOption>();
                //get the lead statuses
                list<LeadStatus> lstStatus = [select MasterLabel from LeadStatus where IsConverted=true order by SortOrder];
                // if there is more than 1 lead status option, add a NONE option  
                if (!lstStatus.isEmpty() && lstStatus.size() > 1) {
                    LeadStatus.add(new SelectOption('NONE', '-None'));
                }
                // add the rest of the lead status options
                for (LeadStatus convertStatus : lstStatus){
                    LeadStatus.add(new SelectOption(convertStatus.MasterLabel, convertStatus.MasterLabel));
                } 
            }
            return LeadStatus;
        }
        set;
    }
    
    /*  Method: TaskDefaulValue
        Description: set the default value based on the picklist sent to the method
    */
    private String TaskDefaulValue(List<Schema.PicklistEntry> pickList)
    {
        String strDefaultValue = '';
        for(Schema.PicklistEntry entry : pickList)
        {
          //if this is the default value then set it
            if(entry.isDefaultValue())
            {
                strDefaultValue = entry.getLabel();
                break;
            }
        }
        return strDefaultValue;
    }
    
    /*  Method: TaskStatus
        Description: this method will get the Task's Statuses
    */
    public List<SelectOption> TaskStatus {
        get {
            if(TaskStatus == null) {
                TaskStatus = new List<SelectOption>();
                for (Schema.PicklistEntry status : lstTaskStatuses)
                {
                    TaskStatus.add(new SelectOption(status.getLabel(), status.getLabel()));
                } 
            }
            return TaskStatus;
        }
        set;
    }
    
    /*  Method: TaskPriority
        Description: this method will get the Task's Priorities
    */
    public List<SelectOption> TaskPriority {
        get {
            if(TaskPriority == null) {
                TaskPriority = new List<SelectOption>();
                
                for (Schema.PicklistEntry priority : lstTaskPriorities)
                {
                    TaskPriority.add(new SelectOption(priority.getLabel(), priority.getLabel()));
                } 
            }
            return TaskPriority;
        }
        set;
    }
    
    /*  Method: convertLead
        Description: This method is called when the user clicks the Convert button on the VF Page
    */
    public PageReference convertLead() {
        // This is the lead convert object that will convert the lead 
        Database.LeadConvert objLeadConvert = new database.LeadConvert();
        // if a due date is set but the subject is not, then show an error 
        if (objTask != null && objTask.ActivityDate != null && string.isBlank(objTask.Subject)){
            PrintError('You must enter a Subject if a Due Date is set..');
            return null;
        } 
        
        // if Lead Status is not entered show an error  
        if (objLead != null && objLead.Status == 'NONE'){
            PrintError('Please select a Lead Status.');
            return null;
        } 
        objLeadConvert.setLeadId(objLead.Id);   //set lead ID   
        
        //if the Account is not set, then show an error
        if (strSelectedAccount == 'NONE')
        {
            PrintError('Please select an Account.');
            return null;
        }
        // otherwise set the account id
        else if (strSelectedAccount != 'NEW') {
            objLeadConvert.setAccountId(strSelectedAccount);
        }
        
        objLeadConvert.setConvertedStatus(objLead.Status);  //set the lead convert status
        objLeadConvert.setDoNotCreateOpportunity(doNotCreateOppty); //set the variable to create or not create an opportunity
        objLeadConvert.setOpportunityName(((doNotCreateOppty) ? null : objOpportunity.Name));   //set the Opportunity name
        objLeadConvert.setOwnerId(objContact.ownerID);  //set the owner id
        objLeadConvert.setSendNotificationEmail(sendOwnerEmail);    //set whether to have a notification email
        
        system.debug('objLeadConvert --> ' + objLeadConvert);
        
        //convert the lead
        Database.LeadConvertResult leadConvertResult = Database.convertLead(objLeadConvert);
        
        // if the lead converting was a success then create a task
        if (leadConvertResult.success)
        {
            if(objTask != NULL && objTask.subject != null)
            {
                //create a new task
                Task objNewTask = new Task();
                //set whether there is a reminder
                //objNewTask.IsReminderSet = myTaskComponentController.remCon.taskID.IsReminderSet;
                
                //if the reminder is set, and the reminder's date is set
                /*if (objNewTask.IsReminderSet 
                    && myTaskComponentController.remCon.taskID.ActivityDate != null) {
                    
                    //set the reminder time based on the reminder class's ActivityDate
                    //The date and time in the reminder class is converted into a datetime by the convertToDatetime() method
                    objNewTask.ReminderDateTime = 
                        convertToDatetime(
                            myTaskComponentController.remCon.taskID.ActivityDate,
                            myTaskComponentController.remCon.reminderTime
                        );
                    system.debug('objNewTask.ReminderDateTime --> ' + objNewTask.ReminderDateTime);
                    
                }   */
                
                objNewTask.WhatId = leadConvertResult.getOpportunityId();   //set the whatId to the Opportunity Id    
                objNewTask.WhoId = leadConvertResult.getContactId();    //set the whoId to the contact Id
                objNewTask.Subject = objTask.Subject;    //set the subject
                objNewTask.Status = objTask.Status;     //set the status
                objNewTask.ActivityDate = objTask.ActivityDate;     //set the activity date 
                objNewTask.Priority = objTask.Priority;     //set the Priority 
                objNewTask.Description =  objTask.Description;  //set the Description field
                
                insert objNewTask;
            }
            
            // redirect the user to the newly created Account
            PageReference pageRef = new PageReference('/' + leadConvertResult.getAccountId());
            pageRef.setRedirect(true);
            return pageRef; 
        }
        else
        {
            //if converting was unsucessful, print the errors to the pageMessages and return null
            System.Debug(leadConvertResult.errors);
            PrintErrors(leadConvertResult.errors);
            return null;
        }
        return null;
    }
    
    /*  Method: PrintErrors
        Description: this method will take database errors and print them to teh PageMessages.
    */
    public void PrintErrors(Database.Error[] errors)
    {
        for(Database.Error error : errors)
        {
            ApexPages.Message msg = new ApexPages.Message(ApexPages.Severity.ERROR, error.message);
            ApexPages.addMessage(msg);
        }
    }
    
    /*  Method: PrintError
        Description: This method will put an error into the PageMessages on the page
    */
    public void PrintError(string error) {
        ApexPages.Message msg = new 
        ApexPages.Message(ApexPages.Severity.ERROR, error);
        ApexPages.addMessage(msg);
    } 
}