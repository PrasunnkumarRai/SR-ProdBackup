/*
###########################################################################
# File..................: AssignInterimAEController.cls
# Version...............: 1
# Created by............: Sridhar Aluru
# Created Date..........: 18-Jun-2021
# Last Modified by......:
# Last Modified Date....:
# Description...........: This class contains controller methods for managing AssignInterimAE page
# TAO Ref#..............: NA
# Test Class............: AssignInterimAEControllerTest.cls
# Change Log............:
#
############################################################################*/
public with sharing class AssignInterimAEController 
{
    public Account assignAccount {get; set;}  // To show From LSM selection
    public Account assignAccountTo {get; set;} // To show To LSM selection
    public User loggedInUser {get; set;} 
    public String loggedInUserProfile {get; set;}    
    public Interim_AE_Account__c interimAcct;
    public Boolean isLSM{get; set;}
    public String effectiveMonthYear{get;set;}

    
    public List<String> lsmProfiles;
    Map <String, Decimal> amtBefore = new Map<String, Integer>();
    Decimal janBefore = 0;
    public List<User> userTemp = new List<User>();
    public Map<Id,String> userMap {get; set;}
    public List<User> userTempTo = new List<User>();   

    public Map<String,List<String>> ucMap ;

    public static Map<String,Integer> mapDate = new Map<String, Integer>{'Jan' => 01, 'Feb' => 02,'Mar' => 03,'Apr' => 04,'May' => 05,'Jun' => 06,'Jul' => 07,'Aug' => 08,'Sep' => 09,'Oct' => 10,'Nov' => 11,'Dec' => 12}; //SRSF-4099
    public static Boolean isDuplcateTSA{get; set;} //SRSF-4099


    public AssignInterimAEController()
    {
        assignAccount = new Account();
        assignAccountTo = new Account();          
        ucMap = new Map<String,List<String>>();   
        userMap = new Map<Id,String>();
        interimAcct = new Interim_AE_Account__c();        

        isDuplcateTSA = FALSE; //SRSF-4099
        
        loggedInUser = [SELECT Id,Name,Profile.Name,Division__c,Region__c FROM User WHERE Id=: UserInfo.getUserId()];
        userMap.put(loggedInUser.Id,loggedInUser.Name);
        
        

        for(UserClassification__mdt uc: [SELECT Id, DeveloperName, User_profiles__c FROM UserClassification__mdt LIMIT 25]){
            if(uc.user_profiles__c.contains(loggedInUser.Profile.Name)){
                loggedInUserProfile = uc.DeveloperName;
            }            
        }

        if(loggedInUserProfile == 'LSM'){
            isLSM = true;           
            assignAccount.LSM_Selection__c = loggedInUser.Id;
        }        
        lsmProfiles = new List<String>();  
        String dosDivision = '%'+loggedInUser.Division__c; 

        for(User u : [SELECT Name,Id FROM User WHERE (Division__c LIKE: dosDivision) AND (Region__c =: loggedInUser.Region__c)]) {
            userMap.put(u.Id,u.Name);                   
        }

        getEffectiveMonth();
    } 
    

    // Method used to display the Month & Year from current Month on VF Page 
    public List<SelectOption> getEffectiveMonth() {
        List<SelectOption> options = new List<SelectOption>();
        options.add(new SelectOption('None','None'));
        String effectiveMonth = '';
        String effectiveMonthVal = '';
        for(Integer i = 0; i < 12; i++){
            /* Removed logic to show current month based on certain Date
            if(Date.Today().day()<=Integer.valueOf(System.Label.ChooseDay_InterimAEEffectiveMonth)){
                effectiveMonth = DateTime.now().addmonths(i).format('MMM YYYY'); 
                effectiveMonthVal = DateTime.now().addmonths(i).format('YYYYMMM'); 
            } else {
                effectiveMonth = DateTime.now().addmonths(i+1).format('MMM YYYY'); 
                effectiveMonthVal = DateTime.now().addmonths(i+1).format('YYYYMMM'); 
            }
            */     
            effectiveMonth = DateTime.now().addmonths(i).format('MMM yyyy'); 
            effectiveMonthVal = DateTime.now().addmonths(i).format('yyyyMMM');              
            options.add(new SelectOption(effectiveMonthVal, effectiveMonth));
        }
        System.debug('options>>>>'+options);
        return options;
    }

    // Method used to get the Last Sunday date of the Month to calculate Broadcast Month Dates
    public static Date getBroadcast(Date dt)
    {           
        Integer numberOfDaysInMonth = Date.daysInMonth(dt.year(), dt.month());       
        Date lastDate = Date.newInstance(dt.year(), dt.month(), numberOfDaysInMonth);            
        DateTime lastDay = DateTime.newInstance(lastDate, Time.newInstance(12, 0, 0, 0));       
        String lastDayWeekName = lastDay.format('EEE');
        Date lastSundayDate = lastDate;
        if('Mon'.equalsIgnoreCase(lastDayWeekName))
            lastSundayDate = lastDate.addDays(-1);
        else if('Tue'.equalsIgnoreCase(lastDayWeekName))
            lastSundayDate = lastDate.addDays(-2);
        else if('Wed'.equalsIgnoreCase(lastDayWeekName))
            lastSundayDate = lastDate.addDays(-3);
        else if('Thu'.equalsIgnoreCase(lastDayWeekName))
            lastSundayDate = lastDate.addDays(-4);
        else if('Fri'.equalsIgnoreCase(lastDayWeekName))
            lastSundayDate = lastDate.addDays(-5);
        else if('Sat'.equalsIgnoreCase(lastDayWeekName))
            lastSundayDate = lastDate.addDays(-6);       
        System.debug('lastSundayDate>>>>'+lastSundayDate);            
    return lastSundayDate;    
    }

    // Write a Logic to insert data into Interim_AE_Account__c object and submit the records for Approval.   
    @RemoteAction
    public static void saveInterimAE(String accSimRecords)
    {
        System.debug('accSimRecords>>>>> '+accSimRecords);
        List<Interim_AE_Account__c> interimAEList = new List<Interim_AE_Account__c>();
        User fromLSMUser;
        User toLSMUser;
        String selectedMonthYear;
        String yearStr;
        String monthStr;
        Date startDate, endDate;
        String ncc, frmLSM, toLSMSel = '';
        List<String> mapString = new List<String>();
        
        Map<String,String> divisionMap = new Map<String, String>();
        try {
            List <SDOF_Division__mdt> sdofLS = [SELECT Divisoin__c, SDOF_ID__c FROM SDOF_Division__mdt LIMIT 50];
            for(SDOF_Division__mdt sdof : sdofLS){
              divisionMap.put(sdof.Divisoin__c,sdof.SDOF_ID__c);
            }
            System.debug('accSimRecords '+ accSimRecords);
            
            if(accSimRecords != null && accSimRecords != '' && accSimRecords.split(';;;').size() > 1) {
                selectedMonthYear = accSimRecords.split(';;;')[2];
                System.debug('selectedMonthYear '+ selectedMonthYear);
                yearStr = selectedMonthYear.substring(0,4);
                monthStr = selectedMonthYear.substring(4,7);       
                System.debug('monthStr '+ monthStr);
                System.debug('yearStr '+ yearStr);         
                                
                Date selMonthDate = Date.valueOf(yearStr+'-'+mapDate.get(monthStr)+'-'+'01');
                Date prevMonthDate;
                if(mapDate.get(monthStr)==1){
                    prevMonthDate = Date.valueOf((Integer.valueof(yearStr)-1)+'-'+12+'-'+'01');
                } else{
                    prevMonthDate = Date.valueOf(yearStr+'-'+(mapDate.get(monthStr)-1)+'-'+'01');
                }   
                // Get Start Date of Broadcast Month : previous months' Last Sunday Date + 1
                startDate = getBroadcast(prevMonthDate)+1;
                System.debug('startDate ##### '+ startDate);
                // Get End Date of Broadcast Month : current months' Last Sunday Date
                endDate = getBroadcast(selMonthDate);  
                System.debug('endDate ##### '+ endDate);
            
         
                for(String s : accSimRecords.split('\\|\\|\\|')){
                   mapString.add(s);
                }
                System.debug('mapString-->'+ mapString);
                
                if(accSimRecords.indexOf('>>>>') > 0)
                  ncc = accSimRecords.substringBetween('>>>>','|||');

                if(accSimRecords.indexOf('_') > 0)
                {
                  frmLSM = accSimRecords.split('_')[1];  
                  System.debug('frmLSM >>>> '+frmLSM);
                  toLSMSel = accSimRecords.split('_')[2];
                  toLSMSel = accSimRecords.indexOf('>>>>') > 0 ? toLSMSel.substring(0,toLSMSel.indexOf('>>>>')) : toLSMSel.substring(0,toLSMSel.indexOf('|||'));
                  System.debug('toLSMSel >>>> '+toLSMSel);
                }  
            }

            fromLSMUser = [SELECT Id, HR_Manager__r.Region__c, HR_Manager__r.Division__c, Division__c FROM User WHERE Name =: frmLSM OR ID=: frmLSM limit 1];
            toLSMUser = [SELECT Id, Region__c, Division__c, HR_Manager__r.Region__c, ManagerId FROM User WHERE Name =: toLSMSel OR ID=: toLSMSel limit 1]; //SRSF-4644 : Added ManagerId
            System.Debug('fromLSMUser:::: '+ fromLSMUser);
            System.Debug('toLSMUser:::: '+ toLSMUser);
            
            for(String atmString : mapString)
            {
                System.Debug('atmString: '+ atmString);
                System.debug('From LSM Region>>>>>> '+fromLSMUser.HR_Manager__r.Region__c);
                System.debug('From LSM Division >>>>>> '+fromLSMUser.HR_Manager__r.Division__c);
                System.debug('To LSM Region>>>>>> '+toLSMUser.Region__c);
                System.debug('To LSM Division >>>>>> '+toLSMUser.Division__c);

                if(!atmString.contains('tempAccess')) 
                {
                    Interim_AE_Account__c interim = new Interim_AE_Account__c();
                    interim.Account__c = atmString.split(';;;')[1];
                    interim.Primary_AE__c = atmString.split(';;;')[0];
                    interim.Interim_AE__c = atmString.split(';;;')[3];
                    // START : SRSF-4465
                    if(atmString.split(';;;').size() > 4)
                    interim.EclipseIds__c = atmString.split(';;;')[4];
                    // END : SRSF-4465
                    interim.StartDate__c = startDate;
                    interim.EndDate__c = endDate;
                    interim.InitiatedBy__c = UserInfo.getUserId();
                    interim.From_LSM__c = fromLSMUser.Id;
                    interim.To_LSM__c = toLSMUser.Id;           
                    // START: SRSF-4534
                    interim.From_Region2__c = fromLSMUser.HR_Manager__r.Region__c;
                    interim.From_Division2__c = fromLSMUser.HR_Manager__r.Division__c;
                    interim.To_Region2__c = toLSMUser.Region__c;     
                    interim.To_Division2__c = toLSMUser.Division__c;
                    // END: SRSF-4534
                    interim.Status__c = 'New';
                    interim.Approver__c = toLSMUser.ManagerId; //SRSF-4644 : Added ManagerId

                    if(divisionMap.containsKey(fromLSMUser.HR_Manager__r.Division__c)){
                        interim.SDOF__c = divisionMap.get(fromLSMUser.HR_Manager__r.Division__c);
                        System.debug('SDOF-1 >>>>>> '+divisionMap.get(fromLSMUser.HR_Manager__r.Division__c));
                    }
                    else{
                        interim.SDOF__c = divisionMap.get(fromLSMUser.Division__c);
                        System.debug('SDOF-2 >>>>>> '+divisionMap.get(fromLSMUser.Division__c));
                    }

                    interimAEList.add(interim);
                }
            }
            System.debug('interimAEList--->'+interimAEList);
        
            if(interimAEList.size()>0)
                INSERT interimAEList;        
            submitInterimAEApproval (interimAEList); 
        } catch (Exception e) {
            Log4SF.logMessage('AssignInterimAEController', 'saveInterimAE', e.getMessage(),e, UserInfo.getUserId(),'','');
            throw e; //SRSF-4644
        }                   
    }

    // Method used to Submit the records for Approval
    public static void submitInterimAEApproval(List<Interim_AE_Account__c> interimAEList){
        try
        {
            for (Interim_AE_Account__c interim : interimAEList){            
                Approval.ProcessSubmitRequest req = new Approval.ProcessSubmitRequest();
                req.setObjectId(interim.Id);
                req.setProcessDefinitionNameOrId(System.Label.InterimAE_Service_Approval_Process);       
                req.setSkipEntryCriteria(false);
                Approval.ProcessResult result =  Approval.process(req); 
                System.debug('New Request submitted for approval successfully: '+result.isSuccess()); 
            }    
        }
        catch(Exception ex)
        {
            Log4SF.logMessage('AssignInterimAEController', 'submitInterimAEApproval', ex.getMessage(),ex, UserInfo.getUserId(),'',''); 
            throw ex;  //SRSF-4644         
        }
    }
  
  
    //TODO: Add the LSM/NSM if they have an Account.
    @RemoteAction
    public static String getmyuserlistRemote(String oID, String dosLSMs){
        try{
            List<String> userList = new List<String>();
            Map<String,String> usrMap = new Map<String,String>();
            Map<String,String> userMap = new Map<String,String>();
            List<String> userDOSList = new List<String>();
            List<User> userTemp = new List<User>();
            List<User> userTempDOS = new List<User>();
            List<String> lsmProfiles = new List<String>();
          
            for(UserClassification__mdt uc: [SELECT Id, DeveloperName, User_profiles__c FROM UserClassification__mdt LIMIT 25]){ 
                if(uc.DeveloperName != 'Admin'){
                    for(String up : uc.User_profiles__c.split(',')){
                        lsmProfiles.add(up);
                    }
                }
            }
            System.debug('LSM List: '+lsmProfiles);           
            System.debug('Checking LSM field '+ oID);
            Id uID = null;
            User userLSM;
            String retStr = '';
            Set<String> lsmProfilesSet = new Set<String>(lsmProfiles);

            if(dosLSMs.length() == 0) {
                if(oID == null || oID.length() == 0 ) {
                    return '';
                }
                userLSM = [SELECT Name,Id,Budget_Type__c FROM User WHERE Name=: oID];
                uID = userLSM.Id;
                userTemp = [SELECT Name,Id, Budget_Type__c FROM User WHERE HR_Manager__c =: uID  AND Profile.Name IN :lsmProfiles AND Budget_Type__c != null AND Budget_Product_Lines__c != null AND Budget_DMA__c != null LIMIT 200];
                if(userTemp.size() > 0)
                userTemp.add(0,userLSM);
                else
                userTemp.add(userLSM);
            }
            else {
              if(dosLSMs.indexOf(';;;') > 0)
              {
                  userDOSList = dosLSMs.split(';;;');
              }
              else
                userDOSList.add(dosLSMs);
              System.debug('userDOSList ' + userDOSList);
              userTempDOS = [SELECT Name,Id,Budget_Type__c FROM User WHERE Id IN: userDOSList];
              System.debug('userTempDOS ' + userTempDOS);  
              userTemp = [SELECT Name,Id, Profile.Name,Budget_Type__c FROM User WHERE HR_Manager__c IN: userDOSList AND Profile.Name IN :lsmProfiles AND Budget_Type__c != null AND Budget_Product_Lines__c != null AND Budget_DMA__c != null LIMIT 200]; 
               Integer i = 0;
               for(User usr : userTempDOS)
               {
                 if(userTemp.size() > 0)
                    userTemp.add(i,usr);
                  else
                    userTemp.add(usr);
                  i++;  
               }
            }
             
            for(User u : userTemp)
            {
                if(retStr.length() > 0) {
                    retStr += ',,,';
                }
                retStr += u.Budget_Type__c + ']]]' + u.Id +':::'+u.Name+ ';;;' + u.Name ;
                userList.add(u.Name);
                usrMap.put(u.Id+':::'+u.Name,u.Name);
            }
            System.debug(userList);
            return retStr;
        }
        catch(Exception ex)
        {
            Log4SF.logMessage('AccountTransferController', 'getmyuserlistRemote', ex.getMessage(),ex, UserInfo.getUserId(),oID,'');
            return null;
        }
    }

    
    @RemoteAction
    public static String getmyuserAccountsList(String aeString){
        List<String> accountList= new List<String>();

        List<String> aeIDs = new List<String>();
        List<String> aeNames = new List<String>();
        List<String> aeNameIDPairs = new List<String>();
        Map<String,String> aeNameIDMap = new Map<String,String>();
        List<Account> accounts = new List<Account>();
        String accountNames = '';
        if(aeString != null) {
            aeNameIDPairs = aeString.replace('[','').replace(']','').split(', ');
            for(String s : aeNameIDPairs) {
                aeIDs.add(s.split(':::')[0]);
                aeNames.add(s.split(':::')[1]);
                aeNameIDMap.put(s.split(':::')[0], s);
                if(accountNames.length() > 0) {
                    accountNames += ',,,';
                }                
            }
        }
        Map<String, String> accountNameMap = new Map<String, String> ();
        if (aeIDs.size() > 0) {
            List<Accountteammember> atmList = [SELECT Id, AccountId, Account.Name, Account.SAM_Designation__c, Account.Eclipse_Id__c, UserId, TeamMemberRole FROM Accountteammember WHERE UserId IN :aeIDs
                                               AND(TeamMemberRole = 'Account Executive' OR TeamMemberRole = 'Sales Manager')];
            if (atmList != null && atmList.size() > 0) {

                //search for account list using aeIDs List
                for (Accountteammember atm : atmList) {
                    accountNameMap.put(String.valueOf(atm.AccountId) + String.valueOf(atm.UserId), atm.AccountId);
                    if (accountNames.length() > 0) {
                        accountNames += ',,,';
                    }
                    accountNames += atm.AccountId + '|||' + atm.Account.Name.replace('\'', '') + '|||' + (String) aeNameIDMap.get((String) atm.UserId) + '|||' + atm.Account.SAM_Designation__c + '|||' + atm.Account.Eclipse_Id__c + ';;;' + atm.Account.Name.replace('\'', '') + '|||' + atm.TeamMemberRole;
                }
            }        
        }
        System.debug('Checking accountList: ' + aeIDs);
        return accountNames;
    }

    // SRSF-3821
    @RemoteAction
    public static String loadEclipseIDs(String[] accountIdStr) 
    {
        System.debug('accountIdStr---->'+accountIdStr);
        String retVal = '';
        // SRSF-4465 : Added TIM_System__c NULL check in the Query
        for (Traffic_Id_Element__c tie: [Select Account__r.Name, Traffic_Id__c, TIM_System__c, ExportSystem_Name__c, Account__c FROM Traffic_Id_Element__c WHERE TIM_System__c = NULL AND Account__c IN :accountIdStr]) {
                if (retVal.length() > 0) {
                    retVal += ';;;';
                }

            retVal += tie.Account__r.Name.replace('\\', '\\\\').replace('"', '\\"').replace('\'', '’') + '|||' + tie.Traffic_Id__c + '|||' + tie.TIM_System__c + '|||' + tie.ExportSystem_Name__c + '|||' + tie.Account__c;
        }

        return retVal;
    } 

    // SRSF-4099
    @RemoteAction
    public static String checkDuplicateTSA(String accountIdStr, String aeString, String selectedMonthYear) 
    {
        List<String> accountIdList = accountIdStr.split(';;;');
        List<String> aeIDs = new List<String>();

        String retVal = '';        
        System.debug('Inside checkDuplicateTSA'+accountIdStr);
        List<String> aeNameIDPairs = new List<String>();
        aeNameIDPairs = aeString.replace('[','').replace(']','').split(', ');
        for(String s : aeNameIDPairs) {
            aeIDs.add(s.split(':::')[0]);            
        }
        System.debug('aeIDs--->'+aeIDs);
       
        if(!CommonUtilities.isStringNullOrEmpty(selectedMonthYear))
        {
            String yearStr = selectedMonthYear.substring(0,4);
            String monthStr = selectedMonthYear.substring(4,7);
            
            Date selMonthDate = Date.valueOf(yearStr+'-'+mapDate.get(monthStr)+'-'+'01');
            Date prevMonthDate;
            if(mapDate.get(monthStr)==1){
                prevMonthDate = Date.valueOf((Integer.valueof(yearStr)-1)+'-'+12+'-'+'01');
            } else{
                prevMonthDate = Date.valueOf(yearStr+'-'+(mapDate.get(monthStr)-1)+'-'+'01');
            }   
            // Get Start Date of Broadcast Month : previous months' Last Sunday Date + 1
            Date startDate = getBroadcast(prevMonthDate)+1;
            System.debug('startDate ##### '+ startDate);
            // Get End Date of Broadcast Month : current months' Last Sunday Date
            Date endDate = getBroadcast(selMonthDate);  
            System.debug('endDate ##### '+ endDate);

            for(Interim_AE_Account__c interimAE : [SELECT Id, Name , Primary_AE__c, Primary_AE__r.Name, Account__r.Name FROM Interim_AE_Account__c WHERE Account__c IN :accountIdList AND  Primary_AE__c IN :aeIDs AND StartDate__c =:startDate AND EndDate__c =:endDate AND Status__c NOT IN('Recalled', 'Denied')]) 
                {
                isDuplcateTSA = TRUE;
                if (retVal.length() > 0) {
                    retVal += ';;;';
                }

                retVal += interimAE.Id + '|||' + interimAE.Name + '|||' + interimAE.Primary_AE__c + '|||' + interimAE.Primary_AE__r.Name + '|||' + interimAE.Account__c + '|||' + interimAE.Account__r.Name.replace('\\', '\\\\').replace('"', '\\"').replace('\'', '’');
            }
            System.debug('retVal ##### '+ retVal); 
        } 
        return retVal;
    }    
}