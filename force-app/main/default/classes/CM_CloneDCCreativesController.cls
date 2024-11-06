/*
    Author      : M & S
    Date        : 28 Mar- 2018
    Description : Apex Controller of CM_CloneDCCreatives.cmp(Lightning component)
                  Cloning Digital Creatives from One Digital Campaign to Another Digital Campaign based on Matrix.
                  Ref : SRSF-850
    Modification History :
*/
public with sharing class CM_CloneDCCreativesController {
    
    
    /*
        Decsription : Retrieves Digital Campaign information 
        Input       : Digital Campaign recordid
        Output      : Digital Campaign Record Information
    */
    @AuraEnabled
    public static Digital_Campaign__c getDigitalCampaign(Id campaignID) {
        Digital_Campaign__c campaignObj = [SELECT Id,Name,Campaign_Name__c,Advertiser__c,Advertiser__r.Name,Status__c,RecordType.Name,Migrated_Creative__c,Campaign_Start_Date__c, Campaign_End_Date__c FROM Digital_Campaign__c WHERE ID=:campaignID];
        return campaignObj;
    }
    /*
        Description : Retrieves All the Digital Creatives based on Digital Campaign
        Input       : Digital Campaign Id
        Output      : List of Digital Cretives
    */
    @AuraEnabled
    public static list<CM_DCCWrap> getDigitalCreatives(Digital_Campaign__c FromDCObj , Id toDCId) 
    {
        list<CM_DCCWrap> wrapList;
        try 
        {
            Digital_Campaign__c toDCObj = [Select Id,Name,Campaign_Name__c,RecordType.Name,Advertiser__c,Status__c,Campaign_Start_Date__c, Campaign_End_Date__c from Digital_Campaign__c Where Id=:toDCId];
            //Initializing a wrapper list
            wrapList = new list<CM_DCCWrap>();
            boolean validRectypes = CM_CloneDCHelper.checkForValidDC(FromDCObj,toDCObj);
            system.debug('validRectypes::'+validRectypes);
            if(!validRectypes)
                return wrapList;
            
            //Getting Clone Creatives Count (SRSF-1427)
            integer maxDCCCount = 100;
            List<DCC_Clone_Count__c> dccCount = DCC_Clone_Count__c.getall().values();
            if( dccCount!=null && !dccCount.isEmpty() && dccCount[0].Max_DCC_Count__c!=null )
                maxDCCCount = Integer.valueof(dccCount[0].Max_DCC_Count__c);
            System.debug('maxDCCCount::'+maxDCCCount);
            //Looping all the Digital_Creative__c of given DigitalCampaign and constructing a wrapper list.
            for(Digital_Creative__c c : [SELECT 
                Name,
                Account_Executive__c,
                Advertiser_Text__c,
                Agency_Text__c,
                Call_to_Action__c,
                Click_Through_URL__c,               
                Companion_Ad__c,
                Creative_Ad_Dimensions_Display__c,
                Creative_End_Date__c,
                Creative_Folder_Location__c,
                Creative_Location__c,
                Creative_Name__c,
                Creative_Notes__c,
                Creative_Producer__c,
                Creative_Ready_for_Trafficking__c,
                Creative_Start_Date__c,
                Digital_Campaign__r.Name,
                Division__c,
                Email_Message__c,
                In_Banner_Video__c,
                In_Banner_Video_Playout__c,
                Landing_Page_Type__c,
                Linkedin_Message__c,
                Linkedin_Subject_Line__c,
                Creative_Link__c,
                Map__c,
                Map_Location__c,
                Mobile_Ad_Unit_Click_Through__c,
                Mobile_Tap_to_Call_Phone__c,
                PreRoll_Spot_Length__c,
                PreRoll_Spot_Length_Other__c,
                Record_Lock__c,
                Rep_Firm_Text__c,
                Sales_Office__c,
                Social__c,
                Spot_Duration__c,
                Spot_End_Date__c,
                Spot_ID_if_needed__c,
                Spot_Start_Date__c,
                Spot_Title__c,
                Status__c,
                Twitter_Text__c,
                YouTube_URL__c,
                Vast_Tag_URL__c,
                Vast_Tag_2_0_Line_1__c,
				Vast_Tag_2_0_Line_2__c,
				Vast_Tag_2_0_Line_3__c,
                Vast_Tag_2_0_Line_4__c,                        
                Vast_Tag_2_0_Line_5__c,    
                Vast_Tag_2_0_Line_6__c,
                Vast_Tag_2_0_Line_7__c,
                Vast_Tag_3_0_Line_1__c,
                Vast_Tag_3_0_Line_2__c,
                Vast_Tag_3_0_Line_3__c,
                Vast_Tag_3_0_Line_4__c,
                Vast_Tag_3_0_Line_5__c,
                Vast_Tag_3_0_Line_6__c,
                Vast_Tag_3_0_Line_7__c,
                Creative_Type__c
                FROM Digital_Creative__c WHERE Digital_Campaign__c = : FromDCObj.Id Limit :maxDCCCount])
            {
                //system.debug('Digital_Creative__c--->'+c);
                wrapList.add(new CM_DCCWrap(false,c,FromDCObj,toDCObj));
            }
            //system.debug('wrapList--->'+wrapList);
            //system.debug('wrapList size-->'+wrapList.size());
            //Returning a wrapper list to component.
            return wrapList;
        }
        catch(Exception exp)
        {
            wrapList = null;
            Return wrapList;
        }
    }
    
    /*
        Description : Clones selected Digital Creatives from the User Iterface
        Input       : List of Selected Digital Cretives, From Digital Campaign Id, To Digital Campaign Id 
        Output      : Result Message to display on UI as String 
    */
    @AuraEnabled
    public static String CreateCloneDigitalCreative(String selWrap, id strDCId , id fromStrDCId)
    {
        String strResponse = '';
        try
        {
            Digital_Campaign__c objFromDC = getDigitalCampaign(fromStrDCId);
            list<CM_DCCWrap> lstResult = getDigitalCreatives(objFromDC,strDCId);//checking Digital Creatives based on Digital Campaign
            if(lstResult.isEmpty()){
                strResponse = Label.CM_Clone_Creative_Tooltip;//Need to display Error Message from Custom Label
                return strResponse;
            }
            //Deserializing a wrapper list received from component.
            list<CM_DCCWrap> lstDCCWrap = (list<CM_DCCWrap>)Json.deserialize(selWrap, list<CM_DCCWrap>.class);
            //Filtering and cloning Digital_Creative__c
            list<Digital_Creative__c> newDCCList = CM_CloneDCHelper.FilterSeletedDigitalCreative(lstDCCWrap,strDCId);
            system.debug(newDCCList);
            //Inserting new cloned Digital_Creative__c.
            if (!newDCCList.isEmpty())
            {
                //system.debug(newDCCList.size());
                Insert newDCCList;  
                strResponse = 'successful';
            }
            else
            {
                strResponse = 'Please select atleast one record to clone';
            }
        }
        catch(exception ex)
        {
            //Handling errors
            system.debug('--->'+Ex.getLineNumber()+' '+ ex.getMessage());
            strResponse =  ex.getMessage();
        }
        return strResponse;
    }
    
}