/* 
    Customer/Project:   Spectrum Reach
    Class name:         SObjectLookupController
    Author/Date:       Brett Ballantyne    3/11/2017
    Release:            TBD
    Purpose:           Apex support for SOjbectLookup
*/

public with sharing class SObjectLookupController {

    private final Account accnt;
    
        // init the controller and display some sample data when the page loads
    public SObjectLookupController(ApexPages.StandardController stdController) {
         this.accnt = (Account)stdController.getRecord();
    }


    public class crossObjInfo {
        @AuraEnabled public String objectType;
        @AuraEnabled public Map<String, ObjectLookupSettings__c> fieldMap;
    }

    public class crossObjQuery {
        @AuraEnabled public String objectType;
        @AuraEnabled public String fields;
        @AuraEnabled public String whereClause;
        @AuraEnabled public String numRecords;
        @AuraEnabled public String nestedQuery;
        @AuraEnabled public String supplementalWhereClause;
    }

    public class AccountRecTypeInfo {
        @AuraEnabled public String recordTypeId;
        @AuraEnabled public String recordTypeName;
        @AuraEnabled public Boolean isDefault;
        @AuraEnabled public String recordTypeDeveloperName;
    }

    @AuraEnabled
    public static List<crossObjInfo> getQueryFields(String objectType) {
        System.debug('------->> objectType = ' + objectType);
        List<crossObjInfo> coiList = new List<crossObjInfo>();
        if (objectType == null || objectType == '')
            return coiList;
        List<String> objTypeList = objectType.split(',');
        System.debug('=============>> objTypeList = ' + objTypeList);
        for (integer i = 0; i < objTypeList.size(); i++) {
            Map<String, ObjectLookupSettings__c> fieldMap = new Map<String, ObjectLookupSettings__c>();
            crossObjInfo coi = new crossObjInfo();
            System.debug('------------>> objTypeList[' + i + '] = ' + objTypeList[i]);
            coi.objectType = objTypeList[i];
            List<ObjectLookupSettings__c> objList = ObjectLookupSettings__c.getAll().values();
            objList.sort();
            for (ObjectLookupSettings__c os : objList) {
                if (os.Object_Type__c == objTypeList[i] && os.Is_Active__c == true) {
                    System.debug('=======>> field, struct = ' + os.Field_To_Search__c + ',' + os);
                    fieldMap.put(os.Field_To_Search__c, os);
                }
            }
            coi.fieldMap = fieldMap;
            coiList.add(coi);
        }
        System.debug('=================>> coiList = ' + coiList);
        return coiList;
    }

    @AuraEnabled
    public static Map<String, ObjectLookupKeys__c> getObjectKeys() {
        return ObjectLookupKeys__c.getAll();
    }

    @AuraEnabled
    public static Map<String, Id> getRecTypeMap(String objectType) {
        System.debug('========>> In getRecTypeMap, objectType = ' + objectType);
        Map<String, Id> retMap = new Map<String, Id>();
        for(RecordType rt : [SELECT Id, Name, DeveloperName FROM RecordType
                             WHERE SobjectType = :objectType and IsActive = true]) {
            retMap.put(rt.Name, rt.Id);
        }
        System.debug('------->> retMap = ' + retMap);
        return retMap;
    }

    @AuraEnabled
    public static String getOpportunityRecordType() {
        return getOpportunityRecordType(null);
    }

    @AuraEnabled
    public static String getOpportunityRecordType(Id ownerId) {
    //public static String getOpportunityRecordType(String acctRecType) {
        //String NatRecIds = System.Label.National_Profile_IDs;
        List<String> NatRecIds = ((System.Label.National_Profile_IDs).split(','));
        Set<String> NatRecIdSet = new Set<String>();
        NatRecIdSet.addAll(NatRecIds);
        if(ownerId == null) {
            System.debug('====================>> NatRecIdSet = ' + NatRecIdSet);
            System.debug('====================>> User Profile = ' + UserInfo.getProfileId().substring(0,15));
        //  if (acctRecType == null || acctRecType == '') return '';
        //  String devName = (acctRecType == 'National_Account') ? 'National_Opportunity' : 'Opportunity';
            String devName = (NatRecIdSet.contains(UserInfo.getProfileId().substring(0,15))) ? 'National Opportunity' : 'Opportunity';
          /*  RecordType opptyRecType = [select Id, Name, DeveloperName 
                                        from RecordType
                                        where DeveloperName = :devName limit 1]; */
            Id prdTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get(devName).getRecordTypeId();                            
           return String.valueOf(prdTypeId);
           // return String.valueOf(opptyRecType.Id);
        }
        else {
            System.debug('====================>> NatRecIdSet = ' + NatRecIdSet);
            System.debug('====================>> User Profile = ' + UserInfo.getProfileId().substring(0,15));
        //  if (acctRecType == null || acctRecType == '') return '';
        //  String devName = (acctRecType == 'National_Account') ? 'National_Opportunity' : 'Opportunity';
            User usrProfileId = [SELECT ProfileId FROM User WHERE Id = :ownerId][0];
            String ownerProfile = ((String)usrProfileId.ProfileId).substring(0,15);    
            String devName = (NatRecIdSet.contains(ownerProfile)) ? 'National Opportunity' : 'Opportunity';
          /*  RecordType opptyRecType = [select Id, Name, DeveloperName 
                                        from RecordType
                                        where DeveloperName = :devName limit 1];
            return String.valueOf(opptyRecType.Id); */
            Id prdTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get(devName).getRecordTypeId();                            
            return String.valueOf(prdTypeId);
        }
    }

    @AuraEnabled
    public static String getAccountAgencyRT() {
        String devName = 'Advertiser_Account';
        RecordType acctRecType = [SELECT Id, Name, DeveloperName 
                                    FROM RecordType
                                    WHERE DeveloperName = :devName LIMIT 1];
        if (acctRecType != null)
            return String.valueOf(acctRecType.Id);
        return '';
    }
/*
    public PageReference createAccount(String acctName) {
        PageReference pageRef = new PageReference('/001/e?retURL%2F001%2Fo&nooverride=1&acc2='+ acctName);
        return pageRef;
    }    
*/
/*  Orignial (pre-cross object) method 
    @AuraEnabled
    public static Map<String, ObjectLookupSettings__c> getQueryFields(String objectType) {
        system.debug('------->> objectType = ' + objectType);
        Map<String, ObjectLookupSettings__c> retMap = new Map<String, ObjectLookupSettings__c>();
        if (objectType == null || objectType == '')
            return retMap;
        List<ObjectLookupSettings__c> objList = ObjectLookupSettings__c.getAll().values();
        objList.sort();
        for (ObjectLookupSettings__c os : objList) {
            if (os.Object_Type__c == objectType && os.Is_Active__c == true) {
                system.debug('=======>> field, struct = ' + os.Field_To_Search__c + ',' + os);
                retMap.put(os.Field_To_Search__c, os);
            }
        }
        return retMap;
    }  
*/
/*  pre cross object method.  Works for a single object type
    @AuraEnabled
    public static List<SObject> getObjects(String objectType, String fields, String whereClause, String numRecords) {
        system.debug('------>> objectType = ' + objectType);
        system.debug('------>> fields = ' + fields);
        system.debug('------>> whereClause = ' + whereClause);
        system.debug('------>> numRecords = ' + numRecords);
        List<SObject> retList = new List<SObject>();
        if (objectType == null || objectType == '' || fields == null || fields == '' || whereClause == null || whereClause == '') {
            return retList;
        }
        if (numRecords == null || numRecords == '') {
            numRecords = '25';  // default to 25 if not set in the lightning component
        }

        String soql = 'select ' + fields + ' from ' + objectType + ' ' + whereClause + ' limit ' + numRecords;
        retList = Database.query(soql);
        return retList;

    } */

    /*  There is a Database.Query inside a for loop, which is normall a big no-no, but this code has to handle multiple object types in one call.
        The purpose of this is being able to mix object types in one result list, which is required when searching accounts on the "New Account" page.
        It searches Accounts, Contacts, and Leads in one search.  It is impractical to assume that a search would be required to search more than
        100 objects at once, but there's a check for that in the code to prevent a "Too many SQOL Queries" error.

        Additionally, the assumption regarding the nestedQuery is that only one object is being searched, otherwise an error will be thrown.
        I don't forsee this being a requirement in the future (multiple objects with nested queries), but if it ever happens
        the design will obviously have to change.  There's a check for that in the code in case someone tries it.

    */
    
    @AuraEnabled
    public static List<SObject> getObjects(String objQuery) {
        system.debug(loggingLevel.WARN, '============>> in getObjects, objQuery = ' + objQuery);
        crossObjQuery[] queryObject = (List<crossObjQuery>) System.JSON.deserializeStrict(objQuery, List<crossObjQuery>.class);     // see http://opfocus.com/lessons-learned-from-my-first-lightning-component/
        system.debug(loggingLevel.WARN, '============>> in getObjects, queryObject = ' + queryObject);
        List<SObject> retList = new List<SObject>();
        String soql;

        if (queryObject == null || queryObject.size() == 0) return retList;
        for (Integer i = 0; i < queryObject.size(); i++) {
            system.debug(loggingLevel.WARN, '==================>> queryObject[0].objectType =  ' + queryObject[i].objectType);
            system.debug(loggingLevel.WARN, '==================>> queryObject[0].fields =      ' + queryObject[i].fields);
            system.debug(loggingLevel.WARN, '==================>> queryObject[0].whereClause = ' + queryObject[i].whereClause);
            system.debug(loggingLevel.WARN, '==================>> queryObject[0].numRecords =  ' + queryObject[i].numRecords);
            system.debug(loggingLevel.WARN, '==================>> queryObject[0].nestedQuery =  ' + queryObject[i].nestedQuery);

            if (queryObject[i].objectType == null || queryObject[i].objectType == '' || queryObject[i].fields == null || queryObject[i].fields == '' || queryObject[i].whereClause == null || queryObject[i].whereClause == '') {
                continue;
            }
            if (queryObject[i].numRecords == null || queryObject[i].numRecords == '') {
                queryObject[i].numRecords = '25';  // default to 25 if not set in the lightning component
            }
            system.debug(loggingLevel.WARN, '------>> objectType = ' + queryObject[i].objectType);
            system.debug(loggingLevel.WARN, '------>> fields = ' + queryObject[i].fields);
            system.debug(loggingLevel.WARN, '------>> whereClause = ' + queryObject[i].whereClause);
            system.debug(loggingLevel.WARN, '------>> supplemental whereClause = ' + queryObject[i].supplementalWhereClause);
            system.debug(loggingLevel.WARN, '------>> numRecords = ' + queryObject[i].numRecords);
            system.debug(loggingLevel.WARN, '------>> nestedQuery = ' + queryObject[i].nestedQuery);

            if (queryObject[i].nestedQuery != null && queryObject[i].nestedQuery != '' && queryObject.size() == 1) {
                soql = 'select ' + queryObject[i].fields + queryObject[i].nestedQuery + ' from ' + queryObject[i].objectType + ' ' + queryObject[i].whereClause + ' limit ' + queryObject[i].numRecords;
            } else {
                soql = 'select ' + queryObject[i].fields + ' from ' + queryObject[i].objectType + ' ' + queryObject[i].whereClause + queryObject[i].supplementalWhereClause + ' limit ' + queryObject[i].numRecords;
            }
            ////String soql = 'select ' + queryObject[i].fields + ' from ' + queryObject[i].objectType + ' ' + queryObject[i].whereClause + ' limit ' + queryObject[i].numRecords;
            system.debug(loggingLevel.WARN, '===============>> soql = ' + soql);
            retList.addAll(Database.query(soql));
        }

        for (SObject so: retList) {
            system.debug(so);
        }

        return retList;

    }

    @AuraEnabled public static String getMyUserId() {
        return String.valueOf(UserInfo.getUserId());
    }

    @AuraEnabled public static List<OpportunityStage> getOpportunityStages() {
        return OpportunityUtil.getOpptyStages();
    }

    @AuraEnabled public static Account getAccountInfo(String acctId) {
        if (acctId == null || acctId == '') return null;
        Account accountInfo;
        try {
            accountInfo = [select Id, Name, RecordTypeId, RecordType.Name, RecordType.DeveloperName, 
                            Agency__c, Agency__r.Name, Rep_Firm__c, Rep_Firm__r.Name, Holding_Account__c, Holding_Account__r.Name, NCC_Account_Rep__c, Networks_to_Avoid__c, 
                            ShippingStreet, ShippingCity, ShippingState, ShippingPostalCode, ShippingCountry,Landscape_Client__c,
                            (Select TeamMemberRole, User.Name, User.Profile.Name From Account.AccountTeamMembers 
                               WHERE (TeamMemberRole='Account Executive' OR TeamMemberRole = 'Sales Manager')
                               AND User.IsActive=TRUE)  // SRSF-2306 : Updated Query to exclude Inactive Users)
                               FROM Account where id = :Id.valueOf(acctId)];  // SRSF-4392 : Added Holding_Account__c, Holding_Account__r.Name,
        } catch (Exception ex) {
            system.debug(loggingLevel.ERROR, 'SObjectLookupController.getAccountInfo Error: ' + ex.getMessage());
        }
        return accountInfo;
    }

    @AuraEnabled public static List<AccountRecTypeInfo> getAccountRecTypeInfo() {
        // find all Opportunity record types
        List<Schema.RecordTypeInfo> infos = Schema.SObjectType.Account.getRecordTypeInfos();
        List<AccountRecTypeInfo> retList = new List<AccountRecTypeInfo>();

        for (Schema.RecordTypeInfo info : infos) {
            if (info.isAvailable() && !info.isMaster() && info.getName() != 'Account Request') {
                AccountRecTypeInfo arti = new AccountRecTypeInfo();
                arti.recordTypeName = info.getName();
                arti.recordTypeId = String.valueOf(info.getRecordTypeId());
                arti.isDefault = info.DefaultRecordTypeMapping;
                arti.recordTypeDeveloperName = Schema.SObjectType.Account.getRecordTypeInfosById().get(info.getRecordTypeId()).getDeveloperName();
                retList.add(arti);
            }
        }
        return retList;
    }

    @AuraEnabled public static Boolean isCurrentUserOnAccountTeam (String acctId) {
        List<AccountTeamMember> atm = [select Id from AccountTeamMember
                                        where UserId = :UserInfo.getUserId()
                                            and AccountId = :acctId ];

        Boolean retVal =  (atm == null || atm.size() == 0) ? false : true;
        String profilename = getUserProfileName();
        if( profilename== 'Master - Spectrum Preferred' || profilename== 'Master - Enterprise Digital')
            retVal = true;
        system.debug(loggingLevel.WARN, '=============>> atm =  ' + atm);
        system.debug(loggingLevel.WARN, '=============>> retVal =  ' + retVal);
        return retVal;
    }
	//Code Added for SRSF-1672 Starts Here
    @AuraEnabled
    public static Map<String,List<String>> getBudgetDMAValue(String userId) {
        Map<String,List<String>> budgetDMAValue =  new Map<String,List<String>>();
        List<String> DmaValues = new List<String>();
        for(Schema.PicklistEntry pickVal :  User.Budget_DMA__c.getDescribe().getPicklistValues()){
            DmaValues.add(pickVal.getValue());
        }

        for(User usr : [SELECT Budget_DMA__c,Budget_Type__c FROM User WHERE ID =:userId ]){
            if(usr.Budget_Type__c!=NULL && usr.Budget_Type__c.equalsIgnoreCase('National') && usr.Budget_DMA__c!=NULL ){
                List<String> natUsrDMAs = new List<String>();
                for(String str : usr.Budget_DMA__c.split(';')){
                    natUsrDMAs.add(str);
                }
                budgetDMAValue.put(natUsrDMAs[0], natUsrDMAs);
            }
            else if(usr.Budget_DMA__c!=NULL){
               // DmaValues.remove(DmaValues.indexOf(usr.Budget_DMA__c.split(';')[0]));
                budgetDMAValue.put(usr.Budget_DMA__c.split(';')[0], DmaValues);
            }
            else{
                List<String> dmaVal = new List<String>{'None'}; dmaVal.addAll(DmaValues);
               budgetDMAValue.put('None', dmaVal);   
            }
        }
        System.debug('Map values::'+budgetDMAValue);
        return budgetDMAValue;
    }


    @AuraEnabled
    public static List<String> getSalesProbability(){
        List<String> options = new List<String>();
        Schema.DescribeFieldResult fieldResult = Opportunity.Sales_Probability__c.getDescribe();
        List<Schema.PicklistEntry> pList = fieldResult.getPicklistValues();
        for (Schema.PicklistEntry p: pList) {
            options.add(p.getValue());
        }
        return options;
    }

    @AuraEnabled
    public static List<String> getFirstLookFields(){
        List<String> options = new List<String>();
        Schema.DescribeFieldResult fieldResult = Opportunity.First_Look__c.getDescribe();
        List<Schema.PicklistEntry> pList = fieldResult.getPicklistValues();
        for (Schema.PicklistEntry p: pList) {
            options.add(p.getValue());
        }
        return options;
    }
    
    @AuraEnabled public static String getUserProfileName(){
        return [SELECT Profile.Name From User Where Id =:UserInfo.getUserId()].Profile.Name;
    }

	//Code Added for SRSF-1672 Ends Here

    @AuraEnabled
    public static List<User> getAccountAEs(Id accId) {        
        return [select Id, Name, Profile.Name from User 
                where Id in 
                (select userId from AccountTeamMember where AccountId = :accId
                    and (TeamMemberRole = 'Account Executive' OR TeamMemberRole = 'Sales Manager'))];
    }

/*
    @AuraEnabled public static String getCurrentPageURL() {
        return ApexPages.currentPage().getURL();
    }

    @AuraEnabled public static Map<String, String> getPageHeaders() {
        PageReference pRef = ApexPages.currentPage();
        system.debug('------->> pRef = ' + pRef);
        Map<String, String> pMap = pRef.getHeaders();
        system.debug('------->> pMap = ' + pMap);
        return pMap;
    }
*/
    public static Date formatDate(String closeDate){
        List<String> strDate = closeDate.split('-');
        Integer year = Integer.valueOf(strDate[0]);
        Integer month = Integer.valueOf(strDate[1]);
        Integer day = Integer.valueOf(strDate[2]);
        Date myDate = Date.newInstance(year, month, day);
        return myDate;
    }

    public static Id acctExecForOppTrg;


    // SRSF-4392 : Added holdingAcct, dsPlatform, ssPlatform, seatId
    @AuraEnabled
    public static String createOppty(String opptyName, Id acctId, String stage, String closeDate, Id acctExec, Id recTypeId,
                                        String agency, String nccAccountRep, String nwToAvoid, String repFirm,String dma,
                                        String salesProb, String flghtSrtDt, String flghtEndDt, String dscrptn, 
                                        String firstLook, String firstLookContVal, boolean createActivity, String holdingAcct, List<String> dsPlatform, List<String> ssPlatform, String seatId, String businessClassification) { //, String discountCode
        String retVal='';
        Map<Id, Opportunity> successOpps = new Map<Id, Opportunity>(); // SRSF-3571
        System.debug ('------------>> opptyName = ' + opptyName);
        System.debug ('------------>> acctId = ' + acctId);
        System.debug ('------------>> stage = ' + stage);
        System.debug ('------------>> closeDate = ' + closeDate);
        System.debug ('------------>> acctExec = ' + acctExec);
        System.debug ('------------>> recTypeId = ' + recTypeId);
        System.debug ('------------>> agency = ' + agency);
        System.debug ('------------>> repFirm = ' + repFirm);
        System.debug ('------------>> dma Value = ' + dma);
        System.debug ('------------>> nccAccountRep = ' + nccAccountRep);
        System.debug ('------------>> nwToAvoid = ' + nwToAvoid);
        System.debug ('------------>> flghtSrtDt = ' + flghtSrtDt);
        System.debug ('------------>> flghtEndDt = ' + flghtEndDt);
        System.debug ('------------>> firstLookContVal = ' + firstLookContVal);
        System.debug ('------------>> createActivity = ' + createActivity);
        System.debug ('------------>> dsPlatform = ' + dsPlatform);
        System.debug ('------------>> ssPlatform = ' + ssPlatform);
        System.debug ('------------>> Hold Co = ' + holdingAcct);
        System.debug ('------------>> Business Classficiation = ' + businessClassification);//SRSF-4604
             
        boolean Activityval =false; //adding for SRSF-4945

        // TODO: error checking
//adding for SRSF-4945

        if(createActivity != null){
            Activityval = createActivity;

        } //adding for SRSF-4945
        List<OpportunityTeamMember> otmList = new List<OpportunityTeamMember>();

/*        List<String> strDate = closeDate.split('-');
        Integer year = Integer.valueOf(strDate[0]);
        Integer month = Integer.valueOf(strDate[1]);
        Integer day = Integer.valueOf(strDate[2]);
        Date myDate = Date.newInstance(year, month, day);
*/        
        Date myDate = formatDate(closeDate);
        Date flghtSrtDate = flghtSrtDt!=NULL? formatDate(flghtSrtDt) : NULL;
        Date flghtEndDate = flghtEndDt!=NULL? formatDate(flghtEndDt): NULL;
        Decimal firstLookContValDec = firstLookContVal!=NULL? Decimal.valueOf(firstLookContVal) : NULL;
        //Decimal firstLookContValDec =  firstLookContVal!=NULL && firstLookContVal.isNumeric()? Decimal.valueOf(firstLookContVal) : Null;
        
        System.debug('1-recid: '+ recTypeId);
        if(acctExec != null) {
            System.debug('2-recid: '+ recTypeId);
            acctExecForOppTrg = acctExec;
            List<String> NatRecIds = ((System.Label.National_Profile_IDs).split(','));
            Set<String> NatRecIdSet = new Set<String>();
            NatRecIdSet.addAll(NatRecIds);
            User usrProfileId = [select ProfileId from User where id = :acctExec][0];
            String ownerProfile = ((String)usrProfileId.ProfileId).substring(0,15);    
            String devName = (NatRecIdSet.contains(ownerProfile)) ? 'National_Opportunity' : 'Opportunity';
            RecordType opptyRecType = [select Id, Name, DeveloperName 
                        from RecordType
                        where DeveloperName = :devName limit 1];
            recTypeId = opptyRecType.Id;
            System.debug('3-recid: '+ recTypeId);
        }

        /* // Commented this Query for SRSF-3571
        Opportunity oppty = new Opportunity(Name = opptyName, AccountId = acctId, StageName = stage, CloseDate = myDate, RecordTypeId = recTypeId,
                                            Agency_Account__c = agency, NCC_Account_Rep__c = nccAccountRep, Networks_to_Avoid__c = nwToAvoid,
                                            Rep_Firm__c = repFirm, Created_By_Account_Executive__c = true,DMA__c = dma, 
                                            Sales_Probability__c = salesProb, Flight_Start_Date__c = flghtSrtDate,
                                            Flight_End_Date__c = flghtEndDate, Description = dscrptn, First_Look__c=firstLook,
                                            First_Look_Contract_Value__c = firstLookContValDec,
                                           Face_to_Face__c = facetoface, Virtual__c=virtualval);*/
                                    //old       Agency_Account__c = agency, NCC_Agency__c = nccAgency, NCC_Account_Rep__c = nccAccountRep);
        // START: SRSF-3571
        List<String> dmaList = dma.split(','); 
        
        List<Opportunity> opptLst = new List<Opportunity> ();
        for (String strdma : dmaList)
        { 
            // If multiple DMA's append DMA to opportunity name
            // SRSF-4392 : Added Holding_Account__c, Demand_Side_Platform__c, Supply_Side_Platform__c, Seat_ID__c
            String oppName = dmaList.size()> 1 ? opptyName+ '_'+strdma : opptyName;
           Opportunity oppty = new Opportunity(Name = oppName, AccountId = acctId, StageName = stage, CloseDate = myDate, RecordTypeId = recTypeId,
                                            Agency_Account__c = agency, NCC_Account_Rep__c = nccAccountRep, Networks_to_Avoid__c = nwToAvoid,
                                            Rep_Firm__c = repFirm, Created_By_Account_Executive__c = true,DMA__c = strdma,  //DMA__c = dma,
                                            Sales_Probability__c = salesProb, Flight_Start_Date__c = flghtSrtDate,
                                            Flight_End_Date__c = flghtEndDate, Description = dscrptn, First_Look__c=firstLook,
                                            First_Look_Contract_Value__c = firstLookContValDec, Virtual__c=false,
                                            Create_Activity__c=Activityval, Demand_Side_Platform__c = String.join(dsPlatform,';'), Supply_Side_Platform__c = String.join(ssPlatform,';'), Seat_ID__c = seatId,  Holding_Account__c = holdingAcct, Business_Classification__c = businessClassification); 
                                            //,Discount_Code__c = discountCode                                  
            opptLst.add (oppty); 
        }  
//Virtual__c=false,     
        // END: SRSF-3571

        List<AccountTeamMember> atmLst = new List<AccountTeamMember>();  // SRSF-2662 
        try {            
            atmLst = [SELECT Id, AccountId, UserId, TeamMemberRole FROM AccountTeamMember WHERE AccountId =: acctId AND UserId =: UserInfo.getUserId() AND TeamMemberRole = 'Interim AE']; // SRSF-2662 
            //system.debug('before:'+oppty.Agency_Account__c);
            // Insert oppty; // Commented for SRSF-3571
            //system.debug('after:'+oppty.Agency_Account__c);
          //  retVal = String.valueOf(oppty.Id); // SRSF-3571: This has to be updated to send list of Opp Ids to UI
            
            //START: SRSF-3571
            Database.SaveResult[] recsToInsert = Database.Insert(opptLst, false);
            for(Integer i = 0 ; i < recsToInsert.size(); i++) 
            {
                if(recsToInsert[i].isSuccess()) {
                    successOpps.put(recsToInsert[i].getId(), opptLst[i]);
                }
                else{ // SRSF-4428 : Added ELSE Block
                    String error = recsToInsert[i].getErrors().get(0).getMessage();
                    throw new DMLException(error);
                }
            }   
            if(successOpps.size()>0){}
            retVal = JSON.serialize(successOpps);   
            //END: SRSF-3571
            //ChangeOpptyOwner.ChangeOwner(acctExec, oppty.Id, acctId); // Commented for SRSF-3571            
            
            if (opptLst.Size()>1) {
                ChangeOpptyOwner.ChangeOwner(acctExec, successOpps.values(), acctId);
                
            } else {
                ChangeOpptyOwner.ChangeOwner(acctExec, successOpps.values().get(0).Id, acctId);
            }
            // END : SRSF-3571
            User objOwner = [select id,Team_Role__c from User where id =:acctExec];
            //Adding Opportunity New Owner as OpportunityTeamMember
            List<OpportunityTeamMember> lstOTM = new List<OpportunityTeamMember>();
             List<Task> taskList = new List<Task>();
            for (Opportunity oppty : successOpps.values()){
                lstOTM.add(new OpportunityTeamMember(UserId = acctExec,
                                                 OpportunityId = oppty.Id,
                                                 OpportunityAccessLevel = 'Edit', 
                                                 TeamMemberRole = objOwner.Team_Role__c));
                System.debug('oppty506' +oppty.Create_Activity__c + acctExec);
                if(oppty.Create_Activity__c != null && oppty.Create_Activity__c == true){
                    taskList.add(new Task(WhatId = oppty.Id,
                                          Subject = 'Other',
                                          ActivityDate = oppty.CloseDate,
                                          OwnerId = acctExec
                                         ));
                }
                
            }   
            if(taskList.size()>0){
                insert taskList;
            }
            if (lstOTM.size() > 0)
                ChangeOpptyOwner.insertOpptyTeam(lstOTM);
            /*list<Opportunity> lstPrefOpp = new list<Opportunity>();
            lstPrefOpp.add(oppty);
            ChangeOpptyOwner.addPreferredTeamMembers(lstPrefOpp);*/ 
        } catch (Exception ex) {
            system.debug (loggingLevel.ERROR, 'SObjectLookupController.createOppty: Error occured creating Opportunity: ' + ex.getMessage());
            retVal = 'ERROR: ' + ex.getMessage();
            //SRSF-4428: Added AuraException and commented return statement
            AuraHandledException auraException = new AuraHandledException(retVal);
            auraException.setMessage(retVal);
            throw auraException;
            //return retVal;
        }
        // now add the requesting user to the oppty team
        User currentUser = [select Id, Name, Team_Role__c from User where Id = :UserInfo.getUserId()];
        User accountExecutive = [select Id, Name, Team_Role__c from User where Id = :acctExec];
        
        // Start - SRSF-2662
        if(!CommonUtilities.isListNullOrEmpty(atmLst) && atmLst.Size()>0){
            currentUser.Team_Role__c = atmLst[0].TeamMemberRole; // To set the Opp TeamMember Role as 'Interim AE'
        }  
        // End - SRSF-2662
        // ChangeOpptyOwner.insertOpptyTeam(currentUser, acctExec, oppty.Id); // Commented for SRSF-3571
        // START : SRSF-3571        
        if (opptLst.Size()>1) {            
            ChangeOpptyOwner.insertOpptyTeam(currentUser, acctExec, successOpps.keySet());
        } else {
            ChangeOpptyOwner.insertOpptyTeam(currentUser, acctExec, successOpps.values().get(0).Id);
        }
        // END : SRSF-3571       
        return retVal;
    }

    @AuraEnabled
    public static String addAdAccount(String opptyId, String advertiserAccount ) {
        //Opportunity obj = (Opportunity) System.JSON.deserializeStrict(objStr, Opportunity.class);
        system.debug('==============>> got here!');
    //  Opportunity oppty = (Opportunity) obj;
        system.debug('=================>> in addAdAccount, opptyId = ' + opptyId + ', advertiserAccount = ' + advertiserAccount);
        String retVal = 'SUCCESS';
        if (!isCurrentUserOnAccountTeam(advertiserAccount)) {
            retVal = 'ERROR:  You must be on the Account Team of the Advertiser Acount to add it to this Opportunity';
            return retVal;
        }
        try {
            Opportunity opp = [select AccountId from Opportunity where Id = :opptyId];
            system.debug('======================>> opp = ' + opp);
            system.debug('==================>> before update');
            opp.AccountId = Id.valueOf(advertiserAccount);
            update opp;
            system.debug('==================>> after update');
        } catch (Exception ex) {
            system.debug (loggingLevel.ERROR, 'SObjectLookupController.createOppty: Error occured creating Opportunity: ' + ex.getMessage());
            retVal = 'ERROR: ' + ex.getMessage();

        } 
        return retVal;
    }

    @AuraEnabled
    public static List<String> getContactRoles() {
        List<String> retVal = new List<String> {'--None--'};
        retVal.addAll(ApexUtils.getPickListValues('Contact', 'Contact_Role__c'));
        return retVal;
       // return ApexUtils.getPickListValues('Contact', 'Contact_Role__c');
    }

    @AuraEnabled
    public static List<String> getAdContactTypes( String recordId) {
        //System.debug('recordId-->'+recordId);
        //SRSF-1352 start
        String picklistName;
        Account acc=[select Id,RecordType.Name from Account where Id=:recordId];
        if(acc.RecordType.Name=='Agency Account')
        {
           picklistName= 'Agency_Contact_Type__c';
        }else if(acc.RecordType.Name=='Advertiser Account')
        {
            picklistName='Advertiser_Contact_Type__c';
        }
        //SRSF-1352 end
        //System.debug('this is piclist values=========picklistName==============>'+picklistName);
        List<String> retVal = new List<String>();  // {'--None--'};
        retVal.addAll(ApexUtils.getPickListValues('Contact', picklistName));
        return retVal;
        
    }

    @AuraEnabled
    public static Map<Id, String> getAvailRecordTypes(String objectApiName) {
        return ApexUtils.getAvailRecordTypes(objectApiName);
    }

    public class newContactResult {
        @AuraEnabled public String result;
        @AuraEnabled public List<Contact> duplicateRecords;
    }

    @AuraEnabled
    //public static newContactResult createNewContact(String fName, String lName, String emailAddr, String aeId, String recTypeId, String acctId, String adConType, Boolean forceSave) {
    public static newContactResult createNewContact(String fName, String lName, String emailAddr, String aeId, String recTypeId, String acctId, String adConType, String strTitle, String strPhone, String strMobile, String strStreet, String strCity, String strState, String strZip, String strCountry,  Boolean forceSave) {
        system.debug('=======>> forceSave = ' + forceSave);
        system.debug('=======>> adConType = ' + adConType);
        system.debug('=======>> fName = ' + fName);
        system.debug('=======>> lName = ' + lName);
        system.debug('=======>> emailAddr = ' + emailAddr);
        system.debug('=======>> aeId = ' + aeId);
        system.debug('=======>> recTypeId = ' + recTypeId);
        system.debug('=======>> acctId = ' + acctId);

        Account acct;
        if (acctId != null) {
            acct = [select ShippingStreet, ShippingCity, ShippingState, ShippingPostalCode, ShippingCountry, Recordtype.Name 
                        from Account
                        where Id = :acctId limit 1];
        }
		String strConRecType = (acct.Recordtype.Name.contains('Agency') )? 'Agency Contact' : 'Advertiser Contact'; 
        Recordtype objConRT = [select id from Recordtype where sobjecttype='Contact' and Name=:strConRecType];
            
        newContactResult retVal = new newContactResult();
        Contact newContact = new Contact(FirstName=fName, 
                                            LastName = lName, 
                                            Email = emailAddr,
                                            Agency_Contact_Type__c = (strConRecType=='Agency Contact')? adConType : null, //Added by Madhusudhan for SRSF-1352 on Oct-29-18
                                         	Advertiser_Contact_Type__c = (strConRecType=='Advertiser Contact')? adConType : null, //Added by Madhusudhan for SRSF-1352 on Oct-29-18
                                            Contact_Status__c  = 'Active',
                                            ownerId = aeId, 
                                            RecordTypeId = (objConRT!=null)? objConRT.Id : recTypeId,
                                         	Title = strTitle,
                                         	Phone = strPhone,
                                         	MobilePhone = strMobile,
                                         	MailingStreet = strStreet, 
                                         	MailingCity = strCity,
                                         	MailingState = strState,
                                         	MailingPostalCode = strZip,
                                         	MailingCountry = strCountry,
                                            AccountId = acctId
                                        );
        /*if (acct != null) {
            newContact.MailingStreet       = acct.ShippingStreet;
            newContact.MailingCity         = acct.ShippingCity;
            newContact.MailingState        = acct.ShippingState;
            newContact.MailingPostalCode   = acct.ShippingPostalCode;
            newContact.MailingCountry      = acct.ShippingCountry;
        }*/
        
        List<Id> dupContactIds = new List<Id>();
        Database.DMLOptions dmlOpts = new Database.DMLOptions();

        dmlOpts.DuplicateRuleHeader.AllowSave = forceSave;
        dmlOpts.DuplicateRuleHeader.runAsCurrentUser = true;
     //   Database.DuplicateError.isAllowSave
        Database.SaveResult sr = Database.insert(newContact, dmlOpts);
        if (!sr.isSuccess()) {
            Datacloud.DuplicateResult duplicateResult;
            for(Database.Error error : sr.getErrors()){
                if (error instanceof Database.DuplicateError) {
                    Database.DuplicateError duplicateError = (Database.DuplicateError)error;
                    duplicateResult = duplicateError.getDuplicateResult();
                    
                    // Get duplicate records
                    List<sObject> duplicateRecords = new List<sObject>();

                    // Return only match results of matching rules that 
                    //  find duplicate records
                    Datacloud.MatchResult[] matchResults = duplicateResult.getMatchResults();

                    // Just grab first match result (which contains the 
                    //   duplicate record found and other match info)
                    Datacloud.MatchResult matchResult = matchResults[0];

                    Datacloud.MatchRecord[] matchRecords = matchResult.getMatchRecords();

                    // Add matched record to the duplicate records variable
                    for (Datacloud.MatchRecord matchRecord : matchRecords) {
                        System.debug(loggingLevel.WARN, '=======>> MatchRecord: ' + matchRecord.getRecord());
                        duplicateRecords.add(matchRecord.getRecord());
                        dupContactIds.add((matchRecord.getRecord()).Id);
                    }
                    //Commentted by Madhu for SRSF-2387(SF Code Review)
                    /*List<Contact> dupContacts = [select Id, Name, Email, Phone, Account.Name, Owner.Name
                                                    From Contact
                                                    where Id in :dupContactIds];
                    retVal.result = 'DUPLICATES FOUND';
                ////    retVal.duplicateRecords = duplicateRecords;
                    retVal.duplicateRecords = dupContacts;*/
                } else {
                    retVal.result = 'ERROR';
                    retVal.duplicateRecords = null;
                }
            }
			if(!dupContactIds.isEmpty()){
				List<Contact> dupContacts = [select Id, Name, Email, Phone, Account.Name, Owner.Name
                                                    From Contact
                                                    where Id in :dupContactIds];
                retVal.result = 'DUPLICATES FOUND';
                ////    retVal.duplicateRecords = duplicateRecords;
                retVal.duplicateRecords = dupContacts;
			}
        } else {
            retVal.result = String.valueOf(newContact.Id);
            retVal.duplicateRecords = null;
        }
        return retVal;
     /*   try {
            insert newContact;
        } catch (Exception ex) {

            return 'ERROR: ' + ex.getMessage();
        }
        */
       // return String.valueOf(newContact.Id);
    }

    // START : SRSF-3212
    // Method used to count Number of Broadcast weeks between Dates
    @AuraEnabled
    public static Integer getNoOfBroadcastWeeks(Date startDt, Date endDt){
        Integer totalDays = startDt.daysBetween(endDt);
        System.debug('totalDays>>'+totalDays);
        Integer numberOfWeeks = 0;        

        for(Integer i=0; i<=totalDays; i++){
            Date dt = startDt + i;  
            DateTime currDate = DateTime.newInstance(dt.year(), dt.month(), dt.day()); 
            String todayDay = currDate.format('EEEE');
           
            if(todayDay =='Sunday') { 
                numberOfWeeks = numberOfWeeks + 1;  
            }            
        }
        DateTime currDate = DateTime.newInstance(endDt.year(), endDt.month(), endDt.day()); 
        String todayDay = currDate.format('EEEE');           
        
        if(todayDay != 'Sunday') {            
            numberOfWeeks= numberOfWeeks+1;
        }

        System.debug('numberOfWeeks---->'+numberOfWeeks); // number of Broadcast Weeks 
       return numberOfWeeks;
    }

    // Method used to calculate Flight End Date based on Start Date & No of weeks
    @AuraEnabled
    public static Date getFlightEndDate(Date startDt, Integer noOfWeeks){
        Integer numberOfWeeks = 0;
        Date endDate;
        for(Integer i=0; i<=noOfWeeks*7; i++){
            Date dt = startDt + i;  
            DateTime currDate = DateTime.newInstance(dt.year(), dt.month(), dt.day()); 
            String todayDay = currDate.format('EEEE');
           
            if(todayDay =='Sunday') { 
                numberOfWeeks = numberOfWeeks + 1;  
                if (numberOfWeeks == noOfWeeks){                     
                    endDate = Date.newInstance(currDate.year(), currDate.month(), currDate.day());
                    System.debug('endDate>>>>>'+endDate);
                }
            }
        }       
    return endDate; 
    }

    // END : SRSF-3212

    // SRSF-4392 : Added below method   
   /* @AuraEnabled
    public static List<String> getDemandSupplyPlatformValues(String fieldName) {
        List<String> options = new List<String>();
        options.addAll(ApexUtils.getPickListValues('Opportunity',fieldName));
        System.debug ('DemandSupplyPlatforms>>>>'+options);
        return options;
    }*/
    @AuraEnabled
    public static List<String> getPicklistValues(String fieldName) {
        List<String> options = new List<String>();
        options.addAll(ApexUtils.getPickListValues('Opportunity',fieldName));
        System.debug ('getPicklistValues>>>>'+options);
        return options;
    }        
}