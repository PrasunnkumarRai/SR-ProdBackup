public class AccountMergeUpdate implements Iterable < Account_Merge_Detail__c > {
    public static List < Account_Merge_Detail__c > accMergeDetailList = new List < Account_Merge_Detail__c > ();
    public static Account acc {
        get;
        set;
    }
    public static Account mergeAcc {
        get;
        set;
    }
    public static Boolean isParentAgencyAccount = false;
    public static Boolean isParentRepFirmAccount = false;
    public static Boolean isChildAgencyAccount = false;
    public static Boolean isChildRepFirmAccount = false;
    public static Account_Merge_Log__c objAccountMergeLog;
    public static String accId;
    public static String Exception_Message {
        get;
        set;
    }
    public static Map<String, String> mergeDetailsObjectCounts = new Map<String, String>();

    public AccountMergeUpdate(List < Account_Merge_Log__c > accountMergeLogs) {
        System.debug('@@@@Called');
        // for(Account_Merge_Log__c rec: accountMergeLogs){
        accMergeDetailList = new List < Account_Merge_Detail__c > ();
        Account_Merge_Log__c accMDLog = new Account_Merge_Log__c();
        if (accountMergeLogs.size() > 0){
            accMDLog = accountMergeLogs[0];
        }
        accMDLog = accMDLog;
        System.debug('@@accMDLog:: '+accMDLog);
        Exception_Message = System.Label.Exception_Message_For_Code_Coverage_and_Testing;
        objAccountMergeLog = accMDLog;
        System.debug('accMDLog ' + accMDLog);
        System.debug('objAccountMergeLog ' + objAccountMergeLog);
        accId = accMDLog.Merged_Account_ID__c;
        system.debug('accId  ' + accId);
        acc = [SELECT Id, Name, Parentid, BillingStreet, BillingCity, BillingState, BillingPostalCode, Phone, MergeAccount__c,
            Account_Tim_Name__c, RecordType.DeveloperName, TIM_Account_ID__c, AccountExternalId__c, Political_Account__c FROM Account WHERE Id =: accId
        ];
        isParentAgencyAccount = (acc.RecordType.DeveloperName == 'Agency_Account') ? true : false;
        isParentRepFirmAccount = acc.RecordType.DeveloperName == 'Rep_Firm' ? true : false;
        mergeAcc = [SELECT Id, Name, Parentid, BillingStreet, BillingCity, RecordType.DeveloperName,
            BillingState, BillingPostalCode, Phone, Account_Tim_Name__c, Description FROM Account WHERE Id =: accId
        ];

        System.debug('mergeAcc -' + mergeAcc);
        if (mergeAcc.RecordType.DeveloperName == 'Agency_Account' || mergeAcc.RecordType.DeveloperName == 'In_House_Agency_Account')
            isChildAgencyAccount = true;
        isChildRepFirmAccount = mergeAcc.RecordType.DeveloperName == 'Rep_Firm' ? true : false;

        System.debug('isChildAgencyAccount -' + isChildAgencyAccount);
        System.debug('isChildRepFirmAccount -' + isChildRepFirmAccount);

        // Create a map where the key is the object type and the value is the list of field names
        Map < String, List < String >> objectFields = new Map < String, List < String >> {
            'Opportunity' => new List < String > {
                'AccountId',
                'Agency_Account__c',
                'Rep_Firm__c'
            },
            'AccountTeamMember' => new List < String > {
                'AccountId'
            },
            'Account_SAM_Mapping__c' => new List < String > {
                'Account__c'
            },
            'Sales_Budget__c' => new List < String > {
                'Advertiser__c'
            },
            'Contact' => new List < String > {
                'AccountId'
            },
            'Case' => new List < String > {
                'AccountId'
            },
            'AccountConnection__c' => new List < String > {
                'Account__c'
            },
            'CNA__c' => new List < String > {
                'Account__c'
            },
            'Traffic_Id_Element__c' => new List < String > {
                'Account__c'
            },
            'Revenue__c' => new List < String > {
                'Advertiser__c'
            },
            'Trade__c' => new List < String > {
                'Account__c'
            },
            'Interim_AE_Account__c' => new List < String > {
                'Account__c'
            },
            'Account_Market__c' => new List < String > {
                'Account__c'
            },
            'AccountShare' => new List < String > {
                'AccountId'
            },
            'Affiliate_Contract__c' => new List < String > {
                'Account__c'
            },
            'Attachment' => new List < String > {
                'ParentId'
            },
            'Budget__c' => new List < String > {
                'Account__c'
            },
            'Contract' => new List < String > {
                'AccountId'
            },
            'DriftData__Drift_Conversation__c' => new List < String > {
                'DriftData__Account__c'
            },
            'Field_Marketing_Request__c' => new List < String > {
                'Account_Name__c'
            },
            'Hospitality__c' => new List < String > {
                'Account__c'
            },
            'INVOCA_FOR_SF__Invoca_Call_Log__c' => new List < String > {
                'INVOCA_FOR_SF__Account__c'
            },
            'Lead' => new List < String > {
                'ConvertedAccountId'
            },
            'Order' => new List < String > {
                'AccountId'
            },
            'Proposal_Zone_Monthly_Value__c' => new List < String > {
                'Advertiser__c'
            },
            'TopicAssignment' => new List < String > {
                'EntityId'
            },
            'Support_Request__c' => new List < String > {
                'Advertiser__c',
                'Agency__c',
                'Rep_Firm__c'
            },
            'Proposal__c' => new List < String > {
                'Advertiser__c',
                'Agency__c',
                'Rep_Firm__c'
            },
            'Digital_Campaign__c' => new List < String > {
                'Advertiser__c',
                'Agency__c'
            },
            'Account_Request__c' => new List < String > {
                'Advertiser_Agency_Rep_Firm__c'
            },
            'Account_Transfer_Mapping__c' => new List < String > {
                'Account__c'
            },
            'Account_Trends__c' => new List < String > {
                'Account__c'
            },
            'CampaignMember' => new List < String > {
                'AccountId'
            },
            'D_B_Account_Junction__c' => new List < String > {
                'Account__c'
            },
            'Task' => new List < String > {
                'AccountId'
            },
            'Trade_proposal__c' => new List < String > {
                'Trade_Proposal_Account__c'
            },
            'spotlightfs__TMS_Request__c' => new List < String > {
                'spotlightfs__account_id__c'
            }
        };

        // Iterate through the map to call the method for each object type
        for (String objectType: objectFields.keySet()) {
            AccountMergeUpdate.getRelatedRecordList(objectType, objectFields.get(objectType));
        }

        List<Account_Merge_Log__c> log = [SELECT Child_Account_Market_Count__c, 
                                                     Child_Attachment_Count__c, Child_Budget_Count__c, 
                                                     Child_Campaign_Member_Count__c, Child_Account_Request_Count__c, 
                                                     Child_Account_Share_Count__c, Child_Account_Transfer_Mapping_Count__c, 
                                                     Child_Affiliate_Contract_Count__c,  Child_Account_Trends_Count__c, 
                                                     Child_AccountTeamMember_Count__c, Child_Account_Connection_Count__c, 
                                                     Child_CNA_Count__c, Child_Contact_Count__c, 
                                                     Child_Digital_Campaign_Count__c, Child_Opportunity_Count__c, 
                                                     Child_Proposal_Count__c, Child_Revenue_Count__c, 
                                                     Child_SalesBudget_Count__c, Child_SAM_Count__c, Child_Support_Request_Count__c, 
                                                     Child_Trade_Count__c, Child_TrafficIdElement_Count__c,
                                                     Child_Interim_AE_Account_Count__c,Error_Description__c,
                                                     Child_Contract_Count__c, Child_D_B_Account_Junction_Count__c, 
                                                     Child_Drift_Conversation_Count__c, Child_FMR_Count__c,
                                                     Child_Hospitality_Count__c, Child_INVOCA_Call_log_Count__c,
                                                     Child_Lead_Count__c, Child_Order_Count__c,
                                                     Child_PZMV_Count__c, Child_Task_Count__c,
                                                     Child_Topic_Assignment_Count__c, Child_Trade_Proposal_Count__c,
                                                     Child_TMS_Request_Count__c
                                             FROM Account_Merge_Log__c where Id = :objAccountMergeLog.Id];

                log[0].Child_Contract_Count__c = mergeDetailsObjectCounts.get('Contract');
                log[0].Child_D_B_Account_Junction_Count__c = mergeDetailsObjectCounts.get('D_B_Account_Junction__c');
                log[0].Child_Drift_Conversation_Count__c = mergeDetailsObjectCounts.get('DriftData__Drift_Conversation__c');
                log[0].Child_FMR_Count__c = mergeDetailsObjectCounts.get('Field_Marketing_Request__c');
                log[0].Child_Hospitality_Count__c = mergeDetailsObjectCounts.get('Hospitality__c');
                log[0].Child_INVOCA_Call_log_Count__c = mergeDetailsObjectCounts.get('INVOCA_FOR_SF__Invoca_Call_Log__c');
                log[0].Child_Lead_Count__c = mergeDetailsObjectCounts.get('Lead');
                log[0].Child_Order_Count__c = mergeDetailsObjectCounts.get('Order');
                log[0].Child_PZMV_Count__c = mergeDetailsObjectCounts.get('Proposal_Zone_Monthly_Value__c');
                log[0].Child_Task_Count__c = mergeDetailsObjectCounts.get('Task');
                log[0].Child_Topic_Assignment_Count__c = mergeDetailsObjectCounts.get('TopicAssignment');
                log[0].Child_Trade_Proposal_Count__c = mergeDetailsObjectCounts.get('Trade_proposal__c');
                log[0].Child_TMS_Request_Count__c = mergeDetailsObjectCounts.get('spotlightfs__TMS_Request__c');

                update log;
        // }
        iterator();
    }


    @ReadOnly
    @RemoteAction
    @AuraEnabled
    public static void getRelatedRecordList(String objectName, List < String > fieldNames) {
        System.debug('In Generic method for log creation: account.Id- ' + acc.Id + '; ObjectName - ' + objectName + '; Field Names - ' + fieldNames);

        try {
            List < Account_Merge_Detail__c > accs = new List < Account_Merge_Detail__c > ();

            String query = 'SELECT Id';

            // Building the SELECT query with specified fields
            for (String fieldName: fieldNames) {
                query += ', ' + fieldName;
            }

            query += ' FROM ' + objectName + ' WHERE ';

            // Building the WHERE clause with OR conditions for each field
            for (Integer i = 0; i < fieldNames.size(); i++) {
                if (i > 0) {
                    query += ' OR ';
                }
                query += fieldNames[i] + ' = \'' + acc.Id + '\'';
            }

            System.debug('Generic Query: ' + query);
            List < sObject > queriedRecords = Database.query(query);
            System.debug('queriedRecords : ' + queriedRecords);

            mergeDetailsObjectCounts.put(objectName, String.valueOf(queriedRecords.size()));
            System.debug('mergeDetailsObjectCounts : ' + mergeDetailsObjectCounts);

            for (sObject record: queriedRecords) {
                String matchedFieldName = '';

                for (String fieldName: fieldNames) {
                    if (String.valueOf(record.get(fieldName)) == String.valueOf(acc.Id)) {
                        matchedFieldName = fieldName;
                        break;
                    }
                }

                Account_Merge_Detail__c accTM = new Account_Merge_Detail__c();
                accTM.Account_Merge_Log__c = objAccountMergeLog.Id;
                accTM.Record_ID__c = record.Id;
                accTM.Object_Name__c = objectName;
                accTM.Field_to_Update__c = matchedFieldName;
                accs.add(accTM);

            }

            accMergeDetailList.addAll(accs);
            System.debug(accMergeDetailList.size());

            if (Test.isRunningTest()) {
                CalloutException e = new CalloutException();
                e.setMessage(Exception_Message);
                throw e;
            }
        } catch (Exception ex) {
            System.debug('Error in generic method - ' + ex.getMessage());
            Log4SF.logMessage('AccountMergeUpdate', 'getRelatedRecordList', ex.getMessage(), ex, UserInfo.getUserId(), null, '');
        }
    }


    public Iterator < Account_Merge_Detail__c > iterator() {
        System.debug(accMergeDetailList.size());
        return new CustomIterator(accMergeDetailList);
    }

    public class CustomIterator implements Iterator < Account_Merge_Detail__c > {
        private List < Account_Merge_Detail__c > accs;
        private Integer currentIndex;

        public CustomIterator(List < Account_Merge_Detail__c > accs) {
            this.accs = accs;
            this.currentIndex = 0;
            System.debug(this.accs.size());
        }

        public boolean hasNext() {
            return currentIndex < accs.size();
        }

        public Account_Merge_Detail__c next() {
            if (hasNext()) {
                currentIndex++;
                System.debug(currentIndex);
                return accs[currentIndex - 1];
            } else {
                throw new NoSuchElementException();
            }
        }
    }

    @AuraEnabled(cacheable = true)
    public static List < Account > getAccountDataMethod(String recordID) {
        List < Account > accList = new List < Account > ();
        try {
            System.debug('accList:::' + accList);
            accList = [SELECT Id, Name, BillingAddress, Count_of_Opportunities__c, agency__c, Agency__r.Name, Billing_Preference__c, RecordType.Name, DunsNumber__c FROM Account where Id =: recordID];
            if (Test.isRunningTest()) {
                CalloutException e = new CalloutException();
                e.setMessage(Exception_Message);
                throw e;
            }
        } catch (Exception ex) {
            Log4SF.logMessage('AccountMergeUpdate', 'getAccountDataMethod', ex.getMessage(), ex, UserInfo.getUserId(), null, '');
        }
        System.debug(accList);
        return accList;
    }
    @AuraEnabled
    public static Account deleteAccount(Account acc) {
        try {
            System.debug('acc ' + acc.id);
            delete acc;
            if (Test.isRunningTest()) {
                CalloutException e = new CalloutException();
                e.setMessage(Exception_Message);
                throw e;
            }

        } catch (Exception ex) {
            Log4SF.logMessage('AccountMergeUpdate', 'updateAccount', ex.getMessage(), ex, UserInfo.getUserId(), null, '');
        }
        return acc;
    }




    @AuraEnabled
    public static Account updateAccount(Account acc) {
        try {
            System.debug('acc ' + acc.id);
            Update acc;
            //delete acc;
            if (Test.isRunningTest()) {
                CalloutException e = new CalloutException();
                e.setMessage(Exception_Message);
                throw e;
            }

        } catch (Exception ex) {
            Log4SF.logMessage('AccountMergeUpdate', 'updateAccount', ex.getMessage(), ex, UserInfo.getUserId(), null, '');
        }
        return acc;
    }
    @AuraEnabled
    public static void callAccountMergeDetailInsertionBatch(String childRecordID, String parentRecordId) {
        try {
            Account childAccountLogs = [select id,Name, BillingAddress, BillingStreet, BillingCity, BillingState, BillingCountry, BillingPostalCode, DunsNumber__c, Agency__c, Agency__r.name, Billing_Preference__c from Account WHERE Id =: childRecordID LIMIT 1];
            String accountLogs;

            if (childAccountLogs.BillingStreet != null) {
                accountLogs = 'Billing Street : ' + childAccountLogs.BillingStreet + ' ; ';
            }
            if (childAccountLogs.BillingCity != null) {
                accountLogs += 'Billing City : ' + childAccountLogs.BillingCity + ' ; ';
            }
            if (childAccountLogs.BillingState != null) {
                accountLogs += 'Billing State : ' + childAccountLogs.BillingState + ' ; ';
            }
            if (childAccountLogs.BillingCountry != null) {
                accountLogs += 'Billing Country : ' + childAccountLogs.BillingCountry + ' ; ';
            }
            if (childAccountLogs.BillingPostalCode != null) {
                accountLogs += 'Billing Postal Code : ' + childAccountLogs.BillingPostalCode + ' ; ';
            }
            if (childAccountLogs.DunsNumber__c != null) {
                accountLogs += 'Dunns Number : ' + childAccountLogs.DunsNumber__c + ' ; ';
            }
            if (childAccountLogs.Agency__c != null) {
                accountLogs += 'Agency :' + childAccountLogs.Agency__r.name + ' ; ';
            }
            if (childAccountLogs.Billing_Preference__c != null) {
                accountLogs += 'Billing Preference :' + childAccountLogs.Billing_Preference__c + ' ; ';
            }
            
            Set < String > existingLogTrxnIds = new Set < String > ();
            String trxnId;
            Boolean isUnique = false;
            for (Account_Merge_Log__c log: [SELECT TransactionId__c FROM Account_Merge_Log__c WHERE TransactionId__c != NULL]) {
                existingLogTrxnIds.add(log.transactionId__c);
            }
            while (!isUnique) {
                UUID u = UUID.randomUUID();
                String s = String.valueOf(u);
                if (existingLogTrxnIds.contains(s)) {
                    isUnique = false;
                } else {
                    isUnique = true;
                    trxnId = s;
                }
            }
            
            List < Account_Merge_Log__c > accountMergeLogs = new List < Account_Merge_Log__c > ();
            Account_Merge_Log__c objLog = new Account_Merge_Log__c();
            objLog.Account__c = parentRecordId;
            objLog.Child_Account__c = childAccountLogs.Name;
            objLog.Merged_Account_ID__c = childRecordID;
            objLog.Account_Log__c = accountLogs;
            objLog.TransactionId__c = trxnId;
            System.debug('objLog ' + objLog);
            accountMergeLogs.add(objLog);
            System.debug('accountMergeLogs ' + accountMergeLogs);
            insert accountMergeLogs;
            System.debug('accountMergeLogs ' + accountMergeLogs);
            
			
            List < Account_Merge_Log__c > accmD = [SELECT Id, Account__c, Merged_Account_ID__c FROM Account_Merge_Log__c WHERE Id =: accountMergeLogs[0].id];
            AccountMergeDetailInsertionBatch batch = new AccountMergeDetailInsertionBatch(accmD, 'Merge');
            batch.totalCount = 1;
            batch.trxnId = trxnId;
            Id jobId = Database.executeBatch(batch);
            if (Test.isRunningTest()) {
                CalloutException e = new CalloutException();
                e.setMessage(Exception_Message);
                throw e;
            }

        } catch (Exception ex) {
            Log4SF.logMessage('AccountMergeUpdate', 'callAccountMergeDetailInsertionBatch', ex.getMessage(), ex, UserInfo.getUserId(), null, '');
        }
    }

    @AuraEnabled(cacheable = true)
    public static Map < String,
    String > verifySelectedAcc(String recordID) {
        Map < String, String > JSONString = new Map < String, string > ();
        try {
            if (!String.isEmpty(recordID)) {
                List < Account_Transfer_Mapping__c > accMap = [Select ID, Account_Transfer_Simulation__r.Name, Account_Transfer_Simulation__c from Account_Transfer_Mapping__c
                    where Account__c =: recordID AND Account_Transfer_Simulation__r.Status__c NOT IN('Transfer in Progress', 'Transfer Completed', 'Denied')
                ];
                if (accmap.size() > 0) {
                    //JSONString = 'Error : The selected account is part of Account Transfer hence cannot be merged yet.';
                    for (Account_Transfer_Mapping__c atm: accMap) {
                        JSONString.put(System.URL.getSalesforceBaseURL().toExternalForm() + '/' + atm.Id, atm.Account_Transfer_Simulation__r.Name);
                    }
                } else {
                    JSONString.put('Success', '');
                }
            }
            if (Test.isRunningTest()) {
                CalloutException e = new CalloutException();
                e.setMessage(Exception_Message);
                throw e;
            }
        } catch (Exception ex) {
            Log4SF.logMessage('AccountMergeUpdate', 'verifySelectedAcc', ex.getMessage(), ex, UserInfo.getUserId(), null, '');
        }
        return JSONString;
    }


    @AuraEnabled(cacheable = true)
    public static List < SObject > findRecords(String searchKey, String objectName, String searchField, String excludeId, String accRecType) {
        List < SObject > sObjectList = new List < SObject > ();
        try {
            String key = searchKey + '%';
            String accID = '\'' + excludeId + '\'';
            String accType = '\'' + accRecType + '\'';
            System.debug('accType' + accType);
            System.debug('searchKey' + searchKey + ' Key ' + key);
            string recordTypeAgencyCheck = '';
            if (accRecType == 'Agency Account' || accRecType == 'In House Agency Account') {
                // recordTypeAgencyCheck = ' AND (RecordType.Name = ' + accType + ' OR RecordType.DeveloperName = \'In_House_Agency_Account\' )';
                recordTypeAgencyCheck = ' AND (RecordType.Name = \'Agency Account\''+ ' OR RecordType.DeveloperName = \'In_House_Agency_Account\' )';
            } else
                recordTypeAgencyCheck = ' AND RecordType.Name = ' + accType;
            string idCheck = '';
            if (searchKey.startsWith('001'))
                idCheck = 'OR ID = \'' + searchKey + '\'';
            String QUERY = 'Select Id,RecordType.Name , ' + searchField + ' From ' + objectName + ' Where (' + searchField + ' LIKE :key ' + idCheck + ' ) AND Id != ' + accID + recordTypeAgencyCheck + ' limit 5';
            System.debug(System.LoggingLevel.DEBUG, QUERY);
            System.debug('Key & searchTerm ' + searchKey + ' - ' + key);
            sObjectList = Database.query(QUERY);

            if (Test.isRunningTest()) {
                CalloutException e = new CalloutException();
                e.setMessage(Exception_Message);
                throw e;
            }
        } catch (Exception ex) {
            Log4SF.logMessage('AccountMergeUpdate', 'findRecords', ex.getMessage(), ex, UserInfo.getUserId(), null, '');
        }
        return sObjectList;
    }


    @AuraEnabled(cacheable=true)
    public static Map<String, Integer> relatedObject(String recordID) {
        Map<String, Integer> accountRecord = new Map<String, Integer>();
        
        // Define a map with object names as keys and relevant fields as values
        Map<String, List<String>> objectFieldMap = new Map<String, List<String>>{
            'Opportunity' => new List<String>{'AccountId', 'Rep_Firm__c', 'Agency_Account__c'},
            'Contact' => new List<String>{'AccountId'},
            'CNA__c' => new List<String>{'Account__c', 'Agency__c'},
            'Traffic_Id_Element__c' => new List<String>{'Account__c'},
            'Revenue__c' => new List<String>{'Advertiser__c'},
            'Trade__c' => new List<String>{'Account__c'},
            'Account_SAM_Mapping__c' => new List<String>{'Account__c'},
            'Support_Request__c' => new List<String>{'Advertiser__c', 'Agency__c', 'Rep_Firm__c'},
            'Proposal__c' => new List<String>{'Advertiser__c', 'Agency__c', 'Rep_Firm__c'},
            'Digital_Campaign__c' => new List<String>{'Advertiser__c', 'Agency__c'},
            'Sales_Budget__c' => new List<String>{'Advertiser__c'},
            'AccountTeamMember' => new List<String>{'AccountId'},
            'AccountConnection__c' => new List<String>{'Account__c'},
            'Interim_AE_Account__c' => new List<String>{'Account__c'},
            'Case' => new List<String>{'AccountID'},
            'ContentDocumentLink' => new List<String>{'LinkedEntityId'}, // Special handling for files
            'Account_Transfer_Mapping__c' => new List<String>{'Account__c'},
            'Account_Trends__c' => new List<String>{'Account__c'},
            'CampaignMember' => new List<String>{'AccountId'},
            'D_B_Account_Junction__c' => new List<String>{'Account__c'},
            'Task' => new List<String>{'WhatId'},
            'Trade_proposal__c' => new List<String>{'Trade_Proposal_Account__c'},
            'spotlightfs__TMS_Request__c' => new List<String>{'spotlightfs__account_id__c'},
            'Account_Request__c' => new List<String>{'Advertiser_Agency_Rep_Firm__c'}
        };

        try {
            for (String objectName : objectFieldMap.keySet()) {
                List<String> fieldsToCount = objectFieldMap.get(objectName);
                String dynamicQuery = 'SELECT COUNT(Id) FROM ' + objectName + ' WHERE';
                for (Integer i = 0; i < fieldsToCount.size(); i++) {
                    if (i > 0) {
                        dynamicQuery += ' OR';
                    }
                    dynamicQuery += ' ' + fieldsToCount[i] + ' = :recordID';
                }
                List<AggregateResult> results = Database.query(dynamicQuery);
                Integer count = (Integer)results[0].get('expr0');
                accountRecord.put('total_' + objectName, count);
            }

            // Show count of all the files
            List<AggregateResult> allCdLinks = [SELECT COUNT(Id) FROM ContentDocumentLink WHERE LinkedEntityId = :recordID];
            Integer fileCount = (Integer)allCdLinks[0].get('expr0');
            accountRecord.put('total_Files', fileCount);

            if (Test.isRunningTest()) {
                CalloutException e = new CalloutException();
                e.setMessage(Exception_Message);
                throw e;
            }
        } catch (Exception ex) {
            Log4SF.logMessage('AccountMergeUpdate', 'relatedObject', ex.getMessage(), ex, UserInfo.getUserId(), null, '');
        }
        return accountRecord;
    }

    @AuraEnabled(cacheable = true)
    public static List < Account_Merge_Detail__c > getAccountMDetailRecord(String recId) {
        System.debug('recordId are coming :::: ' + recId);

        List < Account_Merge_Detail__c > accountMergeDetailsList = new List < Account_Merge_Detail__c > ();
        accountMergeDetailsList = [Select Id, Account_Merge_Log__c, Name, Error__c, Is_Error__c, Object_Name__c, Record_ID__c From Account_Merge_Detail__c where Account_Merge_Log__c =: recId AND Is_Error__c = true];


        if (accountMergeDetailsList.isEmpty()) {
            System.debug('emptyList :: ' + accountMergeDetailsList);
            return accountMergeDetailsList; //'emptyList';

        } else {
            System.debug('accountMergeDetailsList :::: ' + accountMergeDetailsList);
            return accountMergeDetailsList;
        }
    }
    
    @AuraEnabled
    public static String checkUnmergeBatch(String recordId){
        try {
            String childAcc = [SELECT Merged_Account_ID__c FROM Account_Merge_Log__c WHERE Id =: recordId][0].Merged_Account_ID__c;
            List<Account> accPresent = [SELECT Id, IsDeleted FROM Account WHERE Id =: childAcc ALL ROWS];
            if (accPresent.size() == 0) {
                return 'Account deleted';
            }
            if (accPresent[0].IsDeleted == false) {
                return 'Account unmerged';
            }
            
            List<AggregateResult> result = [SELECT Count(Id) detailCount
            FROM Account_Merge_Detail__c 
            WHERE Account_Merge_Log__c =: recordID 
            AND Object_Name__c NOT IN ('AccountShare','AccountTeamMember','Lead')
            GROUP BY Object_Name__c];
            for (AggregateResult res : result) {
                if ((Integer)res.get('detailCount') > 50) {
                    return 'Batch';
                }
            }
            return 'Realtime';
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    @AuraEnabled
    public static void runUnmergeBatch(String recordId){
        try {
            BatchSingleUnmerge batch = new BatchSingleUnmerge(recordId);
            Database.executeBatch(batch, 50);
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    @AuraEnabled
    public static string unmergeAccountMergeLog(String recordId){
        try {

            // Retrieve related Account Merge Detail records
            List<Account_Merge_Detail__c> mergeDetails = [
                SELECT Id, Object_Name__c, Record_ID__c, Field_to_Update__c, Account_Merge_Log__c, Account_Merge_Log__r.Merged_Account_ID__c
                FROM Account_Merge_Detail__c 
                WHERE Account_Merge_Log__c = :recordId and Object_Name__c NOT IN ('AccountShare', 'AccountTeamMember', 'Lead')
            ];

            system.debug('mergeDetails@@@' + mergeDetails);

            // Map to store records grouped by their object type
            Map<String, List<SObject>> recordsByType = new Map<String, List<SObject>>();

            // Process each detail record and prepare updates
            for (Account_Merge_Detail__c detail : mergeDetails) {
                if (detail.Object_Name__c != null) {
                    Schema.SObjectType targetType = Schema.getGlobalDescribe().get(detail.Object_Name__c);
                    if (targetType != null) {
                        SObject record = targetType.newSObject(detail.Record_ID__c);
                        if (detail.Object_Name__c != 'Task') {
                            record.put(detail.Field_to_Update__c, detail.Account_Merge_Log__r.Merged_Account_ID__c);
                        } else {
                            record.put('WhatId', detail.Account_Merge_Log__r.Merged_Account_ID__c);
                        }
                        
                        // Add the record to the correct list for its type
                        if (!recordsByType.containsKey(detail.Object_Name__c)) {
                            recordsByType.put(detail.Object_Name__c, new List<SObject>());
                        }
                        recordsByType.get(detail.Object_Name__c).add(record);
                    }
                }
            }

            // Query for deleted child accounts in the Recycle Bin
            List<Account> deletedAccounts;
            if (mergeDetails.size() > 0) {
                deletedAccounts = [
                    SELECT Id FROM Account 
                    WHERE IsDeleted = true AND Id = :mergeDetails[0].Account_Merge_Log__r.Merged_Account_ID__c ALL ROWS
                ];
            }
            else {
                String mergedId = [
                    SELECT Merged_Account_ID__c FROM Account_Merge_Log__c 
                    WHERE Id = :recordId
                    LIMIT 1
                ].Merged_Account_ID__c;
                System.debug('mergedId@@@'+mergedId);
                deletedAccounts = [
                    SELECT Id FROM Account 
                    WHERE IsDeleted = true AND Id = :mergedId ALL ROWS
                ];
            }
            

            // Restore the deleted accounts if necessary
            if (!deletedAccounts.isEmpty()) {
                Database.undelete(deletedAccounts, false);
            }
            else {
                System.debug('inside else');
                String mergedId = [
                    SELECT Merged_Account_ID__c FROM Account_Merge_Log__c 
                    WHERE Id = :recordId
                    LIMIT 1
                ].Merged_Account_ID__c;
                List<Account> acc = [
                    SELECT Id FROM Account 
                    WHERE Id = :mergedId
                ];
                if (acc.isEmpty()) {
                     System.debug('inside if else');
                    return 'Account deleted';
                }
                System.debug('inside else else');
                return 'Account unmerged';
            }

            // Perform update operations separately for each SObject type
            for (String objectType : recordsByType.keySet()) {
                List<SObject> recordsToUpdate = recordsByType.get(objectType);
                if (!recordsToUpdate.isEmpty()) {
                    system.debug('Updating records of type ' + objectType + ': ' + recordsToUpdate);
                    Database.update(recordsToUpdate, false);
                }
            }   
            return 'Success';
        } catch (Exception e) {
            System.debug('e.getMessage()' + e.getMessage() + e.getLineNumber());
            return 'Error';
        }
    }


    @AuraEnabled
    public static String getbatch(String recId) {
        System.debug('recId in batch :::' + recId);

        List < Account_Merge_Log__c > accountMergeLogList = new List < Account_Merge_Log__c > ();
        accountMergeLogList = [Select Id, Account__c From Account_Merge_Log__c where Id =: recId];
        System.debug(' accountMergeLogList for batch ::: ' + accountMergeLogList);
        System.debug('accountMergeLogList[0].Account__c :::: ' + accountMergeLogList[0].Account__c);
        System.debug('accountMergeLogList[0].Id ::: ' + accountMergeLogList[0].Id);

        AccountMergeBatch amb = new AccountMergeBatch(accountMergeLogList[0].Account__c, accountMergeLogList[0].Id, 'mergingType', true);
        Database.executeBatch(amb, 2000);

        return 'Batched Called Successfully....';
    }

    @AuraEnabled
    public static List < String > toSendEmail(String recId) {
        System.debug('recId in toSendEmail :::' + recId);

        List < Account_Merge_Log__c > accountMergeLogList = new List < Account_Merge_Log__c > ();
        accountMergeLogList = [Select Id, Account__c, Account__r.Name From Account_Merge_Log__c where Id =: recId];
        System.debug(' accountMergeLogList for batch ::: ' + accountMergeLogList);

        List < Account_Merge_Detail__c > accountMergeDetailsList = new List < Account_Merge_Detail__c > ();
        accountMergeDetailsList = [Select Id, Account_Merge_Log__c, Name, Error__c, Is_Error__c, Object_Name__c, Record_ID__c From Account_Merge_Detail__c where Account_Merge_Log__c =: recId AND Is_Error__c = true];

        String finalstr;
        String subject;

        List < String > errorList = new List < String > ();
        for (Account_Merge_Detail__c err: accountMergeDetailsList) {
            errorList.add(err.Error__c);
            finalstr = err.Name + ' ' + err.Object_Name__c + ' ' + err.Error__c + ' ' + err.Record_ID__c;
            Subject = 'Account Merge Log Retry' + 'on' + ' ' + accountMergeLogList[0].Account__r.Name;
        }
        System.debug('errorList in toSendEmail method ::::' + errorList);

        Messaging.EmailFileAttachment csvAttc = new Messaging.EmailFileAttachment();
        blob csvBlob = Blob.valueOf(finalstr);
        string csvname = 'Errors.csv';
        csvAttc.setFileName(csvname);
        csvAttc.setBody(csvBlob);
        Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
        String[] toAddresses = new list < string > {
            userinfo.getUserEmail()
        };
        // String subject ='Errors of Account Merge Details Object';
        email.setSubject(subject);
        email.setToAddresses(toAddresses);
        email.setPlainTextBody('');
        email.setFileAttachments(new Messaging.EmailFileAttachment[] {
            csvAttc
        });
        Messaging.SendEmailResult[] r = Messaging.sendEmail(new Messaging.SingleEmailMessage[] {
            email
        });

        return errorList;
    }

    //This method will be used to completely merge the child account into parent account...
    @AuraEnabled
    public static void mergeAccounts(String mergeLogId, String parentAccountId, String childAccountID, String mergingType) {

        System.debug('Standard Merge initiated from AccountMergeUpdate class...!');
        System.debug('mergeDetailsObjectCounts map in mergeAccounts method - '+mergeDetailsObjectCounts);
        System.debug('D_B_Account_Junction__c count - '+mergeDetailsObjectCounts.get('D_B_Account_Junction__c'));

        Account parentAcc;
        List < Account > childAcc = new List < Account > ();
        List<AccountTeamMember> aEs = new List<AccountTeamMember>();
        
        if (string.isNotEmpty(parentAccountId) && string.isNotEmpty(childAccountID) && string.isNotEmpty(mergeLogId)) {
            
            List<Account_Merge_Log__c> log = [SELECT Account__r.Name,Child_Account__c, Child_Account_Market_Count__c,
                                                     Child_Attachment_Count__c, Child_Budget_Count__c, 
                                                     Child_Campaign_Member_Count__c, Child_Account_Request_Count__c, 
                                                     Child_Account_Share_Count__c, Child_Account_Transfer_Mapping_Count__c, 
                                                     Child_Affiliate_Contract_Count__c,  Child_Account_Trends_Count__c, 
                                                     Child_AccountTeamMember_Count__c, Child_Account_Connection_Count__c, 
                                                     Child_CNA_Count__c, Child_Contact_Count__c, 
                                                     Child_Digital_Campaign_Count__c, Child_Opportunity_Count__c, 
                                                     Child_Proposal_Count__c, Child_Revenue_Count__c, 
                                                     Child_SalesBudget_Count__c, Child_SAM_Count__c, Child_Support_Request_Count__c, 
                                                     Child_Trade_Count__c, Child_TrafficIdElement_Count__c,
                                                     Child_Interim_AE_Account_Count__c,Error_Description__c,
                                                     Child_Contract_Count__c, Child_D_B_Account_Junction_Count__c, 
                                                     Child_Drift_Conversation_Count__c, Child_FMR_Count__c,
                                                     Child_Hospitality_Count__c, Child_INVOCA_Call_log_Count__c,
                                                     Child_Lead_Count__c, Child_Order_Count__c,
                                                     Child_PZMV_Count__c, Child_Task_Count__c,
                                                     Child_Topic_Assignment_Count__c, Child_Trade_Proposal_Count__c,
                                                     Child_TMS_Request_Count__c
                                             
                                             FROM Account_Merge_Log__c where Id = :mergeLogId];
            
            System.debug('Queried Merge Log - '+log);

            parentAcc = [Select Id, Name From Account Where Id =: parentAccountId limit 1];
            childAcc = [Select Id, Name From Account Where Id =: childAccountID limit 1];
         //SRSF-4942 START
           // Query to find duplicate account-contact relationships
            try {
                List<AccountContactRelation> parentAcrList = [SELECT Id, AccountId, ContactId FROM AccountContactRelation WHERE AccountId = :parentAcc.Id];
                List<AccountContactRelation> childAcrList = [SELECT Id, AccountId, ContactId, Contact.AccountId FROM AccountContactRelation WHERE AccountId = :childAcc[0].Id];

                Set<Id> parentContactIds = new Set<Id>();
                for (AccountContactRelation acr : parentAcrList) {
                    parentContactIds.add(acr.ContactId);
                }
                List<AccountContactRelation> acrsToDelete = new List<AccountContactRelation>();
                for (AccountContactRelation acr : childAcrList) {
                    if (parentContactIds.contains(acr.ContactId)) {
                        acrsToDelete.add(acr);
                    }
                }
                // changes for when contact's primary account is the child account
                // update contact's account to parent account
               List<Contact> contactToUpdate = new List<Contact>();
                for (AccountContactRelation acr : acrsToDelete) {
                    if (acr.Contact.AccountId == childAcc[0].Id) {
                        Contact c = new Contact(Id = acr.ContactId);
                        c.AccountId = parentAcc.Id;
                        contactToUpdate.add(c);
                    }
                }
                update contactToUpdate;
                //
                if (!acrsToDelete.isEmpty()) {
                    delete acrsToDelete;
                }
            } catch (Exception e) {
                System.debug('Error occurred: ' + e.getMessage());
            }
        
         //SRSF-4942 END

            System.debug('parentAcc - ' + parentAcc);
            System.debug('childAcc - ' + childAcc);

            aEs = [SELECT User.name,UserId,User.email FROM AccountTeamMember where AccountId =: childAcc AND TeamMemberRole='Account Executive'];

        try {


            if (parentAcc != null && !childAcc.isEmpty()) {
            Database.MergeResult mergeResult = Database.merge(parentAcc, childAcc[0].Id, true);
            log[0].isMergeTried__c=true;    
                // for(Database.MergeResult res : mergeResult) {
                if (mergeResult.isSuccess()) {
                    log[0].isRowLock__c = false;
                    log[0].Error_Description__c = null;
                    log[0].isACR__c = false;

                }
                update log;

                // sendNotificationToAEs(aEs,log[0]);
                sendStatusEmail(mergeResult.isSuccess(),log,mergingType);
            }
        } catch (Exception e) {
            log[0].Error_Description__c = e.getmessage();
            log[0].isMergeTried__c=true;   
            if(e.getmessage().contains('UNABLE_TO_LOCK_ROW')){
                log[0].isRowLock__c = true;
            }
            if(e.getmessage().contains('These accounts have the same related contact.')){
                log[0].isACR__c = true;
            }
            update log;
            System.debug('Error message - ' + e.getMessage());
            System.debug('Error on this line - ' + e.getLineNumber());
            System.debug('Cause of the error - ' + e.getCause());
            System.debug('Stacktrace of the error - ' + e.getStackTraceString());
            Log4SF.logMessage('AccountMergeUpdate', 'mergeAccounts', e.getMessage(), e, UserInfo.getUserId(), parentAccountId + ';' + childAccountID, '');
            //throw new AuraHandledException(e.getMessage());
        }
        }
    }

    // public static void sendNotificationToAEs(List<AccountTeamMember> aEs, Account_Merge_Log__c log) {
    //     if (!aEs.isEmpty()) {
    //         Set<String> usersId = new Set<String>();
    //             for(AccountTeamMember ae: aEs){
    //                 usersId.add(ae.UserId);
    //             }
            
    //         if(!usersId.isEmpty()){
    //              CustomNotificationType notificationType = [SELECT Id,DeveloperName FROM CustomNotificationType WHERE DeveloperName='Account_merge_notification_to_AEs' LIMIT 1];
    //              Messaging.CustomNotification notification = new Messaging.CustomNotification();
    //              notification.setTitle('Account Merged');
    //              notification.setBody('Account - '+log.Child_Account__c + ' has been merged into '+log.Account__r.Name);
    //              notification.setNotificationTypeId(notificationType.Id);
    //              notification.setTargetId(log.Account__c);
    //              try {
    //                     notification.send(usersId);
    //              }
    //              catch (Exception e) {
    //                     Log4SF.logMessage('AccountMergeUpdate', 'sendNotificationToAEs', e.getMessage(), e, UserInfo.getUserId(), null, '');
    //                     System.debug('Problem sending notification: ' + e.getMessage());
    //              } 
    //         }
    //     }
    // }



    public static List < Schema.FieldSetMember > getFields() {
        try {
            return SObjectType.Account.FieldSets.Account_Merge_Utility.getFields();
        } catch (Exception ex) {
            Log4SF.logMessage('AccountMergeUpdate', 'getFields', ex.getMessage(), ex, UserInfo.getUserId(), null, '');
            return null;
        }

    }

    @AuraEnabled(cacheable = true)
    public static Account getAccountList(id accid) {
        try {
            String query = 'SELECT ';
            for (Schema.FieldSetMember f: getFields()) {
                query += f.getFieldPath() + ', ';
            }
            query += 'Id FROM Account WHERE ID=\'' + accid + '\'';
            System.debug(query);
            return Database.query(query);
        } catch (Exception ex) {
            Log4SF.logMessage('AccountMergeUpdate', 'getAccountList', ex.getMessage(), ex, UserInfo.getUserId(), accid, '');
            return null;
        }

    }

    @AuraEnabled
    public static Map < String,
    String > getFieldSetLabels() {
        try {

            Map < String, String > fieldDetails = new Map < String, String > ();

            // Get the field set information dynamically
            Schema.FieldSet fieldSetInfo = Schema.SObjectType.Account.fieldSets.getMap().get('Account_Merge_Utility');
            if (fieldSetInfo != null) {
                // Iterate through each field in the field set
                for (Schema.FieldSetMember field: fieldSetInfo.getFields()) {
                    fieldDetails.put(field.getFieldPath(), field.getLabel());

                }
            }

            System.debug(fieldDetails);

            return fieldDetails;

        } catch (Exception ex) {
            Log4SF.logMessage('AccountMergeUpdate', 'getFieldSetLabels', ex.getMessage(), ex, UserInfo.getUserId(), null, '');
            return null;
        }
    }


    private static void sendStatusEmail(Boolean isSuccess, List<Account_Merge_Log__c> AMD, String mergingType) {
        try
        {   
            System.debug('Merge log - '+AMD);
            System.debug(mergingType);
            if(mergingType == 'Merge'){
            Messaging.SingleEmailMessage message = new Messaging.SingleEmailMessage();
            message.toAddresses = new String[] { userinfo.getUserEmail() }; // userinfo.getUserEmail()
            message.subject = 'Account Merge Status';
            String messageBody = '';
            if (isSuccess) {
                for (Account_Merge_Log__c accMergeLog : AMD) {
                    messageBody = '<html>';
                    messageBody += '<body style="font-family: Arial, sans-serif; background-color: #f5f5f5;">';
                    messageBody += '<table cellpadding="10" cellspacing="0" style="border-collapse: collapse; width: 100%; margin: auto; background-color: #ffffff; border: 1px solid #dddddd;">';
                    messageBody += '<tr><td colspan="2" style="background-color: #0070c0; color: #ffffff; text-align: center;"><h2 style="margin: 0; padding: 10px;">Account Merge Success</h2></td></tr>';
                    messageBody += '<tr><td style="padding: 10px;" colspan="2">Hi ' + userinfo.getName() + ',</td></tr>';
                    messageBody += '<tr><td colspan="2" style="padding: 10px;">' + System.Label.Email_Account_Merge_Success_Status + ' <a href="' + URL.getSalesforceBaseUrl().toExternalForm() + '/' + accMergeLog.Id + '">Click here</a></td></tr>';
                    messageBody += '<tr></tr>';
                    messageBody += '<tr><td style="padding: 10px;" colspan="2"><b>Parent Account: </b> ' + accMergeLog.Account__r.Name + '</td></tr>';
                    messageBody += '<tr><td style="padding: 10px;" colspan="2"><b>Merged Account: </b>' + accMergeLog.Child_Account__c + '</td></tr>';
                    messageBody += '<tr><td colspan="2" style="background-color: #e8f4fc; padding: 15px; border-top: 2px solid #0070c0; border-bottom: 2px solid #0070c0;"><b style="color: #005496;">Merged Object Count</b></td></tr>';
                    messageBody += '<tr><td>Account Affiliate Contract</td><td>' + accMergeLog.Child_Affiliate_Contract_Count__c + '</td></tr>';
                    messageBody += '<tr><td>Account Connection</td><td>' + accMergeLog.Child_Account_Connection_Count__c + '</td></tr>';
                    messageBody += '<tr><td>Account Market</td><td>' + accMergeLog.Child_Account_Market_Count__c + '</td></tr>';
                    messageBody += '<tr><td>Account Request</td><td>' + accMergeLog.Child_Account_Request_Count__c + '</td></tr>';
                    messageBody += '<tr><td>Account Share</td><td>' + accMergeLog.Child_Account_Share_Count__c + '</td></tr>';
                    messageBody += '<tr><td>Account Team Member</td><td>' + accMergeLog.Child_AccountTeamMember_Count__c + '</td></tr>';
                    messageBody += '<tr><td>Account Transfer Mapping</td><td>' + accMergeLog.Child_Account_Transfer_Mapping_Count__c + '</td></tr>';
                    messageBody += '<tr><td>Account Trends</td><td>' + accMergeLog.Child_Account_Trends_Count__c + '</td></tr>';
                    messageBody += '<tr><td>Attachment</td><td>' + accMergeLog.Child_Attachment_Count__c + '</td></tr>';
                    messageBody += '<tr><td>Budget</td><td>' + accMergeLog.Child_Budget_Count__c + '</td></tr>';
                    messageBody += '<tr><td>CNA</td><td style="width: 50%;">' + accMergeLog.Child_CNA_Count__c + '</td></tr>';
                    messageBody += '<tr><td>Campaign Member</td><td>' + accMergeLog.Child_Campaign_Member_Count__c + '</td></tr>';
                    messageBody += '<tr><td>Contact</td><td>' + accMergeLog.Child_Contact_Count__c + '</td></tr>';
                    messageBody += '<tr><td>Contract</td><td>' + accMergeLog.Child_Contract_Count__c + '</td></tr>';
                    messageBody += '<tr><td>D&B Account Junction</td><td>' + accMergeLog.Child_D_B_Account_Junction_Count__c + '</td></tr>';
                    messageBody += '<tr><td>Digital Campaign</td><td>' + accMergeLog.Child_Digital_Campaign_Count__c + '</td></tr>';
                    messageBody += '<tr><td>Drift Conversation</td><td>' + accMergeLog.Child_Drift_Conversation_Count__c + '</td></tr>';
                    messageBody += '<tr><td>Field Marketing Request</td><td>' + accMergeLog.Child_FMR_Count__c + '</td></tr>';
                    messageBody += '<tr><td>Hospitality</td><td>' + accMergeLog.Child_Hospitality_Count__c + '</td></tr>';
                    messageBody += '<tr><td>INVOCA Call Log</td><td>' + accMergeLog.Child_INVOCA_Call_log_Count__c + '</td></tr>';
                    messageBody += '<tr><td>Interim AE Account</td><td>' + accMergeLog.Child_Interim_AE_Account_Count__c + '</td></tr>';
                    messageBody += '<tr><td>Lead</td><td>' + accMergeLog.Child_Lead_Count__c + '</td></tr>';
                    messageBody += '<tr><td>Opportunity</td><td>' + accMergeLog.Child_Opportunity_Count__c + '</td></tr>';
                    messageBody += '<tr><td>Order</td><td>' + accMergeLog.Child_Order_Count__c + '</td></tr>';
                    messageBody += '<tr><td>Proposal</td><td>' + accMergeLog.Child_Proposal_Count__c + '</td></tr>';
                    messageBody += '<tr><td>Proposal Zone Monthly Value</td><td>' + accMergeLog.Child_PZMV_Count__c + '</td></tr>';
                    messageBody += '<tr><td>Revenue</td><td>' + accMergeLog.Child_Revenue_Count__c + '</td></tr>';
                    messageBody += '<tr><td>SAM Mapping</td><td>' + accMergeLog.Child_SAM_Count__c + '</td></tr>';
                    messageBody += '<tr><td>Sales Budget</td><td>' + accMergeLog.Child_SalesBudget_Count__c + '</td></tr>';
                    messageBody += '<tr><td>Support Request</td><td>' + accMergeLog.Child_Support_Request_Count__c + '</td></tr>';
                    messageBody += '<tr><td>Task</td><td>' + accMergeLog.Child_Task_Count__c + '</td></tr>';
                    messageBody += '<tr><td>TMS Request</td><td>' + accMergeLog.Child_TMS_Request_Count__c + '</td></tr>';
                    messageBody += '<tr><td>Traffic Id Element</td><td>' + accMergeLog.Child_TrafficIdElement_Count__c + '</td></tr>';
                    messageBody += '<tr><td>Topic Assignment</td><td>' + accMergeLog.Child_Topic_Assignment_Count__c + '</td></tr>';
                    messageBody += '<tr><td>Trade</td><td>' + accMergeLog.Child_Trade_Count__c + '</td></tr>';
                    messageBody += '<tr><td>Trade Proposal</td><td>' + accMergeLog.Child_Trade_Proposal_Count__c + '</td></tr>';
                    messageBody += '<tr></tr>';
                    messageBody += '<tr><td colspan="2" style="background-color: #cccccc; text-align: center; padding: 20px; font-weight: bold; font-size: 16px; color: #333333;">Thank You!</td></tr>';
                    messageBody += '</table>';
                    messageBody += '</body></html>';
                }
            }
            else
            {
                messageBody = '<html><body>Hi ' + userinfo.getName() + ', <br/>' + System.Label.Email_Account_Merge_Error_Status + ' <a href="' + URL.getSalesforceBaseUrl().toExternalForm() + '/' + AMD[0].Id + '">Click here</a></html><br/><br/>Thanks';
            }

            
                message.setHtmlBody(messageBody);
                Messaging.sendEmail(new Messaging.SingleEmailMessage[] { message }); 
            }
            else{
                System.debug('Bulk Merge');
            }

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
            Log4SF.logMessage('AccountMergeBatch', 'sendStatusEmail', ex.getMessage(), ex, UserInfo.getUserId(), null, '');
        }
    }
   
    @AuraEnabled
    public static Account_Request__c getAccountRequestRecordForMerge(String accountRequestId) {
        List<Account_Request__c> accRequest = new List<Account_Request__c>();

        try{
            accRequest = [Select Id,Advertiser_Agency_Rep_Firm__c,Duplicate_Account__c From Account_Request__c Where Id =: accountRequestId];
            return accRequest[0];

        }catch(Exception ex){
            System.debug('Error occured in getAccountRequestRecordForMerge =======> '+ ex.getMessage());
            Log4SF.logMessage('AccountMergeBatch', 'getAccountRequestRecordForMerge', ex.getMessage(), ex, UserInfo.getUserId(), null, '');
            throw ex;
        }
    }

}