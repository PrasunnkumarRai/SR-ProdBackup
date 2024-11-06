/*
###########################################################################
# Created by............: Sai Anuja
# Created Date..........: 18-June-2018
# Last Modified by......: Puneet Khosla
# Last Modified Date....: 28-July-2018
# Description...........: This class is being used to delete older logger records.
# Change Log:               
# 1. Puneet Khosla - Added Limit statement
############################################################################*/

global class BatchToDeleteLoggers implements Database.Batchable<sObject> {
    public String query;
    private final string DAY_LIMIT ='Logger_Batch_Day_Limit';
    private final string RECORD_LIMIT = 'Logger_Batch_Record_Limit';
    
    global BatchToDeleteLoggers() {
        Date referDt = Date.newInstance(2018, 1, 1);
        integer daysBetween = 302 - referDt.daysBetween(Date.today());
        set<string> settingKey = new set<string>{DAY_LIMIT,RECORD_LIMIT};

        List<Common_Setting__mdt> commonSettingList = [SELECT NumberValue__c,DeveloperName FROM Common_Setting__mdt
                                        WHERE DeveloperName IN :settingKey];
        
        integer noOfDays = 365;
        integer recordLimit = 50000;
        for(Common_Setting__mdt commonSetting : commonSettingList)
        {
            if(commonSetting.DeveloperName == DAY_LIMIT)
            {
                noOfDays = Integer.valueOf(commonSetting.NumberValue__c);
            }
            else if(commonSetting.DeveloperName == RECORD_LIMIT)
            {
                recordLimit = Integer.valueOf(commonSetting.NumberValue__c);
            }
        }
        
        integer noDays = (daysBetween > noOfDays)?daysBetween:noOfDays;
        string whereSubClause = ' WHERE CreatedDate < LAST_N_DAYS:'+Integer.ValueOf(noDays) + ' Order by CreatedDate asc ';
        whereSubClause += ' LIMIT ' + recordLimit;
        if (Test.isRunningTest()) 
        {
            whereSubClause ='';
        }
        String query = 'SELECT Id, CreatedDate,name FROM logger__c'+ whereSubClause;
        //system.debug('query::'+query);
        this.query = query;
    }
    
    global Database.QueryLocator start(Database.BatchableContext bc) {
        return Database.getQueryLocator(query);
    }
    
    global void execute(Database.BatchableContext BC, list<Sobject> objects) {
        List<logger__c> loggerListToDelete = (List<logger__c>)objects;
        List<Id> delLoggerIds = new List<Id>();
        List<Id> recycleIds = new List<Id>();
        try{
            Database.DeleteResult[] deleteResults = Database.delete(loggerListToDelete, false);
            for(Database.DeleteResult dr : deleteResults) {
                if (dr.isSuccess()) {
                    delLoggerIds.add(dr.getId());
                }
            }
            if(delLoggerIds.size() > 0){
                UtilityClass.emptyRecycleBin(delLoggerIds);
            }
        }
        catch(exception e){
            system.debug(e);
        }        
    }
    
    global void finish(Database.BatchableContext BC) {

    }
}