public class CloneOpportunityController {
    
    public static Map<String,String> childObjMap = new Map<String,String>();
    public static Map<String,String> childObjRelationMap = new Map<String,String>();
    public static Map<String,String> childSObjectToClone = new Map<String, String>();   
    public static Set<Id> parentIds = new Set<Id>();
    public static Id newProposalId;
    public static String accName;
    public static Opportunity oppty; // SRSF-2590 : 09-03-2021

    @AuraEnabled
    public static Opportunity prePopulateOppData(String recordId) {
        Opportunity opp;       
        if(!CommonUtilities.isStringNullOrEmpty(recordId)){          
            opp = [SELECT Id, Name, StageName, Sales_Probability__c, DMA__c, AccountId, Account.RecordType.DeveloperName, Agency_Account__c, Rep_Firm__c, Flight_Start_Date__c, Flight_End_Date__c, CloseDate, Total_Forecast_Amount__c, RecordTypeId, RecordType.DeveloperName FROM Opportunity WHERE Id=:recordId LIMIT 1];
        }        
        return opp;
    }


    @AuraEnabled
    public static Account validateAccountSelection (String recId){
        Account acct;
        List<AccountTeamMember> atm; 
        if(!CommonUtilities.isStringNullOrEmpty(recId)){
            atm = [SELECT AccountId, UserId FROM AccountTeamMember WHERE UserId = :Userinfo.getUserId() AND AccountId=:recId];
            System.debug('Entered in validateAccountSelection>>>>'+atm.Size());
            if(!CommonUtilities.isListNullOrEmpty(atm) && atm.Size()>0){
                acct = [SELECT Id, Name, Agency__c, Rep_Firm__c, RecordType.DeveloperName FROM Account WHERE Id=:recId LIMIT 1];
            } else {                           
                String error = System.Label.Only_AccountTeamMember_can_Clone_an_Opportunity;
                setErrorMessage(error);                 
            }    
        }
        return acct;
    }
    
    @AuraEnabled
    public static Opportunity cloneOpportunity( String recordId, Opportunity record){        
        Opportunity opp, originalRecord, clonedRecord;
        Map<Id,Id> original2CloneMap = new Map<Id,Id>();   

        String loginUser = UserInfo.getUserId();
        try { 
            if(!CommonUtilities.isStringNullOrEmpty(recordId)){    
                opp = [SELECT Id,Name,OwnerID,RecordType.DeveloperName, Owner.Team_Role__c FROM Opportunity WHERE Id=:recordId LIMIT 1];
            }

            if(opp!=Null && opp.OwnerID == loginUser) {
                String recordQuery = getCreatableFieldsSOQL('Opportunity', 'Id = :recordId');               
                originalRecord = (Opportunity) Database.query( recordQuery );
                System.debug('originalRecord...'+originalRecord);
                clonedRecord = originalRecord.clone(false, false, false, false);
              
                Map<String, CloneOppRecTypeSetting__c> recTypeMap = CloneOppRecTypeSetting__c.getAll();
                
                if(opp.RecordType.DeveloperName.contains('Locked')) {  // RecordType Developer Name must have a word 'Locked'
                    if (recTypeMap.Size() > 0) { 
                        String rt = recTypeMap.get(opp.RecordType.DeveloperName).OppRecTypeDevName__c;                                                    
                        clonedRecord.RecordTypeId = CommonUtilities.fetchRecordTypeDetails('Opportunity').get(rt).Id; 
                    }
                }               
                clonedRecord.OwnerId = originalRecord.OwnerId; // Need to get from new Parent Opp field which will be created on Opp
                if(originalRecord.Cloned_From_Opportunity__c!=NULL) {
                    clonedRecord.Cloned_From_Opportunity__c = originalRecord.Cloned_From_Opportunity__c;
                } else {
                    clonedRecord.Cloned_From_Opportunity__c = originalRecord.Id;
                }
                //Set User selected values to cloned opportunity 
                setDataForClonedOpportunity(clonedRecord, record);

                System.debug('$$$ Opportunity clonedRecord--->'+clonedRecord);
                if (clonedRecord != NULL) {
                    Insert clonedRecord; 

                    if(clonedRecord.Id != NULL){   
                        OpportunityTeamMember newAccTm = new OpportunityTeamMember(OpportunityId = clonedRecord.Id , UserId = loginUser, TeamMemberRole = opp.Owner.Team_Role__c);
                        Insert newAccTm;             
                        //If Advertiser Account on Opportunity changed, then Proposal, PZ & PZMV names should be populated as per the latest account name from cloned Opportunity
                    //  Opportunity oppty = [SELECT Account.Name FROM Opportunity WHERE Id = :clonedRecord.Id]; // SRSF-2590: commented on 09-03-2021
                        oppty = [SELECT AccountId, Account.Name, Agency_Account__c, Rep_Firm__c FROM Opportunity WHERE Id = :clonedRecord.Id]; // SRSF-2590 : 9th March 2021
                       
                        if(oppty != null) {
                            accName = oppty.Account.Name.length() > 40 ?oppty.Account.Name.subString(0,40):oppty.Account.Name;
                        }
                        
                        original2CloneMap.put(originalRecord.Id, clonedRecord.Id);            
                        
                        //Clone childs Proposal, PZ & PZMV 
                        childSObjectToClone.put('Opportunity','Proposal__c');
                        childSObjectToClone.put('Proposal__c','Proposal_Zone__c');                
                        childSObjectToClone.put('Proposal_Zone__c','Proposal_Zone_Monthly_Value__c');
                    
                        //  Level 1
                        getChildRlnshpCreatableFldsSOQL('Opportunity');
                        Map<Id,SObject> childClone = cloneChildren('Opportunity', original2CloneMap);
                        //  Level 2
                        getChildRlnshpCreatableFldsSOQL('Proposal__c');
                        Map<Id,SObject> childClone2 = cloneChildren('Proposal__c', original2CloneMap);
                        
                       //  Level 3
                        getChildRlnshpCreatableFldsSOQL('Proposal_Zone__c');
                        Map<Id,SObject> childClone3 = cloneChildren('Proposal_Zone__c', original2CloneMap);
                    } 
                }   
            } else {
               String pageMsg = System.Label.Only_Opportunity_Owner_can_Clone_the_record;
               setErrorMessage(pageMsg);
            }    
        }
        catch(Exception ex) {    
            String msg = ex.getMessage() + ' at Line no : ' + ex.getLineNumber();
            System.debug(msg);
            Log4SF.logMessage('cloneOpportunityController', 'cloneOpportunity', msg, ex, loginUser,'NA');
            setErrorMessage(ex.getMessage());  
        }
        return clonedRecord;    
    }


// Returns a dynamic SOQL statement for the whole object, includes only creatable fields since we will be inserting a cloned result of this query
    //@AuraEnabled
    private static String getCreatableFieldsSOQL(String objectAPIName, String whereClause) {
        String selects = '';
        String query='';
        //if (whereClause == null || whereClause == ''){ return null; } --Commented Usha
        // Get a map of field name and field token
        Map<String, Schema.SObjectField> fMap = Schema.getGlobalDescribe().get(objectAPIName.toLowerCase()).getDescribe().Fields.getMap();
        List<String> selectedFields = new List<String>();
        if (fMap != null) {
            for (Schema.SObjectField ft : fMap.values()) { // loop through all field tokens (ft)
                Schema.DescribeFieldResult fd = ft.getDescribe(); // describe each field (fd)
             //   if (fd.isCreateable()) { // field is creatable  // Commented this because Sales Profiles does not have Create access on PZ, PZMV object
                    selectedFields.add(fd.getName());
             //   }
            }
        }
        if (!selectedFields.isEmpty()) {
            selects = String.join(selectedFields, ', ');
        }
        System.debug('$$$ selectedFields--->'+selectedFields);
        query = 'SELECT ' + selects + ' FROM ' + objectAPIName;
        if(whereClause != null || whereClause != '') { 
           query +=  ' WHERE ' + whereClause;
        }
        return query;
    }
    
