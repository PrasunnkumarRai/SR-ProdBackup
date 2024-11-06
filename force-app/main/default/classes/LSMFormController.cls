/*
	Author 				 :  M & S
	Date   				 :  Feb 13-2020
	Description 		 :  Lightning Controller of LSMForm
							Displays CNA Questions from Questions__c based on selected Category
	Modification History : 
*/
public class LSMFormController {
    
    public static List<QuestionWrap> generalQuestionWrap;
    
    public Static List<User> getAEUsers(String struserid) {
		return [SELECT Id, Name FROM User WHERE HR_Manager__c = :struserid order by Name desc];
	}
    
    //Retrieves Questions based on Category from Questions__c object
    @AuraEnabled
    public static list<QuestionWrap> getQuestions(string category){
        list<QuestionWrap> lstQuestions = new list<QuestionWrap>();
        
        for(Questions__c objQuestion : [select Id,Name,Question__c,Question_Type__c,(select Option_Value__c from Question_Items__r order by Option_Value__c)  from Questions__c where RecordType.Name='LSM' order by Order_Number__c]){
            QuestionWrap qw = new QuestionWrap();
            //qw.objQuestion = objQuestion;
            qw.isAnsPicklistOptions = false;
            qw.question = objQuestion.Question__c;
            qw.questionType = objQuestion.Question_Type__c;
            list<CustomSelectOptions> lstAnsPicklistOptions = new list<CustomSelectOptions>();
            list<CustomSelectOptions> lstAnsMultiselPicklistOptions = new list<CustomSelectOptions>();
            
            if(objQuestion.Question_Type__c == 'User Picklist'){
                list<User> lstHRUser = getAEUsers(Userinfo.getUserId());
                System.debug('lstHRUser::'+lstHRUser);
                if(lstHRUser!=null && !lstHRUser.isEmpty()){
                    qw.isAnsPicklistOptions = true;
                    for(User obj : lstHRUser){
                        lstAnsPicklistOptions.add(new CustomSelectOptions(obj.Name,obj.Id));
                    }
                }
            }else if(objQuestion.Question_Type__c!='Text'){
                boolean isMultiPicklist = (objQuestion.Question_Type__c == 'Picklist (Multi-Select)');
                System.debug('isMultiPicklist::'+isMultiPicklist);
                list<Question_Picklist_Value__c> lstQI = objQuestion.Question_Items__r;
                if( lstQI !=null && !lstQI.isEmpty() ){
                    for( Question_Picklist_Value__c objQI : lstQI){
                        //System.debug(pickListVal.getLabel() +' '+pickListVal.getValue());
                        if(isMultiPicklist)
                            lstAnsMultiselPicklistOptions.add(new CustomSelectOptions(objQI.Option_Value__c,objQI.Option_Value__c));
                        else
                            lstAnsPicklistOptions.add(new CustomSelectOptions(objQI.Option_Value__c,objQI.Option_Value__c));
                    }
                }
            }
            System.debug('lstAnsPicklistOptions::'+lstAnsPicklistOptions);
            System.debug('lstAnsMultiselPicklistOptions::'+lstAnsMultiselPicklistOptions);
            qw.lstAnsPicklistOptions = lstAnsPicklistOptions;
            qw.lstAnsMultiselPicklistOptions = lstAnsMultiselPicklistOptions;
            qw.answer = '';
            lstQuestions.add(qw);
        }
        return lstQuestions;
    }
    
    //sending Email
    @AuraEnabled
    public static boolean emailQuestionsAndAnswers(string strgeneralQuestionWrap, string aeid){
        boolean issent = false;
        try{
            System.debug(strgeneralQuestionWrap);
            generalQuestionWrap = (List<QuestionWrap>)JSON.deserialize(strgeneralQuestionWrap, List<QuestionWrap>.class);
            System.debug(generalQuestionWrap);
            String strResult='';
            strResult+='\nQuestions\n';
            for(integer i=0;i<generalQuestionWrap.size();i++){
               strResult+=(i+1)+'. '+ generalQuestionWrap[i].question+'\n';
               string ans = '';
               if(generalQuestionWrap[i].questionType=='Text')
               		ans = (generalQuestionWrap[i].answer!=null)? generalQuestionWrap[i].answer : '';
               else if(generalQuestionWrap[i].questionType=='Picklist')
                    ans = (generalQuestionWrap[i].strSelPicklistOption!=null)? generalQuestionWrap[i].strSelPicklistOption : '';
                else if(generalQuestionWrap[i].questionType=='User Picklist'){
                    User selobjuser = [select id,Name from User where id=:aeid];
                    ans = (selobjuser.Name!=null)? selobjuser.Name : '';
                }               
                else{
                    list<string> lstSelectedAanswers = generalQuestionWrap[i].lstSelectedAanswers;
                    if(lstSelectedAanswers!=null && !lstSelectedAanswers.isEmpty()){
                        ans+='\n';
                        for(string str : lstSelectedAanswers){
                            ans+=str+'\n';
                        }
                    }
                }
                strResult+='Ans. '+ ans+'\n\n';
            }
            System.debug('strResult :\n'+strResult);
            List<string> emailAddress = new List<string>();
            set<string> setEmailRecipient = new set<string>();
            setEmailRecipient.add(UserInfo.getUserId());
            if(aeid!=null)
                setEmailRecipient.add(UserInfo.getUserId());
            list<User> RecipientUsers=[SELECT Email FROM User WHERE Id in :setEmailRecipient] ;
 			for(User objUser : RecipientUsers)
				emailAddress.add(objUser.Email);
            string subject = 'LSM Form';
            EmailHelper.sendEmailToListOfUsers(emailAddress,subject,strResult);
            
        }catch(Exception ex){
            System.debug('Exception :'+ex);
        }
        return issent;
    }
    
    public class QuestionWrap{
        @AuraEnabled public string question;//CNA_Questions__c.Question__c
        @AuraEnabled public string answer;//Answer Text
        @AuraEnabled public string questionType;//Answer Text
        @AuraEnabled public list<CustomSelectOptions> lstAnsPicklistOptions;//Picklist Answer Options
        @AuraEnabled public string strSelPicklistOption;//Picklist Answer Options
        @AuraEnabled public list<CustomSelectOptions> lstAnsMultiselPicklistOptions;//Multiselect Answer Options
        @AuraEnabled public list<string> lstSelectedAanswers;//Selected Answers
        @AuraEnabled public boolean isAnsPicklistOptions;
    }
    
    //Wraper class for Picklist / DualBox
    public class CustomSelectOptions{
        @AuraEnabled public String label {get;set;}
        @AuraEnabled public String value {get;set;}
    
        public CustomSelectOptions() {
            this.label = '';
            this.value = '';
        }
    
        public CustomSelectOptions(String lab, String val) {
            this.label = lab;
            this.value = val;
        }
    }
}