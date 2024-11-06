/*
    Author : MAndS 
    Date   : 09/05/2017
    Description : Supporting class for OppThresholdNotification trigger to get all Parent Roles.
    Modification History : 
*/
public with sharing class OppThresholdController {
    /*
    public static final string TEMPLATE_NAME = 'Opportunity_Threshold_Notification_Template';   //Email template name
    //to get all users above opportunity owner in role hierarchy
    public static void notifyUsersOnThresExceed(list<Opportunity> lstOpps, map<string,Id> mapUserRole)
    {
        list<Messaging.SingleEmailMessage> lstMails = new list<Messaging.SingleEmailMessage> ();    //list to hold emails
        map<string,set<Id>> mapOwnerToParents = new map<string,set<Id>> (); //map to hold opp owner to set of parent roles
        map<string,list<User>> mapOwnerToPUsers = new map<string,list<User>> ();    //map to hold opp owner to list of users above him
        map<string,list<User>> mapRoleToUser = new map<string,list<User>> ();   //map to hold user role and related user object
        list<User> lstUsers = new list<User> ();    //list to hold opp owner and users above him
        System.debug('mapUserRole: ' + mapUserRole);
        if(!mapUserRole.isEmpty()){
            set<Id> setRoleIds = new set<Id> ();
            for(string strId : mapUserRole.keyset())
            {
                set<Id> setTemp = new set<Id> {mapUserRole.get(strId)}; //fetch owner's role
                set<Id> setRIds = new set<Id> ();
                setRIds = getParentRoleId(setTemp); //get parent role ids
                setRIds.add(mapUserRole.get(strId));
                mapOwnerToParents.put(strId,setRIds);
                setRoleIds.addAll(setRIds);     //add all owner's and parent's role ids
            }
            //query on users to get all users with above role ids
            // Query updated by Govind Thathera to exclude users without Role.
            lstUsers = [select Id, Name, FirstName, LastName, Email, UserRoleId, Opportunity_Threshold__c 
                                        from User WHERE UserRoleId IN: setRoleIds AND UserRoleId != null
                                        and  Opportunity_Threshold__c > 0];
            System.debug('lstUsers: ' + lstUsers);                            
            if(!lstUsers.isEmpty()){
                for(User objUser : lstUsers)
                {
                    list<User> lstTemp = new list<User> ();
                    if(mapRoleToUser.containsKey(objUser.UserRoleId))
                        lstTemp = mapRoleToUser.get(objUser.UserRoleId);
                    lstTemp.add(objUser);
                    mapRoleToUser.put(objUser.UserRoleId,lstTemp);
                }
                //prepare map to hold opp owner to users above him in role hierarchy
                for(string strId : mapOwnerToParents.keyset())
                {
                    set<Id> setTemp = mapOwnerToParents.get(strId);
                    list<User> lstU = new list<User> ();
                    for(Id roleId : setTemp)
                    {
                        if(mapRoleToUser.containsKey(roleId)){
                            lstU.addAll(mapRoleToUser.get(roleId));
                        }
                    }
                    mapOwnerToPUsers.put(strId,lstU);
                }
            }                                       
        }
        
        if(!lstOpps.isEmpty())
        {
            map<Id, Contact> mapContactByUserId = new map<Id, Contact>();
            //query the template which needs to be sent
            list<EmailTemplate> lstTemplate = [Select id, Subject, HTMLValue, Body from EmailTemplate where DeveloperName =: TEMPLATE_NAME];
            if(!lstTemplate.isEmpty()){
                EmailTemplate objTemplate = lstTemplate[0];
                for(Opportunity objOpp : lstOpps)
                {
                    if(mapOwnerToPUsers.containsKey(objOpp.OwnerId))
                    {
                        list<User> lstU = mapOwnerToPUsers.get(objOpp.OwnerId);
                        for(User objUser : lstU)
                        {
                            System.debug('objOpp.Total_Forecast_Amount__c: ' + objOpp.Total_Forecast_Amount__c);       
                            //if forecast amount on user is greater than or equal to threshold on opportunity, send email to those users 
                            if(objOpp.Total_Forecast_Amount__c >= objUser.Opportunity_Threshold__c){
                              mapContactByUserId.put( objUser.Id, new Contact( FirstName=objUser.FirstName, LastName=objUser.LastName, Email=objUser.Email));
                                lstMails.add( prepareEmailMessage( objUser.Id, objOpp.Id, objTemplate.Id, objUser.Email ) );//  EmailHelper.sendEmailToUsers(objUser.Id, objOpp.Id, objTemplate, 'Opportunity')); 
                                
                            }
                        }
                    }
                }
                if(!lstMails.isEmpty())

                    try{

                        //insert mapContactByUserId.values();
                        System.debug('lstMails: ' + lstMails);
                        Messaging.sendEmail(lstMails);

                    }Catch( Exception ex ){
                        
                    }
                    
            }
        }
    }

    private static Messaging.SingleEmailMessage prepareEmailMessage( Id targetUserId, Id relatedOpptyId, Id templateId, String email ){
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        mail.setToAddresses(new List<String>{email});
        mail.setTargetObjectId (Label.MailAssistContact);
        mail.setTemplateId( templateId );
        mail.setReplyTo('no-reply@spectrumreach.com');
        mail.setSenderDisplayName('SR');
        mail.setSaveAsActivity(false);
        mail.setWhatId( relatedOpptyId );
        return mail;
    }

    // To get all Parent Roles.
    public static Set<Id> getParentRoleId(Set<ID> setRoleIds) {

        Set<ID> setCurrentRoleIds = new Set<ID>();
        // get all of the parent roles.
        for(UserRole objUR :[select Id, ParentRoleId from UserRole where Id IN: setRoleIds]) {
            if(objUR.ParentRoleId != null)
                setCurrentRoleIds.add(objUR.ParentRoleId);
        }
        // go fetch some more rolls!
        if(setCurrentRoleIds.size() > 0) {
            setCurrentRoleIds.addAll(getParentRoleId(setCurrentRoleIds));
        }
        return setCurrentRoleIds;
    }
    */
}