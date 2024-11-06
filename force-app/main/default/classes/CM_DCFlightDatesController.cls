/*
    Author : MAndS 
    Date   : Jul 18-2018
    Description : Lightning component Apex controller of CM_DCFlightDates to Add/Remove/Update flight dates on DigitalCampaign
    Modification History : 
*/
public class CM_DCFlightDatesController{
    
    public static map<string,string> mapMonToNum = new map<string,string>();
    public static map<string,string> mapNumToMon = new map<string,string>();
    /**
     	MethodName  : PrepareData
		Input       : DigitalCampaign Id
		Output      : List of Flight Records
     	Description : Aura enabled method to prepare the data 
     */
    @AuraEnabled
    public static ResultWrap PrepareData(String dcRecordId){
        ResultWrap objWrap = new ResultWrap();
        try{
            mapMonToNum = PrepareMonthToNum();
            mapNumToMon = PrepareNumToMonth();
            Digital_Campaign__c dcRecord = [Select Id,Flight_Dates_Backend__c,Campaign_Start_Date__c,Campaign_End_Date__c
                        from Digital_Campaign__c where id=: dcRecordId];
            String strDates = dcRecord.Flight_Dates_Backend__c;
            
            list<FlightWrap> lstFW = new list<FlightWrap>();
            if( strDates!=null ){
                list<string> lstDate = strDates.split(';');
                if( lstDate!=null && !lstDate.isEmpty() ){
                    for( integer i=0; i<lstDate.size();i++ ){
                        String strDate = lstDate[i];
                        if( strDate!=null ){
                            list<string> lstDt = strDate.split(':');
                            String stDt = changeDateFormatApexToJS(lstDt[0]);
                            String endDt = changeDateFormatApexToJS(lstDt[1]);
                            FlightWrap objFR = new FlightWrap();
                            objFR.RecordNum = i;
                            objFR.startDate = stDt;
                            objFR.endDate = endDt;
                            System.debug(objFR);
                            lstFW.add(objFR);
                        }
                    }
                    objWrap.lstFlightDates = lstFW; 
                }
            }
            objWrap.objDCampaign = dcRecord;
        }catch( Exception ex){
            objWrap.strMsg = 'Error : '+ex.getMessage();
        }
        return objWrap;
    }
    
    /**
     	MethodName  : PrepareData
		Input       : DigitalCampaign Id
		Output      : List of Flight Records
     	Description : Aura enabled method to update the data 
     */
    @AuraEnabled
    public static ResultWrap UpdateData(String dcRecordId, String strData){
        Digital_Campaign__c dcRecord = [Select Id,Flight_Dates_Backend__c,Flight_Dates__c,Campaign_Start_Date__c,Campaign_End_Date__c
                    from Digital_Campaign__c where id=: dcRecordId];
        String strDates = dcRecord.Flight_Dates_Backend__c;
        ResultWrap objWrap = new ResultWrap();
        //System.debug(strDates+'==='+strData);
        try{
            if( strDates!= strData){
                System.debug('Data is Different');
                dcRecord.Flight_Dates_Backend__c = strData;
                User objuser = [select id,Name from User where id=:UserInfo.getUserId()];
                String strOldDateDesc = (dcRecord.Flight_Dates__c !=null)? dcRecord.Flight_Dates__c : '';
                String strNewDateDesc= objuser.Name+' '+datetime.now()+'\n';
                if(strData != null && strData!=''){
                    list<string> lstDate = strData.split(';');
            		if( lstDate!=null && !lstDate.isEmpty() ){
                        for( integer i=0; i<lstDate.size();i++ ){
                            String strDate = lstDate[i];
                            if( strDate!=null ){
                                list<string> lstDt = strDate.split(':');
                                String stDt = lstDt[0];
                                String endDt = lstDt[1];
                                boolean isValidate  = validateData(lstDt[0],lstDt[1]);
                                if(!isValidate){
                                    objWrap.strMsg = 'Error : '+'Record Number '+(i+1)+'. Flight End Date must be equal to or Greater than Flight Start Date';
                                    return objWrap;
                                }
                                strNewDateDesc+=(i+1)+'. '+stDt+', '+endDt+'\n';
                            }
                        }
                    }	   
                }
                
                String FlightDates = strNewDateDesc+'\n'+strOldDateDesc;
                if(FlightDates!=null && FlightDates.length()>32000 ){ //If data is exceeded field length, we need to trim the text
                    String strReviseOldDateDesc = '';
                    String fd = dcRecord.Flight_Dates__c;
                    list<string> lstFD = fd.split('\n');
                    for( integer i=0;i<100;i++ ){
                        strReviseOldDateDesc+= lstFD[i]+'\n';
                    }
                    strOldDateDesc = strReviseOldDateDesc;
                }
                dcRecord.Flight_Dates__c = strNewDateDesc+'\n'+strOldDateDesc;
                update dcRecord;
                objWrap.strMsg = 'The Flight Dates have been added successfully.';
            }
            else{
                System.debug('Data is Same');
                objWrap.strMsg = 'No changes in Flight Dates.';
            }
            //objWrap = PrepareData(dcRecordId);
        }catch( Exception ex){
            objWrap.strMsg = 'Error : '+ex.getMessage();
        }
        return objWrap;
    }
    
