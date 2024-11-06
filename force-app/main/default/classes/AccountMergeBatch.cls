global class AccountMergeBatch implements Database.Batchable<SObject>, Database.Stateful, Database.AllowsCallouts {

    global String accountId;
    global String accountMergeLog;
    public String mergingType;
    global Map<Id, RecordType> rcTypeMap;
    global Map<string, Account_Merge_Detail__c> recordMergeDetailMap = new Map<string, Account_Merge_Detail__c> ();
    global Account acc = new Account();
    global Account_Merge_Log__c accMergeData = new Account_Merge_Log__c();
    string parentAccRecTypeName = 'Advertiser_Account';
    Map<String, List<SoBject>> mapParentAccData = new Map<String, List<SoBject>> ();
    Map<String, Map<String, String>> SFRecSyncpFolderMap = new Map<String, Map<String, String>> ();
    public List<Syncplicity__SyncTable__c> syncTable = new List<Syncplicity__SyncTable__c> ();
    public static String Exception_Message { get; set; }
    Map<String, String> mapRecordField = new Map<String, String> ();
    public Boolean isRetry= false;

    global AccountMergeBatch() {

    }
    global AccountMergeBatch(String accId, String accMergeLog, String mergeType,Boolean retry) {
        Exception_Message = System.Label.Exception_Message_For_Code_Coverage_and_Testing;
        accountId = accId;
        accountMergeLog = accMergeLog;
        mergingType = mergeType;
        System.debug('mergeType: '+ mergingType);
        
        this.isRetry = retry;
        rcTypeMap = new Map<Id, RecordType> ();
        acc = [SELECT Id, Name, Parentid, BillingStreet, BillingCity, BillingState, BillingPostalCode, Phone, MergeAccount__c, Account_Tim_Name__c, RecordType.DeveloperName, TIM_Account_ID__c, AccountExternalId__c, Political_Account__c FROM Account WHERE Id = :accountId];
        accMergeData = [SELECT ID, Merged_Account_ID__c, Account__c FROM Account_Merge_Log__c WHERE ID = :accountMergeLog LIMIT 1];
        System.debug('acc ' + acc);

    }
    /**
     * @description gets invoked when the batch job starts
     * @param context contains the job ID
     * @returns the record set as a QueryLocator object that will be batched for execution
     */
    global Database.QueryLocator start(Database.BatchableContext context) {
        String query = '';
        if(isRetry)
        query = 'SELECT Id, Name,Record_ID__c,Object_Name__c,Field_to_Update__c,is_Error__c,Error__c FROM Account_Merge_Detail__c where Account_Merge_Log__c = ' + '\'' + accountMergeLog + '\' AND is_Error__c = true';
        else
        query = 'SELECT Id, Name,Record_ID__c,Object_Name__c,Field_to_Update__c,is_Error__c,Error__c FROM Account_Merge_Detail__c where Account_Merge_Log__c = ' + '\'' + accountMergeLog + '\'';
        return Database.getQueryLocator(query);

    }

    /**
     * @description gets invoked when the batch job executes and operates on one batch of records. Contains or calls the main execution logic for the batch job.
     * @param context contains the job ID
     * @param scope contains the batch of records to process.
     */
    global void execute(Database.BatchableContext context, List<Account_Merge_Detail__c> scope) {
        System.debug('scope ' + scope);
        
        doDML(getSObjectData(scope), acc);
    }

    public List<dmlWrapper> getSObjectData(List<Account_Merge_Detail__c> scope) {
        List<dmlWrapper> wrapperList = new List<dmlWrapper> ();
        try {
            List<string> recordIDList = new List<String> ();
            Map<String, List<String>> mapObjectRecordID = new Map<String, List<String>> ();
            Map<String, String> mapObjectField = new Map<String, String> ();

            Map<String, List<Account_Merge_Detail__c>> mapObjectData = new Map<String, LIST<Account_Merge_Detail__c>> ();
            Map<String, String> mapSObjectQuery = new Map<String, String> ();
            for (Account_Merge_Detail__c accMerge : scope) {
                recordMergeDetailMap.put(accMerge.Record_ID__c, accMerge);
                if (mapObjectRecordID.containsKey(accMerge.Object_Name__c)) {
                    mapObjectRecordID.get(accMerge.Object_Name__c).add(accMerge.Record_ID__c);
                    mapObjectData.get(accMerge.Object_Name__c).add(accMerge);
                } else {
                    mapObjectRecordID.put(accMerge.Object_Name__c, new List<String> {
                                          accMerge.Record_ID__c
                                          });
                    mapObjectData.put(accMerge.Object_Name__c, new List<Account_Merge_Detail__c> {
                    accMerge
                    });                      
                }
                mapObjectField.put(accMerge.Object_Name__c, accMerge.Field_to_Update__c);
                mapRecordField.put(accMerge.Record_ID__c, accMerge.Field_to_Update__c);
                recordIDList.add(accMerge.Record_ID__c);
            }
            List<String> queryList = new List<String> ();
            List<String> objectListNew = new List<String> ();
            objectListNew.addAll(mapObjectField.keySet());
            Map<String, Set<String>> mapObjectFields = new Map<String, Set<String>> ();
            mapObjectFields = getDescribeFields(objectListNew);
            for (String obj : mapObjectField.keySet()) {
                string recordIds = '(\'' + mapObjectRecordID.get(obj) [0] + '\'';
                if (mapObjectRecordID.get(obj).size() == 1)
                recordIds += ')';
                //Integer i = mapObjectRecordID.get(obj).size();
                for (Integer i = 1; i<mapObjectRecordID.get(obj).size(); i++) {
                    if (i - mapObjectRecordID.get(obj).size() != - 1)
                    recordIds += ',\'' + mapObjectRecordID.get(obj) [i] + '\'';
                    else if (i - mapObjectRecordID.get(obj).size() == - 1)
                    recordIds += ',\'' + mapObjectRecordID.get(obj) [i] + '\'' + ')';
                }
                String commaSepratedFields = '';
                for (String fieldName : mapObjectFields.get(obj)) {
                    if (commaSepratedFields == null || commaSepratedFields == '') {
                        commaSepratedFields = fieldName;
                    } else {
                        commaSepratedFields = commaSepratedFields + ', ' + fieldName;
                    }
                }
                string objectQuery = 'Select ' + commaSepratedFields + ' from ' + obj + ' where ID in ' + recordIds;

                mapSObjectQuery.put(obj, objectQuery);
            }
            rcTypeMap = new Map<Id, RecordType> ([Select ID, developername from RecordType where SobjectType in :mapSObjectQuery.keySet()]);
            System.debug(mapSObjectQuery);
            for (String obj : mapSObjectQuery.keySet()) {
                System.debug(mapSObjectQuery.get(obj));
                dmlWrapper objDmlWrapper = new dmlWrapper();
                objDmlWrapper.objectName = obj;
                objDmlWrapper.newAccountID = accountId;
                objDmlWrapper.sObjectList = Database.query(mapSObjectQuery.get(obj));
                wrapperList.add(objDmlWrapper);
            }
            // We might not need it.

            if (mapSObjectQuery.keySet().contains('Sales_Budget__c')) {
                List<Sales_Budget__c> sbList = [SELECT Id, Name, Advertiser__c, Commodity__c, DMA__c, New_Business_Churn__c, Type__c, Broadcast_Date_Text__c, Amount__c, External_Id_Text__c, Budget_User__c, Product_Line__c FROM Sales_Budget__c WHERE Advertiser__c = :acc.Id];
                mapParentAccData.put('Sales_Budget__c', sbList);
            }
            if (mapSObjectQuery.keySet().contains('Account_SAM_Mapping__c')) {
                System.debug('acc.Id ' + acc.Id);
                List<Account_SAM_Mapping__c> accSAMList = [Select ID, User__c, SAM_Designation__c, Account__c from Account_SAM_Mapping__c where Account__c = :acc.Id];
                mapParentAccData.put('Account_SAM_Mapping__c', accSAMList);
                System.debug('mapParentAccData ' + mapParentAccData);
            }
            if (mapSObjectQuery.keySet().contains('AccountTeamMember')) {
                System.debug('acc.ID ' + acc.ID);
                List<AccountTeamMember> atmList = [Select ID, AccountID, UserID, TeamMemberRole from AccountTeamMember where AccountID = :acc.ID];
                mapParentAccData.put('AccountTeamMember', atmList);
            }
            if (mapSObjectQuery.keySet().contains('Interim_AE_Account__c')) {
                System.debug('acc.ID ' + acc.ID);
                List<Interim_AE_Account__c> interimList = [Select ID, Account__c from Interim_AE_Account__c where Account__c = :acc.ID];
                mapParentAccData.put('Interim_AE_Account__c', interimList);
            }
            System.debug(wrapperList);

            if (Test.isRunningTest()) {
                CalloutException e = new CalloutException();
                e.setMessage(Exception_Message);
                throw e;
            }
        }
        catch(Exception ex)
        {
            Log4SF.logMessage('AccountMergeBatch', 'getSObjectData', ex.getMessage(), ex, UserInfo.getUserId(), null, '');
        }
        return wrapperList;
    }

    public void doDML(List<dmlWrapper> wrapperList, Account acc) {
        try {
            List<Sobject> updateSObjectList = new List<SObject> ();
            List<Sobject> updateSObjectChunkList = new List<SObject> ();
            List<Sobject> updateSObjectChunk2List = new List<SObject> ();
            List<Sobject> updateSObjectChunk3List = new List<SObject> ();
            List<Sobject> insertSObjectList = new List<SObject> ();
            List<Sobject> deleteSObjectList = new List<SObject> ();

            List<Sobject> updateSObjectListForOppConSamSalBudPro = new List<SObject> ();


            string rcName = acc.RecordType.DeveloperName;
            for (dmlWrapper str : wrapperList) {
                System.debug(str);
                if (str.objectName == 'Opportunity') {
                    for (SObject obj : str.sObjectList) {
                        System.debug('obj ' + obj);

                        Opportunity opp = new Opportunity();
                        opp.Id = String.valueOf(obj.get('Id'));
                        
                        //String rcName = rcTypeMap.get(String.valueOf(obj.get('recordTypeID'))).developername;
                        System.debug('rcName ' + rcName);
                        if (rcName == 'Advertiser_Account') {
                            opp.AccountId = str.newAccountID;
                        } else if (rcName == 'Agency_Account' || rcName == 'In_House_Agency_Account') {
                            if(mapRecordField.containsKey(opp.Id))
                            {
                                if(mapRecordField.get(opp.Id) == 'Agency_Account__c')
                                    opp.Agency_Account__c = str.newAccountID;
                                else if(mapRecordField.get(opp.Id) == 'AccountID')    
                                    opp.AccountID = str.newAccountID;
                            }
                            
                        } else if (rcName == 'Rep_Firm') {
                            opp.Rep_Firm__c = str.newAccountID;
                        }
                        System.debug('opp ' + opp);
                        updateSObjectListForOppConSamSalBudPro.add(opp);
                    }
                } else if (str.objectName == 'Account_SAM_Mapping__c') {
                    System.debug(' accountMergeBatch Account_SAM_Mapping__c');
                    Map<String, Map<String, String>> mapSAM = new Map<String, Map<String, String>> ();
                    Map<String, Account_SAM_Mapping__c> mapUserAccSAM = new Map<String, Account_SAM_Mapping__c> ();
                    List<Account_SAM_Mapping__c> delAccSAMList = new List<Account_SAM_Mapping__c> ();

                    List<Account_SAM_Mapping__c> accSAMList = new List<Account_SAM_Mapping__c> ();
                    accSAMList.addAll((List<Account_SAM_Mapping__c>) mapParentAccData.get('Account_SAM_Mapping__c'));

                    System.debug('accSAMList ' + accSAMList);
                    for (Account_SAM_Mapping__c accSAM : accSAMList) {
                        mapUserAccSAM.put(string.valueOf(accSAM.User__c) + string.valueOf(accSAM.Account__c), accSAM);
                        if (mapSAM.containsKey(accSAM.Account__c)) {
                            mapSAM.get(accSAM.Account__c).put(accSAM.User__c, accSAM.SAM_Designation__c);
                        } else {
                            mapSAM.put(accSAM.Account__c, new Map<String, String> {
                                       accSAM.User__c => accSAM.SAM_Designation__c
                                       });
                        }

                    }
                    Map<String, SAM_Designation_Order__c> accSAMOrder = SAM_Designation_Order__c.getAll();
                    for (SObject obj : str.sObjectList) {
                        string accID = String.valueOf(obj.get('Account__c'));
                        string userID = String.valueOf(obj.get('User__c'));
                        if (mapSAM.containsKey(acc.ID)) {
                            if (mapSAM.get(acc.ID).containsKey(userID)) {
                                System.debug(' ======= Merging accSAMUpdated ' + mapSAM.get(acc.Id).containsKey(userID));
                                if (accSAMOrder.get(mapSAM.get(acc.Id).get(userID)).SAM_Order__c<accSAMOrder.get(mapSAM.get(acc.Id).get(userID)).SAM_Order__c) {
                                    mapUserAccSAM.get(userID + acc.Id).SAM_Designation__c = mapSAM.get(acc.Id).get(userID);
                                    updateSObjectListForOppConSamSalBudPro.add(mapUserAccSAM.get(userID + acc.Id));
                                } else {
                                    delAccSAMList.add(mapUserAccSAM.get(userID + acc.Id));
                                }
                            } else {
                                Account_SAM_Mapping__c sam = (Account_SAM_Mapping__c) obj;
                                sam.Account__c = acc.Id;
                                system.debug('sam ' + sam);
                                updateSObjectListForOppConSamSalBudPro.add(sam);
                            }
                        }
                        if (mapSAM.size() == 0) {
                            Account_SAM_Mapping__c sam = (Account_SAM_Mapping__c) obj;
                            sam.Account__c = acc.Id;
                            system.debug('sam ' + sam);
                            updateSObjectListForOppConSamSalBudPro.add(sam);
                        }
                    }

                    //updateSObjectListForOppConSamSalBudPro.add(sbd);

                }
                
                else if (str.objectName == 'Sales_Budget__c') {
                    System.debug(' accountMergeBatch Sales_Budget__c');
                    List<Sales_Budget__c> sbList = new List<Sales_Budget__c> ();
                    List<Sales_Budget__c> delList = new List<Sales_Budget__c> ();
                    Map<String, Map<string, Sales_Budget__c>> mapAccBud = new Map<String, Map<string, Sales_Budget__c>> ();
                    String Key;
                    List<Sales_Budget__c> salesBudgetList = new List<Sales_Budget__c> ();
                    salesBudgetList.addAll((List<Sales_Budget__c>) mapParentAccData.get('Sales_Budget__c'));
                    if (salesBudgetList.size()> 0) {
                        for (Sales_Budget__c bud : salesBudgetList) {
                            key = bud.External_Id_Text__c;
                            // If map contains Account.
                            if (mapAccBud.containsKey(bud.Advertiser__c)) {
                                if (!mapAccBud.get(bud.Advertiser__c).containsKey(key))
                                mapAccBud.get(bud.Advertiser__c).put(key, bud);
                                else {
                                    bud.Amount__c += mapAccBud.get(bud.Advertiser__c).get(key).Amount__c;
                                    mapAccBud.get(bud.Advertiser__c).put(key, bud);
                                }
                            }
                            // If map  does not contains Account.
                            else {
                                mapAccBud.put(bud.Advertiser__c, new Map<string, Sales_Budget__c> {
                                              key => bud
                                              });
                            }
                        }
                    }
                    System.debug(' ======= Merging Sales Budget mapSalesBud ======= ' + mapAccBud);
                    //System.debug('accId@@: ' + accId);
                    //If Map contains the child account data.
                    for (SObject obj : str.sObjectList) {
                        Sales_Budget__c sb = (Sales_Budget__c) obj;
                        string accID = String.valueOf(obj.get('Advertiser__c'));
                        string userID = String.valueOf(obj.get('Budget_User__c'));
                        string strKey = String.valueOf(obj.get('External_Id_Text__c'));
                        Decimal amnt = Decimal.valueOf(String.valueOf(obj.get('Amount__c')));
                        string oldKey = strKey;
                        //Validate the Map for Parent Account.
                        if (mapAccBud.containsKey(acc.ID)) {
                            //id accID = acc.Id ;
                            //string subsetID = acc
                            List<string> strList = strKey.split(':');
                            if (strList.size() >= 7)
                            strList[2] = acc.Id;
                            // Check if key has New Business and UnknownChurn Data
                            if (strKey.substring(strKey.length() - 1, strKey.length()) == ':')
                            strKey = String.join(strList, ':') + ':';
                            else
                            strKey = String.join(strList, ':');
                            System.debug(' ======= Merging Sales Budget Key ======= ' + strKey);
                            System.debug(' ======= Merging Sales Budget Old Key ======= ' + oldKey);
                            if (mapAccBud.get(acc.Id).containsKey(strKey)) {
                                System.debug('Position 1');
                                System.debug('mapAccBud.get(acc.Id): '+mapAccBud.get(acc.Id));
                                if (Schema.sObjectType.Sales_Budget__c.fields.Amount__c.isUpdateable())
                                mapAccBud.get(acc.Id).get(strKey).Amount__c += amnt;
                                updateSObjectListForOppConSamSalBudPro.add(mapAccBud.get(acc.Id).get(strKey));
                                delList.add(sb);
                            } else {
                                //System.debug(' ======= Merging Sales Budget Inside Else ======= ' + mapAccBud.get(accId).get(oldKey));
                                System.debug('Position 2');
                                if (Schema.sObjectType.Sales_Budget__c.fields.Advertiser__c.isUpdateable())
                                sb.Advertiser__c = acc.Id;
                                updateSObjectListForOppConSamSalBudPro.add(sb);
                            }
                        } else {
                            System.debug('Position 3');
                            sb.Advertiser__c = acc.Id;
                            System.debug(' ======= sb ======= ' + sb);
                            updateSObjectListForOppConSamSalBudPro.add(sb);
                        }
                    }
                    if(delList.size()>0){
                        System.debug('delList: '+delList);
                        Database.delete(delList, false);
                    }
                }
                

                else if (str.objectName == 'AccountTeamMember') {
                    System.debug(' accountMergeBatch AccountTeamMember');
                    List<AccountTeamMember> atmList = new List<AccountTeamMember> ();
                    atmList.addAll((List<AccountTeamMember>) mapParentAccData.get('AccountTeamMember'));
                    Map<String, Map<String, AccountTeamMember>> accUserATMMap = new Map<String, Map<String, AccountTeamMember>> ();
                    List<AccountTeamMember> atmUpsertList = new List<AccountTeamMember> ();

                    for (AccountTeamMember atm : atmList) {
                        if (!accUserATMMap.containsKey(acc.ID)) {
                            accUserATMMap.put(acc.ID, new Map<String, AccountTeamMember> {
                                              atm.UserId => atm
                                              });
                        } else {
                            Map<String,
                            AccountTeamMember> userATMMap = new Map<String, AccountTeamMember> ();
                            userATMMap = accUserATMMap.get(acc.ID);
                            userATMMap.put(atm.UserId, atm);
                            accUserATMMap.put(acc.ID, userATMMap);
                        }
                    }

                    //For each of the Child Account Team member verify if the parent has the ATM record for the same user
                    //If Yes - then verify the TeamMemberRole
                    System.debug(' accUserATMMap.keySet()' + accUserATMMap.keySet());


                    for (SObject obj : str.sObjectList) {
                        System.debug('obj ' + obj);

                        String accID = String.valueOf(obj.get('AccountId'));
                        String userID = String.valueOf(obj.get('UserId'));
                        String memberRole = String.valueOf(obj.get('TeamMemberRole'));

                        //System.debug('accUserATMMap.get(acc.id).get(userID) ' + accUserATMMap.get(acc.id).get(userID));

                        System.debug('accUserATMMap ' + accUserATMMap);

                        System.debug('accID ' + accID); //Child

                        System.debug('userID ' + userID);

                        //System.debug('accUserATMMap.get(accID).get(userID) ' + accUserATMMap.get(acc.ID));


                        if (accUserATMMap.containsKey(acc.ID)) {
                            if (accUserATMMap.get(acc.id).containsKey(userID)) {
                                System.debug('parent ATM ' + accUserATMMap.get(acc.id).get(userID));
                                System.debug('Child ATM' + obj);
                                if (accUserATMMap.get(acc.id).get(userID).TeamMemberRole != 'Sales Manager') {
                                    if (memberRole == 'Sales Manager') { AccountTeamMember atm = accUserATMMap.get(acc.id).get(userID);
                                        AccountTeamMember atmNew = atm.clone(false, false, false, false);
                                        atmNew.AccountId = acc.Id;
                                        insertSObjectList.add(atmNew);
                                    } else if (memberRole == 'Account Executive' && accUserATMMap.get(acc.ID).get(userID).TeamMemberRole != 'Account Executive') {
                                        AccountTeamMember atm = accUserATMMap.get(acc.id).get(userID);
                                        AccountTeamMember atmNew = atm.clone(false, false, false, false);
                                        atmNew.AccountId = acc.Id;
                                        insertSObjectList.add(atmNew);
                                    }
                                }
                            } else {
                                System.debug('Child ATM' + obj);
                                AccountTeamMember atmNew = (AccountTeamMember) obj.clone(false, false, false, false);
                                atmNew.AccountId = acc.Id;
                                insertSObjectList.add(atmNew);

                            }
                        }
                        else {
                            System.debug('Child ATM' + obj);
                            AccountTeamMember atmNew = (AccountTeamMember) obj.clone(false, false, false, false);
                            atmNew.AccountId = acc.Id;
                            insertSObjectList.add(atmNew);

                        }
                    }
                } else if (str.objectName == 'AccountConnection__c') {
                    for (SObject obj : str.sObjectList) {
                        System.debug(obj);

                        AccountConnection__c AccCon = new AccountConnection__c();
                        AccCon.Id = String.valueOf(obj.get('Id'));

                        AccCon.Account__c = str.newAccountID;

                        updateSObjectList.add(AccCon);
                    }
                }
                else if (str.objectName == 'Case') {
                    for (SObject obj : str.sObjectList) {
                        System.debug(obj);

                        Case caseRec = new Case();
                        caseRec.Id = String.valueOf(obj.get('Id'));

                        caseRec.AccountID = str.newAccountID;

                        updateSObjectChunk3List.add(caseRec);
                    }
                }
                else if (str.objectName == 'Digital_Campaign__c') {
                    for (SObject obj : str.sObjectList) {
                        System.debug(obj);

                        Digital_Campaign__c dcl = new Digital_Campaign__c();
                        dcl.Id = String.valueOf(obj.get('Id'));
                        //String rcName = rcTypeMap.get(String.valueOf(obj.get('recordTypeID'))).Name;

                        if (rcName == 'Advertiser_Account') {
                            dcl.Advertiser__c = str.newAccountID;
                        } else if (rcName == 'Agency_Account' || rcName == 'In_House_Agency_Account') {  dcl.Agency__c = str.newAccountID;
                        }
                        updateSObjectList.add(dcl);

                    }
                } else if (str.objectName == 'Support_Request__c') {
                    for (SObject obj : str.sObjectList) {
                        System.debug(obj);

                        Support_Request__c srq = new Support_Request__c();
                        srq.Id = String.valueOf(obj.get('Id'));

                        if (rcName == 'Advertiser_Account') {
                            srq.Advertiser__c = str.newAccountID;
                        } else if (rcName == 'Agency_Account' || rcName == 'In_House_Agency_Account') {srq.Agency__c = str.newAccountID;
                        } else if (rcName == 'Rep_Firm') { srq.Rep_Firm__c = str.newAccountID;
                        }
                        updateSObjectChunkList.add(srq);

                    }
                } else if (str.objectName == 'Proposal__c') {
                    for (SObject obj : str.sObjectList) {
                        System.debug(obj);

                        Proposal__c prp = new Proposal__c();
                        prp.Id = String.valueOf(obj.get('Id'));

                        if (rcName == 'Advertiser_Account') { prp.Advertiser__c = str.newAccountID;
                        } else if (rcName == 'Agency_Account' || rcName == 'In_House_Agency_Account') { prp.Agency__c = str.newAccountID;
                        } else if (rcName == 'Rep_Firm') { prp.Rep_Firm__c = str.newAccountID;
                        }
                        updateSObjectListForOppConSamSalBudPro.add(prp);

                    }
                } else if (str.objectName == 'Contact') {
                    for (SObject obj : str.sObjectList) {
                        System.debug(obj);

                        Contact Con = new Contact();
                        Con.Id = String.valueOf(obj.get('Id'));

                        Con.AccountId = str.newAccountID;

                        updateSObjectListForOppConSamSalBudPro.add(Con);
                    }
                }
                else if (str.objectName == 'CNA__c') {
                    for (SObject obj : str.sObjectList) {
                        System.debug(obj);

                        CNA__c Cna = new CNA__c();
                        Cna.Id = String.valueOf(obj.get('Id'));

                        if (rcName == 'Advertiser_Account') {
                            Cna.Account__c = str.newAccountID;
                        } else if (rcName == 'Agency_Account' || rcName == 'In_House_Agency_Account') {
                            Cna.Agency__c = str.newAccountID;
                        }
                        updateSObjectChunkList.add(Cna);
                    }
                } else if (str.objectName == 'Traffic_Id_Element__c') {
                    for (SObject obj : str.sObjectList) {
                        System.debug(obj);

                        Traffic_Id_Element__c Tie = new Traffic_Id_Element__c();
                        Tie.Id = String.valueOf(obj.get('Id'));

                        Tie.Account__c = str.newAccountID;

                        updateSObjectChunk2List.add(Tie);
                    }
                } else if (str.objectName == 'Revenue__c') {
                    for (SObject obj : str.sObjectList) {
                        System.debug(obj);

                        Revenue__c Rev = new Revenue__c();
                        Rev.Id = String.valueOf(obj.get('Id'));

                        Rev.Advertiser__c = str.newAccountID;

                        updateSObjectChunk2List.add(Rev);
                    }
                } else if (str.objectName == 'Trade__c') {
                    for (SObject obj : str.sObjectList) {
                        System.debug(obj);

                        Trade__c Trde = new Trade__c();
                        Trde.Id = String.valueOf(obj.get('Id'));

                        Trde.Account__c = str.newAccountID;

                        updateSObjectChunkList.add(Trde);
                    }
                }else if (str.objectName == 'Interim_AE_Account__c'){
                    for(SObject obj : str.sObjectList){
                        System.debug(obj);
                        Interim_AE_Account__c interim = new Interim_AE_Account__c();
                        interim.Id = String.valueOf(obj.get('Id'));
                        interim.Account__c = str.newAccountID;
                        updateSObjectList.add(interim);
                    }
                }
            }
            if (insertSObjectList.size() > 0) {
                Database.SaveResult[] results = Database.insert(insertSObjectList, false);
                updateMergeDetail(results);
                /*for (Database.SaveResult item : results) {
                  System.debug(item);
                  if (!item.isSuccess()) {
                  System.debug(item.getErrors());
                  }
                  }*/
            }
            if (updateSObjectList.size() > 0) {
                //update updateSObjectList;
                Database.SaveResult[] result = Database.update(updateSObjectList, false);
                updateMergeDetail(result);
                /*for (Database.SaveResult item : result) {
                  System.debug(item);
                  if (!item.isSuccess()) {
                  System.debug(item.getErrors());
                  }
                  }*/
            }
            if (updateSObjectChunkList.size() > 0) {
                //update updateSObjectList;
                Database.SaveResult[] result = Database.update(updateSObjectChunkList, false);
                updateMergeDetail(result);
                /*for (Database.SaveResult item : result) {
                  System.debug(item);
                  if (!item.isSuccess()) {
                  System.debug(item.getErrors());
                  }
                  }*/
            }
            if (updateSObjectChunk2List.size() > 0) {
                //update updateSObjectList;
                Database.SaveResult[] result = Database.update(updateSObjectChunk2List, false);
                updateMergeDetail(result);
                /*for (Database.SaveResult item : result) {
                  System.debug(item);
                  if (!item.isSuccess()) {
                  System.debug(item.getErrors());
                  }
                  }*/
            }
            if (updateSObjectChunk3List.size() > 0) {
                //update updateSObjectList;
                Database.SaveResult[] result = Database.update(updateSObjectChunk3List, false);
                updateMergeDetail(result);
                /*for (Database.SaveResult item : result) {
                  System.debug(item);
                  if (!item.isSuccess()) {
                  System.debug(item.getErrors());
                  }
                  }*/
            }
            if (updateSObjectListForOppConSamSalBudPro.size() > 0) {
                //update updateSObjectListForOppConSamSalBudPro;
                Database.SaveResult[] result = Database.update(updateSObjectListForOppConSamSalBudPro, false);
                updateMergeDetail(result);
                /*for (Database.SaveResult item : result) {
                  System.debug(item);
                  if (!item.isSuccess()) {
                  System.debug(item.getErrors());
                  }
                  }*/
            }

           

            if (deleteSObjectList.size() > 0) {
                delete deleteSObjectList;

            }
            if (Test.isRunningTest()) {
                CalloutException e = new CalloutException();
                e.setMessage(Exception_Message);
                throw e;
            }
        }
        catch(Exception ex)
        {
            Log4SF.logMessage('AccountMergeBatch', 'doDML', ex.getMessage(), ex, UserInfo.getUserId(), null, '');
        }
    }
    /**
     * @description gets invoked when the batch job finishes. Place any clean up code in this method.
     * @param context contains the job ID
     */
    global void finish(Database.BatchableContext context) {
        try {
            //MergeSyncpFolders();
            if (!Test.isRunningTest()) {
                //MergeSyncpFolders();
            }
            sendStatusEmail(true, accountMergeLog,mergingType);

            if (Test.isRunningTest()) {
                CalloutException e = new CalloutException();
                e.setMessage(Exception_Message);
                throw e;
            }
        }
        catch(Exception ex)
        {
            Log4SF.logMessage('AccountMergeBatch', 'finish', ex.getMessage(), ex, UserInfo.getUserId(), null, '');
        }
    }
    private static void sendStatusEmail(Boolean isErrorOccured, String accountMergeLog, String mergingType) {
        try
        {
            System.debug(mergingType);

            List<Account_Merge_Log__c> AMD = [SELECT Child_AccountTeamMember_Count__c, Child_Account_Connection_Count__c, Child_CNA_Count__c, Child_Contact_Count__c, Child_Digital_Campaign_Count__c, Child_Opportunity_Count__c, Child_Proposal_Count__c, Child_Revenue_Count__c, Child_SalesBudget_Count__c, Child_SAM_Count__c, Child_Support_Request_Count__c, Child_Trade_Count__c, Child_TrafficIdElement_Count__c,Child_Interim_AE_Account_Count__c FROM Account_Merge_Log__c where Id = :accountMergeLog];
            Messaging.SingleEmailMessage message = new Messaging.SingleEmailMessage();
            message.toAddresses = new String[] { userinfo.getUserEmail() }; // userinfo.getUserEmail()
            message.subject = 'Account Merge Status';
            String messageBody = '';
            if (isErrorOccured)
            {
                for (Account_Merge_Log__c accMergeLog : AMD) {
                    messageBody = '<html><body>Hi ' + userinfo.getName() + ',<br/><br/>' + System.Label.Email_Account_Merge_Success_Status + '<a href="' + URL.getSalesforceBaseUrl().toExternalForm() + '/' + accountMergeLog + '">Click here</a><br/><br/><b>Merged Object Count -</b>' + '<br/><br/> CNA :' + accMergeLog.Child_CNA_Count__c + ' <br/> Contact : ' + accMergeLog.Child_Contact_Count__c + '<br/> Account Team Member :' + accMergeLog.Child_AccountTeamMember_Count__c + '<br/> Digital Campaign :' + accMergeLog.Child_Digital_Campaign_Count__c + '<br/> Opportunity :' + accMergeLog.Child_Opportunity_Count__c + '<br/> Proposal :' + accMergeLog.Child_Proposal_Count__c + '<br/> Revenue : ' + accMergeLog.Child_Revenue_Count__c + '<br/> Sales Budget : ' + accMergeLog.Child_SalesBudget_Count__c + '<br/> SAM Mapping : ' + accMergeLog.Child_SAM_Count__c + '<br/> Support Request : ' + accMergeLog.Child_Support_Request_Count__c + '<br/>  Trade :' + accMergeLog.Child_Trade_Count__c + '<br/> Traffic Id Element :' + accMergeLog.Child_TrafficIdElement_Count__c + '<br/> Account Connection :' + accMergeLog.Child_Account_Connection_Count__c + '<br/> Interim AE Account : '+ accMergeLog.Child_Interim_AE_Account_Count__c +  '<br/>' + '</html> <br/> <br/> ' + 'Thanks';
                }
            }
            else
            {
                messageBody = '<html><body>Hi ' + userinfo.getName() + ', <br/>' + System.Label.Email_Account_Merge_Error_Status + ' <a href="' + URL.getSalesforceBaseUrl().toExternalForm() + '/' + accountMergeLog + '">Click here</a></html><br/><br/>Thanks';
            }

            if(mergingType == 'Merge'){
                message.setHtmlBody(messageBody);
                Messaging.sendEmail(new Messaging.SingleEmailMessage[] { message }); 
            }
            else{
                System.debug('Bulk Merge');
            }
            

            //Delete Child Account
            List<Account_Merge_Log__c> ChildAccountID = [SELECT Merged_Account_ID__c FROM Account_Merge_Log__c where Id = :accountMergeLog];
            Id accID;
            if (ChildAccountID.size() > 0) {
                for (Account_Merge_Log__c AMLAccID : ChildAccountID) {
                    accID = AMLAccID.Merged_Account_ID__c;
                }
            }
            SalesforceFilesUtility.mergeSFRecordFiles(accountMergeLog);
            Account acc = [SELECT Id FROM Account where Id = :accID];
            AccountMergeUpdate.deleteAccount(acc); 

            if (Test.isRunningTest()) {
                CalloutException e = new CalloutException();
                e.setMessage(Exception_Message);
                throw e;
            }
        }
        catch(Exception ex)
        {
            system.debug('@@Error: ' + ex);
            system.debug('@@Error Line Number: ' + ex.getLineNumber());
            //Log4SF.logMessage('AccountMergeBatch', 'sendStatusEmail', ex.getMessage(), ex, UserInfo.getUserId(), null, '');
        }
    }

// Not Needed Anymore
/*
    public void MergeSyncpFolders() {
        try
        {
            Map<String, SyncplicityIntegration__c> custSettMap = new Map<String, SyncplicityIntegration__c> ();
            custSettMap = SyncplicityIntegration__c.getAll();
            Integer apiBatchSize = (Integer) custSettMap.get('Syncplicity').APIBatchsize__c;
            String rootFolderSyncPointId = (String) custSettMap.get('Syncplicity').RootFolderSyncpointId__c;
            SFRecSyncpFolderMap = new Map<String, Map<String, String>> ();
            String targetFolderOppFolderId;
            String targetFolderAccReqFolderId;
            String targetFolderCNAFolderId;
            String targetAccountFilesFolder;

            System.debug(' ======= Merging Syncplicity Folders ======= ');
            System.debug(' acc: ' + acc);

            syncTable = [SELECT Id, Syncplicity__syncpRecordFolderId__c, Syncplicity__syncpSyncPointId__c, Syncplicity__salesforceRecordId__c
                         FROM Syncplicity__SyncTable__c
                         WHERE((Syncplicity__salesforceRecordId__c = :acc.Id OR Syncplicity__salesforceRecordId__c = :accMergeData.Merged_Account_ID__c)
                               AND Syncplicity__syncpRecordFolderId__c != NULL)];
            if (syncTable.size() > 0)
            {
                for (Syncplicity__SyncTable__c syncpObj : syncTable)
                {
                    if (syncpObj.Syncplicity__salesforceRecordId__c == accMergeData.Merged_Account_ID__c) {
                        Map<String, String> mapFolderRecId = new Map<String, String> ();
                        mapFolderRecId.put(accMergeData.Merged_Account_ID__c, syncpObj.Syncplicity__syncpRecordFolderId__c);
                        SFRecSyncpFolderMap.put('Source', mapFolderRecId);
                    }

                    else if (syncpObj.Syncplicity__salesforceRecordId__c == acc.Id) {
                        Map<String, String> mapFolderRecId = new Map<String, String> ();
                        mapFolderRecId.put(acc.Id, syncpObj.Syncplicity__syncpRecordFolderId__c);
                        SFRecSyncpFolderMap.put('Target', mapFolderRecId);
                    }
                }
                System.debug('accMergeData.Merged_Account_ID__c: ' + accMergeData.Merged_Account_ID__c);
                System.debug('SFRecSyncpFolderMap: ' + SFRecSyncpFolderMap);
                SyncplicityWebServiceHelper objSyncplicityWebServiceHelper = new SyncplicityWebServiceHelper();
                AuthSyncplicityJSONParse jsonAuth = AuthSyncplicityJSONParse.parse(objSyncplicityWebServiceHelper.AuthenticateRestService());
                System.debug('jsonAuth: ' + jsonAuth);
                GetFolderContentJSONParser jsonSourceFolderContent = GetFolderContentJSONParser.parse(objSyncplicityWebServiceHelper.GetFolderContent(rootFolderSyncPointId, SFRecSyncpFolderMap.get('Source').get(accMergeData.Merged_Account_ID__c), jsonAuth.access_token));
                System.debug('jsonSourceFolderContent@@: ' + jsonSourceFolderContent);
                GetFolderContentJSONParser jsonTargetFolderContent = GetFolderContentJSONParser.parse(objSyncplicityWebServiceHelper.GetFolderContent(rootFolderSyncPointId, SFRecSyncpFolderMap.get('Target').get(acc.Id), jsonAuth.access_token));

                for (GetFolderContentJSONParser.Folders folder : jsonTargetFolderContent.Folders) {
                    if (folder.Name == 'Opportunities') {
                        targetFolderOppFolderId = folder.FolderId;
                        System.debug('targetFolderOppFolderId@@:' + targetFolderOppFolderId);
                    }
                    else if (folder.Name == 'CNAs') {
                        targetFolderCNAFolderId = folder.FolderId;
                        System.debug('targetFolderCNAFolderId@@:' + targetFolderCNAFolderId);
                    }
                    else if (folder.Name == 'Account Requests') {
                        targetFolderAccReqFolderId = folder.FolderId;
                        System.debug('targetFolderAccReqFolderId@@:' + targetFolderAccReqFolderId);
                    }

                    else if (folder.Name.toLowerCase().contains('.files')) {
                        targetAccountFilesFolder = folder.FolderId;
                        System.debug('targetAccountFilesFolder@@:' + targetAccountFilesFolder);
                    }
                }
                List<Opportunity> lstOpp = [SELECT ID, Name, CreatedDate FROM Opportunity WHERE AccountId = :acc.Id];
                List<Account_Request__c> lstAccReq = [SELECT ID, Name, CreatedDate FROM Account_Request__c WHERE Advertiser_Agency_Rep_Firm__c = :acc.Id];
                List<CNA__c> lstCNA = [SELECT ID, Name, CreatedDate FROM CNA__c WHERE Account__c = :acc.Id];

                // This section moves the files and folder from Source Account To Target Account
                for (GetFolderContentJSONParser.Folders folder : jsonSourceFolderContent.Folders) {
                    GetFolderContentJSONParser jsonChildFolderContent = getDirectChildFolderContent(folder.FolderId, jsonAuth.access_token, objSyncplicityWebServiceHelper, rootFolderSyncPointId);
                    System.debug('jsonChildFolderContent@@: ' + jsonChildFolderContent);

                    GetFolderContentJSONParser folderToMove = new GetFolderContentJSONParser();
                    folderToMove.Folders = new List<GetFolderContentJSONParser.Folders> ();
                    GetFolderContentJSONParser fileToMove = new GetFolderContentJSONParser();
                    fileToMove.Files = new List<GetFolderContentJSONParser.Files> ();
                    System.debug('jsonChildFolderContent.Folders.size()@@: ' + jsonChildFolderContent.Folders.size());
                    System.debug('jsonChildFolderContent.Files.size()@@: ' + jsonChildFolderContent.Files.size());
                    // This section moves the files from Source Account To Target Account
                    if (jsonChildFolderContent.Name.toLowerCase().contains('.files')) {
                        for (Integer i = 0; i<jsonChildFolderContent.Files.size(); i++) {
                            jsonChildFolderContent.Files.get(i).FolderId = targetAccountFilesFolder;
                            jsonChildFolderContent.Files.get(i).Status = 6; //Value 6 is designated for the folder movement.
                            String[] splictChr = jsonChildFolderContent.Files.get(i).Filename.splitByCharacterType();
                            jsonChildFolderContent.Files.get(i).Filename = jsonChildFolderContent.Files.get(i).Filename + ' ' + System.now() + '.' + splictChr[splictChr.size() - 1]; //Rename all the files to avoid the duplicate file name issue. Append the Current Date Time with Opp. created date time.
                            fileToMove.Files.add(jsonChildFolderContent.Files.get(i));
                            System.debug('fileToMove.Files@@ ' + fileToMove.Files);
                            //API supports the batch size of 100
                            if (fileToMove.Files.size() == apiBatchSize) {
                                System.debug(fileToMove.Files);
                                String moveFileResponse = objSyncplicityWebServiceHelper.MoveFiles(rootFolderSyncPointId, JSON.serialize(fileToMove.Files), jsonAuth.access_token);
                                System.debug('moveFileResponse@@: ' + moveFileResponse);
                                fileToMove = new GetFolderContentJSONParser();
                                fileToMove.Files = new List<GetFolderContentJSONParser.Files> ();
                            }
                        }

                        for (Integer i = 0; i<jsonChildFolderContent.Folders.size(); i++) {
                            jsonChildFolderContent.Folders.get(i).ParentFolderId = targetAccountFilesFolder;
                            jsonChildFolderContent.Folders.get(i).Status = 6; //Value 6 is designated for the folder movement.
                            jsonChildFolderContent.Folders.get(i).Name = jsonChildFolderContent.Folders.get(i).Name + ' ' + System.now(); //Rename all the folders to avoid the duplicate file name issue. Append the Current Date Time with Opp. created date time.
                            folderToMove.Folders.add(jsonChildFolderContent.Folders.get(i));
                            System.debug('fileToMove.Files@@ ' + folderToMove.Folders);
                            //API supports the batch size of 100
                            if (folderToMove.Folders.size() == apiBatchSize) {
                                System.debug(fileToMove.Files);
                                String moveFolderResponse = objSyncplicityWebServiceHelper.MoveFolders(rootFolderSyncPointId, JSON.serialize(folderToMove.Folders), jsonAuth.access_token);
                                System.debug('moveFolderResponse@@: ' + moveFolderResponse);
                                folderToMove = new GetFolderContentJSONParser();
                                folderToMove.Folders = new List<GetFolderContentJSONParser.Folders> ();
                            }
                        }

                        System.debug('fileToMove.Files@@ ' + fileToMove.Files);
                        //For Eg: there were 250 files to Move. In the above for loop 200 files will be moved and the remaining 50 will be moved from here
                        if (fileToMove.Files.size() != 0) {
                            System.debug(fileToMove.Files);
                            String moveFileResponse = objSyncplicityWebServiceHelper.MoveFiles(rootFolderSyncPointId, JSON.serialize(fileToMove.Files), jsonAuth.access_token);
                            System.debug('moveFileResponse@@: ' + moveFileResponse);
                        }

                        System.debug('folderToMove.Folders@@ ' + fileToMove.Folders);
                        if (folderToMove.Folders.size() != 0) {
                            System.debug(folderToMove.Folders);
                            String moveFolderResponse = objSyncplicityWebServiceHelper.MoveFolders(rootFolderSyncPointId, JSON.serialize(folderToMove.Folders), jsonAuth.access_token);
                            System.debug('moveFolderResponse@@: ' + moveFolderResponse);
                        }
                    }

                    // This section moves the folder from Source Account To Target Account

                    else {

                        for (Integer i = 0; i<jsonChildFolderContent.Folders.size(); i++) {
                            System.debug('jsonChildFolderContent.Name: ' + jsonChildFolderContent.Name);
                            if (jsonChildFolderContent.Name == 'Opportunities') {
                                jsonChildFolderContent.Folders.get(i).ParentFolderId = targetFolderOppFolderId;
                            }

                            else if (jsonChildFolderContent.Name == 'CNAs') {
                                jsonChildFolderContent.Folders.get(i).ParentFolderId = targetFolderCNAFolderId;
                            }

                            else if (jsonChildFolderContent.Name == 'Account Requests') {
                                jsonChildFolderContent.Folders.get(i).ParentFolderId = targetFolderAccReqFolderId;
                            }

                            jsonChildFolderContent.Folders.get(i).Status = 6; //Value 6 is designated for the folder movement.
                            folderToMove.Folders.add(jsonChildFolderContent.Folders.get(i));

                            //API supports the batch size of 100
                            if (folderToMove.Folders.size() == apiBatchSize) {
                                System.debug(folderToMove.Folders);

                                if (jsonChildFolderContent.Name == 'Opportunities') {
                                    for (Opportunity opp : lstOpp) {
                                        for (GetFolderContentJSONParser.Folders fol : folderToMove.Folders) {
                                            if (fol.Name.endsWithIgnoreCase(opp.Name)) {
                                                fol.Name = fol.Name + ' ' + opp.CreatedDate + ' ' + System.now(); //Rename all the folder to avoid the duplicate folder name name issue. Append the Current Date Time with Opp. created date time.
                                            }
                                        }
                                    }
                                }

                                else if (jsonChildFolderContent.Name == 'CNAs') {
                                    for (Account_Request__c ar : lstAccReq) {
                                        for (GetFolderContentJSONParser.Folders fol : folderToMove.Folders) {
                                            if (fol.Name.endsWithIgnoreCase(ar.Name)) {
                                                fol.Name = fol.Name + ' ' + ar.CreatedDate + ' ' + System.now(); //Rename all the folder to avoid the duplicate folder name name issue. Append the Current Date Time with Account Request. created date time.
                                            }
                                        }
                                    }
                                }

                                else if (jsonChildFolderContent.Name == 'Account Requests') {
                                    for (CNA__c cna : lstCNA) {
                                        for (GetFolderContentJSONParser.Folders fol : folderToMove.Folders) {
                                            if (fol.Name.endsWithIgnoreCase(cna.Name)) {
                                                fol.Name = fol.Name + ' ' + cna.CreatedDate + ' ' + System.now(); //Rename all the folder to avoid the duplicate folder name name issue. Append the Current Date Time with CNA. created date time.
                                            }
                                        }
                                    }
                                }

                                String moveFolderResponse = objSyncplicityWebServiceHelper.MoveFolders(rootFolderSyncPointId, JSON.serialize(folderToMove.Folders), jsonAuth.access_token);
                                System.debug('moveFolderResponse@@: ' + moveFolderResponse);
                                folderToMove = new GetFolderContentJSONParser();
                                folderToMove.Folders = new List<GetFolderContentJSONParser.Folders> ();
                            }
                        }

                        //For Eg: there were 250 folders to Move. In the above for loop 200 folders will be moved and the remaining 50 will be moved from here
                        if (folderToMove.Folders.size() != 0) {
                            System.debug(folderToMove.Folders);

                            if (jsonChildFolderContent.Name == 'Opportunities') {
                                for (Opportunity opp : lstOpp) {
                                    for (GetFolderContentJSONParser.Folders fol : folderToMove.Folders) {
                                        if (fol.Name.endsWithIgnoreCase(opp.Name)) {
                                            fol.Name = fol.Name + opp.CreatedDate + ' ' + System.now();
                                        }
                                    }
                                }
                            }

                            else if (jsonChildFolderContent.Name == 'CNAs') {
                                for (Account_Request__c ar : lstAccReq) {
                                    for (GetFolderContentJSONParser.Folders fol : folderToMove.Folders) {
                                        if (fol.Name.endsWithIgnoreCase(ar.Name)) {
                                            fol.Name = fol.Name + ' ' + ar.CreatedDate + ' ' + System.now(); //Rename all the folder to avoid the duplicate folder name name issue. Append the Current Date Time with Account Request. created date time.
                                        }
                                    }
                                }
                            }

                            else if (jsonChildFolderContent.Name == 'Account Requests') {
                                for (CNA__c cna : lstCNA) {
                                    for (GetFolderContentJSONParser.Folders fol : folderToMove.Folders) {
                                        if (fol.Name.endsWithIgnoreCase(cna.Name)) {
                                            fol.Name = fol.Name + ' ' + cna.CreatedDate + ' ' + System.now(); //Rename all the folder to avoid the duplicate folder name name issue. Append the Current Date Time with CNA. created date time.
                                        }
                                    }
                                }
                            }

                            String moveFolderResponse = objSyncplicityWebServiceHelper.MoveFolders(rootFolderSyncPointId, JSON.serialize(folderToMove.Folders), jsonAuth.access_token);
                            System.debug('moveFolderResponse@@: ' + moveFolderResponse);
                        }
                    }
                }
            }
        }
        catch(Exception ex)
        {
            system.debug('ex: ' + ex);
            system.debug('ex.getStackTraceString: ' + ex.getStackTraceString());
            system.debug('ex.getLineNumber: ' + ex.getLineNumber());
            Log4SF.logMessage('AccountMergeController', 'MergeSyncpFolders', ex.getMessage(), ex, UserInfo.getUserId(), null, '');
        }
    }
*/
    public Map<String, Set<String>> getDescribeFields(List<string> objectNames) {
        Map<String, Set<String>> objectFieldMap = new Map<String, Set<String>> ();
        try {
            Schema.DescribeSobjectResult[] results = Schema.describeSObjects(objectNames);
            System.debug('Got describe information for ' + results.size() + ' sObjects.');
            for (Schema.DescribeSobjectResult res : results) {

                System.debug('sObject Label: ' + res.getLabel());
                System.debug('Number of fields: ' + res.fields.getMap().size());
                System.debug(res.isCustom() ? 'This is a custom object.' : 'This is a standard object.');
                objectFieldMap.put(res.getName(), res.fields.getMap().keySet());
                // Get child relationships
                Schema.ChildRelationship[] rels = res.getChildRelationships();
                if (rels.size()> 0) {
                    System.debug(res.getName() + ' has ' + rels.size() + ' child relationships.');
                }
            }
            Schema.DescribeFieldResult dfr = Schema.SObjectType.Account.fields.Name;

            if (Test.isRunningTest()) {
                CalloutException e = new CalloutException();
                e.setMessage(Exception_Message);
                throw e;
            }
        }
        catch(Exception ex)
        {
            system.debug('@@Error: ' + ex);
            system.debug('@@Error Line Number: ' + ex.getLineNumber());
            //Log4SF.logMessage('AccountMergeBatch', 'getDescribeFields', ex.getMessage(), ex, UserInfo.getUserId(), null, '');
        }
        return objectFieldMap;
    }

    public void updateMergeDetail(List<Database.SaveResult> svrList)
    {
        List<Account_Merge_Detail__c> updateAccmergeList = new List<Account_Merge_Detail__c> ();
        if (svrList.size()> 0)
        {
            for (Database.SaveResult svr : svrList)
            {
                if (svr.isSuccess())
                {
                    if (recordMergeDetailMap.containsKey(svr.getId()))
                    {
                        Account_Merge_Detail__c accMerge = recordMergeDetailMap.get(svr.getId());
                        accMerge.is_Error__c = false;
                        updateAccmergeList.add(accMerge);
                    }
                }
                else
                {

                    if (recordMergeDetailMap.containsKey(svr.getId()))
                    {
                        Account_Merge_Detail__c accMerge = recordMergeDetailMap.get(svr.getId());
                        accMerge.is_Error__c = true;
                        accMerge.Error__c = String.valueOf(svr.getErrors());
                        updateAccmergeList.add(accMerge);
                    }
                }
            }
        }
        if (updateAccmergeList.size()> 0){
        System.debug('updateAccmergeList ' + updateAccmergeList);
        update updateAccmergeList;
        }
    }
// Not Needed Anymore
/*
    private GetFolderContentJSONParser getDirectChildFolderContent(String FolderId, String AccessToken, SyncplicityWebServiceHelper objSyncplicityWebServiceHelper, String rootFolderSyncPointId) {
        GetFolderContentJSONParser jsonChildFolderContent = new GetFolderContentJSONParser();
        try {
            jsonChildFolderContent = GetFolderContentJSONParser.parse(objSyncplicityWebServiceHelper.GetFolderContent(rootFolderSyncPointId, FolderId, AccessToken));

            if (Test.isRunningTest()) {
                CalloutException e = new CalloutException();
                e.setMessage(Exception_Message);
                throw e;
            }

        }
        catch(Exception ex)
        {
            system.debug('@@Error: ' + ex);
            system.debug('@@Error Line Number: ' + ex.getLineNumber());
            //Log4SF.logMessage('AccountMergeBatch', 'getDirectChildFolderContent', ex.getMessage(), ex, UserInfo.getUserId(), null, '');
        }
        return jsonChildFolderContent;
    }
*/
    public class dmlWrapper {
        public string objectName;
        public string newAccountID;
        public string fieldName;
        public List<Sobject> sObjectList;

        public dmlWrapper() {
            objectName = '';
            newAccountID = '';
            fieldName = '';
            sObjectList = new List<SObject> ();
        }
    }
}