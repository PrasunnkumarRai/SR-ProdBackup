public with sharing class OMS_MiddlwareController {

    public static Boolean ThrowException = false;
    public static Boolean OverrideProfile = false;
    public static string PayLoadMessage;
    public static Integer StatusCode {
        get;
        set;
    }
    public static string SubmittedDigOps = '03 Submitted to Digital Ops';
    public static string SubmissionError = '3.1 DC Submission Error';
    public static string DigOpsInProgress = '03 Digital Ops In Progress';
    public static string RevisionSubmitted = '13 Revision Submitted to Digital Ops';
    public static string RevisionInProgress = '13 Digital Ops Revision In Progress';
    public static string RevisionError = '13.1 DC Revision Submission Error';
    public static string MissingCreative = '20 Missing Creative / Instructions';
    public static string FlightDateIsBehindMsg = 'The Flight End Date cannot be less than the Campaign End Date';
    public static string FlightDateIsAheadMsg = 'The Flight End Date cannot be greater than the Campaign End Date';
    public static string NoValidateMsg = 'No Validation Issues';
    public static OMS_Settings__c objOMSSettings;
    public static string payload;
    public static string message;
    public static string OTTExtensionVal = 'OTT Extension';
    private static string SuccessIcon = 'utility:success';
    private static string WarningIcon = 'utility:warning';
    private static string ErrorIcon = 'utility:error';
    private static string SuccessVariant = 'success';
    private static string WarningVariant = 'warning';
    private static string ErrorVariant = 'error';


   


    @AuraEnabled(cacheable = false)
    public static string CheckFlightDates(string id) {


        OMSMiddlewareClass omsClass = new OMSMiddlewareClass();
        omsClass.isValid = true;
        omsClass.Message = NoValidateMsg;

        try {

            // if (Test.isRunningTest()){
            if (ThrowException) {
                throw new DMLException('My DML EXCEPTION');

                // }
            }


            List < Digital_Campaign__c > dc = [SELECT Name, Campaign_End_Date__c, Flight_Dates_Backend__c FROM Digital_Campaign__c WHERE id =: id];

            if (dc.size() > 0) {

                string fligthDates = dc[0].Flight_Dates_Backend__c;
                List < string > fligtEndDateList = OMSHelper.GetListOfFligthEndDates(fligthDates);
                List < Date > fligthEndDateList = OMSHelper.ConvertoDateSorted(fligtEndDateList);

                System.debug('Flight Dates Backend Field Value ' + fligthDates);
                System.debug('Flight Dates Size ' + fligthEndDateList.size());

                if (fligthEndDateList.size() > 0) {

                    for (Date endDate: fligthEndDateList) {
                        System.debug('Flight End Date ' + endDate);
                    }

                    Date campaignEndDateFormat = date.valueof(dc[0].Campaign_End_Date__c);
                    Date maxFlightEndDate = fligthEndDateList[fligthEndDateList.size() - 1];

                    System.debug('Campaign End Date Format ' + campaignEndDateFormat);
                    System.debug('Max FlightEndDate ' + maxFlightEndDate);

                    if (maxFlightEndDate > campaignEndDateFormat) {
                        omsClass.Message = FlightDateIsAheadMsg;
                        omsClass.isValid = false;
                    }

                    if (maxFlightEndDate < campaignEndDateFormat) {
                        omsClass.Message = FlightDateIsBehindMsg;
                        omsClass.isValid = false;
                    }


                }

            } else {

                omsClass.Message = 'Campaign ID cannot be id ' + id + ' cannot be found';
                omsClass.isValid = false;
            }

            System.debug(omsClass.Message);
            return JSON.serialize(omsClass);

        } catch (Exception ex) {

            System.debug(ex.getMessage());

            omsClass.Message = ex.getMessage();
            omsClass.isValid = false;
            return JSON.serialize(omsClass);
        }

    }


    @AuraEnabled(cacheable = false)
    public static Boolean AllowSubmission() {

        String profileName = [SELECT Id, Name FROM Profile WHERE Id =: userinfo.getProfileId()].Name;
        List < OMS_Settings__c > oms = [SELECT id, Name FROM OMS_Settings__c
            WHERE Category__c = 'AllowSubmit'
            AND Name =: profileName LIMIT 1
        ];

        if (oms.size() > 0) {
            return true;
        }

        return false;
    }


    @AuraEnabled(cacheable = false)
    public static Boolean isYisfValid(string id) {

        List < Inventory_Source__c > invSource = [SELECT Id, Campaign_Start_Date__c, Line_Item_Id__c, Impressions__c
            FROM Inventory_Source__c
            WHERE Digital_Campaign__c =: id
            AND Digital_Campaign__r.Streaming_TV_Old_Process__c = false
            AND Digital_Campaign__r.Online_Legacy_Campaign__c = false
            AND Campaign_Start_Date__c < TODAY 
            AND Impressions__c != null AND Line_Item_Id__c = null];

        if (invSource.size() > 0) {
            return false;
        }

        return true;

    }

    //SRSF-3598 Start
    @AuraEnabled(cacheable = false)
    public static Boolean isDateValid(string id) {

        List < Inventory_Source__c > lstInvSource = [Select id,Campaign_Start_Date__c, Campaign_End_Date__c, 
                                                            Digital_Campaign__r.Campaign_Start_Date__c, 
                                                            Digital_Campaign__r.Campaign_End_Date__c 
                                                            FROM Inventory_Source__c
                                                            WHERE Digital_Campaign__c =:id ];

        Boolean isDatesValid = false;
        for(Inventory_Source__c invSource :lstInvSource ){
            if(invSource.Campaign_Start_Date__c == invSource.Digital_Campaign__r.Campaign_Start_Date__c &&
               invSource.Campaign_End_Date__c == invSource.Digital_Campaign__r.Campaign_End_Date__c ){
                   isDatesValid = true;
            }else{
                isDatesValid = false;
                break;
            }
        }
        return isDatesValid;
    }
    //SRSF-3598 End
//3579 start getRecordType
    @AuraEnabled(cacheable = false)
    public static Boolean GetRecordtypeval(string id){ 
        List < Digital_Campaign__c > lstDC = [SELECT Id,Name, RecordType.Name, Max_Pending_Creative_End_Date_Record_St__c, Online_Legacy_Campaign__c FROM Digital_Campaign__c WHERE id =: id ];
        Boolean rctType = false;
        for(Digital_Campaign__c dc:lstDC){
            if(dc.RecordType.Name =='Title in Guide'){
                rctType =true;
            }else{
                rctType =false;
                break;
            }
        }
   
    return rctType;
    }

    @AuraEnabled(cacheable = false)
    public static string validationOMSPayload(string id) {

        OMSMiddlewareClass omsClass = new OMSMiddlewareClass();
        omsClass.isValid = false;
        omsClass.Message = NoValidateMsg;

        try {

            if (ThrowException) {
                CalloutException e = new CalloutException();
                e.setMessage('Test Exception');
                throw e;
            }
            //1st Change
            List < Digital_Campaign__c > lstDC = [SELECT Name, AdsE_Platform_s__c, Status__c, AdsE_Network__c, Rate_Classification__c,
                Owner.FirstName, Owner.LastName, Owner.Email, RecordType.Name, Max_Pending_Creative_End_Date_Record_St__c, Online_Legacy_Campaign__c,
                Is_Freewheel_FF_OTT_Primary__c, Freewheel_FF_OTT_Info__c, IsMakegoodDC__c, Makegood_Reason__c, Max_Trafficked_Creative_End_Date__c FROM Digital_Campaign__c WHERE id =: id
            ];


            if (lstDC.size() > 0) {
                String makeGoodReason = lstDC[0].Makegood_Reason__c;
                String rateClassification = lstDC[0].Rate_Classification__c;
                String rateClassificationMG = System.Label.rateClassificationMG;
                List < String > rateClassificationMGSet = rateClassificationMG.split(',');
                if (lstDC[0].IsMakegoodDC__c == true && !String.isEmpty(makeGoodReason) && !rateClassificationMGSet.contains(rateClassification)) {
                    omsClass.Message = 'Rate Classification must be set when Pushing to Operative';
                    omsClass.Icon = ErrorIcon;
                    omsClass.IconVariant = ErrorVariant;
                    return JSON.serialize(omsClass);

                }

                if (lstDC[0].Online_Legacy_Campaign__c == true) {
                    omsClass.UpdateStatus = false;
                    omsClass.isValid = false;
                    omsClass.Message = 'We cannot push this DC to Operative. The DC should be processed manually';
                    omsClass.Icon = ErrorIcon;
                    omsClass.IconVariant = ErrorVariant;
                    return JSON.serialize(omsClass);
                } else {
                    List < string > validStatus = new List < string > ();
                    if (lstDC[0].RecordType.Name == 'Addressable Display' || lstDC[0].RecordType.Name == 'Addressable Video' || lstDC[0].RecordType.Name == 'Pre-roll Custom' || lstDC[0].RecordType.Name == 'Pre-roll' || lstDC[0].RecordType.Name == 'Display Custom' || lstDC[0].RecordType.Name == 'Display' || lstDC[0].RecordType.Name == 'Title in Guide') {
                        omsClass.UpdateStatus = false;
                        omsClass.isValid = false;
                        validStatus.add(SubmittedDigOps);
                        validStatus.add(SubmissionError);
                        validStatus.add(RevisionSubmitted);
                        validStatus.add(RevisionError);
                        validStatus.add(MissingCreative);
                        if (!validStatus.contains(lstDC[0].status__c)) {
                            omsClass.Message = 'Digital Campaign status must be following status <br />03 Submitted to Digital Ops <br />3.1 DC Submission Error<br/>13 Revision Submitted to Digital Ops<br/>13.1 DC Revision Submission Error<br />20 Missing Creative / Instructions';
                            omsClass.Icon = ErrorIcon;
                            omsClass.IconVariant = ErrorVariant;
                            return JSON.serialize(omsClass);
                        }
                        //SRSF-4089
                        else if ((((
                                lstDC[0].Status__c == MissingCreative && lstDC[0].Max_Trafficked_Creative_End_Date__c != null && (lstDC[0].Max_Pending_Creative_End_Date_Record_St__c == '' ||
                                    lstDC[0].Max_Pending_Creative_End_Date_Record_St__c == 'undefined' ||
                                    lstDC[0].Max_Pending_Creative_End_Date_Record_St__c == null ||
                                    lstDC[0].Max_Pending_Creative_End_Date_Record_St__c == '01 Draft Creative' ||
                                    lstDC[0].Max_Pending_Creative_End_Date_Record_St__c == '00 Abandoned Creative'))))) {
                            omsClass.Message = 'This record is currently in Missing Creative status. It needs to have creative submitted by Sales before the DC can be processed';
                            omsClass.Icon = ErrorIcon;
                            omsClass.IconVariant = ErrorVariant;
                            return JSON.serialize(omsClass);
                        }
                        omsClass.UpdateStatus = false;
                        omsClass.isValid = true;


                    } else {
                        validStatus.add(SubmittedDigOps);
                        validStatus.add(SubmissionError);
                        validStatus.add(RevisionSubmitted);
                        validStatus.add(RevisionError);

                        Digital_Campaign__c dc = lstDC[0];
                        String selectedPlatforms = dc.AdsE_Platform_s__c;

                        omsClass.UpdateStatus = false;
                        omsClass.isValid = false;

                        if (!validStatus.contains(dc.status__c)) {
                            omsClass.Message = 'Digital Campaign status must be following status <br />03 Submitted to Digital Ops <br />3.1 DC Submission Error<br/>13 Revision Submitted to Digital Ops<br/>13.1 DC Revision Submission Error';
                            omsClass.Icon = ErrorIcon;
                            omsClass.IconVariant = ErrorVariant;
                            return JSON.serialize(omsClass);
                        }

                        if (dc.Rate_Classification__c == null) {
                            omsClass.Message = 'Please select a rate classification';
                            omsClass.Icon = ErrorIcon;
                            omsClass.IconVariant = ErrorVariant;
                            return JSON.serialize(omsClass);
                        }

                        if (dc.Is_Freewheel_FF_OTT_Primary__c == false) {
                            if (selectedPlatforms == '' || selectedPlatforms == null) {
                                omsClass.Message = 'There are no platforms selected';
                                omsClass.Icon = ErrorIcon;
                                omsClass.IconVariant = ErrorVariant;
                                return JSON.serialize(omsClass);
                            }
                        }

                        if (!OMSHelper.validateEmail(dc.Owner.Email)) {
                            omsClass.Message = 'The Digital Campaign  Owner ' + dc.Owner.FirstName + ' ' + dc.Owner.LastName +
                                ' has an invalid email address. Please correct the email address ' + dc.Owner.Email;
                            omsClass.Icon = ErrorIcon;
                            omsClass.IconVariant = ErrorVariant;
                            return JSON.serialize(omsClass);
                        }

                        omsClass.UpdateStatus = false;
                        omsClass.isValid = true;

                        System.debug(omsClass.Message);
                    }


                }
            }



        } catch (Exception ex) {

            omsClass.UpdateStatus = false;
            omsClass.isValid = false;
            omsClass.Icon = ErrorIcon;
            omsClass.IconVariant = ErrorVariant;
            omsClass.Message = ex.getMessage();

            System.debug('An error occur ' + omsClass.Message + ex.getCause() + ex.getLineNumber());
        }

        return JSON.serialize(omsClass);

    }



    @AuraEnabled(cacheable = false)
    public static string SendData(string id) {
        System.debug('Id coming in sendData :::: ' + id);


        OMSMiddlewareClass omsClass = new OMSMiddlewareClass();
        omsClass.UpdateNetworks = false;
        System.debug('DCC id::' + id);

        try {
            List < User > lstUser = [SELECT id, Profile.name from User where id =: Userinfo.getUserId()];
            String strProfileName = '';

            if (lstUser != null && !lstUser.isEmpty()) {
                strProfileName = lstUser[0].Profile.name;
            }

            if (Test.isRunningTest()) {
                if (OverrideProfile) {
                    strProfileName = 'Profile X';
                }

                if (ThrowException) {
                    CalloutException e = new CalloutException();
                    e.setMessage('This is a constructed exception for testing and code coverage');
                    throw e;
                }
            }


            if (!getMasterDigOpsUser().contains(strProfileName)) {
                omsClass.Message = 'Only Master - Digital Operations users are allowed to push the data to Operative';
                omsClass.isValid = false;
                return JSON.serialize(omsClass);
            }


            List < Digital_Campaign__c > dcList = [SELECT id,
                Name,
                RecordTypeId, RecordType.Name,
                Status__c,
                Advertiser__c, Advertiser__r.Name,
                Agency__c, Agency__r.Name,
                Rep_Firm_Text__c, Opportunity__r.Rep_Firm__c,
                Product_Type__c,
                Content_Type__c,
                Program_Type__c,
                Season__c,
                Episode__c,                  //Tig Changes
                Live_In_Telecast__c,
                Day_of_Week__c,
                Advanced_Customizations__c,
                TIG_Network__c,
                /*SRSF - 4523 Adding Eclipse ID */   
                Eclipse_Customer_ID__c,   
                /*SRSF - 4523 Adding Eclipse ID     */                        
                Product_Vendor__c,
                Digital_Campaign_ID__c,
                TIM_ID__c,
                Campaign_Name__c,
                Campaign_Start_Date__c, Campaign_End_Date__c,
                Total_Impressions__c,
                Gross_CPM1__c,
                Gross_CPM__c,
                Rate_Classification__c,
                VAST_Tag__c,
                AdsE_Platform_s__c,
                Kids_Network_Exclusion__c,
                Tune_In_Exclusions__c,
                AdsE_Network__c,
                AdsE_Genre_s__c,
                DMAs__c,
                OwnerId, Owner.LastName, Owner.FirstName, Owner.Email,
                Sales_Office__c,
                LastModifiedById, LastModifiedBy.Name,
                CustomZipCode__c, Zip_Codes__c,
                State__c,
                Spectrum_Reach_Zones__c,
                Proposal__c,
                Opportunity__r.Enterprise_Account_Type__c,
                Proposal__r.TIM_System__c,
                Proposal__r.Traffic_Order_Number__c,
                Advertiser__r.Political_Account__c,
                Is_Freewheel_FF_OTT_Primary__c,
                Streaming_TV_Old_Process__c,
                Online_Legacy_Campaign__c,
                Preemptable__c,
                Time_Zones__c,
                Frequency_Cap__c,
                Exclude_Networks__c,
                Pilot_Order_ID__c,
                AudienceTrak_Proposal_ID__c,
                Gross_Campaign_Cost__c,
                Makegood_Campaign_CPM__c,
                Makegood_Impressions__c,
                News_Network_Exclusions__c,
                Makegood_CPM__c,
                Data_Catalog__c,
                Export_Key_Logic__c,
                TIG_Activated__c,
                Advanced_Reporting__c,
                Audience_Profile__c,
                Source__c,
                createdbyid,  //Add createdbyid for boomi integeration users SRSF-4473
                Operative_Sales_Order_Hyperlink__c, Efficiency_Packages__c, Full_Avail_Campaign__c, Device_Exclusions__c, Max_Trafficked_Creative_End_Date__c,
                (select id, Audience__c, Campaign_Start_Date__c, Campaign_End_Date__c, COST_Gross__c, CPM_Gross__c,
                    Digital_Campaign__c, Error_Message__c, Geo_Target_Type__c, Impressions__c, Industry__c,
                    Inventory_Resource_Type__c, Name, Line_Item_Id__c, Notes__c, SFDC_DC_Type__c, Exclusions__c from Inventory_Sources__r)
                FROM Digital_Campaign__c WHERE id =: id
            ];

            System.debug('digitalCampaignList ::: ' + dcList);
            System.debug('Total_Impressions__c listsfjsfdja ::::' + dcList[0].Total_Impressions__c);
            System.debug('Size ' + dcList.size());

            if (dcList.size() > 0) {

                Digital_Campaign__c dc = dcList[0];
                 System.debug('dc'+dc);
                String selectedNetworks = dc.AdsE_Network__c;

                if (selectedNetworks != null) {

                    List < String > lstSelectedNetworks = selectedNetworks.split(';');

                    OMS_NetworkValidationClass networkvalidation = OMSHelper.getInvalidNetworks(lstSelectedNetworks);

                    if (!networkvalidation.isValid) {

                        System.debug('Old AdsE_Network__c: ' + dc.AdsE_Network__c);

                        List < string > newValidNetworks = OMSHelper.validNetworks(networkvalidation, lstSelectedNetworks);

                        dc.AdsE_Network__c = String.join(newValidNetworks, ';');

                        System.debug('New AdsE_Network__c: ' + dc.AdsE_Network__c);

                        lstSelectedNetworks = newValidNetworks;
                    }

                    omsClass.UpdateNetworks = (!networkvalidation.isValid);
                }

                /*
                String selectedPlatforms = dc.AdsE_Platform_s__c;
                List<string> invalidNetworksByGenre = OMSHelper.getInvalidNetworksBysGenre(dc);

                if (invalidNetworksByGenre.size() > 1){

                    List<string> newValidNetworks = OMSHelper.getCleanInvalidNetworks(invalidNetworksByGenre, lstSelectedNetworks);
                        dc.AdsE_Network__c = String.join(newValidNetworks, ';');
                }
                */

                omsClass = CallOut(dc);

                //|| invalidNetworksByGenre.size() > 0);

            } else {

                omsClass.UpdateStatus = false;
                omsClass.isValid = false;
                omsClass.Message = 'Digital Campaign is not found';
                omsClass.Icon = ErrorIcon;
                omsClass.IconVariant = ErrorVariant;
            }

        } catch (Exception ex) {

            omsClass.UpdateNetworks = false;
            omsClass.UpdateStatus = true;
            omsClass.isValid = false;
            omsClass.Message = 'Error..\n\nPlease find below details for additional reference.\n\nException Type: ' + ex.getMessage() + '\n' + 'Class Name: OMS_MiddlwareController\nMethod Name: SendData\nLine Number: ' + ex.getLineNumber();
            omsClass.Icon = ErrorIcon;
            omsClass.IconVariant = ErrorVariant;

            VRFCallOuts.SendEmailMessageToAdmins('Sending to OMS ', ex.getMessage() + '\n\n' + 'Class Name: OMS_MiddlwareController\nMethod Name: SendData\nLine Number: ' + ex.getLineNumber() + ', Payload\n\n' + payload);

            return JSON.serialize(omsClass);
        }

        return JSON.serialize(omsClass);
    }

    @AuraEnabled(cacheable = false)
    public static void UpdateNetwork(string id) {

        System.debug('Update Network');

        List < Digital_Campaign__c > dcList = [SELECT id,
            Name,
            AdsE_Network__c,
            AdsE_Genre_s__c
            FROM Digital_Campaign__c
            WHERE id =: id
        ];

        if (dcList.size() > 0) {

            Digital_Campaign__c dc = dcList[0];


            List < String > lstSelectedNetworks = dc.AdsE_Network__c.split(';');

            OMS_NetworkValidationClass networkvalidation = OMSHelper.getInvalidNetworks(lstSelectedNetworks);

            List < string > newValidNetworks = OMSHelper.validNetworks(networkvalidation, lstSelectedNetworks);

            //TODO : Genre Update
            /*  List<string> invalidNetworkByGenre = OMSHelper.getInvalidNetworksBysGenre(dc);

            if (invalidNetworkByGenre.size() > 1){
                newValidNetworks =  OMSHelper.getCleanInvalidNetworks(invalidNetworkByGenre, newValidNetworks);
            }*/

            dc.AdsE_Network__c = String.join(newValidNetworks, ';');

            update dc;

            String dcName = dc.Name;

            NotifyGroupOnNetworks(dcName, networkvalidation); //, invalidNetworkByGenre);
        }

        System.debug('Update Network End');

    }

    //TODO : Genre Update
    @TestVisible
    private static void NotifyGroupOnNetworks(string dcName, OMS_NetworkValidationClass networkValidation) { //, List<string> invalidNetworksByGenreList){

        String InvalidNetworks = String.join(networkvalidation.InvalidNetworks, ';');
        String InActiveNetworks = String.join(networkvalidation.InActiveNetworks, ';');
        String InActiveNetworksLogs = String.join(networkvalidation.InActiveNetworksLog, ';');

        System.debug('Invalid Networks ' + InvalidNetworks);
        System.debug('InActive Networks ' + InActiveNetworks);
        System.debug('InActive Network Logs ' + InActiveNetworksLogs);

        String emailBody = dcName + ' is submitted with the following updates ' + '\n\n' +
            'Remove inActive networks ' +
            '\n' + InActiveNetworksLogs + '\n\n' +
            'Remove invalid networks ' +
            '\n' + InvalidNetworks;

        //TODO : Genre Update
        /* 
        if (invalidNetworksByGenreList.size() > 0){
            String invalidNetworksByGenre = String.join(invalidNetworksByGenreList, ';');
            emailBody += '\n\n' + 'Remove Invalid Networks ' + '\n' + invalidNetworksByGenre;
        }
        */

        System.debug(emailBody);

        VRFCallOuts.SendEmailMessageToAdmins('Network Cleanup on ' + dcName, emailBody);

    }


    @TestVisible
    private static OMSMiddlewareClass CallOut(Digital_Campaign__c dc) {
        System.debug('dc is coming in callout ::: ' + dc);
        System.debug('Total_Impressions__c is coming in callout :::: ' + dc.Total_Impressions__c);

        OMSMiddlewareClass omsClass = new OMSMiddlewareClass();
        System.debug('****IN Callout');
        payload = OMSHelper.prepareJSONDataToOMS(dc);
      
        string url = GetEndPoint(dc);
		  System.debug('****IN Callout::'+url);
        System.debug('payload is in  callout :::' + payload);

        
        
        HttpResponse response = SendToMiddleware(payload, url);

        if (Test.isRunningTest()) {
            response.setStatusCode(statusCode);
        }



        if (Test.isRunningTest()) {
            response.setBody('{\"SalesOrderId\":\"123456\",\"Message\":\"The Digital Campaign DC-0000080697 has already been processed.\",\"Exception\":null}');
        }
		System.debug('******Status Code ' + response.getStatusCode() + ' ' + ', Body' + response.getBody());
       // 1st
       // OMS_ResponseClass omsResponse = (OMS_ResponseClass) System.JSON.deserialize(response.getBody(), OMS_ResponseClass.class);
        

        System.debug('$$$$$$$');
      
        
        
        switch on response.getStatusCode() {
			

            when 200 {
               
                   //SRSF-4309
                       OMS_ResponseClass omsResponse = (OMS_ResponseClass) System.JSON.deserialize(response.getBody(), OMS_ResponseClass.class);          
                
                omsClass.UpdateStatus = true;
                omsClass.isValid = true;
                omsClass.Message = omsResponse.Message;
                omsClass.OperativeID = omsResponse.SalesOrderId;
                omsClass.Icon = SuccessIcon;
                omsClass.IconVariant = SuccessVariant;
	
                //Added for StreamingTV New Process
                String SalesOrderUrl;
                if (dc.Streaming_TV_Old_Process__c != true || dc.Online_Legacy_Campaign__c != true) {
                    if (String.isBlank(omsResponse.ExceptionMessage)) {
                        System.debug('Inside response');
                        map < string, Inventory_Source__c > mapIS = new map < string, Inventory_Source__c > ();

                        map < string, string > mapInvLineitems = new map < string, string > ();
                        for (OMS_ResponseClass.Inventory_ResponseClass objInventorySource: omsResponse.InventorySources) {
                            string str = objInventorySource.SourceName;
                            str = str.replace('Freewheel – O&O/Affiliate/Direct_STVL/3PP/STVV/STB_MRM', 'Freewheel-O&O/Affiliate/Direct');
                            str = str.replace('TTD - CTV_AT', 'TTD-CTV');
                            str = str.replace('Freewheel - FF TVE_MRM', 'Freewheel-FF TVE');
                            str = str.replace('Freewheel - FF OTT_MRM', 'Freewheel-FF OTT');
                            mapInvLineitems.put(str, objInventorySource.LineItemIds);
                        }
                        System.debug(mapInvLineitems);
                        list < Inventory_Source__c > lstIS = new list < Inventory_Source__c > ();
                        for (Inventory_Source__c objIS: dc.Inventory_Sources__r) {
                            System.debug(mapInvLineitems.get(objIS.Inventory_Resource_Type__c));
                            objIS.Line_Item_Id__c = mapInvLineitems.get(objIS.Inventory_Resource_Type__c);
                            lstIS.add(objIS);
                        }
                        update lstIS;
                    }
                    SalesOrderUrl = omsResponse.SalesOrderUrl;
                    System.debug('SalesOrderUrl::' + SalesOrderUrl);
                    dc.Operative_Sales_Order_Hyperlink__c = SalesOrderUrl;
                    update dc;
                }
            }
            when 409 { // Warning Message
                //SRSF-4309
                OMS_ResponseClass omsResponse = (OMS_ResponseClass) System.JSON.deserialize(response.getBody(), OMS_ResponseClass.class);

                omsClass.UpdateStatus = false;
                omsClass.isValid = false;
                omsClass.Message = omsResponse.Message;
                omsClass.OperativeID = omsResponse.SalesOrderId;
                omsClass.Icon = WarningIcon;
                omsClass.IconVariant = WarningVariant;

            }
            when 400 { // Not Found

                if (!String.isBlank(PayLoadMessage)) {
                    response.setBody(PayLoadMessage);
                }


                OMS_ResponseClass response400 = (OMS_ResponseClass) System.JSON.deserialize(response.getBody(), OMS_ResponseClass.class);

                omsClass.UpdateStatus = true;
                omsClass.isValid = false;
                omsClass.Message = response400.Message;
                omsClass.OperativeID = response400.SalesOrderId;
                omsClass.Icon = ErrorIcon;
                omsClass.IconVariant = ErrorVariant;

                if (omsClass.Message.contains('Mapping')) {
                    SendEmailMessage('Sending to OMS Status Code: ' + response.getStatusCode(), url + '\n\n' + omsClass.Message + ' \n\n Payload  \n\n' + payload);
                } else {
                    VRFCallOuts.SendEmailMessageToAdmins('Sending to OMS Status Code: ' + response.getStatusCode(), url + '\n\n' + response.getBody() + ' \n\n Payload  \n\n' + payload);
                }

            }
            when
            else { // Error

                string errorStatus = (dc.Status__c == RevisionSubmitted) ? RevisionError : SubmissionError;

                omsClass.UpdateStatus = true;
                omsClass.isValid = false;
                omsClass.Message = 'Status Code ' + response.getStatusCode() + '\n\n' + response.getBody() + '\n\n' + response;
                omsClass.OperativeID = '';
                omsClass.Icon = ErrorIcon;
                omsClass.IconVariant = ErrorVariant;

                VRFCallOuts.SendEmailMessageToAdmins('Sending to OMS Status Code: ' + response.getStatusCode(), url + '\n\n' + omsClass.Message + ' \n\n Payload  \n\n' + payload);

            }

        }

        return omsClass;

    }

    


     
    @AuraEnabled(cacheable = false)
    public static void UpdateToSuccess(string id, string operativeId) {

        string url = OMS_Settings__c.getValues('Set DCC Status').Endpoint_URL__c;

        System.debug('UpdateToSuccess url: ' + url);

        List < Digital_Campaign__c > dcc = [SELECT id, Status__c,
            Operative_ID__c,
            OMS_Error_Description__c
            FROM Digital_Campaign__c WHERE id =: id LIMIT 1
        ];

        String status = '';

        if (dcc.size() > 0) {
            status = dcc[0].Status__c;

            if (operativeId != '') {
                dcc[0].Operative_ID__c = operativeId;
                dcc[0].OMS_Error_Description__c = '';
                update dcc;
            }
        }

        status = (status == RevisionSubmitted) ? RevisionInProgress : DigOpsInProgress;

        string json = SetStatusLoad(id, status);
        SendToMiddlewareUpdateStatus(json, url + '?id=' + id + '&status=' + EncodingUtil.urlEncode(status, 'UTF-8'));
    }

    @AuraEnabled(cacheable = false)
    public static void UpdateToError(string id, string errorMessage) {


        list < Digital_Campaign__c > dcList = [SELECT id,
            status__c,
            Operative_ID__c,
            OMS_Error_Description__c
            FROM Digital_Campaign__c WHERE id =: id
        ];

        if (dcList.size() > 0) {

            dcList[0].OMS_Error_Description__c = errorMessage;

            update dcList;

            System.debug('Current Status ' + dcList[0].status__c);

            string status = '';

            if (dcList[0].status__c == RevisionError) {
                status = (dcList[0].status__c == RevisionError) ? RevisionError : SubmissionError;
            } else {
                status = (dcList[0].status__c == RevisionSubmitted) ? RevisionError : SubmissionError;
            }

            System.debug('New Status ' + status);

            string url = GetSubmissionEndpoint();
            string json = SetStatusLoad(id, status);

            System.debug('Json ' + json);

            String statusUTF = EncodingUtil.urlEncode(status, 'UTF-8');

            System.debug('UTF-8 Status ' + json);
            SendToMiddlewareUpdateStatus(json, url + '?id=' + id + '&status=' + statusUTF);
        }

    }

    @TestVisible
    private static string SetStatusLoad(string id, string status) {


        JSONGenerator gen = JSON.createGenerator(false);
        gen.writeStartObject();
        gen.writeStringField('id', id);
        gen.writeStringField('status', status);
        gen.writeStringField('version', '1');
        gen.writeEndObject();
        gen.close();

        string payload = gen.getAsString();

        System.debug('Payload ' + payload);

        return payload;

    }


    @TestVisible
    private static string GetSubmissionEndpoint() {
        return OMS_Settings__c.getValues('Set DCC Status').Endpoint_URL__c;
    }


    @TestVisible
    private static string GetEndPoint(Digital_Campaign__c objDC) {
        String url;

        if (objDC.status__c == SubmittedDigOps || objDC.status__c == SubmissionError || objDC.status__c == MissingCreative) {
            url = OMS_Settings__c.getValues('Operative Submit').Endpoint_URL__c;
        } else {
            url = OMS_Settings__c.getValues('Operative Revision').Endpoint_URL__c;
        }

        return url;
    }


    //TODO: Remove hard code
    //check for Master - Digital Operations User
    public static set < string > getMasterDigOpsUser() {
        Set < string > lstMasterDigopsProfiles = new Set < string > ();
        lstMasterDigopsProfiles.add('Master - Account Coordinator');
        lstMasterDigopsProfiles.add('Master - Account Planner');
        lstMasterDigopsProfiles.add('Master - Account Executive');
        lstMasterDigopsProfiles.add('Master - Digital Coordinator');
        lstMasterDigopsProfiles.add('Master - Digital Planner');
        lstMasterDigopsProfiles.add('Master - Digital Sales');
        lstMasterDigopsProfiles.add('Master - Interconnect Account Coordinator');
        lstMasterDigopsProfiles.add('Master - Interconnect Account Planner');
        lstMasterDigopsProfiles.add('Master - Interconnect Sales Manager');
        lstMasterDigopsProfiles.add('Master - Local Sales Manager');
        lstMasterDigopsProfiles.add('Master - National Sales Manager');
        lstMasterDigopsProfiles.add('Master - Digital Operations');
        lstMasterDigopsProfiles.add('Master - Optimization Manager');
        lstMasterDigopsProfiles.add('System Administrator');
        lstMasterDigopsProfiles.add('Integration User');
        return lstMasterDigopsProfiles;
    }

    //Sending data to Middleware
    public static HttpResponse SendToMiddleware(string json, string url) {



        
        Http http = new Http();
        HttpRequest request = new HttpRequest();
        String omsApiKey = System.Label.OmsApiKey;

        System.debug('json::' + json);
        System.debug('url::' + url);

        request.setEndpoint(url);
        request.setTimeout(120000);
        request.setMethod('POST');
        request.setHeader('Content-Type', 'text/plain');
        request.setHeader('OmsApiKey', omsApiKey);
        request.setBody(json);

        HttpResponse response = new HttpResponse();

        if (!Test.isRunningTest()) {
            response = http.send(request);
            
             // not coming becaouse 401 error has occurs and not authorized from server
            System.debug('what response are coming in that :: ' + response);
        }


        return response;
    }

    @future(callout = true)
    public static void SendToMiddlewareUpdateStatus(string json, string url) {


        Http http = new Http();
        HttpRequest request = new HttpRequest();
        String omsApiKey = System.Label.OmsApiKey;

        System.debug('url::' + url);

        request.setEndpoint(url);
        request.setTimeout(120000);
        request.setMethod('POST');
        request.setHeader('Content-Type', 'text/plain');
        request.setHeader('OmsApiKey', omsApiKey);
        request.setBody(json);
        System.debug('json::' +json);

        HttpResponse response = new HttpResponse();

        if (!Test.isRunningTest()) {
            response = http.send(request);
            System.debug('what response are coming in that1 :: ' + response);
        }
        System.debug(response.getStatus() + ' ' + response.getBody());

    }


    @future(callout = true)
    public static void SendEmailMessage(string title, string message) {

        List < OMS_Settings__c > settings = [SELECT Value__c
            FROM OMS_Settings__c
            WHERE Category__c =: 'MappingEmail'
        ];

        List < string > emailList = new List < string > ();

        for (OMS_Settings__c email: settings) {
            emailList.Add(email.Value__c);
        }

        if (!emailList.isEmpty()) {
            EmailHelper.sendEmailToListOfUsers(emailList, title, message);
        }
    }
}