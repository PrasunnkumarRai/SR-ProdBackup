@isTest
public class NewCNAControllerTest {
    //Code coverage forNewCNAController
    static testMethod void testNewCNAController() {
        
        Account objAgencyAcc = TestUtil.getAgencyAccountRec();
        insert objAgencyAcc;
        // now create opptys

        Opportunity objOpp2 = TestUtil.getOpportunityRec(objAgencyAcc.Id);
        objOpp2.Total_Forecast_Amount__c = 10000;
        objOpp2.Created_By_Account_Executive__c = true;
        objOpp2.Temp_AE_Id__c = UserInfo.getUserId();
        objOpp2.AE_Id__c = UserInfo.getUserId();
        insert objOpp2;
        
        list<Questions__c> lstQuestion = new list<Questions__c>();
        Questions__c objQuestion = new Questions__c();
        objQuestion.Category__c = 'General';
        objQuestion.Order_Number__c = 1;
        objQuestion.Question__c = 'What is your Name?';
        objQuestion.Question_Type__c= 'Text';
        lstQuestion.add(objQuestion);
        
        Questions__c objQuestion1 = new Questions__c();
        objQuestion1.Category__c = 'General';
        objQuestion1.Order_Number__c    = 1;
        objQuestion1.Question__c    = 'Do you have phone number?';
        objQuestion1.Question_Type__c= 'Picklist';
        lstQuestion.add(objQuestion1);
        
        Questions__c objQuestion2 = new Questions__c();
        objQuestion2.Category__c = 'General';
        objQuestion2.Order_Number__c    = 1;
        objQuestion2.Question__c    = 'Which Countries you have visited?';
        objQuestion2.Question_Type__c= 'Picklist (Multi-Select)';
        lstQuestion.add(objQuestion2);
        
        insert lstQuestion;
        
        list<Question_Picklist_Value__c> lstQI = new list<Question_Picklist_Value__c>();
        Question_Picklist_Value__c objQI1 = new Question_Picklist_Value__c();
        objQI1.Questions__c = lstQuestion[1].Id;
        objQI1.Option_Value__c = 'Yes';
        lstQI.add(objQI1);
        
        Question_Picklist_Value__c objQI2 = new Question_Picklist_Value__c();
        objQI2.Questions__c = lstQuestion[1].Id;
        objQI2.Option_Value__c = 'No';
        lstQI.add(objQI2);
        
        Question_Picklist_Value__c objQI3 = new Question_Picklist_Value__c();
        objQI3.Questions__c = lstQuestion[2].Id;
        objQI3.Option_Value__c = 'IND';
        lstQI.add(objQI3);
        
        Question_Picklist_Value__c objQI4 = new Question_Picklist_Value__c();
        objQI4.Questions__c = lstQuestion[2].Id;
        objQI4.Option_Value__c = 'USA';
        lstQI.add(objQI4);
        insert lstQI;
        
        list<Questions__c> lstSuppQuestion = new list<Questions__c>();
        Questions__c objQuestion3 = new Questions__c();
        objQuestion3.Category__c = 'Retail';
        objQuestion3.Order_Number__c    = 1;
        objQuestion3.Question__c    = 'What is your Name?';
        objQuestion3.Question_Type__c= 'Text';
        lstSuppQuestion.add(objQuestion3);
        
        Questions__c objQuestion4 = new Questions__c();
        objQuestion4.Category__c = 'Retail';
        objQuestion4.Order_Number__c    = 1;
        objQuestion4.Question__c    = 'Do you have phone number?';
        objQuestion4.Question_Type__c= 'Picklist';
        lstSuppQuestion.add(objQuestion4);
        
        Questions__c objQuestion5 = new Questions__c();
        objQuestion5.Category__c = 'Retail';
        objQuestion5.Order_Number__c    = 1;
        objQuestion5.Question__c    = 'Which Countries you have visited?';
        objQuestion5.Question_Type__c= 'Picklist (Multi-Select)';
        lstSuppQuestion.add(objQuestion5);
        insert lstSuppQuestion;
        
        list<Question_Picklist_Value__c> lstSQI = new list<Question_Picklist_Value__c>();
        Question_Picklist_Value__c objQI15 = new Question_Picklist_Value__c();
        objQI15.Questions__c = lstSuppQuestion[1].Id;
        objQI15.Option_Value__c = 'Yes';
        lstSQI.add(objQI15);
        
        Question_Picklist_Value__c objQI16 = new Question_Picklist_Value__c();
        objQI16.Questions__c = lstSuppQuestion[1].Id;
        objQI16.Option_Value__c = 'No';
        lstSQI.add(objQI16);
        
        Question_Picklist_Value__c objQI7 = new Question_Picklist_Value__c();
        objQI7.Questions__c = lstSuppQuestion[2].Id;
        objQI7.Option_Value__c = 'IND';
        lstSQI.add(objQI7);
        
        Question_Picklist_Value__c objQI8 = new Question_Picklist_Value__c();
        objQI8.Questions__c = lstSuppQuestion[2].Id;
        objQI8.Option_Value__c = 'USA';
        lstSQI.add(objQI8);
        insert lstSQI;
        
        NewCNAController.getCategoryTypes(objOpp2.Id);
        NewCNAController.getCategoryTypes(objOpp2.AccountId);
        list<NewCNAController.QuestionWrap> lstGen = NewCNAController.getQuestions('General','CNA');
        lstGen[1].strSelPicklistOption = lstQI[0].Id;
        lstGen[2].lstSelectedAanswers = new List<string>{lstQI[2].Id, lstQI[3].Id};
        string strgeneralQuestionWrap = JSON.serialize(lstGen);
        list<NewCNAController.QuestionWrap> lstSup = NewCNAController.getQuestions('Retail','CNA');
        for(NewCNAController.QuestionWrap objSWrap : lstSup){
            System.debug(objSWrap.lstAnsPicklistOptions);
            System.debug(objSWrap.lstAnsMultiselPicklistOptions);
        }
        lstSup[1].strSelPicklistOption = lstSQI[0].Id;
        lstSup[2].lstSelectedAanswers = new List<string>{lstSQI[2].Id, lstSQI[3].Id};
        string strsupplementalQuestionWrap = JSON.serialize(lstSup);
        String strCNAWithOpp = NewCNAController.insertQuestionsAndAnswers(objOpp2.Id,'General','Retail',strgeneralQuestionWrap,strsupplementalQuestionWrap,'CNA');
        list<NewCNAController.AnswerForm> lstAWO = NewCNAController.getAnswers(strCNAWithOpp,'Questionnaire');
        NewCNAController.saveAnswers(strCNAWithOpp,JSON.serialize(lstAWO), strsupplementalQuestionWrap);
        String strCNAWithAcc = NewCNAController.insertQuestionsAndAnswers(objOpp2.AccountId,'General','Retail',strgeneralQuestionWrap,strsupplementalQuestionWrap,'CNA');
        list<NewCNAController.AnswerForm> lstAWA = NewCNAController.getAnswers(strCNAWithAcc,'Questionnaire');
        NewCNAController.getCategoryTypesForEdit(strCNAWithAcc,'Questionnaire');
        NewCNAController.saveAnswers(strCNAWithAcc,JSON.serialize(lstAWA),strsupplementalQuestionWrap);
        
        
    }
    
