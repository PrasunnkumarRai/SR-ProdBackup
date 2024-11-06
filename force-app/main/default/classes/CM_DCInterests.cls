/*
	Author      : M&S
	Date        : Sep 23- 2020
	Description : Apex controller for CM_DCInterests to Add/Remove/Update Interests on DigitalCampaign

*/
public class CM_DCInterests {
	/**
     	MethodName  : PrepareData
		Input       : DigitalCampaign Id
		Output      : List of Flight Records
     	Description : Aura enabled method to prepare the data 
     */
    @AuraEnabled
    public static ResultWrap PrepareData(String dcRecordId){
        ResultWrap objResult = new ResultWrap();
        list<string> lstCategory = fetchCategories();
        Digital_Campaign__c objDCampaign = [select Id,Interest_Category__c,Interest_Sub_Category__c,Interest__c,Recordtype.Name,Status__c from Digital_Campaign__c where id=:dcRecordId];
        objResult.objDCampaign = objDCampaign;
        String category = objDCampaign.Interest_Category__c;//'Automotive,Political';
        String subcategory = objDCampaign.Interest_Sub_Category__c;//'Auto Ownership - Fuel Type,Voter Age';
        String interests = objDCampaign.Interest__c;//'Electric,18-34';
        list<string> arrCat = new list<string>();
        if(category!=null && category!='')
        	arrCat = category.split(',');
        map<string,list<string>> mapCatToSubcat = fetchCategoryOfSubcategories(arrCat);
        
        list<string> arrSC = new list<string>();
        if(subcategory!=null && subcategory!='')
            arrSC = subcategory.split(',');
        list<Interests__c> lstInt = [select Interest_Category__c,Interest_Sub_Category__c,Interest__c from Interests__c where Interest_Category__c in : arrCat and Interest_Sub_Category__c in : arrSC];
		System.debug(lstInt);
        
        list<string> arrInt = new list<string>();
        if(interests!=null && interests!='')
            arrInt = interests.split(',');
        list<IndustryWrap> lstInterest = new list<IndustryWrap>();
        //String customInterest = label.CM_DCInterests_Custom;
        //list<string> lstStr = customInterest.split(',');
        String str1 = 'Custom,Custom,Custom 1';
        String str2 = 'Custom,Custom,Custom 2';
        String str3 = 'Custom,Custom,Custom 3';
        for(integer i=0;i<arrCat.size();i++){
            
            String row = arrCat[i]+','+arrSC[i]+','+arrInt[i];
            System.debug('row::'+row);
            if(row == str1 || row == str2 || row==str3){
                objResult.isWraning = true;
            }
            
            IndustryWrap objIW = new IndustryWrap();
            objIW.category = arrCat[i];
            objIW.lstCategory = lstCategory;
            
            objIW.subCategory = arrSC[i];
            objIW.lstSC = mapCatToSubcat.get(arrCat[i]);
            
            objIW.interest = arrInt[i];
            list<string> lstInterests = new list<string>();
            if(!lstInt.isEmpty()){
                for(Interests__c obj : lstInt){
                    if(obj.Interest_Category__c==arrCat[i] && obj.Interest_Sub_Category__c==arrSC[i]){
                        lstInterests.add(obj.Interest__c);
                    }
                }
            }
            objIW.lstInt = lstInterests;
            
            lstInterest.add(objIW);
        }
        objResult.lstInterest = lstInterest;
        return objResult;
    }
    
    /**
     	MethodName  : saveData
		Input       : Categoryname
		Output      : List of string
     	Description : Aura enabled method to fetchSubCategories 
     */
    @AuraEnabled
    public static void saveData(string dcRecordId, string category, string subcategory, string interest){
        System.debug('dcRecordId::'+dcRecordId);
        System.debug('category::'+category);
        System.debug('subcategoryjs::'+subcategory);
        System.debug('interest::'+interest);
        try{
            Digital_Campaign__c objDCampaign = [select Id,Interest_Category__c,Interest_Sub_Category__c,Interest__c,Recordtype.Name,Status__c from Digital_Campaign__c where id=:dcRecordId];
            if( objDCampaign.Status__c == 'Plan Submitted' &&
                (objDCampaign.Recordtype.Name == 'Inventory Request - Addressable Display' || 
                objDCampaign.Recordtype.Name == 'Inventory Request - Addressable Video') ){
                list<string> lstCat = new list<string>();
                if(category!=null && category!=''){
                	lstCat = category.split(',');
                }
                integer count;
                String str = label.CM_DCInterestsCount;
              	if(str!=null){
                	count = Integer.valueOf(str);
                }
                    
                string strcustom = 'Custom 1,Custom 2,Custom 3';
                list<string> lst = interest.split(',');
                boolean iscustom = false;//Contains custom interest then 2 rows(interests) is mandatory otherwise 3 rows mandatory
                for(string interestVal : lst){
                      if(strcustom.contains(interestVal)){
                          iscustom = true;
                          break;
                      }
                }
                System.debug('iscustom::'+iscustom);
                System.debug('lst::'+lst);
                if(iscustom==true && lst.size() <2){
                      throw new DMLException('Atleast 2 rows(interests) is required for Custom Interests when status is Plan Submitted.');
                }else if(iscustom == false && lst.size() < count){
                      throw new DMLException('Atleast '+label.CM_DCInterestsCount+' rows(interests) is required for NonCustom Interests when status is Plan Submitted.');
                }    
            }
            objDCampaign.Interest_Category__c = category;
            objDCampaign.Interest_Sub_Category__c = subcategory;
            objDCampaign.Interest__c = interest;
            update objDCampaign;
        }catch(Exception ex){
            throw new DMLException(ex.getMessage());
        }
    }
    
