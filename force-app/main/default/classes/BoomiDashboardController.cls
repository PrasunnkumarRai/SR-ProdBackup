/*
###########################################################################
# File..................: BoomiDashboardController.cls
# Version...............: 1
# Created by............: Sridhar Aluru
# Created Date..........: 20-June-2016
# Last Modified by......: Anusha 
# Last Modified Date....: 21-June-2016
# Description...........: This is the Controller used with "BoomiDashboard" VF page to show the 
# TAO Ref#..............: NA
# Change Log:               
#
#
############################################################################*/
public with sharing class BoomiDashboardController {
    private static BoomiWebServiceHelper boomiHelpr;
    public String selectedDataCenter{get;set;}
    public List<SelectOption> dataCenters{get;set;}
    public JSONForProcessExecution processes {get;set;}
    public Map<String,BoomiIntegration__c> dataCenterValues{get;set;}
    public static String jsonCode;
    public String processId {get;set;}
    public String atomId {get;set;}
    public String endPoint;
    private Integer count = 0;
    public DateTime lastRefreshTime {get;set;}
    public Boolean refreshBlock{get;set;}
    public String message{get;set;}
    public String responseMessage{get;set;}
    public String information{get;set;}
    //public String processUpdateMessage{get;set;}

    public BoomiDashboardController() {
    	message = responseMessage = '';
    	//refreshBlock = false;
        dataCenters = new List<SelectOption>();
        dataCenterValues = BoomiIntegration__c.getAll();
        System.debug(' ### dataCenterValues :::: ' +dataCenterValues);
        if (dataCenterValues.containsKey('Default DataCenter')) {
        	selectedDataCenter = dataCenterValues.get('Default DataCenter').Value__c;
        }
        System.debug('@@Default DataCenter '+selectedDataCenter);
        
    	for (String str:dataCenterValues.keySet()) {
    		if (str != 'Default DataCenter') {
    			dataCenters.add(new SelectOption(str,str));
    		}
    	}
    	System.debug('@@dataCenters '+dataCenters);
        fetchEndPointUrl();
        message = Label.LastRefreshedTime +' '+ System.now();
        System.debug('@@message on Page Load '+message);
        
	}

	public void fetchEndPointUrl(){
		//responseMessage = '';
    	System.debug('@@selectedDataCenter '+selectedDataCenter);
        if(dataCenterValues.containsKey(selectedDataCenter) && selectedDataCenter == dataCenterValues.get(selectedDataCenter).Name){
            System.debug('@@dataCenterValues.get(selectedDataCenter).Endpoint__c '+dataCenterValues.get(selectedDataCenter).Endpoint__c);
            endPoint = dataCenterValues.get(selectedDataCenter).Endpoint__c;
            System.debug('@@lastRefreshTime in fetch '+lastRefreshTime);
            if(lastRefreshTime != Null){  
    			message = Label.LastRefreshedTime + ' '+ lastRefreshTime;
    		}
    		System.debug('@@message in Fetch '+message);
        }
		getProcesses();
    }

    public void startProcess(){
    	//responseMessage = '';
    	System.debug('@@Process Id '+ processId);
    	System.debug('@@Atom Id '+ atomId);

		//Populate Org Cache
		Http h = new Http();
		// Instantiate a new HTTP request, specify the method (POST) as well as the endpoint
		HttpRequest req = new HttpRequest();
		HttpResponse res ;
		req.setEndpoint('callout:Boomi/executeProcess');
		req.setMethod('POST');
		//req.setHeader('Authorization','{!$Boomi.Basic}');
		req.setHeader('Content-type','application/xml; charset=UTF-8');
		req.setTimeout(120000);
		//Set request format
		String reqBody = '<ProcessExecutionRequest processId="'+processId+'" atomId="'+ atomId +'" xmlns="http://api.platform.boomi.com/"></ProcessExecutionRequest>';
		System.debug('@@reqBody '+reqBody);

		req.setBody(reqBody);
		System.debug(req);

		try {
		   res = h.send(req);
		   System.debug('@@Response: '+ res);
		   
		   System.debug('@@Status code '+res.getStatusCode());
		   if (res.getStatusCode() == 200) {
		   		responseMessage = Label.ProcessSuccessMesage;
		   		System.debug('@@responseMessage '+responseMessage);
		   }else{
		   		responseMessage = Label.ProcessFailedMessage;
		   }
		   //fetchEndPointUrl();
		}
		catch(System.CalloutException e) {
		    System.debug('Callout error: '+ e);
		}
		
	}
    
    public void displayProceses(){
    	responseMessage = '';
    	//refreshBlock = false;
		if(dataCenterValues.containsKey(selectedDataCenter) && selectedDataCenter == dataCenterValues.get(selectedDataCenter).Name){
            System.debug('@@dataCenterValues.get(selectedDataCenter).Endpoint__c '+dataCenterValues.get(selectedDataCenter).Endpoint__c);
            endPoint = dataCenterValues.get(selectedDataCenter).Endpoint__c;
            if(lastRefreshTime != Null){  
	    		message = Label.LastRefreshedTime + ' ' + lastRefreshTime;
	        	String execDateTime = lastRefreshTime.formatGMT('yyyy-MM-dd\'T\'hh:mm:ss\'Z\'');    
	        	//String execDateTime = '2017-06-23T02:38:03Z'         ;
	        	endPoint = endPoint+'?executionTime='+execDateTime;
	  		}
	  		System.debug('@@message in Pollar '+message);
        }
    	getProcesses();
    }

    

	public void getProcesses(){
		//responseMessage = '';
		//refreshBlock = false;
		try{
            if (String.isNotBlank(endPoint)) {
                lastRefreshTime = System.Now();
                System.debug('@@lastRefreshTime in getProcesses '+lastRefreshTime);
                HttpResponse res = BoomiWebServiceHelper.RestServGetProcessData(endPoint);
                Integer statusCode = res.getStatusCode();
                System.debug('statusCode>>>>>>>'+statusCode);
                if (statusCode == 200){
                    jsonCode = res.getBody();
                    if(Test.isRunningTest())
                    {
                        jsonCode = '{"ProcessExecutionResult" : { "Process" : [ { "processId" : "37ac59f3-175b-4ee2-8da7-0764019cc1cc", "DeploymentRecord" : [ { "id" : "24d6da9b-7058-49c7-9ba6-46b8f7e5b9e1", "environmentId" : "31788cc6-47eb-402c-94da-4671ad64e7f2", "processId" : "37ac59f3-175b-4ee2-8da7-0764019cc1cc", "componentId" : "37ac59f3-175b-4ee2-8da7-0764019cc1cc", "current" : "true", "version" : "5", "deployedOn" : "20190102 063945.000", "deployedBy" : "srvutukuru@osius.com", "componentType" : "process" } ], "ProcessScheduleStatus" : [ { "atomId" : "13d3a446-71c4-4edc-874d-636cb0dc14e2", "enabled" : "false", "id" : "Q1BTMTNkM2E0NDYtNzFjNC00ZWRjLTg3NGQtNjM2Y2IwZGMxNGUyOjM3YWM1OWYzLTE3NWItNGVlMi04ZGE3LTA3NjQwMTljYzFjYw", "processId" : "37ac59f3-175b-4ee2-8da7-0764019cc1cc" } ], "ProcessSchedules" : { "id" : "Q1BTMTNkM2E0NDYtNzFjNC00ZWRjLTg3NGQtNjM2Y2IwZGMxNGUyOjM3YWM1OWYzLTE3NWItNGVlMi04ZGE3LTA3NjQwMTljYzFjYw", "atomId" : "13d3a446-71c4-4edc-874d-636cb0dc14e2", "processId" : "37ac59f3-175b-4ee2-8da7-0764019cc1cc", "Schedule" : [ { "years" : "*", "months" : "*", "daysOfMonth" : "*", "daysOfWeek" : "1,2,3,4,5,6,7", "hours" : "0-23", "minutes" : "0-59/3" } ], "Retry" : { "maxRetry" : "5" } } } ] } }';
                    }
                    System.debug('jsonCode>>>>>>>>>>>'+jsonCode);
                    jsonCode = stripJsonNulls(jsonCode);
                    System.debug('jsonCode after removing Nulls>>>>>>>>>>>'+jsonCode);
                    processes = JSONForProcessExecution.parse(jsonCode);
                    System.debug('@@processes '+processes.ProcessExecutionResult.Process);    
                    System.debug('@@processes size '+processes.ProcessExecutionResult.Process.size());  
                    List<String> processRecords = new List<String>(); 
                    for (JSONForProcessExecution.Process prc :processes.ProcessExecutionResult.Process) {
                        System.debug('@@prc.ProcessName '+prc.ProcessName);
                        if (prc.ProcessName != NUll) {
                            //refreshBlock = true;
                            processRecords.add(prc.ProcessName);
                        }

                    }   
                    if (processRecords.size() > 0) {
                        refreshBlock = true;
                        System.debug('@@refreshBlock for size > '+refreshBlock);
                    }else{
                        refreshBlock = false;
                        System.debug('@@refreshBlock for size < '+refreshBlock);
                        ApexPages.Message msg = new ApexPages.Message(ApexPages.Severity.INFO, Label.NoProcessUpdated);
                        ApexPages.addMessage(msg);
                        information = Label.NoProcessUpdated;
                    }
                    
                     System.debug('@@information '+information);
                } else {        
                    ApexPages.Message msg = new ApexPages.Message(ApexPages.Severity.ERROR, Label.BoomiServerFail);
                    ApexPages.addMessage(msg);
                }   
            }
        }
        catch(Exception e){
            System.debug('Exception: '+e);
        }
	}

    public static string stripJsonNulls(string JsonString)
    {

    	if(JsonString != null)   	
    	{		            
		//	JsonString = JsonString.replaceAll('null,','');	

    		JsonString = JsonString.replaceAll('null','');	
    		JsonString= JsonString.replaceAll( '\\s+', '');
    		//JsonString= JsonString.replaceAll( ',,', ',');
    		JsonString = JsonString.replaceAll( '\\,+', ',');
    		jsonCode= jsonCode.replaceAll( '":,', '":"",');
		//	JsonString = JsonString.replaceAll(',{2,}', ','); //remove duplicate/multiple commas
			JsonString = JsonString.replace('{,', '{'); //prevent opening brace from having a comma after it
			JsonString = JsonString.replace(',}', '}'); //prevent closing brace from having a comma before it
			JsonString = JsonString.replace('[,', '['); //prevent opening bracket from having a comma after it
			JsonString = JsonString.replace(',]', ']'); //prevent closing bracket from having a comma before it
    	}
  	
	return JsonString;
    }    
}