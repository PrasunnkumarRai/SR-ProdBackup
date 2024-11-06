/* 
    Customer/Project:  Spectrum Reach
    Class name:         UserConnectionController
    Author/Date:       Brett Ballantyne    2/22/18
    Release:            4.0
    Purpose:           Apex support for the UserConnection VF page
*/

public with sharing class UserConnectionController {

    public List<Traffic_Id_Element__c> myTrafficIdElement {get; set;}
    private User currentUser;
    private ApexPages.StandardController controller {get; set;}

    public Id getCurrentUserId() {
        return currentUser.Id;
    }

    public UserConnectionController(ApexPages.StandardController controller) {
        this.controller = controller;
        this.currentUser = (User) controller.getRecord();
        this.getUserConnections();
    }

    public List<Schema.FieldSetMember> getFields() {
        return SObjectType.Traffic_Id_Element__c.FieldSets.TI_Field_Set.getFields();
    }

    public List<Traffic_Id_Element__c> getUserConnections() {
    /*  List<UserConnection__c> ucList = [select Name, External_System__c, Is_Primary__c, AE_Id__c, TIM_System__c, Username__c
                                            From UserConnection__c
                                            where User__c = :currentUser.Id];
                                            */
        String query = 'select Id, Name';
        for (Schema.FieldSetMember f : this.getFields()) {
            String fieldName = f.getFieldPath();
            if (fieldName == 'Name' || fieldName == 'Id')   // Always include Id and Name, so avoid duplicating fields in query
                continue;
            query += ', ' + fieldName;
        }
        query += ' From Traffic_Id_Element__c where User__c = \'' + currentUser.Id + '\'';
        myTrafficIdElement = Database.query(query);
        return myTrafficIdElement;
    }

    public void dummyUpdateUser(){
        User dummyUpdate = new User();
        dummyUpdate.Id = currentUser.Id;
        update dummyUpdate;
    }

}