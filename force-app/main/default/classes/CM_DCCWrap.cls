/*
    Author : MAndS 
    Date   : 28 Mar- 2018
    Description : Supporting class for CM_CloneDCCreativesController
    Modification History : 
*/
Public Class CM_DCCWrap 
{
    @AuraEnabled Public boolean isCheck {get;set;} //Record Selected from CM_CloneDCCreatives lightning component UI
    @AuraEnabled public Digital_Creative__c Con {get;set;} //Selected Digital Creative Record
    @AuraEnabled public string strdcStDate {get;set;} //Campaign_Start_Date__c in mm-dd-yyyy
    @AuraEnabled public string strdcEndDate {get;set;} //Campaign_End_Date__c in mm-dd-yyyy
    @AuraEnabled public string strdccStDate {get;set;} //Creative_Start_Date__c in mm-dd-yyyy
    @AuraEnabled public string strdccEndDate {get;set;} //Creative_End_Date__c in mm-dd-yyyy
    @AuraEnabled public String dccCN {get;set;} //Creative_Name__c
    @AuraEnabled public String dccStatus {get;set;} //Status__c
    @AuraEnabled public String dccName {get;set;} //Name
    //Constructor
    public CM_DCCWrap(boolean bool, Digital_Creative__c c, Digital_Campaign__c FromDCObj, Digital_Campaign__c ToDCObj)
    {
        this.isCheck = bool;
        Date dccStDt = c.Creative_Start_Date__c;
        Date dccEndDt = c.Creative_End_Date__c;
        c.Creative_Start_Date__c = ToDCObj.Campaign_Start_Date__c;
        c.Creative_End_Date__c = ToDCObj.Campaign_End_Date__c;
        this.Con = c;
        Date dcStDate = ToDCObj.Campaign_Start_Date__c;
        Date dcEndDate = ToDCObj.Campaign_End_Date__c;
        
        //Changing the date formats
        if( dccStDt!=null ){
            Integer d = dccStDt.day();
            Integer mo = dccStDt.month();
            Integer yr = dccStDt.year();
            //DateTime DT = DateTime.newInstance(yr, mo, d);
            this.strdccStDate = mo+'-'+d+'-'+yr;
        	//this.strdccStDate = dccStDate.format('MM-dd-yyyy',Userinfo.getTimeZone().getId());
        }
        if( dccEndDt!=null ){
            Integer d = dccEndDt.day();
            Integer mo = dccEndDt.month();
            Integer yr = dccEndDt.year();
            //DateTime DT = DateTime.newInstance(yr, mo, d);
            this.strdccEndDate = mo+'-'+d+'-'+yr;
        	//this.strdccEndDate = dccEndDate.format('MM-dd-yyyy',Userinfo.getTimeZone().getId());
        }
        if( dcStDate!=null ){
            Integer d = dcStDate.day();
            Integer mo = dcStDate.month();
            Integer yr = dcStDate.year();
            //DateTime DT = DateTime.newInstance(yr, mo, d);
            this.strdcStDate = mo+'-'+d+'-'+yr;
        	//this.strdccStDate = dccStDate.format('MM-dd-yyyy',Userinfo.getTimeZone().getId());
        }
        if( dcEndDate!=null ){
            Integer d = dcEndDate.day();
            Integer mo = dcEndDate.month();
            Integer yr = dcEndDate.year();
            //DateTime DT = DateTime.newInstance(yr, mo, d);
            this.strdcEndDate = mo+'-'+d+'-'+yr;
        	//this.strdccEndDate = dccEndDate.format('MM-dd-yyyy',Userinfo.getTimeZone().getId());
        }
        
        //trimming the text to 6 characters for QuickAction popup lightning component column
        dccCN = c.Creative_Name__c;
        if( dccCN!=null && dccCN.length()>18 )
            dccCN = dccCN.substring(0,18)+'..';
        dccStatus = c.Status__c;
        if( dccStatus!=null && dccStatus.length()>2 )
            dccStatus = dccStatus.substring(0,2)+'..';
        dccName = c.Name;
        if( dccName!=null && dccName.length()>6 )
            dccName = dccName.substring(0,6)+'..';
    }
}