    // Returns a dynamic SOQL statement for the whole object, includes only creatable fields since we will be inserting a cloned result of this query
    @TestVisible private static void getChildRlnshpCreatableFldsSOQL(String objectAPIName) {       
        SObjectType objToken = Schema.getGlobalDescribe().get(objectAPIName); 
        DescribeSObjectResult objDef = objToken.getDescribe();
        
        for (Schema.ChildRelationship cr: objDef.getChildRelationships()) {          
            if(cr.getField().getDescribe().isAccessible() && cr.getRelationshipName()!=null){ //cr.getField().getDescribe().isCreateable() && //removed this because Sales Profiles does not have Create access on PZ, PZMV object
                if(childSObjectToClone.get(objectAPIName).equals(''+cr.getChildSObject())) {
                    childObjMap.put(''+cr.getChildSObject()  , ''+cr.getRelationshipName());
                    System.debug('childObjMap....'+childObjMap);
                    childObjRelationMap.put(''+cr.getRelationshipName()  , ''+cr.getField());
                    System.debug('childObjRelationMap....'+childObjRelationMap);
                }
            }
        }
    }

   
    private static List<String> prepareSubqueries(Map<String , String> childrelatedListObjects, Set<Id> recIds){
        List<String> subqueries = new List<String>();
        parentIds = recIds;
        System.debug('parentIds : ' + parentIds);
        try {
            for(String childObject : childrelatedListObjects.keySet()){               
                String whereClause =childObjRelationMap.get(childObjMap.get(childObject))+' IN :parentIds';
                if(childObject.equals('Proposal__c')) 
                {
                    whereClause += ' AND RecordType.DeveloperName = \'Opportunity_Budget\'';
                }
                subqueries.add(getCreatableFieldsSOQL(childObject, whereClause));
            }
        }
        catch(Exception ex) {
            System.debug(ex.getMessage() + ' at Line no : ' + ex.getLineNumber());
            setErrorMessage(ex.getMessage());             
        }
        return subqueries;
    }