    /**
     	MethodName  : validateData
		Input       : 
		Output      : True / Flase
     	Description : Checks for StartDate & EndDate (Flight End Date must be equal to or Greater than Flight Start Date)
     */
    public static boolean validateData( string strStDt, String strEndDt) {
        //boolean isFlag = false;
        Date stDt = date.parse(strStDt);
        System.debug('-->'+stDt);
        Date endDt = date.parse(strEndDt);
        System.debug('-->'+endDt);
        System.debug('@@@'+(stDt<=endDt));
        return (stDt<=endDt);
    }
    
    /**
     	MethodName  : PrepareMonthToNum
		Input       : 
		Output      : Month Name to Number
     	Description : Prepares key as Month & Value as Number
     */
    public static map<string,string> PrepareMonthToNum() {
        map<string,string> mapMonToNum = new map<string,string>();
        mapMonToNum.put('Jan', '01');
        mapMonToNum.put('Feb', '02');
        mapMonToNum.put('Mar', '03');
        mapMonToNum.put('Apr', '04');
        mapMonToNum.put('May', '05');
        mapMonToNum.put('Jun', '06');
        mapMonToNum.put('Jul', '07');
        mapMonToNum.put('Aug', '08');
        mapMonToNum.put('Sep', '09');
        mapMonToNum.put('Oct', '10');
        mapMonToNum.put('Nov', '11');
        mapMonToNum.put('Dec', '12');
        return mapMonToNum;
	}
    
    /**
     	MethodName  : PrepareNumToMonth
		Input       : 
		Output      : Month Name to Number
     	Description : Prepares key as Number & Value as Month
     */
    public static map<string,string> PrepareNumToMonth() {
        map<string,string> mapNumToMon = new map<string,string>();
        mapNumToMon.put('01','Jan');
        mapNumToMon.put('02','Feb');
        mapNumToMon.put('03','Mar');
        mapNumToMon.put('04','Apr');
        mapNumToMon.put('05','May');
        mapNumToMon.put('06','Jun');
        mapNumToMon.put('07','Jul');
        mapNumToMon.put('08','Aug');
        mapNumToMon.put('09','Sep');
        mapNumToMon.put('10','Oct');
        mapNumToMon.put('11','Nov');
        mapNumToMon.put('12','Dec');
        return mapNumToMon;
	}
    
    /*
    	MethodName  : changeDateFormat
		Input       : Date in String format
		Output      : Date in String format
     	Description : Convert String type to date using parse
    */
    public static string changeDateFormatApexToJS( String strDate ) {
       //strDate = '06/20/2018';
       list<string> lst = strDate.split('/');
       String result = '';
       result+= mapNumToMon.get(lst[0])+' '+lst[1]+', '+lst[2];
       return result;
	}
        
    public class ResultWrap{
        @AuraEnabled public Digital_Campaign__c objDCampaign; //Holds Digital Campaign information
        @AuraEnabled public string strMsg; //Result after Digital Campaign DML
        @AuraEnabled public Boolean isLockRecord; //To lock record in UI level
        @AuraEnabled public list<FlightWrap> lstFlightDates{get;set;} //Holds list of flight dates
    }
    
    public class FlightWrap{
        @AuraEnabled public integer RecordNum{get;set;} //Record Number
        @AuraEnabled public string startDate{get;set;} //Flight StartDate
        @AuraEnabled public string endDate{get;set;} //Flight EndDate
    }
}