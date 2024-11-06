/*
    Author      : M & S
    Date        : 17 Jan- 2020
    Description : Helper Class for CM_CloneDCCreativesController, CM_CloneMultipleDCCreatives
    Modification History :
*/
public class CM_CloneDCHelper {
	
    /*
        Description : Check From and To DigitalCampaign recordtype combination is exists in DCC_Clone_Matrix__mdt(CustomMetaType) 
        Input       : From DigitalCampaign, To DigitalCampaign
        Output      : combination is exists or not in CustomMetatype
    */
    public static boolean checkForValidDC(Digital_Campaign__c fromDCObj , Digital_Campaign__c toDCObj) {
        Boolean validRectypes = false;
        try 
        {
            //Initializing a wrapper list
            String fromRecType = FromDCObj.RecordType.Name;
            String toRecType = toDCObj.RecordType.Name;
            List<DCC_Clone_Matrix__mdt> dcc_clone_MatrixLst = [Select From_Digital_Campaign_RecordType__c,To_Digital_Campaign_RecordType__c from DCC_Clone_Matrix__mdt limit 50000];
            for(DCC_Clone_Matrix__mdt cloneMatrix : dcc_clone_MatrixLst) {
                if(cloneMatrix.From_Digital_Campaign_RecordType__c == fromRecType && cloneMatrix.To_Digital_Campaign_RecordType__c == toRecType) {
                    validRectypes = true;
                    break;
                }
            }
        }
        catch(Exception exp)
        {
            System.debug('--->'+exp.getMessage());
        }
        return validRectypes;
    }
    
    /*
        Description : Supporting method of CreateCloneDigitalCreative.
        Input       : List of Selected Digital Cretives, To Digital Campaign Id 
        Output      : List of Digital Creatives.
    */
    public static list<Digital_Creative__c> FilterSeletedDigitalCreative(list<CM_DCCWrap> SelectedCons,id strDCId)
    {
        //Initializing a new list.
        list<Digital_Creative__c> newDCCList = new list<Digital_Creative__c>();
        if (!SelectedCons.isEmpty())
        {
            //system.debug('SelectedCons--->'+SelectedCons);
            list<Digital_Creative__c> SelDCCList = new list<Digital_Creative__c>();
            //Looping all the wrapper Digital_Creative__c and filtering checked Digital_Creative__c
            for(CM_DCCWrap cw : SelectedCons)
            {
                if(cw.isCheck == true)
                {
                    system.debug('--->'+cw.IsCheck);
                    SelDCCList.add(cw.Con);
                }
            }
            //system.debug('--->'+SelDCCList);
            if(!SelDCCList.isEmpty())
            {
                //Looping all the checked Digital_Creative__c and cloning them
                for (Digital_Creative__c c : SelDCCList)
                {
                    //Cloning each Digital_Creative__c
                    Digital_Creative__c objClone = c.clone(false,false,false,false);
                    //Assainigng parent account ID
                    objClone.Digital_Campaign__c = strDCId;
                    objClone.Status__c = '01 Draft Creative';
                    objClone.Creative_Ready_for_Trafficking__c = false;//SRSF-1424
                    objClone.Has_Hit_05_Trafficked_by_Dig_Ops__c = false;
                    objClone.Bypass_Apex_Execution__c = true;
                    objClone.Source__c = 'Cloned from DCC';
                    
                    //Adding cloned Digital_Creative__c to new list to insert
                    newDCCList.add(objClone);
                }
            }
        }
        return newDCCList;
    }
}