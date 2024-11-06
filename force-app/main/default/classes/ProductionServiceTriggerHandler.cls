/* 
    Customer/Project:   Spectrum Reach 
    Class name:          ProductionServiceTriggerHandler
    Author/Date:        John King    6/2/2017
    Release:             TBD
    Related US:         264, 97
    Purpose:            Provides handler methods for the Production_Service__c Trigger
    Modifications:      Brett Ballantyne, 4/4/2018, SRSF-408
                        Brett Ballantyne, 6/4/2018, SRSF-1034

  // This should be used in conjunction with the ApexTriggerComprehensive.trigger template
  // The origin of this pattern is http://www.embracingthecloud.com/2010/07/08/ASimpleTriggerTemplateForSalesforce.aspx

*/

public with sharing class ProductionServiceTriggerHandler {
  private boolean m_isExecuting = false;
  private Integer BatchSize = 0;
  public static Map<Id,String> sendtoBoomi;
  public static HttpCalloutMock mock = null;

  public ProductionServiceTriggerHandler(boolean isExecuting, integer size){
    m_isExecuting = isExecuting;
    BatchSize = size;
    sendtoBoomi = new Map<Id,String>(); 
  }

  public void OnBeforeInsert(Production_Service__c[] newProduction_Services){
    List<Id> PId = new List<Id>();
    List<Production_Service__c> psList = new List<Production_Service__c>();
    List<Production_Service__c> UpdateproductionService = new List<Production_Service__c>();
    for(Production_service__c ps: newProduction_Services){

      if(ps.Rate_Card_Value__c == null){
        ps.Rate_Card_Value__c = 0;
      }

      if(ps.Amount_to_be_Billed__c == null){
        ps.Amount_to_be_Billed__c = 0;
      }

      if(ps.KDD__c == null){
        ps.KDD__c = 0;
      }

     /*if(ps.Kernel_Offer__c == '2021 First Look'){
      ps.fsa_amount__c  = ps.Rate_Card_Value__c - (ps.Rate_Card_Value__c*0.35 + ps.Amount_to_be_Billed__c + math.abs(ps.KDD__c));
     } else if (ps.First_Look__c == true || ps.Kernel_Offer__c != null){
      ps.fsa_amount__c  = ps.Rate_Card_Value__c - (ps.Rate_Card_Value__c*0.15 + ps.Amount_to_be_Billed__c + math.abs(ps.KDD__c));
     } else {
      ps.fsa_amount__c = ps.Rate_Card_Value__c - (ps.Amount_to_be_Billed__c + math.ABS(ps.KDD__c));
     }*/
        
      if(ps.Sponsorship_Type__c != null) {
         ps.fsa_amount__c = 0;
         ps.Sponsorship_Discount__c = ps.Rate_Card_Value__c - (ps.Amount_to_be_Billed__c + math.ABS(ps.KDD__c));
      } else {
        ps.Sponsorship_Discount__c = 0;
        if(ps.Kernel_Offer__c == '2021 First Look'){
          ps.fsa_amount__c  = ps.Rate_Card_Value__c - (ps.Rate_Card_Value__c*0.35 + ps.Amount_to_be_Billed__c + math.abs(ps.KDD__c));
        } else if (ps.First_Look__c == true || ps.Kernel_Offer__c == 'Summertime' || ps.Kernel_Offer__c == 'Q1 Promo' || ps.Kernel_Offer__c == 'Q2 Promo' || ps.Kernel_Offer__c == 'Q3 Promo' || ps.Kernel_Offer__c == 'Q4 Promo'){
          ps.fsa_amount__c  = ps.Rate_Card_Value__c - (ps.Rate_Card_Value__c*0.15 + ps.Amount_to_be_Billed__c + math.abs(ps.KDD__c));
        } else {
          ps.fsa_amount__c = ps.Rate_Card_Value__c - (ps.Amount_to_be_Billed__c + math.ABS(ps.KDD__c));
        }
      }
      System.debug('Kernel Offer = ' + ps.Kernel_Offer__c + '@@@@@' + 'Rate Card Value = ' + ps.Rate_Card_Value__c + '@@@@@' + '@@@@@' + 'Amount to be Billed = ' + ps.Amount_to_be_Billed__c + '@@@@@' + 'KDD = ' + ps.KDD__c + '@@@@@' + 'FSA Amount = ' + ps.fsa_amount__c + '@@@@@' + 'ps.Status__c = ' + ps.Status__c);          
    }

    /*if(ps.fsa_amount__c < 0){
      ps.adderror(system.label.KDD_Error);
     } 
    */
 
  //  for(Production_Service__c ps: newProduction_Services) {
  /*
      List<Support_Request__c> sr = [SELECT Linear_status__c, Digital_Status__c, Target_Demographics__c from Support_Request__c where Id = : ps.Support_Request__c];
      ps.Linear_status__c = sr[0].Linear_status__c;
      ps.Digital_Status__c = sr[0].Digital_Status__c;
      ps.Target_Demographic__c = sr[0].Target_Demographics__c;
  */
    //  List<Support_Request__c> sr = [SELECT Linear_Order_Status__c, Digital_Order_Status__c from Support_Request__c where Id = : ps.Support_Request__c];//, Target_Demographics__c
    //  ps.Linear_Order_Status__c = sr[0].Linear_Order_Status__c;
     // ps.Digital_Order_Status__c = sr[0].Digital_Order_Status__c;
      //ps.Target_Demographic__c = sr[0].Target_Demographics__c;

  //  }
  /*
    for(Production_Service__c ps: newProduction_Services) {
        if (ps.Production_Service_Record_Type__c  != null) {
            if (ps.Production_Service_Record_Type__c.startsWith('Digital')) {
                ps.Linear_Order_Status__c = null;
            } else if (ps.Production_Service_Record_Type__c.startsWith('Linear')) {
                ps.Digital_Order_Status__c = null;
            } else {
                ps.Digital_Order_Status__c = null;
                ps.Linear_Order_Status__c = null;
            }
        }
    }
  */
    Map<Id, Schema.RecordTypeInfo> rtMap = Production_Service__c.SObjectType.getDescribe().getRecordTypeInfosById();
    // SRSF-1034 had to do the following because the name field of custom settings wasn't big enough to hold all record type names
    Map<String, Prod_Service_RecType_Order_Statuses__c > ProdSvcs = Prod_Service_RecType_Order_Statuses__c.getAll();
    Map<String, Prod_Service_RecType_Order_Statuses__c> recTypeNameToPSMap = new Map<String, Prod_Service_RecType_Order_Statuses__c>();
    
    for (Prod_Service_RecType_Order_Statuses__c ps : ProdSvcs.Values()) {
        recTypeNameToPSMap.put(ps.Record_Type_Name__c, ps);
    }    
            
    for(Production_Service__c ps: newProduction_Services) {
         
      if (ps.RecordTypeId  != null) {
        String recType = rtMap.get(ps.recordTypeId).getName();
        Prod_Service_RecType_Order_Statuses__c ProdSvcSetting = recTypeNameToPSMap.get(recType);
        System.debug('------------>> recType = ' + recType);
        System.debug('------------>> ProdSvcSetting = ' + ProdSvcSetting);
        if (ProdSvcSetting == null) {
            continue;
        }
        if (ProdSvcSetting.Is_Digital_RecType__c == true) {
            ps.Linear_Order_Status__c = null;
        } else if (ProdSvcSetting.Is_Linear_RecType__c == true) {
            ps.Digital_Order_Status__c = null;
        } 
      }   
        
      //clearing the Dell boomi fields for cloned or new records
      ps.Boomi_Error_Message__c=null;
      ps.IMN_ID__c=null;
      ps.Integrated_with_IMN__c=false; 
      ps.IMN_Sync_Status__c=''; 
    }

    /*
      if (ps.isClone() == true) {
          ps.Digital_Order_Status__c = null;
          ps.Linear_Order_Status__c = null;
      }      
    }*/
  }

  public void OnAfterInsert(Production_Service__c[] newProduction_Services){
    //SyncplicitySRUtils.CreateSyncplicityFolders(new List<Id>(new Map<Id, Production_Service__c>(newProduction_Services).keySet()));
  }

  @future public static void OnAfterInsertAsync(Set<ID> newProduction_ServiceIDs){
    //Example usage
    //List<Production_Service> newProduction_Services = [select Id, Name from Production_Service where Id IN :newProduction_ServiceIDs];
  }

  public void OnBeforeUpdate(Production_Service__c[] oldProduction_Services, Production_Service__c[] updatedProduction_Services, Map<ID, Production_Service__c> Production_ServiceMap){
  
    List<Id> PId = new List<Id>();
    List<Production_Service__c> psList = new List<Production_Service__c>();
    List<Production_Service__c> UpdateproductionService = new List<Production_Service__c>();
    String profileId = userinfo.getprofileId();
    for(Production_service__c ps: updatedProduction_Services){
      if(profileId != System.label.IntegrationUserProfileId){
        ps.Boomi_Error_Message__c = null;
        // ps.Integrated_with_IMN__c = false; // commented for SRSF-2529
        // ps.IMN_Sync_Status__c='';  // commented for SRSF-2529
      }

      if(ps.Rate_Card_Value__c == null){
        ps.Rate_Card_Value__c = 0;
      }

      if(ps.Amount_to_be_Billed__c == null){
        ps.Amount_to_be_Billed__c = 0;
      }

      if(ps.KDD__c == null){
        ps.KDD__c = 0;
      }

      // if(ps.Rate_Card_Value__c !=null && ps.Amount_to_be_Billed__c != null && ps.KDD__c!= null){
      /*if(ps.Kernel_Offer__c == '2021 First Look'){
        ps.fsa_amount__c  = ps.Rate_Card_Value__c - (ps.Rate_Card_Value__c*0.35 + ps.Amount_to_be_Billed__c + math.abs(ps.KDD__c));
      } else if (ps.First_Look__c == true || ps.Kernel_Offer__c != null){
        ps.fsa_amount__c  = ps.Rate_Card_Value__c - (ps.Rate_Card_Value__c*0.15 + ps.Amount_to_be_Billed__c + math.abs(ps.KDD__c));
      } else {
        ps.fsa_amount__c = ps.Rate_Card_Value__c - (ps.Amount_to_be_Billed__c + math.ABS(ps.KDD__c));
      }*/
      
      if(ps.Sponsorship_Type__c != null) {
         ps.fsa_amount__c = 0;
         ps.Sponsorship_Discount__c = ps.Rate_Card_Value__c - (ps.Amount_to_be_Billed__c + math.ABS(ps.KDD__c));
      } else {
        ps.Sponsorship_Discount__c = 0;
        if(ps.Kernel_Offer__c == '2021 First Look'){
          ps.fsa_amount__c  = ps.Rate_Card_Value__c - (ps.Rate_Card_Value__c*0.35 + ps.Amount_to_be_Billed__c + math.abs(ps.KDD__c));
        } else if (ps.First_Look__c == true || ps.Kernel_Offer__c == 'Summertime' || ps.Kernel_Offer__c == 'Q1 Promo' || ps.Kernel_Offer__c == 'Q2 Promo' || ps.Kernel_Offer__c == 'Q3 Promo' || ps.Kernel_Offer__c == 'Q4 Promo'){
          ps.fsa_amount__c  = ps.Rate_Card_Value__c - (ps.Rate_Card_Value__c*0.15 + ps.Amount_to_be_Billed__c + math.abs(ps.KDD__c));
        } else {
          ps.fsa_amount__c = ps.Rate_Card_Value__c - (ps.Amount_to_be_Billed__c + math.ABS(ps.KDD__c));
        }
      } 
      
      System.debug('Kernel Offer = ' + ps.Kernel_Offer__c + '@@@@@' + 'Rate Card Value = ' + ps.Rate_Card_Value__c + '@@@@@' + '@@@@@' + 'Amount to be Billed = ' + ps.Amount_to_be_Billed__c + '@@@@@' + 'KDD = ' + ps.KDD__c + '@@@@@' + 'FSA Amount = ' + ps.fsa_amount__c + '@@@@@' + 'ps.Status__c = ' + ps.Status__c);     
      System.debug(ps.fsa_amount__c+'@@@@@'+ps.Status__c);
      
      if(ps.fsa_amount__c < 0 && ps.Status__c != 'Cancelled'){
        ps.addError(System.label.KDD_Error+' for production service : '+ps.name+' ('+ps.Id+')');
      }

      //}else{
      //  ps.fsa_amount__c = 0;
      //}
    } 
  
    /*for(Production_service__c ps:updatedProduction_Services){
      if(ps.fsa_amount__c < 0){
        ps.adderror(system.label.KDD_Error);
      }
    } */

    //Example Map usage
    //Map<ID, Contact> contacts = new Map<ID, Contact>( [select Id, FirstName, LastName, Email from Contact where Production_ServiceId IN :Production_ServiceMap.keySet()] );
    // SRSF-439 - update sales office, region, and division
    /* 
    for(Production_Service__c ps: updatedProduction_Services) {
      if (ps.Production_Service_Record_Type__c  != null) {
        if (ps.Production_Service_Record_Type__c.startsWith('Digital')) {
          ps.Linear_Order_Status__c = null;
        } else if (ps.Production_Service_Record_Type__c.startsWith('Linear')) {
          ps.Digital_Order_Status__c = null;
        } else {
          ps.Digital_Order_Status__c = null;
          ps.Linear_Order_Status__c = null;
        }
      }
    } */

    Map<Id, Schema.RecordTypeInfo> rtMap = Production_Service__c.SObjectType.getDescribe().getRecordTypeInfosById();
    // SRSF-1034 had to do the following because the name field of custom settings wasn't big enough to hold all record type names
    Map<String, Prod_Service_RecType_Order_Statuses__c > ProdSvcs = Prod_Service_RecType_Order_Statuses__c.getAll();
    Map<String, Prod_Service_RecType_Order_Statuses__c> recTypeNameToPSMap = new Map<String, Prod_Service_RecType_Order_Statuses__c>();
    for (Prod_Service_RecType_Order_Statuses__c ps : ProdSvcs.Values()) {
      recTypeNameToPSMap.put(ps.Record_Type_Name__c, ps);
    }

    for(Production_Service__c ps: updatedProduction_Services) {
      if (ps.RecordTypeId  != null) {
        String recType = rtMap.get(ps.recordTypeId).getName();
        Prod_Service_RecType_Order_Statuses__c ProdSvcSetting = recTypeNameToPSMap.get(recType);
        if (ProdSvcSetting == null) {
          continue;
        }
       // if (recType.startsWith('Digital') || recType.startsWith('News')) {
        if (ProdSvcSetting.Is_Digital_RecType__c == true) {
          ps.Linear_Order_Status__c = null;
        } else if (ProdSvcSetting.Is_Linear_RecType__c == true) {  // if the record type is not digital, clear digital status (can be linear record type or other (Print, Logos, etc))
          ps.Digital_Order_Status__c = null;
        } 
      }      
    }

    Set<Id> AEIds = new Set<Id>();
    for (Production_Service__c ps : updatedProduction_Services) {
      AEIds.add(ps.Account_Executive__c);
    }
    Map<Id, User> userInfoMap = new Map<Id, User>([SELECT Id, Sales_Office__c, Region__c, Division__c FROM User WHERE Id in :AEIds]);
    for (Production_Service__c ps : updatedProduction_Services) {
      User ae = userInfoMap.get(ps.Account_Executive__c);
      if (ae != null) {
        ps.Sales_Office__c = ae.Sales_Office__c;
        ps.Region__c = ae.Region__c;
        ps.Division__c = ae.Division__c;
      }
    }
    // End of SRSF-439
  }

  public void OnAfterUpdate(Production_Service__c[] oldProduction_Services, Production_Service__c[] updatedProduction_Services, Map<ID, Production_Service__c> Production_ServiceMap){
 
  /**** production issue - SRSF-1211  moving this to time-based WFs
    // SRSF-408 start
    // build set of Support_Request__c ids to use in query
    Set<Id> SRIdSet = new Set<Id>();
    for(Production_Service__c ps : updatedProduction_Services) {
      SRIdSet.add(ps.Support_Request__c);
    } 

    List<Support_Request__c> SupReqUpdateList = new List<Support_Request__c>();

   // Map<Id, Integer> compPsMap = new Map<Id, Integer>();
   // Set<Id> incompletePsSet = new Set<Id>();
   // Set<Id> cancelledPsSet = new Set<Id>();

    Set<Id> SRsToCancel = new Set<Id>();
    Set<Id> SRsToClose = new Set<Id>();

    Map<Id, AggregateResult> completedMap = new  Map<Id, AggregateResult>([select Support_Request__c Id, count(Id) 
                                                                            from Production_Service__c 
                                                                            where Support_Request__c in :SRIdSet and Status__c = 'Complete - Billing Submitted'  
                                                                            group by Support_Request__c]);


    Map<Id, AggregateResult> cancelledMap = new  Map<Id, AggregateResult>([select Support_Request__c Id, count(Id) 
                                                                            from Production_Service__c 
                                                                            where Support_Request__c in :SRIdSet and Status__c = 'Cancelled'  
                                                                            group by Support_Request__c]);

    Map<Id, AggregateResult> allPSMap  = new  Map<Id, AggregateResult>([select Support_Request__c Id, count(Id) 
                                                                        from Production_Service__c 
                                                                        where Support_Request__c in :SRIdSet 
                                                                        group by Support_Request__c]);

    

    for (Id srId : allPSMap.keySet()) {
        Integer allCount = 0;
        Integer completedCount = 0;
        Integer cancelledCount = 0;
        AggregateResult agResAll = allPSMap.get(srId);
        allCount = (Integer) agResAll.get('expr0');
        AggregateResult agResCompleted = completedMap.get(srId);
        if (agResCompleted != null) {
            completedCount = (Integer) agResCompleted.get('expr0');
        }
        AggregateResult agResCancelled = cancelledMap.get(srId);
        if (agResCancelled != null) {
            cancelledCount = (Integer) agResCancelled.get('expr0');
        }

        if (allCount == cancelledCount) {    // All PS' have been cancelled
            SRsToCancel.add((Id) agResAll.get('Id'));
        } else if (allCount == completedCount || allCount == completedCount + cancelledCount) {  // All PS' have been completed or completed and cancelled
            SRsToClose.add((Id) agResAll.get('Id'));
        }
    }

    if (SRsToClose.size() > 0) {
        for (Support_Request__c sr : [select Id, Name, Status__c from Support_Request__c where Id in :SRsToClose]) {
          sr.Status__c = 'Completed by Kernel';
          SupReqUpdateList.add(sr);
        }
    }

    if (SRsToCancel.size() > 0) {
        for (Support_Request__c sr : [select Id, Name, Status__c from Support_Request__c where Id in :SRsToCancel]) {
          sr.Status__c = 'Cancelled';
          SupReqUpdateList.add(sr);
        }
    }

    if (SupReqUpdateList.size() > 0) {
        update SupReqUpdateList;
    }
    ****/

    /*
    // build a set of Ids of Support Requests that have Production Services in Cancelled status
    aggCountsCancelled = [
    for (AggregateResult ar : aggCountsCancelled)  {
        System.debug('Cancelled Support Request ID = ' + ar.get('Support_Request__c'));
        System.debug('Cancelled Count of Production_Services = ' + ar.get('expr0'));
        cancelledPsSet.add((Id) ar.get('Support_Request__c'));
    }

    // Loop through all SRs that have at least one Production Service in completed status
    for (Id srId : compPsMap.keySet()) {
        if (!incompletePsSet.contains(srId) && compPsMap.get(srId) != null) {    // no Production Services with status other than 'Complete - Billing Submitted'
            SRIdsToClose.add(srId);                                              // so add it to the list of SRs to close
        }
    }

    List<Support_Request__c> SRsToClose = new List<Support_Request__c>();
    if (SRIdsToClose.size() > 0) {
      for (Support_Request__c sr : [select Id, Name, Status__c from Support_Request__c where Id in :SRIdsToClose]) {
        sr.Status__c = 'Completed by Kernel';
        SRsToClose.add(sr);
      }
      if (SRsToClose.size() > 0) {
        update SRsToClose;
      }
    }
    */
    // SRSF-408 end
  }

  @future public static void OnAfterUpdateAsync(Set<ID> updatedProduction_ServiceIDs){
    //List<Production_Service__c> updatedProduction_Services = [select Id, Name from Production_Service where Id IN :updatedProduction_ServiceIDs];
  }

  public void OnBeforeDelete(Production_Service__c[] Production_ServicesToDelete, Map<ID, Production_Service__c> Production_ServiceMap){

  }

  public void OnAfterDelete(Production_Service__c[] deletedProduction_Services, Map<ID, Production_Service__c> Production_ServiceMap){

  }

  @future public static void OnAfterDeleteAsync(Set<ID> deletedProduction_ServiceIDs){

  }

  public void OnUndelete(Production_Service__c[] restoredProduction_Services){

  }

  public boolean IsTriggerContext{
    get{ return m_isExecuting;}
  }

  public boolean IsVisualforcePageContext{
    get{ return !IsTriggerContext;}
  }

  public boolean IsWebServiceContext{
    get{ return !IsTriggerContext;}
  }

  public boolean IsExecuteAnonymousContext{
    get{ return !IsTriggerContext;}
  }
  
   //SRSF - 1136

  @future (callout=true)
  public static void sendProductionServToIMN (Set<ID> updatedProdServIDs, Boolean retryVal) 
  {
    sendtoBoomi = new Map<Id,String>();
    System.debug('$$$In sendProductionServToIMN $'+sendtoBoomi); 
    List<Production_Service__c> prodServList = [Select ID, IMN_Sync_Status__c, Boomi_Error_Message__c, Status__c FROM Production_Service__c WHERE ID IN: updatedProdServIDs];
    if(sendtoBoomi.isEmpty() ) { // && ConstantVariables.recurssivevar == false
      for(ID  prodServID : updatedProdServIDs){
        sendtoBoomi.put(prodServID,'Submitted_to_Kernel_Complete_Billing__c');          
      } 
      // Need to send 1 record at a time if not RETRY ie. if initiated from Trigger/UI
      System.debug('$$$sendtoBoomi $'+sendtoBoomi.size()); 
      if(sendtoBoomi.size()>0)
      {

        List<String> ProductionServicefields = new List<String>();
        List<Production_Service__c> lstPSrecs = new List<Production_Service__c>();
        List<Logger__c> logSuccessData = new List<Logger__c>();

        List<Kernel_Production_Service_Fields__c> PrdService= Kernel_Production_Service_Fields__c.getall().values();
        for(Kernel_Production_Service_Fields__c eachPSF : PrdService)
            ProductionServicefields.add(eachPSF.name);
             
        ProductionServicefields.add('Support_Request__r.Account_Executive__r.name');         
        String soql = 'select  ' + String.join(ProductionServicefields , ', ') +' from Production_Service__c where Id IN: updatedProdServIDs';
        System.debug('$$$In Excute method query $'+soql); 
        List<Production_Service__c>  prodServiceRec= Database.query(soql);
        System.debug('##In Execute method Production Service####'+prodServiceRec);   
        /* SRSF-2572: Moving to other method 'sendRequestToIMN'
        String JsonString1 = JSON.serialize(prodServiceRec);
        System.debug('##Second web serive request JsonString1  ####'+JsonString1 );
        */
        if(retryVal)
        {
           String jsonString1 = JSON.serialize(prodServiceRec);
           sendRequestToIMN(retryVal, jsonString1, lstPSrecs, prodServList, logSuccessData);
        }
        else
        {
          for(Production_Service__c ps :   prodServiceRec)
          {
            List<Production_Service__c> psList = new List<Production_Service__c>();
            psList.add(ps);
            String jsonString1 = JSON.serialize(psList);
            sendRequestToIMN(retryVal,  jsonString1, lstPSrecs, prodServList, logSuccessData);
          }        
        }
        //END:SRSF-2572
        // SRSF-2143 : Added below if condition
        System.debug('lstPSrecs---->'+lstPSrecs);
        if(lstPSrecs.size()>0)
          UPDATE lstPSrecs; 

        System.debug('logSuccessRecs---->'+logSuccessData);
        if(logSuccessData.size()>0)
          INSERT logSuccessData;
      } 
    }     
  }

  // Existing Logic
    /*public static void callBatchProductionServ(Production_Service__c[] newBatchProdService){
      if(sendtoBoomi.isEmpty() && ConstantVariables.recurssivevar == false)   {
        for(Production_Service__c eachPS : newBatchProdService){
            // SRSF-1136
            if(eachPS.Status__c == 'Complete - Billing Submitted')
            sendtoBoomi.put(eachPS.Id,'Submitted_to_Kernel_Complete_Billing__c');
            
        }
        if(sendtoBoomi.size()>0){
            system.debug('Map inside Trigger handler>>>>'+sendtoBoomi);
            Database.executeBatch(new sendProductionService(sendtoBoomi,false),1);
            ConstantVariables.recurssivevar = true;
        }
      }    
    }*/

    //03-22-2021 : Added below code
  private static void sendRequestToIMN(Boolean retryVal,  String request, List<Production_Service__c> lstPSrecs, List<Production_Service__c> prodServList, List<Logger__c> logSuccessRecs)
  {
    //Getting the Web Serive Username and password from custom settings
    String endpoint = retryVal ? 'ProductionService_Retry' : 'ProductionService';
    Kernel_Project__c prodCustomSett = Kernel_Project__c.getValues(endpoint);
    String prdEndPoint = prodCustomSett.End_Point__c;
    String prdUsername= prodCustomSett.User_name__c;
    String prdPassword= prodCustomSett.Password__c;

    System.debug('prdEndPoint>>>'+prdEndPoint);

    System.debug('Second Web Service Start>>>');
    HttpRequest req1 = new HttpRequest();
    HttpResponse res1 = new HttpResponse();
    Http http1 = new Http();
    req1.setHeader('Content-type','application/json');      
    req1.setEndpoint(prdEndPoint);            
    Blob headerValue1 = Blob.valueOf(prdUsername+':' +prdPassword); 
    String authorizationHeader1 = 'Basic '  + EncodingUtil.base64Encode(headerValue1);
    System.debug('Encoder Value'+EncodingUtil.base64Encode(headerValue1)); 
    req1.setHeader('Authorization', authorizationHeader1);      
    req1.setTimeout(120000);        
    req1.setMethod('POST');

   // String JsonString1 = JSON.serialize(request);
    System.debug('##Second web serive request JsonString1  ####'+request );
    System.debug('#######'+request);           
    req1.setBody(request);  

    System.debug('!!In Second Webservice class req!!'+req1);
    try 
      {
        if(!Test.isRunningTest()){
          res1 = http1.send(req1);
        }else{
          res1 = mock.respond(req1);
        }
        System.debug('$$$$'+res1.getbody());

        if (res1.getStatusCode() == 200)
        {
         Logger__c logger = new Logger__c(
                      Class__c = 'sendProductionService',
                      Method__c = 'Execution Method',
                      Message__c = 'Successfully sent to Boomi at time: '+ DateTime.Now()+' with status : '+res1.getStatus(),                     
                      User__c = UserInfo.getUserId(),
                      Record_Id__c = '');
         logSuccessRecs.add(logger);        
       /* Log4SF.logMessage('sendProductionService','Execution Method',,
                    UserInfo.getUserId(),'');*/
        }
        else
        {
          //SRSF-2143: Added below logic to update error fields if any error occured from boomi 
            for(Production_Service__c ps: prodServList)
            {
              ps.Boomi_Error_Message__c = 'Error while sending data to Boomi with status :'+res1.getStatus();
              ps.IMN_Sync_Status__c = 'Error';
              lstPSrecs.add(ps);
            }              
        }
      }
      catch(System.CalloutException e) 
      {
          System.debug('Callout error: '+ e);
          System.debug(res1.toString());
          //SRSF-2143: Added below logic to update error fields if any error occured from boomi   
          System.debug('scopeSReq---->'+prodServList);               
          for(Production_Service__c ps: prodServList)
          {
              System.debug('ps---->'+ps);
              ps.Boomi_Error_Message__c = 'Error while sending data to Boomi :'+e;
              ps.IMN_Sync_Status__c = 'Error';
              lstPSrecs.add(ps);
          }     
      }
   }
}