    /**
     	MethodName  : fetchCategories
		Output      : List of string
     	Description : Aura enabled method to fetchCategories 
     */
    @AuraEnabled
    public static list<string> fetchCategories(){
        list<string> lstCategory = new list<string>();
        for(AggregateResult objInd : [select Interest_Category__c from Interests__c where Interest_Category__c!=null and Active__c=true group by Interest_Category__c order by Interest_Category__c]){
            lstCategory.add((string)objInd.get('Interest_Category__c'));
        }
        return lstCategory;
    }
    
    /**
     	MethodName  : fetchSubCategories
		Input       : Categoryname
		Output      : List of string
     	Description : Aura enabled method to fetchSubCategories 
     */
    @AuraEnabled
    public static list<string> fetchSubCategories(string strCategory){
        list<string> lstSubCategory = new list<string>();
        for(AggregateResult objInd : [select Interest_Sub_Category__c from Interests__c where Interest_Category__c=:strCategory and Interest_Sub_Category__c!=null group by Interest_Sub_Category__c order by Interest_Sub_Category__c]){
            lstSubCategory.add((string)objInd.get('Interest_Sub_Category__c'));
        }
        System.debug('lstSubCategory::'+lstSubCategory);
        return lstSubCategory;
    }
    
    /**
     	MethodName  : fetchInterests
		Input       : Categoryname, SubCategoryname
		Output      : List of string
     	Description : Aura enabled method to fetchInterests 
     */
    @AuraEnabled
    public static list<string> fetchInterests(string strCategory, string strSubCategory){
        list<string> lstInterest = new list<string>();
        for(Interests__c objInd : [select Interest__c from Interests__c where Interest_Category__c=:strCategory and Interest_Sub_Category__c=:strSubCategory order by Interest__c]){
            lstInterest.add(objInd.Interest__c);
        }
        return lstInterest;
    }
    
    /**
     	MethodName  : fetchCategoryOfSubcategories
		Input       : categories list
		Output      : categories to list of subcategories
     	Description : to fetch subcategories related to specific categories 
     */
    public static map<string,list<string>> fetchCategoryOfSubcategories(list<string> lstCat){
        map<string,list<string>> result = new map<string,list<string>>();
        map<string,set<string>> resultTemp = new map<string,set<string>>();
        for(Interests__c objInd : [select Interest_Category__c,Interest_Sub_Category__c from Interests__c where Interest_Category__c in : lstCat]){
            set<string> setsubcat = new set<string>();
            if(resultTemp.containskey(objInd.Interest_Category__c)){
                setsubcat = resultTemp.get(objInd.Interest_Category__c);
            }
            setsubcat.add(objInd.Interest_Sub_Category__c);
            resultTemp.put(objInd.Interest_Category__c,setsubcat);
        }
        for(string strcat : resultTemp.keyset()){
            list<string> lstsubcat = new list<string>();
            set<string> setsubcat = resultTemp.get(strcat);
            if(!setsubcat.isEmpty()){
                for(string str : setsubcat){
                    lstsubcat.add(str);
                }
                lstsubcat.sort();
            }
            result.put(strcat,lstsubcat);
        }
        return result;
    }
    
    public class ResultWrap{
        @AuraEnabled public Digital_Campaign__c objDCampaign; //Holds Digital Campaign information
        @AuraEnabled public string strMsg; //Result after Digital Campaign DML
        @AuraEnabled public Boolean isWraning; //To lock record in UI level
        @AuraEnabled public list<IndustryWrap> lstInterest{get;set;} //Holds list of Industry
    }
    
    public class IndustryWrap{
        @AuraEnabled public integer RecordNum{get;set;} //Record Number
        @AuraEnabled public string category{get;set;} //Industry Category
        @AuraEnabled public string subCategory{get;set;} //Industry Sub-Category
        @AuraEnabled public string interest{get;set;} //Interest
        @AuraEnabled public list<string> lstCategory{get;set;} //list of categories
        @AuraEnabled public list<string> lstSC{get;set;} //list of subcategories
        @AuraEnabled public list<string> lstInt{get;set;} //list of interests
    }
}