/*
###########################################################################
# File..................: ProposalOpportunityBudgetController.cls
# Version...............: 1
# Created by............: Sanchit Singhal
# Created Date..........: 27-March-2017
# Last Modified by......: Ankit Bhatia
# Last Modified Date....: 
# Description...........: This class contains controller methods for ProposalOpportunityBudgetController visualforce page
# TAO Ref#..............: NA
# Change Log:               
#
#
############################################################################*/
public without sharing class ProposalOpportunityBudgetController{

    public account opptyAccount{get;set;}
    public Opportunity oppty{get;set;}
    public ID currentRecordId{get;set;}
    public ID opptyId{get;set;}
    public String CurrentYear{get;set;}
    public String pageMsg{get;set;}
    public Boolean isValidated{get;set;}
    public String SfInstance{get;set;}    
    public Proposal__c proposal{get;set;} 
    /*public Date startDate{get; set;}
    public Date endDate{get; set;}   */
    public string changeInDate{get; set;}
    // public Date changedDate{get; set;}
    
    //Proposal Standard Controller Constructor
    public ProposalOpportunityBudgetController(Apexpages.standardcontroller cntrl)
    {
        changeInDate = '';
    	try
    	{
          //Extract the current Opportunity Account
          System.debug('oppId: ' + Apexpages.currentpage().getparameters().get('oppId'));
          opptyId = Apexpages.currentpage().getparameters().get('oppId');
          List<Proposal__c> propList = new List<proposal__c>();
          currentRecordId = Apexpages.currentpage().getparameters().get('id');
          System.debug('currentRecordId: ' + currentRecordId);
          oppty=[select id,name,accountid,Number_Of_Manual_Proposal_Records__c,CloseDate,Flight_Start_Date__c,Flight_End_Date__c from opportunity where id=:opptyId];
          
          opptyAccount=[select id,name from account where id=:oppty.accountid]; 
          
          //Extract current year
          if(String.valueOf(Date.today().month()).equalsIgnoreCase('January'))              
            CurrentYear= String.valueOf(Date.today().year()); 
          else
            CurrentYear= String.valueOf(Date.today().year()) + ' - ' + String.valueOf(Date.today().year()+1);
            
            isValidated = true;
            
            SfInstance = URL.getSalesforceBaseUrl().toExternalForm();    
            proposal = new Proposal__c();
            //if(String.isNotEmpty(currentRecordId ))
            propList = [Select ID,Name,Start_Date__c,End_Date__c,Opportunity__c from Proposal__c where Opportunity__c =: oppty.id and RecordType.Name = 'Opportunity Budget' limit 1];
            System.debug(propList );
            if(propList .size() > 0)
            {
                proposal = propList[0];
               	if(proposal.Start_Date__c == null)
                	proposal.Start_Date__c = oppty.Flight_Start_Date__c == null?system.today():oppty.Flight_Start_Date__c;
            
            	if(proposal.End_Date__c == null)
                	proposal.End_Date__c = oppty.Flight_End_Date__c == null?oppty.CloseDate:oppty.Flight_End_Date__c; 
            }
    	}
        catch(exception ex)
        {
        	pageMsg = ex.getMessage();
        }       
    }
    
    // Validate the Opportunity Budget for the Opportunity.
    public pageReference validateProposals (){
    if (proposal != null) System.debug(proposal.ID);
    //Redirect to the Opp Budget if it already exists.
        
        if(oppty.Number_Of_Manual_Proposal_Records__c != 0 && proposal!= null && String.isEmpty(currentRecordId)){
            pageMsg = 'An Opportunity Budget already exists for this Opportunity.';
            isValidated = false;  
            return new PageReference('/apex/ProposalLightningEditSwitcher?id='+proposal.ID + '&oppId='+oppty.Id);
        }
        //Create new.
        else if(oppty.Number_Of_Manual_Proposal_Records__c <=0){
            isValidated = true;
            proposal = new Proposal__c();
            proposal.Start_Date__c = oppty.Flight_Start_Date__c == null?system.today():oppty.Flight_Start_Date__c;
            proposal.End_Date__c = oppty.Flight_End_Date__c == null?oppty.CloseDate:oppty.Flight_End_Date__c; 
        }
        return null;
    }
    
    //Save Opportunity Budget records
    @RemoteAction
    public static string saveRecords(string selStartDate, string selEndDate, String selYear,ID seloppty,Id proposalId,list<list<string>> BudgetList){
                  
         //custom settings map variable, using custom settings for generating Opportunity Budget SysCode
         Map<String,SysCodeManualProposalCreation__c> custSettMap = new Map<String,SysCodeManualProposalCreation__c>();
         custSettMap = SysCodeManualProposalCreation__c.getAll();
         string SysCode= custSettMap.get('LinearSysCode').Value__c;
         string digitalSysCode= custSettMap.get('DigitalSysCode').Value__c;
         string productionRequestSysCode= custSettMap.get('ProductionRequestSysCode').Value__c;
         string srNewsSysCode= custSettMap.get('SRNews').Value__c;
         string rsnSysCode= custSettMap.get('RSN').Value__c;
            
         RecordType rt = [select id from RecordType where name='Opportunity Budget'];
         account acc=[select id,name from account where id in (select accountid from opportunity where id=:seloppty)];
         list<Proposal__c> proplist=[select id,Name,Start_Date__c,End_Date__c from proposal__c where id=:proposalId];
         Date CurrentDate=Date.Today();
         Date myDate = date.Parse(selStartDate);
         Date endDate = date.Parse(selEndDate);
         Integer month = myDate.month();
         boolean isSuccess=true;
         Proposal__c prop;
         
         //If proposal does not exist, create a new Proposal of type Opportunity Budget
         if(proplist.size()==0){             
             prop=new Proposal__c(name='Opportunity Budget '+acc.name,RecordTypeId= rt.id, Opportunity__c =seloppty,Start_Date__c=date.Parse(selStartDate),End_Date__c=date.Parse(selEndDate));
             insert prop;
         }
         else
         {
         	System.Debug('date test '+ proplist[0].Start_Date__c.month() + date.Parse(selStartDate).month());
            if(proplist[0].Start_Date__c.month() != myDate.month() || proplist[0].End_Date__c.month() != endDate.month())
            {
            proplist[0].Start_Date__c = myDate;
            proplist[0].End_Date__c = endDate;
            update proplist[0];
            }
         }
         
         for(list<string> strlist: budgetList){
             system.debug('strlist is list:::'+strlist); 
             //try{
                 //If Opportunity Budget Proposal does not exist
                 if(proplist.size()==0)
                 {
                     if(Decimal.Valueof(strlist[1]== null?'0':strlist[1] )<>0||Decimal.Valueof(strlist[2]== null?'0':strlist[2])<>0||Decimal.Valueof(strlist[3]== null?'0':strlist[3])<>0||Decimal.Valueof(strlist[4]== null?'0':strlist[4])<>0||Decimal.Valueof(strlist[5]== null?'0':strlist[5])<>0||Decimal.Valueof(strlist[6]== null?'0':strlist[6])<>0||Decimal.Valueof(strlist[7]== null?'0':strlist[7])<>0||Decimal.Valueof(strlist[8]== null?'0':strlist[8])<>0||Decimal.Valueof(strlist[9]== null?'0':strlist[9])<>0||Decimal.Valueof(strlist[10]== null?'0':strlist[10])<>0||Decimal.Valueof(strlist[11]== null?'0':strlist[11])<>0||Decimal.Valueof(strlist[12]== null?'0':strlist[12])<>0)
                     {
                         //Create New Proposal Zone and Monthly Values for Linear
                         if(strlist[0] == 'Linear'){
                             Proposal_Zone__c propline=new Proposal_Zone__c(name='Proposal line '+ acc.name,Proposal__c=prop.id,Sys_Code__c=SysCode);
                             insert propline;
                             
                             list<Proposal_Zone_Monthly_Value__c> lineschedulelist=new list<Proposal_Zone_Monthly_Value__c>();                       
                             for(integer i=1;i<strlist.size();i++)
                             { 
                             
                                 if(String.isNotBlank(strlist[i]))
                                 {  
                                    if(Decimal.Valueof(strlist[i])<>0)
                                        {                      
                                            Date broadcastdate= System.Date.newInstance(Integer.Valueof(myDate.addMonths(i-1).year()), myDate.addMonths(i-1).month(), 15);                
                                            Proposal_Zone_Monthly_Value__c lineschedule=new Proposal_Zone_Monthly_Value__c(name='Monthly Value '+acc.name,Advertiser__c=acc.id,Proposal_Zone__c=propline.id,Broadcast_Month_Date__c=broadcastdate,Gross_Amount__c=Decimal.Valueof(strlist[i]),Schedule_Type__c='Linear');
                                            lineschedulelist.add(lineschedule);
                                            
                                        }
                                 }   
                            }
                            insert lineschedulelist;                             
                         }
                         //Create New Proposal Zone and Monthly Values for Digital
                         else if(strlist[0] == 'Digital'){
                            Proposal_Zone__c digitalPropline=new Proposal_Zone__c(name='Proposal line '+ acc.name,Proposal__c=prop.id,Sys_Code__c=digitalSysCode);
                            insert digitalPropline;
                            
                            list<Proposal_Zone_Monthly_Value__c> lineschedulelist=new list<Proposal_Zone_Monthly_Value__c>();                        
                             for(integer i=1;i<strlist.size();i++)
                             {   
                             
                                 if(String.isNotBlank(strlist[i]))
                                 {
                                    if(Decimal.Valueof(strlist[i])<>0)
                                    {                      
                                        Date broadcastdate= System.Date.newInstance(Integer.Valueof(myDate.addMonths(i-1).year()), myDate.addMonths(i-1).month(), 15);                
                                        Proposal_Zone_Monthly_Value__c lineschedule=new Proposal_Zone_Monthly_Value__c(name='Monthly Value '+acc.name,Advertiser__c=acc.id,Proposal_Zone__c=digitalPropline.id,Broadcast_Month_Date__c=broadcastdate,Gross_Amount__c=Decimal.Valueof(strlist[i]),Schedule_Type__c='Digital');
                                        lineschedulelist.add(lineschedule);
                                    
                                    }
                                 }   
                            }
                            insert lineschedulelist;
                         }
                         //Create New Proposal Zone and Monthly Values for SR News                         
                         else if(strlist[0] == 'SRNews'){
                            Proposal_Zone__c srNewsPropline=new Proposal_Zone__c(name='Proposal line '+ acc.name,Proposal__c=prop.id,Sys_Code__c=srNewsSysCode);
                            insert srNewsPropline;
                            
                            list<Proposal_Zone_Monthly_Value__c> lineschedulelist=new list<Proposal_Zone_Monthly_Value__c>();                        
                             for(integer i=1;i<strlist.size();i++)
                             {   
                                 if(String.isNotBlank(strlist[i]))
                                 {
                                    if(Decimal.Valueof(strlist[i])<>0)
                                    {                      
                                        Date broadcastdate= System.Date.newInstance(Integer.Valueof(myDate.addMonths(i-1).year()), myDate.addMonths(i-1).month(), 15);                
                                        Proposal_Zone_Monthly_Value__c lineschedule=new Proposal_Zone_Monthly_Value__c(name='Monthly Value '+acc.name,Advertiser__c=acc.id,Proposal_Zone__c=srNewsPropline.id,Broadcast_Month_Date__c=broadcastdate,Gross_Amount__c=Decimal.Valueof(strlist[i]),Schedule_Type__c='SRNews');
                                        lineschedulelist.add(lineschedule);
                                    
                                    }
                                 }
                            }
                            insert lineschedulelist;
                         }
                         //Create New Proposal Zone and Monthly Values for RSN                         
                         else if(strlist[0] == 'RSN'){
                            Proposal_Zone__c rsnPropline=new Proposal_Zone__c(name='Proposal line '+ acc.name,Proposal__c=prop.id,Sys_Code__c=rsnSysCode);
                            insert rsnPropline;
                            
                            list<Proposal_Zone_Monthly_Value__c> lineschedulelist=new list<Proposal_Zone_Monthly_Value__c>();                        
                             for(integer i=1;i<strlist.size();i++)
                             {  
                                 
                                 if(String.isNotBlank(strlist[i]))
                                 { 
                                    if(Decimal.Valueof(strlist[i])<>0)
                                    {                      
                                        Date broadcastdate= System.Date.newInstance(Integer.Valueof(myDate.addMonths(i-1).year()), myDate.addMonths(i-1).month(), 15);                
                                        Proposal_Zone_Monthly_Value__c lineschedule=new Proposal_Zone_Monthly_Value__c(name='Monthly Value '+acc.name,Advertiser__c=acc.id,Proposal_Zone__c=rsnPropline.id,Broadcast_Month_Date__c=broadcastdate,Gross_Amount__c=Decimal.Valueof(strlist[i]),Schedule_Type__c='RSN');
                                        lineschedulelist.add(lineschedule);
                                    
                                    }
                                }
                            }
                            insert lineschedulelist;
                         }
                         //Create New Proposal Zone and Monthly Values for Production Requests
                         else{
                            Proposal_Zone__c productionRequestPropline=new Proposal_Zone__c(name='Proposal line '+ acc.name,Proposal__c=prop.id,Sys_Code__c=productionRequestSysCode);
                            insert productionRequestPropline;
                            
                            list<Proposal_Zone_Monthly_Value__c> lineschedulelist=new list<Proposal_Zone_Monthly_Value__c>();                        
                             for(integer i=1;i<strlist.size();i++)
                             {
                             
                                 if(String.isNotBlank(strlist[i]))
                                 {   
                                    if(Decimal.Valueof(strlist[i])<>0)
                                    {                      
                                        Date broadcastdate= System.Date.newInstance(Integer.Valueof(myDate.addMonths(i-1).year()), myDate.addMonths(i-1).month(), 15);                
                                        Proposal_Zone_Monthly_Value__c lineschedule=new Proposal_Zone_Monthly_Value__c(name='Monthly Value '+acc.name,Advertiser__c=acc.id,Proposal_Zone__c=productionRequestPropline.id,Broadcast_Month_Date__c=broadcastdate,Gross_Amount__c=Decimal.Valueof(strlist[i]),Schedule_Type__c='Linear');
                                        lineschedulelist.add(lineschedule);
                                    
                                    }
                                }
                            }
                            insert lineschedulelist;
                         }                                    
                         
                     }
                }
                //If Opportunity Budget Proposal already exists
                else{
                     String proposalType = '';
                     if(strlist[0] == 'Linear'){
                        proposalType = SysCode;
                     }
                     else if(strlist[0] == 'Digital'){
                        proposalType = digitalSysCode;
                     }
                     else if(strlist[0] == 'SRNews'){
                        proposalType = srNewsSysCode;
                     }
                     else if(strlist[0] == 'RSN'){
                        proposalType = rsnSysCode;
                     }
                     else{
                        proposalType = productionRequestSysCode;
                     }
                     
                     
                     //Select existing proposal zones
                     list<Proposal_Zone__c> propLineList=[select id 
                                                          from Proposal_Zone__c 
                                                          where proposal__c=:proplist[0].id
                                                                and Sys_Code__c=:proposalType];
                     
                     if(propLineList.size() == 0){
                        Proposal_Zone__c propline=new Proposal_Zone__c(name='Proposal line '+ acc.name,Proposal__c=proplist[0].id,Sys_Code__c=proposalType);
                        insert propline;
                        propLineList.add(propLine);
                     }
                     
                     //Ankit- Update based on new dates
                     
                                                                  
                     //Create a Map for existing schedules on given proposal (key=Broadcast_Month__c+Year__c)
                     Map<String,Proposal_Zone_Monthly_Value__c> ScheduleMap=getProposalMap(selStartDate,selEndDate ,propList[0],null ,strlist[0]);
                     
                     Map<String,String> propDateMap=new map<String,String>();
                     list<Proposal_Zone_Monthly_Value__c> upSertList =new list<Proposal_Zone_Monthly_Value__c>();
                     
                     System.debug(ScheduleMap);                
                     //Create current date map
                     Map<integer,String> currentDateMap = new Map<integer,String>();
                     List<String> sortOrder = new List<String>(); 
                      
                     for(integer i=1; i<=12; i++){
                        String s = String.valueOf(myDate.addMonths(i-1).month()).removeStart('0') + String.valueOf(myDate.addMonths(i-1).year());        
                        currentDateMap.put(i,s);                        
                     }
                     System.debug(currentDateMap);
                     //Loop on new values entered in Opportunity Budget page
                     for(integer i=1;i<strlist.size();i++){
                     
                        Date broadcastdate= System.Date.newInstance(Integer.Valueof(myDate.addMonths(i-1).year()), myDate.addMonths(i-1).month(), 15);
                        System.debug(ScheduleMap.get(currentDateMap.get(i)));    
                        //If exisiting schedule does not exist and new Opportunity Budget value is not 0
                        if (ScheduleMap.get(currentDateMap.get(i)) == null && strlist[i] != '0' && strlist[i] != null){
                           System.Debug('The new line schedule records needs to be inserted');
                           upSertList.add(new Proposal_Zone_Monthly_Value__c(name='Monthly Value '+acc.name,Advertiser__c=acc.id,Proposal_Zone__c=propLineList[0].id,Broadcast_Month_Date__c=broadcastdate,Gross_Amount__c=Decimal.Valueof(strlist[i]),Schedule_Type__c = strList[0] =='Production'?'Production':strList[0]));
                        }
                        //If exisiting schedule exists and new Opportunity Budget value is different than existing schedule value
                        else if(ScheduleMap.get(currentDateMap.get(i)) != null && String.valueof(ScheduleMap.get(currentDateMap.get(i)).gross_Amount__c) != String.valueof(strlist[i]) ){
                            //System.Debug('The existing line schedule records needs to be updated for ' + currentDateMap.get(i) + 'with amount:' + strlist[i]);
                            Proposal_Zone_Monthly_Value__c propsch=ScheduleMap.get(currentDateMap.get(i));
                            propsch.Gross_Amount__c=Decimal.Valueof(strlist[i] == null ? '0' : strlist[i]);
                            upSertList.add(propsch);
                        }                
                     }
                     upsert upSertList;
                }
            /*}
            catch(exception e){
                 System.debug('Error Message: '+e);
                 isSuccess = False;             
            }*/
        }
        if (isSuccess){
              return 'Opportunity Budget has been Created/Updated.';
        }
        else
            return 'An error occurred while processing this request.  Please contact your Administrator for more details.';   
    }
    
    //Get Opportunity Budget records
    @RemoteAction
    public static List<Decimal> getRecords(ID proposalId,string newDate){
      // Array to hold amounts for 12 months
      List<Decimal> amounts = new List<Decimal>();
      
      //custom settings map variable, using custom settings for generating Opportunity Budget SysCode
     Map<String,SysCodeManualProposalCreation__c> custSettMap = new Map<String,SysCodeManualProposalCreation__c>();
     custSettMap = SysCodeManualProposalCreation__c.getAll();
     string SysCode= custSettMap.get('LinearSysCode').Value__c;
     string digitalSysCode= custSettMap.get('DigitalSysCode').Value__c;
     string productionRequestSysCode= custSettMap.get('ProductionRequestSysCode').Value__c;
     string srNewsSysCode= custSettMap.get('SRNews').Value__c;
     string rsnSysCode= custSettMap.get('RSN').Value__c;      
     List<Proposal__c> propList = [Select ID,Name,Start_Date__c,End_Date__c from Proposal__c where id =: proposalId and RecordType.Name = 'Opportunity Budget'];
      Map<String,decimal> currentDateMap = new Map<String,decimal>();
      List<String> sortOrder = new List<String>(); 
      Date myDate;
      if(propList.size() > 0 && newDate != null)
      {
        myDate = Date.parse(newDate);
      }
      else
       myDate = date.today();
      
      for(integer i=0; i<12; i++){
        String s = String.valueOf(myDate.addMonths(i).month()) + String.valueOf(myDate.addMonths(i).year());        
        currentDateMap.put(s+SysCode,0);
        System.debug('s+SysCode: ' + s+SysCode);
        sortOrder.add(s+SysCode);       
        currentDateMap.put(s+digitalSysCode,0);
        System.debug('s+digitalSysCode: ' + s+digitalSysCode);
        sortOrder.add(s+digitalSysCode);
        currentDateMap.put(s+productionRequestSysCode,0);
        System.debug('s+productionRequestSysCode: ' + s+productionRequestSysCode);
        sortOrder.add(s+productionRequestSysCode);
        currentDateMap.put(s+srNewsSysCode,0);
        System.debug('s+productionRequestSysCode: ' + s+srNewsSysCode);
        sortOrder.add(s+srNewsSysCode);
        currentDateMap.put(s+rsnSysCode,0);
        System.debug('s+rsnSysCode: ' + s+rsnSysCode);
        sortOrder.add(s+rsnSysCode);
      }
      
      System.debug('currentDateMap: ' + currentDateMap.size());
      if(String.isNotBlank(proposalId)){
        
          for (Proposal_Zone_Monthly_Value__c proplineschedule :[select id,gross_Amount__c,Broadcast_Month__c,Year__c,Proposal_Zone__r.Sys_Code__c 
                                                                 from Proposal_Zone_Monthly_Value__c 
                                                                 where Proposal_Key_Index__c =:proposalId order by Proposal_Zone__r.Sys_Code__c,Broadcast_Month__c]){
              String s = String.valueOf(proplineschedule.Broadcast_Month__c).removeStart('0')+ String.valueOf(proplineschedule.year__c) + proplineschedule.Proposal_Zone__r.Sys_Code__c;
              currentDateMap.put(s,proplineschedule.gross_Amount__c); 
              System.debug('s: ' + s);
          }       
      }
      
      for(String s:sortOrder){
        amounts.add(currentDateMap.get(s));
      }
    
      return amounts;
   }
   public void changeDate()
   {
   }
   
   /*
   Method used to get the Proposal Monthly Zone values and the ID Mapped.
   @return - Map<String,Proposal_Zone_Monthly_Value__c> 
   */
   @RemoteAction 
   public static Map<String,Proposal_Zone_Monthly_Value__c> getProposalMap(string sDate, string eDate, proposal__c proposal,ID propID, String scheduleType)
   {
   	//Ankit- Update based on new dates
   	Date myDate = date.Parse(sDate);
	Date endDate = date.Parse(eDate);
	if(string.isNotEmpty(scheduleType))
	{
		if(scheduleType == 'Production')
		scheduleType = 'Production';
	}
   	if(null == proposal)
   	{
   		proposal = new proposal__c();
   		list<Proposal__c> proplist=[select id,Name,Start_Date__c,End_Date__c from proposal__c where id=:propID];
   		if(propList.size() > 0)
   			proposal = propList[0];
   	}
     List<Proposal_Zone_Monthly_Value__c> propZoneMonList = new List<Proposal_Zone_Monthly_Value__c>();
     propZoneMonList = [select id, Broadcast_Month__c,gross_Amount__c,year__c,schedule_type__c 
                                                  from Proposal_Zone_Monthly_Value__c 
                                                  where Proposal_Key_Index__c=:proposal.Id and schedule_type__c =:scheduleType];
                                                  
     //Create a Map for existing schedules on given proposal (key=Broadcast_Month__c+Year__c)
     Map<String,Proposal_Zone_Monthly_Value__c> ScheduleMap=new map<String,Proposal_Zone_Monthly_Value__c>();
     Map<String,String> propDateMap=new map<String,String>();
     list<Proposal_Zone_Monthly_Value__c> upSertList =new list<Proposal_Zone_Monthly_Value__c>();
     list<Proposal_Zone_Monthly_Value__c> deleteList =new list<Proposal_Zone_Monthly_Value__c>();
     if(propZoneMonList.size() > 0)
     {
         for(Proposal_Zone_Monthly_Value__c schedule : propZoneMonList){
         //Start Date and End Date Comparison with the current proposal zone values
            
            if((Integer.valueOf(schedule.Broadcast_Month__c.removeStart('0')) >= myDate.month() && Integer.valueOf(schedule.Broadcast_Month__c.removeStart('0')) <= endDate.month() && Integer.valueOf(schedule.year__c) == myDate.year())  || (Integer.valueOf(schedule.Broadcast_Month__c.removeStart('0')) <= endDate.month() && Integer.valueOf(schedule.year__c) > endDate.year()))
            {
                propDateMap.put(String.Valueof(schedule.Broadcast_Month__c.removeStart('0')+schedule.year__c)+schedule.schedule_type__c,string.valueOf(schedule.gross_Amount__c));
                ScheduleMap.put(String.Valueof(schedule.Broadcast_Month__c.removeStart('0')+schedule.year__c),schedule);
            }
            else
            {
                deleteList.add(schedule);
            }
            System.debug('ScheduleMap: ' + String.Valueof(schedule.Broadcast_Month__c.removeStart('0')+schedule.year__c));
         }
         System.debug('deleteList: ' + deleteList);
         delete deleteList;
     }
     return ScheduleMap;
   }
   //Navigate back to parent opportunity
   public PageReference GoBackToOpportunity(){
        return new PageReference('/' + opptyId);
    }
}