    public static Map<Id,SObject> cloneChildren(String objectAPIName, Map<Id,Id> original2CloneMap){  
        Map<Id,SObject> insertList = new Map<Id,SObject>();  
        List<String> subqueries = new List<String>();
        Id originalId;
        String errorMsg ='';
        try{    
            subqueries = prepareSubqueries(childObjMap, original2CloneMap.keySet()); 
            System.debug('$$$ subqueries--->'+subqueries); 
            String sObjName = childSObjectToClone.get(objectAPIName);
            System.debug('sObjName....'+sObjName);
            String relatedFldNm = childObjRelationMap.get(childObjMap.get(sObjName));
            System.debug('$$$ relatedFldNm--->'+relatedFldNm);
            for(String eachQry : subqueries) {
               System.debug('eachQry>>>'+eachQry);
                for(SObject temp : Database.query(eachQry)) {
                    if (temp.getSObjectType() == Proposal__c.sObjectType) { 
                       originalId = ((Proposal__c)temp).Opportunity__c;
                       ((Proposal__c)temp).Name = 'Opportunity Budget ' + accName;

                        //Start: SRSF-2590: 9th March 2021 - To populate Advertiser, Agency, RepFirm on Proposal from the New Opportunity                      
                        ((Proposal__c)temp).Advertiser__c = oppty.AccountId; 
                        ((Proposal__c)temp).Agency__c = oppty.Agency_Account__c; 
                        ((Proposal__c)temp).Rep_Firm__c = oppty.Rep_Firm__c;                        
                        // End: SRSF-2590: 9th March 2021   
                    }
                    if (temp.getSObjectType() == Proposal_Zone__c.sObjectType) { 
                       originalId = ((Proposal_Zone__c)temp).Proposal__c;
                       newProposalId = original2CloneMap.get(originalId);
                       ((Proposal_Zone__c)temp).Name = 'Proposal line ' + accName;                      
                    }
                    if (temp.getSObjectType() == Proposal_Zone_Monthly_Value__c.sObjectType) { 
                       originalId = ((Proposal_Zone_Monthly_Value__c)temp).Proposal_Zone__c;
                       ((Proposal_Zone_Monthly_Value__c)temp).Name ='Monthly Value '+ accName;

                       //Start: SRSF-2590: 9th March 2021 - To populate Advertiser and OppId on PZMV from the New Opportunity
                       ((Proposal_Zone_Monthly_Value__c)temp).Advertiser__c = oppty.AccountId;  
                       ((Proposal_Zone_Monthly_Value__c)temp).Opportunity__c = oppty.Id; 
                       // End: SRSF-2590: 9th March 2021  

                       //Set Cloned proposal Id to Proposal_Key_Index__c
                       Id propId = newProposalId != null ? String.valueof(newProposalId) : null ;
                       ((Proposal_Zone_Monthly_Value__c)temp).Proposal_Key_Index__c = propId;
                    }

                    Sobject cloneSObject = temp.clone(false, false, false, false);
                    cloneSObject.put(relatedFldNm, original2CloneMap.get(originalId));
                    insertList.put(temp.Id, cloneSObject);
                }
            }
            System.debug('$$$ Records to be inserted--->'+insertList);   
            if(insertList.size()>0) {                
                Database.SaveResult[] results = Database.insert(insertList.values(), false);
                for (Integer i = 0; i < results.size(); i++) {
                    if (!results[i].isSuccess()) {
                        errorMsg +=  results[i].getErrors()[i].getMessage() + '\n';
                        System.debug('Cloning failed due to: '+ errorMsg);
                    }
                }
                original2CloneMap.clear();
                resetChildObjMaps();

                for (Id i : insertList.keyset()) { 
                    original2CloneMap.put(i, insertList.get(i).id);
                }
                System.debug('$$$ original2CloneMap--->'+original2CloneMap);
            }                      
        }
        catch(Exception ex) {    
            String message = ex.getMessage() + ' at Line no : ' + ex.getLineNumber();        
            System.debug(message);
            Log4SF.logMessage('cloneOpportunityController', 'cloneOpportunity', errorMsg, message, UserInfo.getUserId(),'NA');
            setErrorMessage(ex.getMessage());
        }
        return insertList;
    }

    private static void setDataForClonedOpportunity(Opportunity clonedRecord, Opportunity record) {
        clonedRecord.Name = record.Name;
        clonedRecord.StageName = record.StageName;
        clonedRecord.CloseDate = record.CloseDate;
        clonedRecord.Sales_Probability__c = record.Sales_Probability__c;
        clonedRecord.AccountId = record.AccountId;
        clonedRecord.Agency_Account__c = record.Agency_Account__c;
        clonedRecord.Rep_Firm__c = record.Rep_Firm__c;
        clonedRecord.DMA__c = record.DMA__c;
        clonedRecord.Spectrum_Reach_Preferred__c = false;
        clonedRecord.Closed_Won_Lost_Date__c = null;
    }
    
    
    @TestVisible private static void resetChildObjMaps() {
        childObjMap.clear();
        childObjRelationMap.clear();
    } 

    private static void setErrorMessage(String message) {
        System.debug(message);
        AuraHandledException auraEx = new AuraHandledException(message);
        auraEx.setMessage(message);
        throw auraEx;  
    }
}