    //Code coverage for NewLSMController
    static testMethod void testLSMController() {
        
        RecordType rt = [SELECT Id, Name FROM RecordType WHERE SobjectType = 'Questions__c' and Name='LSM'];
            
        list<Questions__c> lstQuestion = new list<Questions__c>();
        Questions__c objQuestion = new Questions__c();
        objQuestion.Category__c = 'General';
        objQuestion.Order_Number__c = 1;
        objQuestion.Question__c = 'What is your Name?';
        objQuestion.Question_Type__c= 'Text';
        lstQuestion.add(objQuestion);
        
        Questions__c objQuestion1 = new Questions__c();
        objQuestion1.Category__c = 'General';
        objQuestion1.Order_Number__c    = 1;
        objQuestion1.Question__c    = 'Do you have phone number?';
        objQuestion1.Question_Type__c= 'Picklist';
        lstQuestion.add(objQuestion1);
        
        Questions__c objQuestion2 = new Questions__c();
        objQuestion2.Category__c = 'General';
        objQuestion2.Order_Number__c    = 1;
        objQuestion2.Question__c    = 'Which Countries you have visited?';
        objQuestion2.Question_Type__c= 'Picklist (Multi-Select)';
        lstQuestion.add(objQuestion2);
        
        Questions__c objQuestion3 = new Questions__c();
        objQuestion3.Category__c = 'Retail';
        objQuestion3.Order_Number__c    = 1;
        objQuestion3.Question__c    = 'What is your Name?';
        objQuestion3.Question_Type__c= 'Text';
        lstQuestion.add(objQuestion3);
        
        Questions__c objQuestion4 = new Questions__c();
        objQuestion4.Category__c = 'Retail';
        objQuestion4.Order_Number__c    = 1;
        objQuestion4.Question__c    = 'Do you have phone number?';
        objQuestion4.Question_Type__c= 'Picklist';
        lstQuestion.add(objQuestion4);
        
        Questions__c objQuestion5 = new Questions__c();
        objQuestion5.Category__c = 'Retail';
        objQuestion5.Order_Number__c    = 1;
        objQuestion5.Question__c    = 'Which Countries you have visited?';
        objQuestion5.Question_Type__c= 'Picklist (Multi-Select)';
        lstQuestion.add(objQuestion5);
        
        Questions__c objQuestion6 = new Questions__c();
        objQuestion6.Category__c = 'General';
        objQuestion6.Order_Number__c    = 1;
        objQuestion6.Question__c    = 'Account Executive';
        objQuestion6.Question_Type__c= 'User Picklist';
        lstQuestion.add(objQuestion6);
        
        for(Questions__c obj : lstQuestion){
            if(rt!=null && rt.Id!=null)
                obj.RecordtypeId = rt.Id;
        }
        insert lstQuestion;
        
        list<Question_Picklist_Value__c> lstQI = new list<Question_Picklist_Value__c>();
        Question_Picklist_Value__c objQI1 = new Question_Picklist_Value__c();
        objQI1.Questions__c = lstQuestion[1].Id;
        objQI1.Option_Value__c = 'Yes';
        lstQI.add(objQI1);
        
        Question_Picklist_Value__c objQI2 = new Question_Picklist_Value__c();
        objQI2.Questions__c = lstQuestion[1].Id;
        objQI2.Option_Value__c = 'No';
        lstQI.add(objQI2);
        
        Question_Picklist_Value__c objQI3 = new Question_Picklist_Value__c();
        objQI3.Questions__c = lstQuestion[2].Id;
        objQI3.Option_Value__c = 'IND';
        lstQI.add(objQI3);
        
        Question_Picklist_Value__c objQI4 = new Question_Picklist_Value__c();
        objQI4.Questions__c = lstQuestion[2].Id;
        objQI4.Option_Value__c = 'USA';
        lstQI.add(objQI4);
        
        Question_Picklist_Value__c objQI15 = new Question_Picklist_Value__c();
        objQI15.Questions__c = lstQuestion[1].Id;
        objQI15.Option_Value__c = 'Yes';
        lstQI.add(objQI15);
        
        Question_Picklist_Value__c objQI16 = new Question_Picklist_Value__c();
        objQI16.Questions__c = lstQuestion[1].Id;
        objQI16.Option_Value__c = 'No';
        lstQI.add(objQI16);
        
        Question_Picklist_Value__c objQI7 = new Question_Picklist_Value__c();
        objQI7.Questions__c = lstQuestion[2].Id;
        objQI7.Option_Value__c = 'IND';
        lstQI.add(objQI7);
        
        Question_Picklist_Value__c objQI8 = new Question_Picklist_Value__c();
        objQI8.Questions__c = lstQuestion[2].Id;
        objQI8.Option_Value__c = 'USA';
        lstQI.add(objQI8);
        insert lstQI;
        
        Account objAgencyAcc = TestUtil.getAgencyAccountRec();
        insert objAgencyAcc;
        // now create opptys

        Opportunity objOpp2 = TestUtil.getOpportunityRec(objAgencyAcc.Id);
        objOpp2.Total_Forecast_Amount__c = 10000;
        objOpp2.Created_By_Account_Executive__c = true;
        objOpp2.Temp_AE_Id__c = UserInfo.getUserId();
        objOpp2.AE_Id__c = UserInfo.getUserId();
        insert objOpp2;
        list<LSMFormController.QuestionWrap> lstGen = LSMFormController.getQuestions(objOpp2.Id);
        string strgeneralQuestionWrap = JSON.serialize(lstGen);
        LSMFormController.emailQuestionsAndAnswers(strgeneralQuestionWrap,userinfo.getUserId());
    }
}