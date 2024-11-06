/*
###########################################################################
# File..................: ProposalSCXUploadController.cls
# Version...............: 1
# Created by............: Ankit Bhatia   
# Created Date..........: 24-April-2017
# Last Modified by......: Bhuvanasankar Das
# Last Modified Date....: 11-July-2018
# Description...........: This class contains controller methods for Uploading / Previewing SCX file and sendind the associate data to TIM. 
# TAO Ref#..............: NA
# Change Log:               
# 1. Puneet Khosla - Fixes for SRSF-1096 / SRSF-1097
# 2. Bhuvanasankar - Fixes for SRSF-1147
############################################################################*/

public without sharing class ProposalSCXUploadController {
    //Class Properties
    public transient Blob uploadedFile{get; set;}
    public String pageMsg{get; set;}
    public String advName{get;set;}
    public String agencyName{get;set;} // It can be agency / repfirm
    public String accAgencyCode{get;set;}
    public String accAdvCode{get;set;}
    public Decimal totalGross{get;set;}
    public List<ProposalZoneValues> orderList{get; set;}
    public String startDate{get;set;}
    public String endDate{get;set;}
    public boolean hasDetailLine{get;set;}
    public Opportunity opp{get; set;}
    public integer estimateId{get;set;}
    public Proposal__c proposal{get; set;}
    public String name{get;set;}
    public String marketName{get; set;}
    public String propName{get; set;}
    public Integer stepInfo{get; set;}
    public String oppAgency{get; set;}
    public String recordID{get; set;}
    //Code changes to add inventory recordType to page :Aditi:2/26/2018
    public String specialRecType{get;set;}
    //code changes complete
    
    // Class Variables
    public Boolean isMerge;
    public String xmlString;
    public String advCode;
    
    public String agencyCode;
    public String repAgency = '';
    public String agencyTag = '';
    public String repFirmTag = '';
    //Opp Owner User Con List
    public List<UserConnection__c> userCon;
    //Logged in User Con List
    public List<UserConnection__c> loggedInUserCon;
    public List<AccountConnection__c> accountConAdvList;
    public List<AccountConnection__c> accountConAgencyList;
    public List<AccountConnection__c> accountConRepFirmList;
    public BoomiWebServiceHelper boomi;
    public Map<ID,Account> mapAccount;
    public Boolean isPoliticalOpp ;
    public Boolean isThirdParty = false;
    public Boolean isRepFirm = false;
    public Boolean isConfirm = false; // SRSF-1762
    public String createAccInTIM = 'false';  // SRSF-1762
    
    public Boolean isDeleteOppBudgt{get;set;} // Code Added for SRSF-1304
    public List<Proposal__c> propToDelete{get;set;} // Code Added for SRSF-1304
    public Common_Setting__mdt cmnSetting = new Common_Setting__mdt();

    public String proposalSource = '';
    public String propSysCode = '';
    public String selectedRateCard{get;set;}
    public List<SelectOption> rateCards{get;set;}
   // public Boolean fromConstructor{get;set;} // SRSF-1762

    //Default Constructor
    public ProposalSCXUploadController()
    {
           
        recordID = ApexPages.currentPage().getParameters().get('OppId');
        specialRecType = ApexPages.currentPage().getParameters().get('recType');
        isPoliticalOpp = Boolean.valueOf(ApexPages.currentPage().getParameters().get('isPolitical'));
        // START : SRSF-1762  
        isConfirm = null != ApexPages.currentPage().getParameters().get('isConfirm')?Boolean.valueOf(ApexPages.currentPage().getParameters().get('isConfirm')):false;        
        // END : SRSF-1762  
        populateDetailsforAnOpportunity(recordID);
       
    }
    
    
    //Parameterised Constructor
    //Parameter - Opportunity ID
    public ProposalSCXUploadController(string OppID)
    {
        populateDetailsforAnOpportunity(oppId);
    }
    
    private void populateDetailsforAnOpportunity(String oppId){
        cmnSetting = [SELECT Id, Label, DeveloperName, MasterLabel, Condition_Enable__c FROM Common_Setting__mdt WHERE DeveloperName = 'EnableAccountConnectionCreate'];  
        try{
            proposal = new proposal__c();
            estimateId = -1;
            xmlString = '';
            accAgencyCode = oppAgency = '';
            accAdvCode = '';
            mapAccount = new Map<ID,Account>();
            orderList = new  List<ProposalZoneValues>();
            userCon = new List<UserConnection__c>();
            accountConAdvList = new List<AccountConnection__c>();
            accountConAgencyList = new List<AccountConnection__c>();
            accountConRepFirmList = new List<AccountConnection__c>();
            hasDetailLine = false;
            pageMsg='';
            isDeleteOppBudgt = FALSE;
            propToDelete = new List<Proposal__c>();
            selectedRateCard = '';

            List<String> parameters = new List<String>();
            recordID = recordID == null ? OppId:recordID;
            //Get the Opportunity and Account Details
            opp = [SELECT ID,Name,TIM_System__c, OwnerID ,Owner.Name,AE_ID__c ,Agency_Account__r.Account_Tim_Name__c,Rep_Firm__r.Account_Tim_Name__c,Rep_Firm__r.ID ,Agency_Account__r.Name, Account.Name,AccountID,Agency_Account__r.ID,Account.RecordType.Name,Account.Account_Tim_Name__c,Rep_Firm__c,Account.Agency__c,Account.BillingStreet ,Account.BillingCity,Account.Phone,Account.BillingState,Rep_Firm__r.Name, Account.BillingPostalCode,Agency_Account__c, PoliticalOpportunity__c,(SELECT Id FROM Proposals__r WHERE RecordTypeId =: label.Opportunity_Budget_RecordTypeId) FROM Opportunity WHERE Id=:recordID LIMIT 1];
            
            try{

                isPoliticalOpp = opp.PoliticalOpportunity__c;               
                // UtilityClass.showDebugStatement(, Boolean isDisplay)
                // Opportunity Owner User Con
                userCon = [SELECT ID, Name, Tim_System__c,AE_Id__c FROM UserConnection__c WHERE User__c =: opp.OwnerID AND AE_Id__c != null AND Is_Primary__c = true];
                //!= null ? opp.OwnerID : userInfo.getUserId()
                System.debug('userCon::'+userCon);
                if(userCon.size() == 0 && System.label.CacheFailSafe == 'true')
                {
                    User usr = [SELECT ID,Name FROM User WHERE Name = 'Boomi Integration User'];
                    userCon.clear();
                    userCon = [SELECT ID, Name, Tim_System__c,AE_Id__c FROM UserConnection__c WHERE User__c =: usr.ID AND Is_Primary__c = true LIMIT 1];
                }
                else if(userCon.size() == 0){
                    parameters.add(opp.Owner.Name);
                    pageMsg = String.format(System.Label.TIMCreate_No_UserCon_Error,parameters); 
                    return;
                }
                else if(userCon.size() > 1)
                 {
                    parameters.clear();
                    parameters.add(opp.Owner.Name);
                    pageMsg = String.format(System.Label.TIMCreate_Multiple_UserConError, parameters);
                    return;
                 }
                 //Logged in User's UserConnection details
                 loggedInUserCon = [SELECT ID, Name, Tim_System__c,AE_Id__c FROM UserConnection__c WHERE User__c =: UserInfo.getUserId() AND Tim_System__c =: userCon[0].Tim_System__c];
                 System.debug(' ### loggedInUserCon :::: ' +loggedInUserCon);
                 if(loggedInUserCon.size() > 1)
                 {
                    parameters.clear();
                    parameters.add(UserInfo.getName());
                    parameters.add(userCon[0].Tim_System__c);
                    pageMsg = String.format(System.Label.TIMCreate_MultipleTimSystem_UserConError, parameters);
                    return;
                 }                  
                else if(loggedInUserCon.size() == 0)
                {
                    parameters.add(UserInfo.getName());
                    parameters.add(userCon[0].Tim_System__c);
                    pageMsg = String.format(System.Label.No_User_Connection_for_Tim_System,parameters); 
                    return;
                }     
            }
            catch(Exception ex){
                System.debug('@@Exception '+ex);
                //pageMsg = pageMsg = string.format(System.Label.TIMCreate_No_UserCon_Error,parameters);
                pageMsg = pageMsg = System.Label.User_Connection_Error;
                return;
            }
            
            //Code Added for SRSF- 1304
            if(NULL!=opp && opp.Proposals__r.size()>0) propToDelete.addAll(opp.Proposals__r);
            //Code Ends here

            isMerge = false;
            boomi  = new BoomiWebServiceHelper(userCon[0]);
            boomi.isFrmSCXUpload = true;

            mapAccount.put( opp.Account.Id, opp.Account);
           
            if(opp.Rep_Firm__r.Id != null)
            {
                oppAgency = opp.Rep_Firm__r.Account_Tim_Name__c;
                mapAccount.put( opp.Rep_Firm__r.ID, [SELECT Name,BillingState,BillingCity,BillingStreet ,Phone,BillingPostalCode, RecordType.Name,ShippingState,ShippingCity,ShippingStreet,ShippingPostalCode,Agency__c, Account_Tim_Name__c FROM Account WHERE Id=:opp.Rep_Firm__r.Id LIMIT 1]);
            } 
            else if(opp.Agency_Account__r.Id != null)
            {
                oppAgency = opp.Agency_Account__r.Account_Tim_Name__c;
                mapAccount.put( opp.Agency_Account__r.ID, [SELECT Name,BillingState,BillingCity,BillingStreet ,Phone,BillingPostalCode, RecordType.Name,ShippingState,ShippingCity,ShippingStreet,ShippingPostalCode,Agency__c, Account_Tim_Name__c FROM Account WHERE Id=:opp.Agency_Account__r.Id LIMIT 1]);
            }                                      
            System.debug(' @@@ mapAccount ::::: ' + mapAccount);
        }
        catch(exception e)
        {
            System.debug(' ### Exception ::: ' +e.getMessage() + ' ### ' + e.getLineNumber() + e.getStackTraceString());
            pageMsg= e.getMessage();
            Log4SF.logMessage('ProposalSCXUploadController','populateDetailsforAnOpportunity',e.getMessage(),e,UserInfo.getUserId(),recordID);
        } 
    } 
    /*
    Method for calling boomiservice to Verify Accounts in TIM
    */
    public Map<String,String> accResponseMap = new Map<String,String>();

    public PageReference verifyTimAccountID()
    {
        try
        {
            System.debug('@@@ mapAccount' + mapAccount);
           // SRSF-2043 Start : Self Heal Cache: 08-01-2020
            try{
                String timSystem = userCon[0].Tim_System__c; 
                System.debug(CacheManager.checkCacheSize(timSystem));
               if(CacheManager.checkCacheSize(timSystem) <=0){ 
                    System.debug(CacheManager.checkCacheSize(timSystem));   
                    if(Label.CacheAutoRefresh=='true'){
                        CacheManager.refreshTIMCache(timSystem);
                    }
                    Log4SF.logMessage('ProposalSCXUploadController', 'createProposal', 'Refreshed All Cache' , UserInfo.getUserId(), opp.Id);
                    PageReference pg = new PageReference('/apex/Proposal_Cache_Error?timSystem='+timSystem+'&oppID='+opp.Id);
                    String returlstr = '/apex/ConfirmToSaveAccountsInTim?OppId='+opp.Id+'&isPolitical='+isPoliticalOpp+'&recType='+specialRecType+'';
                    pg.getParameters().put('retURL', returlstr);
                    return pg;
                }              
            }
            catch(Exception ex){
                System.debug('refreshCache Callout error: '+ ex);
            }
            // SRSF-2043 End: Self Heal Cache: 08-01-2020             
            boomi.confirmCreateAcc = isConfirm; //SRSF-1762
            if(mapAccount.size() > 0) accResponseMap = boomi.verifyAccountTimIds(opp,mapAccount,userCon[0]);
             //SRSF-1762 Code starts here
            if(Boolean.valueOf(System.Label.Show_confirmation_msg_for_new_account_creation_in_TIM))
                createAccInTIM = accResponseMap.get('createAccInTIM'); 
           // System.debug('SCX createAccInTIM::: ' + createAccInTIM); 
            //SRSF-1762 Code Ends here
        }
        catch(exception ex)
        {
            pageMsg = ex.getMessage();
            Log4SF.logMessage('ProposalSCXUploadController','verifyTimAccountID',ex.getMessage(),ex,UserInfo.getUserId(),recordID);
        } 
        return null;
    }
    
    public String mergeAccountDetailsToSCX(String xmlStringFromWS) {
        isThirdParty = true;
        xmlString = '';
        xmlString = xmlStringFromWS.replace('\'', '\"');
        xmlString = xmlString.unescapeHtml4();        
        xmlParser();
        mergeOpp();
        return xmlString;
    }

    /*
    Method for merging Account information to the SCX
    */
    public void  mergeOpp() {
        String oppAgencyName;
        String uploadedFileUpdate = '',mergeStr = '',lastPart = '';
        isMerge = true;
        
        try {
            //agencyName = oppAgency;
            
            if(isMerge  && String.IsNotEmpty(xmlString))
            {
                System.debug(' ### xmlString ::::::: ' +xmlString);
                xmlString = xmlString.unescapeHtml4();
                /* 
                xmlString = xmlString.normalizeSpace();
                xmlString = xmlString.replaceAll('\\t','');
                xmlString = xmlString.replaceAll('\\r','');
                xmlString = xmlString.replaceAll('\\n','');
                */
                xmlString = xmlString.normalizeSpace();
                xmlString = xmlString.replace('> <', '><');
                uploadedFileUpdate = xmlString;
                
                System.debug('advName::'+advName);
                //Replace Advertiser
                if(String.isNotBlank(advName)){
                    // xmlString = xmlString.replace(advName,System.Label.Dummy_SCX_advertiser.replace('&','&amp;'));   // Commented by bhuvan on 21-Nov-2018
                    // xmlString = xmlString.replace('<advertiser><name>' + advName + '</name>', '<advertiser><name>' + System.Label.Dummy_SCX_advertiser.replace('&','&amp;') + '</name>');             
                    String advertiserSubString = xmlString.substringBetween('<advertiser><name>','</name>');
                    String replacedAdvString = '';
                    if( String.isNotBlank(advertiserSubString) && advertiserSubString.ContainsIgnoreCase('CDATA')) {
                        replacedAdvString = '<![CDATA[' + Label.Dummy_SCX_advertiser.replace('&','&amp;') + ']]>';
                    }
                    else replacedAdvString = Label.Dummy_SCX_advertiser.replace('&','&amp;');

                    xmlString = xmlString.replace('<advertiser><name>' + advertiserSubString + '</name>', '<advertiser><name>' + replacedAdvString + '</name>');
                }
                else if(String.isBlank(Label.Dummy_SCX_advertiser) && String.isNotBlank(advName))
                {
                    xmlString = xmlString.replace(advName,'0');               
                }
                else if(String.isBlank(advName))
                {
                    uploadedFileUpdate = xmlString;
                    mergeStr = xmlString.substring(0,xmlString.indexOf('<advertiser>'));
                    uploadedFileUpdate = xmlString.substring(xmlString.indexOf('<advertiser>'),xmlString.length());
                    if(uploadedFileUpdate.indexOf('</name>') > 0)
                    {
                        lastPart = uploadedFileUpdate.substring(0,uploadedFileUpdate.indexOf('</name>'));
                        /*lastPart = lastPart.replaceAll('\\t','');
                        lastPart = lastPart.replaceAll('\\r','');
                        lastPart = lastPart.replaceAll('\\n','');*/
                        lastPart = lastPart.normalizeSpace();                        
                        uploadedFileUpdate = uploadedFileUpdate.substring(uploadedFileUpdate.indexOf('</name>'),uploadedFileUpdate.length());
                    }
                    else if(uploadedFileUpdate.indexOf('<name/>') > 0)
                    {
                        lastPart = uploadedFileUpdate.substring(0,uploadedFileUpdate.indexOf('<name/>')).replace('<name/>','<name>'+Label.Dummy_SCX_advertiser.replace('&','&amp;') + '</name>');
                        /*lastPart = lastPart.replaceAll('\\t','');
                        lastPart = lastPart.replaceAll('\\r','');
                        lastPart = lastPart.replaceAll('\\n','');*/
                        lastPart = lastPart.normalizeSpace();
                        uploadedFileUpdate = uploadedFileUpdate.substring(uploadedFileUpdate.indexOf('<name/>'),uploadedFileUpdate.length());
                    }
                    System.debug(' ### lastPart Advertiser ::: ' +lastPart);
                  
                    if(String.isBlank(Label.Dummy_SCX_advertiser))
                        xmlString = mergeStr.replaceAll('\\n','').replace('\\r','')+ lastPart+'0'+ uploadedFileUpdate;
                    else
                        xmlString = mergeStr.replaceAll('\\n','').replace('\\r','')+ lastPart +Label.Dummy_SCX_advertiser.replace('&','&amp;')+ uploadedFileUpdate.replaceAll('\\n','').replace('\\r','');
                }               

                //Replace Agency
                if(String.isNotBlank(Label.Dummy_SCX_agency) && String.isNotBlank(agencyName) && !isRepFirm){

                    // xmlString = xmlString.replace(agencyName,Label.Dummy_SCX_agency.replace('&','&amp;')); // Commented by bhuvan on 21-Nov-2018
                    // xmlString = xmlString.replace('<company type="Agency"><name>' + agencyName + '</name>', '<company type="Agency"><name>' + System.Label.Dummy_SCX_agency.replace('&','&amp;') + '</name>');

                    String agencySubString = xmlString.substringBetween(agencyTag+'<name>','</name>');
                    System.debug(' #### agencySubString ::: ' +agencySubString);
                    String replacedAgencyString = '';
                    if(String.isNotBlank(agencySubString) && agencySubString.ContainsIgnoreCase('CDATA')) {
                        replacedAgencyString = '<![CDATA[' + Label.Dummy_SCX_agency.replace('&','&amp;') + ']]>';
                    }
                    else replacedAgencyString = Label.Dummy_SCX_agency.replace('&','&amp;');

                    xmlString = xmlString.replace( agencyTag+'<name>' + agencySubString + '</name>', agencyTag+'<name>' + replacedAgencyString + '</name>');
                }
                else if(String.isBlank(Label.Dummy_SCX_agency) && String.isNotBlank(agencyName) && !isRepFirm)
                {
                    xmlString = xmlString.replace(agencyName,'0');
                }
                else if(isRepFirm)
                {
                    System.debug(' ### repAgency ::: ' +repAgency + ' ### agencyName :::: ' +agencyName);
                    System.debug(' @@@ String.isNotBlank(repAgency) ::: ' +String.isNotBlank(repAgency));
                    // repAgency is equal to agency name when repfirm is also included in the SCX file.
                    // xmlString = String.isNotBlank(repAgency) ? xmlString.replace(repAgency,Label.Dummy_SCX_agency.replace('&','&amp;')) : xmlString;

                    // Changes by bhuvan - SRSF-1488 START
                    if(String.isNotBlank(repAgency)) {
                        // xmlString = xmlString.replace(repAgency,Label.Dummy_SCX_agency.replace('&','&amp;')); // commented by bhuvan on 23/11/2018
                        String agencySubString = xmlString.substringBetween(agencyTag+'<name>','</name>');
                        System.debug(' #### agencySubString ::: ' +agencySubString);
                        String replacedAgencyString = '';
                        if(String.isNotBlank(agencySubString) && agencySubString.ContainsIgnoreCase('CDATA')) {
                            replacedAgencyString = '<![CDATA[' + Label.Dummy_SCX_agency.replace('&','&amp;') + ']]>';
                        }
                        else replacedAgencyString = Label.Dummy_SCX_agency.replace('&','&amp;');

                        xmlString = xmlString.replace( agencyTag+'<name>' + agencySubString + '</name>', agencyTag+'<name>' + replacedAgencyString + '</name>');
                    }
                    else {
                        uploadedFileUpdate = xmlString;
                        mergeStr = xmlString.substring(0,xmlString.indexOf(agencyTag));
                        uploadedFileUpdate = xmlString.substring(xmlString.indexOf(agencyTag),xmlString.length());
                        if(uploadedFileUpdate.indexOf('</name>') > 0)
                        {
                            lastPart = uploadedFileUpdate.substring(0,uploadedFileUpdate.indexOf('</name>'));
                            /*lastPart = lastPart.replaceAll('\\t','');
                            lastPart = lastPart.replaceAll('\\r','');
                            lastPart = lastPart.replaceAll('\\n','');*/
                            lastPart = lastPart.normalizeSpace();                            
                            uploadedFileUpdate = uploadedFileUpdate.substring(uploadedFileUpdate.indexOf('</name>'),uploadedFileUpdate.length());
                        }
                        else if(uploadedFileUpdate.indexOf('<name/>') > 0)
                        {
                            lastPart = uploadedFileUpdate.substring(0,uploadedFileUpdate.indexOf('<name/>')).replace('<name/>','<name>'+Label.Dummy_SCX_agency.replace('&','&amp;') + '</name>');
                            /*lastPart = lastPart.replaceAll('\\t','');
                            lastPart = lastPart.replaceAll('\\r','');
                            lastPart = lastPart.replaceAll('\\n','');*/
                            lastPart = lastPart.normalizeSpace();
                            //System.debug('@@@ lastPart else' +lastPart);
                            uploadedFileUpdate = uploadedFileUpdate.substring(uploadedFileUpdate.indexOf('<name/>'),uploadedFileUpdate.length());
                            //.replace('<name/>','<desc>'+name.replace('&','&amp;') + '</desc>');
                        }
                        System.debug(' ### oppAgency ::: ' +oppAgency + ' ### lastPart :::: ' +lastPart);
                        if(String.isBlank(oppAgency))
                            xmlString = mergeStr.replaceAll('\\n','').replace('\\r','')+ lastPart+'0'+ uploadedFileUpdate;
                        else
                            xmlString = mergeStr.replaceAll('\\n','').replace('\\r','')+ lastPart +Label.Dummy_SCX_agency.replace('&','&amp;')+ uploadedFileUpdate.replaceAll('\\n','').replace('\\r','');
                    }
                    // Changes by Bhuvan - SRSF-1488 END
                    xmlString = xmlString.replace('<name>' + agencyName + '</name>','<name>' + Label.Dummy_SCX_agency.replace('&','&amp;') + '</name>');                    
                }
                else if(String.isBlank(agencyName))
                {
                    uploadedFileUpdate = xmlString;
                    mergeStr = xmlString.substring(0,xmlString.indexOf(agencyTag));
                    uploadedFileUpdate = xmlString.substring(xmlString.indexOf(agencyTag),xmlString.length());
                    if(uploadedFileUpdate.indexOf('</name>') > 0)
                    {
                        lastPart = uploadedFileUpdate.substring(0,uploadedFileUpdate.indexOf('</name>'));
                        /*lastPart = lastPart.replaceAll('\\t','');
                        lastPart = lastPart.replaceAll('\\r','');
                        lastPart = lastPart.replaceAll('\\n','');*/
                        lastPart = lastPart.normalizeSpace();                      
                        uploadedFileUpdate = uploadedFileUpdate.substring(uploadedFileUpdate.indexOf('</name>'),uploadedFileUpdate.length());                        
                    }
                    else if(uploadedFileUpdate.indexOf('<name/>') > 0)
                    {
                        lastPart = uploadedFileUpdate.substring(0,uploadedFileUpdate.indexOf('<name/>')).replace('<name/>','<name>'+Label.Dummy_SCX_agency.replace('&','&amp;') + '</name>');
                        /*lastPart = lastPart.replaceAll('\\t','');
                        lastPart = lastPart.replaceAll('\\r','');
                        lastPart = lastPart.replaceAll('\\n','');*/
                        lastPart = lastPart.normalizeSpace();                    
                        uploadedFileUpdate = uploadedFileUpdate.substring(uploadedFileUpdate.indexOf('<name/>'),uploadedFileUpdate.length());
                        //.replace('<name/>','<desc>'+name.replace('&','&amp;') + '</desc>');                    
                    }
                    System.debug(' ### oppAgency ::: ' +oppAgency + ' ### lastPart :::: ' +lastPart);
                    if(String.isBlank(oppAgency))
                        xmlString = mergeStr.replaceAll('\\n','').replace('\\r','')+ lastPart+'0'+ uploadedFileUpdate;
                    else
                        xmlString = mergeStr.replaceAll('\\n','').replace('\\r','')+ lastPart +Label.Dummy_SCX_agency.replace('&','&amp;')+ uploadedFileUpdate.replaceAll('\\n','').replace('\\r','');
                }
                uploadedFileUpdate = xmlString;               
                advName = opp.Account.Name ; 
                agencyName = oppAgency ;
                name = opp.Name;                
            }
        }
        catch(Exception ex) {
            pageMsg = ex.getMessage();
            System.debug('### exception ::: ' +ex.getMessage() + ' Line Number ::: ' +ex.getLineNumber());
            return;
        }
    }

    /**
     *  Method to Parse the xml Uploaded 
     * 
     * @param  (none) (NA)
     * @return (PageReference) (PageReference)
    */  
    public void xmlParser()
    {
        stepInfo = 2;
        String parser = '';
        advName = name= startDate = endDate = propName ='';
        totalGross = 0;
        // Check the file uploaded is recieved with Data to process
        if(uploadedFile == null && !isThirdParty) 
            pageMsg = 'No Data to process';
        
        
        xmlString = isThirdParty ? xmlString : uploadedFile.tostring();
        // xmlString = EncodingUtil.urlDecode(xmlString, 'UTF-8');
        XmlStreamReader reader = new XmlStreamReader(xmlString);
        boolean isSafeToGetNextXmlElement = true;
        orderList = new  List<ProposalZoneValues>();
        proposalZoneValues proposal;
        try{
            System.debug(' ### cpu time before parsing XML :::: ' +Limits.getCpuTime());
        //to do
        //Parsing of XMl starts
            reader.setCoalescing(true);
            while (isSafeToGetNextXmlElement) 
            {
                // Start at the beginning of the XML 
                if (reader.getEventType() == XmlTag.START_ELEMENT) 
                {
                    if ('advertiser' == reader.getLocalName()) 
                    {
                        advName = getAdvertiser(reader);
                        if(string.isNotBlank(advName) && advName.indexOf('-') > 0)
                        {
                            advCode = advName.split('-')[1];
                        }
                    }
                    if ('estimate' == reader.getLocalName()) 
                    {
                        while(reader.hasNext()) {
                           if (reader.getEventType() == XmlTag.END_ELEMENT) {
                                break;
                           }
                           else if (reader.getEventType() == XmlTag.CHARACTERS) {
                                propName= reader.getText();
                                name= reader.getText();
                           }                          
                           reader.next();
                        }
                    }
                    if ('company' == reader.getLocalName()) 
                    {
                        if(reader.getAttributeCount() > 0)
                        {
                            if(reader.getAttributeValue(null,'type') == 'Rep')
                            {
                                while(reader.hasNext()) {
                                    if (reader.getEventType() == XmlTag.END_ELEMENT)
                                        break;
                        
                                    else if (reader.getEventType() == XmlTag.CHARACTERS)
                                    {                                        
                                        agencyName = reader.getText();
                                        // isRepFirm = true;
                                        isRepFirm = String.isNotBlank(agencyName) ? true : false;
                                    }
                                        
                                   reader.next();
                                }
                            }

                            else if(reader.getAttributeValue(null,'type') == 'Agency')
                            {
                                agencyTag = '<company type="Agency"';
                                /*System.debug('### reader ::: ' +reader);
                                System.debug(' attribute count ::: ' + reader.getAttributeCount());  
                                System.debug(' Entered inside role attribute :::: ' + reader.getAttributeValue(null, 'role'));*/
                                String roleString = reader.getAttributeValue(null, 'role');
                                if(roleString != null) {

                                    /*if(String.isNotBlank(roleString)) {
                                        agencyTag += ' role="' + roleString + '"';
                                    }
                                    else {
                                        agencyTag += ' role=""';
                                    }*/
                                    agencyTag += String.isNotBlank(roleString) ? ' role="' + roleString + '"' : ' role=""';
                                }
                                agencyTag += '>';

                                while(reader.hasNext()) {
                                    if (reader.getEventType() == XmlTag.END_ELEMENT)
                                        break;
                        
                                    else if (reader.getEventType() == XmlTag.CHARACTERS)
                                    {
                                        if(isRepFirm) {
                                            repAgency = reader.getText();
                                        }
                                        else {
                                            agencyName = reader.getText();
                                        } 
                                    }
                                    
                                   reader.next();
                                }
                            }

                            /*if(reader.getAttributeValue(null, 'role') != null) {
                                // agencyTag += 'role="">';
                            }*/
                        }
                    }  
                    if ('startDate' == reader.getLocalName()) 
                    {
                        while(reader.hasNext()) {
                            if (reader.getEventType() == XmlTag.END_ELEMENT)
                                break;
                
                            else if (reader.getEventType() == XmlTag.CHARACTERS)
                                startDate = reader.getText();
                           reader.next();
                        }  
                    }  
                    if ('endDate' == reader.getLocalName()) 
                    {
                        while(reader.hasNext()) {
                           if (reader.getEventType() == XmlTag.END_ELEMENT)
                                break;
                
                           else if (reader.getEventType() == XmlTag.CHARACTERS)
                                endDate = reader.getText();
                           reader.next();
                        }  
                    }  
                    
                      
                   if ('market' == reader.getLocalName()) 
                    {
                        try{
                            reader.next();
                            reader.next();
                            reader.next();
                            marketName = reader.getText();   
                            reader.next();
                        }
                        catch(exception ex)
                        {
                            System.debug('@@ Market' +  ex.getMessage() +  marketName);
                        }              
                    }                    
                        
                    if ('systemOrder' == reader.getLocalName()) 
                    {
                        proposal = new proposalZoneValues();
                        while(reader.hasNext()) {
                            if (reader.getEventType() == XmlTag.END_ELEMENT) {
                                break;
                            }
                            else if (reader.getEventType() == XmlTag.START_ELEMENT && 'systemOrder' == reader.getLocalName()) {
                                proposal.market = marketName;
                                orderList.add(getOrder(reader,proposal));
                            }
                            reader.next();
                        }
                    }      
                }
                if (reader.hasNext()) {
                    // System.debug(' ### cpu time after parsing XML :::: ' +Limits.getCpuTime());
                    try{
                        // System.debug(' ### reader event type ::: '+reader.getEventType() + ' ### next :::: ' +reader.next());
                        reader.next();
                    }
                    catch(XmlException ex) {
                        System.debug(' XmlException :::: '+ex);
                        isSafeToGetNextXmlElement = false;
                        break;
                    }
                    catch(Exception ex) {
                        System.debug(' Exception :::: '+ex.getMessage()+ 'at line Number::'+ex.getLineNumber());
                    }
                } else {
                    isSafeToGetNextXmlElement = false;
                    break;
                }    
            }
            for(proposalZoneValues prop : orderList)
            {
                totalGross += Decimal.valueOf(prop.grossAmount);
            }
        }
        catch(exception ex)
        {
          //  pageMsg = System.Label.Custom_Error_SCX_Upload; // Comment by Sridhar: 08-01-2020 : To show user friendly error
            pageMsg = 'Error occured during XML parsing ::'+ ex.getMessage(); // Sridhar: 08-01-2020 : Showing actual error message
            System.debug(' ### exception ::: ' +ex.getMessage() + ' line Number ::: ' +ex.getLineNumber());
            Log4SF.logMessage('ProposalSCXUploadController','xmlParser',ex.getMessage(),ex,UserInfo.getUserId(),recordID);
        }
    }
        /**
     * Getting the advertiser details from the XML 
     * 
     * @param  (none) (NA)
     * @return (String) (Advertiser Name)
    */  
   public String getAdvertiser(XMLStreamReader reader)
   {
    
          while(reader.hasNext()) {
           if (reader.getEventType() == XmlTag.END_ELEMENT) {
                break;
           }
           else if (reader.getEventType() == XmlTag.CHARACTERS) {
                advName = reader.getText();
                //Uncomment to throw error if advertiser does not exist in SCX
                //if(String.isBlank(advName))
                //pageMsg = 'Advertiser does not exit in SCX.';
           }
           reader.next();
          }
          return advName;
   }
 
    /**
     * Traversing the order details from the XML 
     * 
     * @param  (none) (NA)
     * @return (proposalZoneValues) (Wrapper Class for all proposal lines)
    */  
  public proposalZoneValues getOrder(XMLStreamReader reader, proposalZoneValues proposal)
   {
        boolean isSafeToGetNextXmlElement = true;
       
        while(isSafeToGetNextXmlElement) {
            if ('system' == reader.getLocalName()) 
            {
                while(reader.hasNext()) {
                    if (reader.getEventType() == XmlTag.END_ELEMENT) {
                        break;
                    }
                    else if (reader.getEventType() == XmlTag.CHARACTERS) {
                        proposal.zone = reader.getText();
                    }
                    reader.next();
                }
            }
            if ('syscode' == reader.getLocalName()) 
            {
                if (reader.getEventType() == XmlTag.START_ELEMENT) {
                    reader.next();
                    proposal.sysCode = reader.getText();
                    propSysCode = reader.getText();
                }
            }
            if ('spotCost' == reader.getLocalName()) 
            {
                if (reader.getEventType() == XmlTag.START_ELEMENT) {
                    reader.next();
                    if( reader.getText() != '')
                        hasDetailLine = true;
                }
            }
            if ('cost' == reader.getLocalName()) 
            {
                if (reader.getEventType() == XmlTag.START_ELEMENT) {
                    reader.next();
                    proposal.grossAmount = reader.getText();
                    break;
                }
            
                if (reader.getEventType() == XmlTag.END_ELEMENT) {
                     break;
                }
            }
            if (reader.getEventType() == XmlTag.END_ELEMENT && 'systemOrder' == reader.getLocalName()) 
            {    
                break;
            }
            
            if (reader.hasNext()) {
                reader.next();
            } else {
                isSafeToGetNextXmlElement = false;
                break;
            }
             
        }
        return proposal;     
   } 

   // Wrapper Class to showcase the data for orders 
   public class proposalZoneValues
   {
    public String zone{get;set;}
    // public string netAmount{get;set;}
    public String grossAmount{get;set;}
    public String sysCode{get;set;}
    public String market{get;set;}
   
   public proposalZoneValues()
   {
   }
       /*public proposalZoneValues(string zone,string grossAmount, string netAmount, string market, string sysCode)
       {
        zone = this.zone;
        market = this.market;
        netAmount = this.netAmount;
        grossAmount = this.grossAmount;
        sysCode = this.sysCode;
       }*/
   }
   
   // Calling Tim Service at this step.
   public void timServiceCall()
   {
        
        try
        {
         // Before Sending request to Tim, merge the Proposal Name value entered by the user on SCX.
            String uploadedFileUpdate = '',mergeStr = '',lastPart = '';
            System.debug('isMerge::'+isMerge);
            System.debug('xmlString::'+xmlString);
            System.debug(' @@ propName'+ propName.trim() + ' #### name :::'+name);
            System.debug('### selectedRateCard ::: '+selectedRateCard);
            if(name.length() > 50) name = name.substring(0,50);

            if(String.isNotBlank(name) && !name.equalsIgnoreCase(propName.trim()) && String.isNotBlank(propName) )
            {
                 xmlString = xmlString.replace(propName,name.replace('&','&amp;'));
            }
            else if(String.isBlank(propName) && xmlString.indexOf('<desc></desc>') > 0 )
            {
                xmlString = xmlString.replace('<desc></desc>','<desc>'+name.replace('&','&amp;') + '</desc>');
            }
            else if(String.isBlank(propName) && xmlString.indexOf('<desc/>') > 0 )
            {
                xmlString = xmlString.replace('<desc/>','<desc>'+name.replace('&','&amp;') + '</desc>');
            }
        
            else if(isMerge && !name.equalsIgnoreCase(propName.trim()))
            {   
                uploadedFileUpdate = '';
                mergeStr = lastPart = '';
                uploadedFileUpdate = xmlString;
                mergeStr = xmlString.substring(0,xmlString.indexOf('<estimate>'));
             
                uploadedFileUpdate = xmlString.substring(xmlString.indexOf('<estimate>'),xmlString.length()).unescapeHtml4();
             
                lastPart = uploadedFileUpdate.substring(0,uploadedFileUpdate.indexOf('<desc/>'));
             
                uploadedFileUpdate = uploadedFileUpdate.substring(uploadedFileUpdate.indexOf('<desc/>'),uploadedFileUpdate.length()).unescapeHtml4();
                xmlString = mergeStr.unescapeHtml4().replaceAll('\\n','').replace('\\r','')+ lastPart.unescapeHtml4() +name.replace('&','&amp;')+ uploadedFileUpdate.unescapeHtml4().replaceAll('\\n','').replace('\\r','');
            }
         //Merge End   
            HttpResponse httpRes;
            BoomiWebServiceHelper boomi = new BoomiWebServiceHelper(userCon[0]);
            boomi.isFrmSCXUpload = true;
            
            
            // Get the opp agency account details 
            List<AccountConnection__c> agcCon = new List<AccountConnection__c>();
            Set<String> agencyTimIdSet = new Set<String>();
            List<String> parameters = new List<String>();
            try
            {
                // Code Changes for SRSF-1097
                /*if(opp.Agency_Account__c != null)
                {
                parameters.add(' Agency-' + opp.Agency_Account__r.Name );
                agcCon = [Select ID,AgencyTIMId__c from AccountConnection__c where Tim_System__c =: userCon[0].Tim_System__c and AgencyTIMId__c != null and AgencyTIMId__c != '0' and Account__c= :opp.Agency_Account__c LIMIT 1];
                }
                else if(opp.Rep_Firm__c != null)
                {
                parameters.add(' Rep Firm -' + opp.Rep_Firm__r.Name );
                agcCon = [Select ID,AgencyTIMId__c from AccountConnection__c where Tim_System__c =: userCon[0].Tim_System__c and AgencyTIMId__c != null and AgencyTIMId__c != '0' and Account__c= :opp.Rep_Firm__c LIMIT 1];
                }*/ 

                if(opp.Rep_Firm__c != null)
                {
                    parameters.add(' Rep Firm -' + opp.Rep_Firm__r.Name );
                    agcCon = [SELECT ID,AgencyTIMId__c FROM AccountConnection__c WHERE Tim_System__c =: userCon[0].Tim_System__c AND AgencyTIMId__c != null AND AgencyTIMId__c != '0' AND Account__c= :opp.Rep_Firm__c ]; // LIMIT 1
                    if(agcCon.size() > 0) {
                        // To get all the Agency TIM Ids..
                        for(AccountConnection__c agencyConn : agcCon) {
                            agencyTimIdSet.add(agencyConn.AgencyTIMId__c);
                        }
                    }

                }
                else if(opp.Agency_Account__c != null)
                {
                    parameters.add(' Agency-' + opp.Agency_Account__r.Name );
                    agcCon = [SELECT ID,AgencyTIMId__c FROM AccountConnection__c WHERE Tim_System__c =: userCon[0].Tim_System__c AND AgencyTIMId__c != null AND AgencyTIMId__c != '0' AND Account__c= :opp.Agency_Account__c]; //  LIMIT 1
                    if(agcCon.size() > 0) {
                        // To get all the Agency TIM Ids..
                        for(AccountConnection__c agencyConn : agcCon) {
                            agencyTimIdSet.add(agencyConn.AgencyTIMId__c);
                        }
                    }
                }
                else
                {
                    agcCon.add(new AccountConnection__c(AgencyTimID__c = '0'));
                }
                //Check for Agency Account Connection validity
                if((agcCon.size() == 0 || String.isEmpty(agcCon[0].AgencyTIMId__c)) && (String.isNotEmpty(opp.Agency_Account__c) || String.isNotEmpty(opp.Rep_Firm__c)))
                {
                    parameters.add(' Agency/Rep Firm ');
                    
                    // if(label.EnableAccountConnectionCreate.equalsIgnoreCase('true')){
                    if(cmnSetting.Condition_Enable__C){
                        // Changes START for SRSF-1300
                        verifyTimAccountID();
                        if(accResponseMap.size()>0 && accResponseMap.values()[0].contains('Error')){
                            pageMsg = accResponseMap.values()[0];
                            return;
                        }
                        pageMsg = BoomiWebServiceHelper.isAccConnectionCreated ? Label.SCX_Account_Connection_Created : Label.SCX_Account_Connection_Create_Error;
                        // Changes END
                    }
                    else
                        pageMsg  = String.format(Label.SCX_Account_Connection_Error, parameters);    

                    return;
                }
              
            }
            catch(Exception ex)
            {
                parameters.add(' Agency/Rep Firm ');
                pageMsg  = String.format(Label.SCX_Account_Connection_Error, parameters);
                return;
            }

            
            System.debug(' ### agency account connection size ::: ' +agcCon.size());
            System.debug(' ### agencyTimIdSet ::: ' +agencyTimIdSet);
            // Get the opp advertiser account details 
            List<AccountConnection__c> advCon = new List<AccountConnection__c>();
            try
            {
                if(opp.AccountID != null && String.isNotEmpty(userCon[0].Tim_System__c))
                {
                    System.debug(' @@@@ agencyTimIdSet size :::: ' +agencyTimIdSet.size());
                    if(agencyTimIdSet.size() == 0) {
                        System.debug(' ===== No agencyTimId ======= ');
                        advCon = [SELECT Id,Tim_ID__c, AgencyTIMId__c, AE_ID__c, Tim_System__c FROM AccountConnection__c WHERE Tim_System__c =: userCon[0].Tim_System__c AND AE_ID__c =: userCon[0].AE_ID__c AND Account__c= :opp.AccountID AND AgencyTIMId__c = null LIMIT 1];
                    }
                    else {
                        System.debug(' ===== with agencyTimId ======= ');
                        advCon = [SELECT Id,Tim_ID__c, AgencyTIMId__c, AE_ID__c, Tim_System__c FROM AccountConnection__c WHERE Tim_System__c =: userCon[0].Tim_System__c AND AE_ID__c =: userCon[0].AE_ID__c AND Account__c= :opp.AccountID AND AgencyTIMId__c IN :agencyTimIdSet];
                    }

                    System.debug(' ### advertiser account connection ::: ' +advCon.size());
                }
                else if(String.isEmpty(userCon[0].Tim_System__c))
                {
                    pageMsg  = Label.SCX_Opp_Tim_System_Error;
                    return;
                }
            }
            catch(Exception ex)
            {
                parameters.add(' Advertiser-' + opp.Account.Name );
                pageMsg  = String.format(Label.SCX_Account_Connection_Error, parameters);

                return;
            }
            //Check for Advertiser Account Connection validity
            if(advCon.size() == 0)
            {
              parameters.add(' Advertiser-' + opp.Account.Name );
              
              // if(label.EnableAccountConnectionCreate.equalsIgnoreCase('true')){
                if(cmnSetting.Condition_Enable__C){
                  // Changes for SRSF-1300 START
                    verifyTimAccountID();
                    System.debug(' ### BoomiWebServiceHelper.isAccConnectionCreated ::: ' +BoomiWebServiceHelper.isAccConnectionCreated);
                    if(accResponseMap.size()>0 && accResponseMap.values()[0].contains('Error')){
                        pageMsg = accResponseMap.values()[0];
                        return;
                    }
                    pageMsg = BoomiWebServiceHelper.isAccConnectionCreated ? Label.SCX_Account_Connection_Created : Label.SCX_Account_Connection_Create_Error;
                  // Changes for SRSF-1300 END
                }
                else
                    pageMsg  = String.format(Label.SCX_Account_Connection_Error, parameters);  
                return;

            }
            parameters.clear();           
            
            if(String.IsNotEmpty(xmlString)) {
                System.debug(' $$$ Executing import SCX process ::: ');
                httpRes = boomi.importSCX(xmlString,userCon[0].Tim_System__c,userCon[0].AE_Id__c,advCon[0].Tim_ID__c,agcCon[0].AgencyTIMId__c,selectedRateCard);
            }

            Boolean hasErrors = false;
            System.debug('### httpRes ::: '+httpRes.getBody());
            Response res = parse(httpRes.getBody());
            
            // SRSF-2050 : Added below if condition
            if(res.ImportSCX_Result.HasErrors == 'false')
                 estimateId  =Integer.valueOf(res.ImportSCX_Result.ID);
            // IF estimate ID is greater than 0 then create a Linear Proposal in SF with the same details.    
            System.debug('estimateId%%'+estimateId);
            if(estimateId > 0)
            {
                Proposal__c prop = new Proposal__c();
                if(opp.Account.Name != advName)
                {
                    List<Account> adv = [SELECT Id,Name FROM Account WHERE Name = : advName];
                    if(adv.size() > 0)
                        prop.Advertiser__c = adv[0].Id;
                }
                else prop.Advertiser__c = opp.Account.Id;
                prop.TIM_Id__c = String.valueOf(estimateId);
                if(opp.Agency_Account__r.Name != agencyName)
                {
                    List<Account> agencyList = [SELECT Id,Name FROM Account WHERE Name = : agencyName];
                    if(agencyList.size() > 0)
                    prop.Agency__c = agencyList[0].ID;          
                }
                else prop.Agency__c = opp.Agency_Account__r.Id;
                
                //RecordType linearProposal = [Select id from recordtype where name='Linear' limit 1];
                //prop.RecordTypeId= linearProposal.id;
                prop.Start_Date__c = Date.valueOf(startdate);
                prop.End_Date__c = Date.valueOf(enddate);
                prop.Name = name;
                // prop.TIM_Id__c = string.valueOf(estimateId);
                prop.Opportunity__c = opp.Id;
                // Changes START by bhuvan on 03-July-2018
                prop.TIM_System__c = userCon[0].Tim_System__c;
                prop.AE_ID__c = userCon[0].AE_ID__c;
                prop.Ratecard__c = selectedRateCard;
                prop.Sync_Pending__c = TRUE;
                prop.Sync_Pending_Since__c = System.now();
                // Changes END by bhuvan on 03-July-2018
                 //Code changes to add inventory recordType by Aditi : 2/26/2018
                System.debug('<<<<< proposalSource >>>>>'+proposalSource);
                if(isThirdParty && proposalSource == 'Audience App') {
                     specialRecType = '_INV';
                } 

                String query = 'SELECT Id FROM RecordType WHERE SobjectType =\'Proposal__c\'';

                if(null != specialRecType && specialRecType != ''){
                    // String query = 'Select ID from RecordType where SobjectType =\'Proposal__c\'';
                    if(specialRecType.contains('_INV')){
                        query += ' AND Name = \''+Label.Inventory_RT+'\'';
                    }
                    else if(specialRecType.contains('_PR')){
                        query += ' AND Name = \''+Label.Political_RT+'\'';
                    }
                    else if(specialRecType.contains('_TR')){
                        query += ' AND Name = \''+Label.Trade_RT+'\'';
                    }else if(specialRecType.contains('_LR')){
                        query += ' AND Name = \''+Label.Linear_RT+'\'';
                    }
                   // query += ' limit 1';
                   // RecordType recordType = Database.query(query);
                   // RecordType inventoryProposal = [Select id from recordtype where name='Inventory' limit 1]; 
                   // prop.RecordTypeId = recordType.id;
                }
                else
                {
                    // RecordType defaultRecordType;
                    if(isPoliticalOpp != null && isPoliticalOpp) {
                        query += ' AND Name = \''+Label.Political_RT+'\'';
                        //defaultRecordType = [Select id from recordtype where name='Political' limit 1]; 
                    }
                    else {
                        query += ' AND Name = \''+Label.Linear_RT+'\'';
                        //defaultRecordType = [Select id from recordtype where name='Linear' limit 1]; 
                    }
                    //prop.RecordTypeId = defaultRecordType.id;
                }
                query += ' limit 1';
                System.debug('<<<<< Query formed >>>>>'+query);
                RecordType recordType = Database.query(query);
                prop.RecordTypeId = recordType.Id;
                
                if(String.isNotBlank(proposalSource) && isThirdParty ) {
                    prop.Source__c = proposalSource;
                    prop.Origin__c = proposalSource; // SRSF-1865 
                } else prop.Origin__c = System.Label.Proposal_Origin_SCX_Import; // SRSF-1865 
                //Code changes complete
                if(prop != null)
                {
                   System.debug('prop%%%'+prop);
                    //insert prop;
                    proposal =  prop;
                    complete(prop);
                    //Code changes by Aditi : 4_12_2018
                    //completeAsync(prop,pageMsg ,userCon);
                    //Code changes ends
                }
            }   
            if(res.ImportSCX_Result.HasErrors == 'true' && res.ImportSCX_Result.Errors.Error.size() > 0){
                pageMsg = System.Label.SCX_ErrorFromTim + res.ImportSCX_Result.Errors.Error[0]; // SRSF-2050 : Added custom label
                // SRSF-2050 : Added custom label and below conditions
               /* if(isThirdParty) pageMsg = System.Label.Custom_Error_SCX_Upload; 
                else pageMsg = System.Label.SCX_ErrorFromTim + res.ImportSCX_Result.Errors.Error[0]; */ 
            }
            //else if(estimateId > 0 && !pageMsg.ContainsIgnoreCase('Exception')){
            else if(estimateId > 0){    
                pageMsg +='\n ' + 'Proposal was created successfully. '+ estimateId; 
                System.debug('@@@ PageMsg '+ pageMsg );
            } // && !pageMsg.contains('Error')
        }
        catch(exception e)
        {
         //   pageMsg = System.Label.Custom_Error_SCX_Upload;  // Commented by Sridhar: 08-01-2020 : To show proper Error Message
         //   pageMsg = System.Label.Boomi_Custom_Error +'\n'+'Error::'+ e.getMessage(); // Sridhar: 08-01-2020 : Showing actual error message
          
          //  pageMsg = System.Label.SCX_ErrorFromTim +'\n'+'Error::'+ e.getMessage(); // Sridhar: 08-01-2020 : Showing actual error message
            pageMsg = 'Error::'+ e.getMessage(); // Sridhar: 08-01-2020 : Showing actual error message
           
            System.debug(' ### exception ::: ' +e.getMessage() + ' line Number ::: ' +e.getLineNumber());
            Log4SF.logMessage('ProposalSCXUploadController','timServiceCall',e.getMessage() ,e,UserInfo.getUserId(),recordID); // + '$$$ Response ::: ' +httpRes.getBody()
        }
    }
    /**
     * This methods gets called on Click of Complete Proposal button
     *
     * @return (PageReference) (PageReference for next view)
    */
    public PageReference complete(proposal__c prop)
    {
        try{
            List<Proposal__c> newPropList = new List<Proposal__c>();
            newPropList.add(prop);
            System.debug('newPropList----'+newPropList);
            // If proposal has been created properly, create Proposal Line and Schedules in Salesforce, else display this message on VF page
            String res = boomi.syncProposalLineItems(newPropList.get(0), userCon[0]);        
            
            // If proposal Proposal Line and Schedules have been created in Salesforce, Lock the opportunity record*
            if('Success'.equalsIgnoreCase(res)){
                if(isDeleteOppBudgt) Delete propToDelete;  //Code Added for SRSF-1304        
                return new PageReference('/'+ newPropList.get(0).Id);
            }
            else{
                pageMsg = res;            
                return null;
            }
        }
        catch(Exception ex){
            pageMsg= ex.getMessage();
            return null;
        }
    }


    /**
 * This methods gets called on Click of Complete Proposal button
 *
 * @return (PageReference) (PageReference for next view)
*/
    public PageReference complete()
    {
        try{
            System.debug('propsal--id'+proposal.Id);

            if(null != proposal.Id){
                //List<Proposal__c> newPropList = [Select id , name from Proposal__c where Id =: propId];
                List<Proposal__c> newPropList = new List<Proposal__c>();
                newPropList.add(proposal);
                System.debug('newPropList----'+newPropList);
                /*If proposal has been created properly, create Proposal Line and Schedules in Salesforce, else display this message on VF page*/
                String res = boomi.syncProposalLineItems(newPropList.get(0), userCon[0]);        
                
                /*If proposal Proposal Line and Schedules have been created in Salesforce, Lock the opportunity record*/
                System.debug('res'+res);
                if(res == 'Success'){
                    if(isDeleteOppBudgt) Delete propToDelete;  //Code Added for SRSF-1304                    
                    return new PageReference('/'+ newPropList.get(0).Id);
                }
                else{
                    pageMsg = res;            
                    return null;
                }
            } 
            else{
                pageMsg = Label.SCX_ErrorFromTim + Label.SCX_MissingProposal;
                return null;   
            }
        }
        catch(Exception ex){
            System.debug('Error in Complete Proposal block: ' + ex);
            pageMsg = Label.SCX_ErrorFromTim + ex.getMessage();
            Log4SF.logMessage('ProposalSCXUploadController','complete',ex.getMessage(),ex,UserInfo.getUserId(),recordID);
            return null;
        }
    }

    //to make a future method for complete proposal
    //Code changes by Aditi : 12/4/2018 :to call proposal line item creation async
    /*@future
    public static void completeAsync(Set<Id> propIds, String pageMesg , Set<Id> userIdsCon)
    {
        try{
            /List<Proposal__c> newPropList = new List<Proposal__c>();
            newPropList.add(prop);
            System.debug('newPropList----'+newPropList);/
            /If proposal has been created properly, create Proposal Line and Schedules in Salesforce, else display this message on VF page/
            String res = boomi.syncProposalLineItems(propList.get(0), userCon[0]);   
            //String res = boomi.syncProposalLineItems(newPropList.get(0), userCon[0]);
            /If proposal Proposal Line and Schedules have been created in Salesforce, Lock the opportunity record/
            if(res == 'true'){            
                //return new PageReference('/'+ newPropList.get(0).Id);
                pageMesg ='';
            }
            else{
                pageMesg = System.Label.TIMCreate_Sync_ProposalLineItems_Error; 
                //pageMsg = System.Label.TIMCreate_Sync_ProposalLineItems_Error;            
                //return null;
            }    
        }
        catch(Exception ex){
            System.debug('Error in Complete Proposal block: ' + ex);
             return null;
        }
    }*/
    public class Response {
        public ImportSCX_Result ImportSCX_Result;
    }
   
    public class Errors {
        public List<String> Error;
        public Metadata metadata; //SRSF-2050
    }

    public class Messages {
        public List<String> Message;
    }

   public class Metadata {
        public String executionId;
        public String processName;
        public String executionDate;
        public String timSystem;
    }

    public class ImportSCX_Result {
        public String ID;
        public String HasErrors;
        public Messages Messages;
        public Errors Errors;
        public String proposalID;
    }
    
    public static Response parse(String json) {
        return (Response) System.JSON.deserialize(json, Response.class);
    }

    // SRSF-1779 Changes
    public void getRateCardsForTIM (){ 
        System.debug('TIM System>>>>>>'+userCon[0].Tim_System__c);
        System.debug('propSysCode>>>>>>'+propSysCode); 
        rateCards  = new List<SelectOption>();  
        try{     
            List<RateCard__c> rateCardsList = [SELECT Id,RateCard_Id__c, Name,Syscode__c FROM RateCard__c WHERE TIM_System__c =:userCon[0].Tim_System__c AND Active__c=TRUE];
            if(rateCardsList.size()>0){
                for(RateCard__c rcard: rateCardsList){
                    if(rcard.Syscode__c!=NULL && rcard.Syscode__c.contains(propSysCode.trim()) && String.isNotBlank(propSysCode))  //SRSF-3483 : Added NULL Check
                        rateCards.add(new SelectOption(rcard.Name, rcard.Name));
                }
            } 
            rateCards.sort();
            rateCards.add(0,new SelectOption('--None--', '--None--')); 
         }catch(Exception ex){
            rateCards.add(new SelectOption('--None--', '--None--'));
            System.debug('Error in Get RateCards: ' + ex);
           // pageMsg = Label.RateCards_Not_Found+' for Syscode :'+propSysCode;
            Log4SF.logMessage('ProposalSCXUploadController','getRateCardsForTIM',ex.getMessage(),ex,UserInfo.getUserId(),recordID);
         }
        System.debug('rateCards>>>>>>'+rateCards); 
    }

    public void populateSelectedRateCard(){  
        System.debug('selectedRateCard>>>>>>'+selectedRateCard);
    }
}