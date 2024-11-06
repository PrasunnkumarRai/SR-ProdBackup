/*
	Author 				 :  M & S
	Date   				 :  Mar 10-2020
	Description 		 :  Lightning Controller of CM_DCTimOrders
							Displays TIM Orders from TIM_Orders__c based on active checkbox
	Modification History : 
*/
public class DCTimOrdersController {
	
    /**
     	MethodName  : PrepareData
		Input       : DigitalCampaign Id
		Output      : List of Records
     	Description : Aura enabled method to prepare the data 
     */
    @AuraEnabled
    public static ResultWrap PrepareData(String dcRecordId){
        ResultWrap objWrap = new ResultWrap();
        try{
            Digital_Campaign__c dcRecord = [Select Id,TIM_Orders_Backend__c
                        from Digital_Campaign__c where id=: dcRecordId];
            String strTIMInfo = dcRecord.TIM_Orders_Backend__c;
            list<string> lstTimData = DCTimOrdersController.getTrafficSystemData();
            list<TIMWrap> lstFW = new list<TIMWrap>();
            if( strTIMInfo!=null ){
                list<string> lstTimInfo = strTIMInfo.split(';');
                if( lstTimInfo!=null && !lstTimInfo.isEmpty() ){
                    for( integer i=0; i<lstTimInfo.size();i++ ){
                        String strDate = lstTimInfo[i];
                        if( strDate!=null ){
                            list<string> lstTim = strDate.split(':');
                            String strTrafficSystem = lstTim[0];
                            String strTimOrder = lstTim[1];
                            TIMWrap objFR = new TIMWrap();
                            objFR.RecordNum = i;
                            objFR.selTrafficSystem = strTrafficSystem;
                            objFR.TIMOrder = strTimOrder;
                            objFR.lstTrafficSystem = lstTimData;
                            System.debug(objFR);
                            lstFW.add(objFR);
                        }
                    }
                    objWrap.lstTimInfo = lstFW; 
                }
            }
        }catch( Exception ex){
            objWrap.strMsg = 'Error : '+ex.getMessage();
        }
        return objWrap;
    }
    
    /**
     	MethodName  : FetchTrafficSystemData
		Input       : 
		Output      : list of values
     	Description : Aura enabled method to update the data 
    */
    @AuraEnabled
    public static list<string> getTrafficSystemData(){
        list<string> lstTimData = new list<string>();
        for(TIM_Orders__c objTimOrd : [select id,Name from TIM_Orders__c where Is_Active__c=true]){
            lstTimData.add(objTimOrd.Name);
        }
        return lstTimData;
    }
    
    /**
     	MethodName  : UpdateData
		Input       : DigitalCampaign Id
		Output      : ResultWrap
     	Description : Aura enabled method to update the data 
     */
    @AuraEnabled
    public static ResultWrap UpdateData(String dcRecordId, String strData){
        Digital_Campaign__c dcRecord = [Select Id,TIM_Orders_Backend__c
                    from Digital_Campaign__c where id=: dcRecordId];
        String strTIMInfo = dcRecord.TIM_Orders_Backend__c;
        ResultWrap objWrap = new ResultWrap();
        System.debug(strTIMInfo+'*****'+strData);
        try{
            if( strTIMInfo!= strData){
                System.debug('Data is Different');
                dcRecord.TIM_Orders_Backend__c = strData;
                update dcRecord;
                dcRecord = [Select Id,TIM_Orders_Backend__c
                    from Digital_Campaign__c where id=: dcRecordId];
                System.debug('dcRecord.TIM_Orders_Backend__c::'+dcRecord.TIM_Orders_Backend__c);
                objWrap.strMsg = 'Tim information have been updated successfully.';
            }
            else{
                System.debug('Data is Same');
                objWrap.strMsg = 'No changes in TrafficSystem.';
            }
            //objWrap = PrepareData(dcRecordId);
        }catch( Exception ex){
            objWrap.strMsg = 'Error : '+ex.getMessage();
        }
        return objWrap;
    }
    
    
    public class ResultWrap{
        @AuraEnabled public Digital_Campaign__c objDCampaign; //Holds Digital Campaign information
        @AuraEnabled public string strMsg; //Result after Digital Campaign DML
        @AuraEnabled public Boolean isLockRecord; //To lock record in UI level
        @AuraEnabled public list<TIMWrap> lstTimInfo{get;set;} //Holds list of dates
    }
    
    public class TIMWrap{
        @AuraEnabled public integer RecordNum{get;set;} //Record Number
        @AuraEnabled public list<string> lstTrafficSystem{get;set;} //TrafficSystem
        @AuraEnabled public string selTrafficSystem{get;set;} //TrafficSystem
        @AuraEnabled public string TIMOrder{get;set;} //TIMOrder
    }
}