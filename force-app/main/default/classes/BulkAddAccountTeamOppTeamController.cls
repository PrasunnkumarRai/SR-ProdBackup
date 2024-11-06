public Without sharing class BulkAddAccountTeamOppTeamController {
    public static string sessionId;
    
    public BulkAddAccountTeamOppTeamController() {

    }

    @AuraEnabled
    public static List < ListView > getUserListView() {
        List < ListView > listViewList = new List < ListView > ();
        listViewList = [SELECT Id, Name, DeveloperName, NamespacePrefix, SobjectType, IsSoqlCompatible
            FROM ListView WHERE SobjectType = 'User'
           //Commenting For Region Changes// AND DeveloperName IN('Central_Division', 'East_Division', 'West_Division', 'National_Division')
           AND DeveloperName IN('West', 'Adlink_SRS', 'Central', 'Northern','Great_Lakes','Southeast','Blue_Ridge')
        ];
        System.debug('listViewList ::: ' + listViewList);
        return listViewList;
    }

    @AuraEnabled
    public static List < UsersDetails > getListViewData(String lisviewId, Integer offset) {
        System.debug('listViewId ::: ' + lisviewId);
        System.debug('offset :::::: ' + offset);
        sessionId = '';
        if(!Test.isRunningTest()){
            PageReference reportPage = Page.GetSessionIdVF;
            String vfContent = reportPage.getContent().toString();
            System.debug('vfContent ' + vfContent);
            
            Integer startP = vfContent.indexOf('Start_Of_Session_Id') + 'Start_Of_Session_Id'.length(),
            endP = vfContent.indexOf('End_Of_Session_Id');
            sessionId = vfContent.substring(startP, endP);
            System.debug('sessionId ' + sessionId);
        }
        String sfdcURL = URL.getSalesforceBaseUrl().toExternalForm();
        String restAPIURL = sfdcURL + '/services/data/v56.0/sobjects/user/listviews/' + lisviewId + '/results?limit=100&offset=' + offset + '';
        HttpRequest httpRequest = new HttpRequest();
        httpRequest.setMethod('GET');
        System.debug('sessionId ::: ' + sessionId);
        httpRequest.setHeader('Authorization', 'Bearer ' + sessionId);
        httpRequest.setEndpoint(restAPIURL);
        String response = '';
        try {
            Http http = new Http();
            HttpResponse httpResponse = http.send(httpRequest);
            if (httpResponse.getStatusCode() == 200) {
                response = JSON.serializePretty(JSON.deserializeUntyped(httpResponse.getBody()));
            } else {
                System.debug(' httpResponse ' + httpResponse.getBody());
                throw new CalloutException(httpResponse.getBody());
            }
        } catch (System.Exception e) {
            System.debug('ERROR: ' + e);
            throw e;
        }
        ListViewResponseModel lvUserResponse = ListViewResponseModel.parse(response);
        List < UsersDetails > userDetails = new List < UsersDetails > ();
        for (ListViewResponseModel.Records userRecord: lvUserResponse.Records) {
            UsersDetails ud = new UsersDetails();
            for (ListViewResponseModel.Columns userField: userRecord.columns) {
                System.debug('userField.fieldNameOrPath:: ' + userField.fieldNameOrPath);
                if (userField.fieldNameOrPath == 'Name') {
                    System.debug('userField.fieldNameOrPath:: ' + userField.value);
                    ud.name = userField.value;
                }
                if (userField.fieldNameOrPath == 'Username') {
                    System.debug('userField.fieldNameOrPath:: ' + userField.value);
                    ud.userName = userField.value;
                }
                if (userField.fieldNameOrPath == 'Profile.Name') {
                    System.debug('userField.fieldNameOrPath:: ' + userField.value);
                    ud.profileName = userField.value;
                }
                if (userField.fieldNameOrPath == 'Region__c') {
                    System.debug('userField.fieldNameOrPath:: ' + userField.value);
                    ud.Region = userField.value;
                }
                if (userField.fieldNameOrPath == 'Id') {
                    System.debug('userField.fieldNameOrPath:: ' + userField.value);
                    ud.Id = userField.value;
                }
                if (userField.fieldNameOrPath == 'Team_Role__c') {
                    System.debug('userField.fieldNameOrPath:: ' + userField.value);
                    ud.teamRole = userField.value;
                }
            }
            userDetails.add(ud);
        }
        System.debug('userDetails:: ' + userDetails);
        return userDetails;
    }

    @AuraEnabled
    public static String getUserProfiles() {
        Id profileId = UserInfo.getProfileId();
        System.debug('ProfileId ::: ' + profileId);
        String profileName = [Select Id, Name from Profile where Id =: profileId].Name;
        System.debug('profileName :: ' + profileName);
        return profileName;
    }

    @AuraEnabled
    public static List < AccountTeamMember > AddAtm(List < AccountTeamMember > atmotmData) {
        System.debug('atmotmData in ADDAtm :::::::: ' + atmotmData);
        // public static void AddAtm(Map < String, List < String >> mapATMData, Map < String, List < String >> mapATMTeamRole) {
        //     String accountIds;
        //     String usersId;

        //     Set < String > idOfAccSet = new Set < String > ();
        //     for (String uId: mapATMData.keySet()) {
        //         idOfAccSet.addAll(new Set < String > (mapATMData.get(uId)));
        //     }
    
        //     Map<Id,String> atmTeampRoleMAP = new Map<Id,String>();
        //     for (String uId1: mapATMTeamRole.keySet()) {
        //         atmTeampRoleMAP.put(uId1,(mapATMTeamRole.get(uId1)[0]));
        //     }
    
        //     System.debug('idOfAccSet :::: ' + idOfAccSet);
        //     sYSTEM.debug('atmTeampRoleMAP ::: ' + atmTeampRoleMAP);

        // Insert atmotmData;
        Database.SaveResult[] srList = Database.insert(atmotmData, false);
        Integer savedRecordsSize = srList.size();

        System.debug('Number of saved records in atm : ' + savedRecordsSize);
        // Iterate through each returned result
        for (Database.SaveResult sr : srList) {
            if (sr.isSuccess()) {
                // Operation was successful, so get the ID of the record that was processed
                System.debug('Successfully inserted account. Account ID: ' + sr.getId());
            }
            else {
                // Operation failed, so get all errors                
                for(Database.Error err : sr.getErrors()) {
                    System.debug('@@err:: '+err); 
                    System.debug('The following error has occurred.');                    
                    System.debug(err.getStatusCode() + ': ' + err.getMessage());
                    System.debug('Account fields that affected this error: ' + err.getFields());
                }
            }
        }

        // AddAccTeamMemberBatch batch = new AddAccTeamMemberBatch(idOfAccSet, mapATMData, atmTeampRoleMAP);
        // Database.executeBatch(batch);
        // System.debug('Batch Called.. in atm');





        return atmotmData;
    }
    @AuraEnabled
    public static void AddAtmUsingBatch(Map < String, List < String >> mapATMData, Map<Id,String> mapATMTeamRole) {
          System.debug('mapATMData :::::: ' + mapATMData);

            String accountIds;
            String usersId;

            Set < String > idOfAccSet = new Set < String > ();
            for (String uId: mapATMData.keySet()) {
                idOfAccSet.addAll(new Set < String > (mapATMData.get(uId)));
            }
    
            System.debug('idOfAccSet :::: ' + idOfAccSet);
            System.debug('atmTeampRoleMAP ::: ' + mapATMTeamRole);

        AddAccTeamMemberBatch batch = new AddAccTeamMemberBatch(idOfAccSet, mapATMData, mapATMTeamRole);
        Database.executeBatch(batch);
        System.debug('Batch Called.. in atm');
    }


    @AuraEnabled
    public static void AddOtm(Map < String, List < String >> mapData, Map<Id,String> oppTeamRoleSet) {
        System.debug('mapData ::::: ' + mapData);
        System.debug('oppTeamRoleSet ::::: ' + oppTeamRoleSet);
        String accountIds;
        String userIds;
        


        Set < String > idOfAcc = new Set < String > ();
        for (String uId: mapData.keySet()) {
            idOfAcc.addAll(new Set < String > (mapData.get(uId)));
        }

        // Map<Id,String> oppTeamRoleSet = new Map<Id,String>();
        // for (String uId1: mapForTeamRoles.keySet()) {
        //     oppTeamRoleSet.put(uId1,(mapForTeamRoles.get(uId1)[0]));
        // }

        System.debug('idOfAcc :::: ' + idOfAcc);
        // System.debug('oppTeamRoleSet :::: ' + oppTeamRoleSet);

        AddOppTeamMembersBatch batch = new AddOppTeamMembersBatch(idOfAcc, mapData, oppTeamRoleSet);
        Database.executeBatch(batch);
        System.debug('Batch Called..');
    }


    public class UsersDetails {
        @AuraEnabled
        public string userName {
            get;
            set;
        }
        @AuraEnabled
        public string name {
            get;
            set;
        }
        @AuraEnabled
        public string email {
            get;
            set;
        }
        @AuraEnabled
        public string profileName {
            get;
            set;
        }
        @AuraEnabled
        public string Region {
            get;
            set;
        }
        @AuraEnabled
        public string Id {
            get;
            set;
        }
        @AuraEnabled
        public string teamRole {
            get;
            set;
        }
    }
}