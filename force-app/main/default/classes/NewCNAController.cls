/*
  Author               :  M & S
  Date                 :  Feb 13-2020
  Description          :  Lightning Controller of NewCNAOverhaul
  Displays CNA Questions from CNA_Questions__c based on selected Category
  Modification History : 
*/
public class NewCNAController {

    //Retrieve Actual CNA
	@AuraEnabled
	public static string getRelatedCNA(string strCNAId) {
        CNA__c obj = [select id,CNA_link__c from CNA__c where id=:strCNAId];
        return obj.CNA_link__c; 
    }
    
    //Retrieve AE from CNA
    @AuraEnabled
    public static string getAeCNA(string strCNAId) {
		CNA__c obj = [SELECT id,Account_Executive__r.Id FROM CNA__c WHERE Id =:strCNAId];
        return obj.Account_Executive__r.Id;
	}
    
	//Retrieve Category__c picklist values from CNA_Questions__c object
	@AuraEnabled
	public static list<string> getCategoryTypes(string opportunityId) {
		boolean isPermission = false;
		if (opportunityId.startsWith('006')) {
			Opportunity objOppty = [SELECT Id, AccountId, Account.Agency__c, Account.ShippingStreet,
			                        Account.ShippingCity, Account.ShippingState, OwnerId,
			                        Owner.Sales_Office__c, Owner.Division__c, Owner.Region__c, (SELECT Id, OpportunityId, UserId FROM OpportunityTeamMembers where UserId = :Userinfo.getUserId())
			                        FROM Opportunity
			                        WHERE Id = :opportunityId limit 1];
			if (objOppty.OpportunityTeamMembers.size() > 0 || objOppty.OwnerId == Userinfo.getUserId()) { //checking for Opportunity Owner or TeamMember
				isPermission = true;
			}
		} else {
			if (opportunityId.startsWith('001')) {
				Account objAcc = [SELECT Id, Agency__c, ShippingStreet,
				                  ShippingCity, ShippingState, OwnerId,
				                  Owner.Sales_Office__c, Owner.Division__c, Owner.Region__c, (SELECT Id, AccountId, UserId FROM AccountTeamMembers where UserId = :Userinfo.getUserId())
				                  FROM Account
				                  WHERE Id = :opportunityId limit 1];
				if (objAcc.AccountTeamMembers.size() > 0 || objAcc.OwnerId == Userinfo.getUserId()) { //checking for Account Owner or TeamMember
					isPermission = true;
				}
			}
		}
		if (isPermission) { //checking for Account/Opportunity Owner or TeamMember
			list<string> lstCategories = new list<string> ();
			String objectName = 'Questions__c';
			String fieldName = 'Category__c';

			Schema.SObjectType s = Schema.getGlobalDescribe().get(objectName);
			Schema.DescribeSObjectResult r = s.getDescribe();
			Map<String, Schema.SObjectField> fields = r.fields.getMap();
			Schema.DescribeFieldResult fieldResult = fields.get(fieldName).getDescribe();
			List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
			for (Schema.PicklistEntry pickListVal : ple) {
				//System.debug(pickListVal.getLabel() +' '+pickListVal.getValue());
				if (pickListVal.getValue() != 'General')
				lstCategories.add(pickListVal.getValue());
			}
			return lstCategories;
		} else
		return null;
	}

	//Retrieve Category__c picklist values from Questions__c object
	@AuraEnabled
	public static list<string> getCategoryTypesForEdit(string strCNAId, string recordTypeName) {
		System.debug('strCNAId::' + strCNAId);
		System.debug('recordTypeName::' + recordTypeName);
		list<string> lstCategories = new list<string> ();
		if (recordTypeName == 'CNA Prep Sheet') {
			return lstCategories;
		}
		set<string> setExcludeCatergory = new set<string> ();
		for (Answer__c objAns :[select Id, Questions__r.Category__c from Answer__c where CNA__c = :strCNAId and CNA__r.RecordType.Name = :recordTypeName order by Questions__r.Category__c]) {
			setExcludeCatergory.add(objAns.Questions__r.Category__c);
		}
		String objectName = 'Questions__c';
		String fieldName = 'Category__c';

		Schema.SObjectType s = Schema.getGlobalDescribe().get(objectName);
		Schema.DescribeSObjectResult r = s.getDescribe();
		Map<String, Schema.SObjectField> fields = r.fields.getMap();
		Schema.DescribeFieldResult fieldResult = fields.get(fieldName).getDescribe();
		List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
		for (Schema.PicklistEntry pickListVal : ple) {
			//System.debug(pickListVal.getLabel() +' '+pickListVal.getValue());
			if (pickListVal.getValue() != 'General' && !setExcludeCatergory.contains(pickListVal.getValue()))
			lstCategories.add(pickListVal.getValue());
		}
		return lstCategories;
	}

	//Retrieves Questions based on Category from Questions__c object
	@AuraEnabled
    public static list<QuestionWrap> getQuestions(string category, string recordTypeName) {
		list<QuestionWrap> lstQuestions = new list<QuestionWrap> ();

		for (Questions__c objQuestion :[select Id, Name, Question__c, Question_Type__c, (select Option_Value__c from Question_Items__r order by Option_Value__c) from Questions__c where RecordType.Name = :recordTypeName and Category__c = :category order by Order_Number__c]) {
			QuestionWrap qw = new QuestionWrap();
			//qw.objQuestion = objQuestion;
			qw.question = objQuestion.Question__c;
			qw.questionType = objQuestion.Question_Type__c;
			qw.questionId = objQuestion.Id;
			//list<string> lstAnsPicklistOptions = new list<string>();
			list<CustomSelectOptions> lstAnsPicklistOptions = new list<CustomSelectOptions> ();
			list<CustomSelectOptions> lstAnsMultiselPicklistOptions = new list<CustomSelectOptions> ();
			boolean isMultiPicklist = (objQuestion.Question_Type__c == 'Picklist (Multi-Select)');
			System.debug('isMultiPicklist::' + isMultiPicklist);
			list<Question_Picklist_Value__c> lstQI = objQuestion.Question_Items__r;
			if (lstQI != null && !lstQI.isEmpty()) {
				for (Question_Picklist_Value__c objQI : lstQI) {
					//System.debug(pickListVal.getLabel() +' '+pickListVal.getValue());
					if (isMultiPicklist)
					lstAnsMultiselPicklistOptions.add(new CustomSelectOptions(objQI.Option_Value__c, objQI.Id));
					else {
						//lstAnsPicklistOptions.add(objQI.Option_Value__c);
						lstAnsPicklistOptions.add(new CustomSelectOptions(objQI.Option_Value__c, objQI.Id));
					}
				}
			}
			System.debug('lstAnsPicklistOptions::' + lstAnsPicklistOptions);
			System.debug('lstAnsMultiselPicklistOptions::' + lstAnsMultiselPicklistOptions);
			qw.lstAnsPicklistOptions = lstAnsPicklistOptions;
			qw.lstAnsMultiselPicklistOptions = lstAnsMultiselPicklistOptions;
			//qw.answer = '';
			lstQuestions.add(qw);
		}
		return lstQuestions;
	}

	//creating CNA based on user input
	@AuraEnabled
	public static string insertQuestionsAndAnswers(string opportunityId, string generalCategory, string supplementalCategory, string strgeneralQuestionWrap, string strsupplementalQuestionWrap, string recordTypeName) {
		CNA__c obj = new CNA__c();
		CNA__c obj1 = new CNA__c();
		try {
			if (opportunityId.startsWith('006')) {
				Opportunity objOppty = [SELECT Id, AccountId, Account.Agency__c, Account.ShippingStreet,
				                        Account.ShippingCity, Account.ShippingState, OwnerId,
				                        Owner.Sales_Office__c, Owner.Division__c, Owner.Region__c
				                        FROM Opportunity
				                        WHERE Id = :opportunityId limit 1];
				obj.put('Opportunity__c', objOppty.Id);
				obj.put('Account_Executive__c', objOppty.OwnerId);
				obj.put('Sales_Office__c', objOppty.Owner.Sales_Office__c);
				obj.put('Division__c', objOppty.Owner.Division__c);
				obj.put('Region__c', objOppty.Owner.Region__c);

				if (objOppty.AccountId != null) {
					obj.put('Account__c', objOppty.AccountId);

					String location = objOppty.Account.ShippingStreet != null ? objOppty.Account.ShippingStreet + ', ' : '';
					location += objOppty.Account.ShippingCity != null ? objOppty.Account.ShippingCity + ', ' : '';
					location += objOppty.Account.ShippingState != null ? objOppty.Account.ShippingState + ', ' : '';
					location = location.EndsWith(', ') ? location.subStringBeforeLast(', ') : location;
					obj.put('Location__c', location);
				}
				if (objOppty.Account.Agency__c != null) {
					obj.put('Agency__c', objOppty.Account.Agency__c);
				}
			} else if (opportunityId.startsWith('001')) {
				Account objAcc = [SELECT Id, Agency__c, ShippingStreet,
				                  ShippingCity, ShippingState, OwnerId,
				                  Owner.Sales_Office__c, Owner.Division__c, Owner.Region__c
				                  FROM Account
				                  WHERE Id = :opportunityId limit 1];
				User objUser = [SELECT Id, Sales_Office__c, Division__c, Region__c FROM User where Id = :Userinfo.getUserId()];
                obj.put('Account__c', objAcc.Id);
				obj.put('Account_Executive__c', Userinfo.getUserId());
				obj.put('Sales_Office__c', objUser.Sales_Office__c);
				obj.put('Division__c', objUser.Division__c);
				obj.put('Region__c', objUser.Region__c);

				if (objAcc.Id != null) {
					obj.put('Account__c', objAcc.Id);

					String location = objAcc.ShippingStreet != null ? objAcc.ShippingStreet + ', ' : '';
					location += objAcc.ShippingCity != null ? objAcc.ShippingCity + ', ' : '';
					location += objAcc.ShippingState != null ? objAcc.ShippingState + ', ' : '';
					location = location.EndsWith(', ') ? location.subStringBeforeLast(', ') : location;
					obj.put('Location__c', location);

				}
				if (objAcc.Agency__c != null) {
					obj.put('Agency__c', objAcc.Agency__c);
				}
			}
			

			System.debug(strgeneralQuestionWrap);
			List<QuestionWrap> generalQuestionWrap = (List<QuestionWrap>) JSON.deserialize(strgeneralQuestionWrap, List<QuestionWrap>.class);
			System.debug('strsupplementalQuestionWrap::' + strsupplementalQuestionWrap);
			List<QuestionWrap> supplementalQuestionWrap = (List<QuestionWrap>) JSON.deserialize(strsupplementalQuestionWrap, List<QuestionWrap>.class);
			System.debug('opportunityId::' + opportunityId);
			System.debug('generalCategory::' + generalCategory);
			System.debug('supplementalCategory::' + supplementalCategory);
			System.debug('generalQuestionWrap::' + generalQuestionWrap);
			System.debug('supplementalQuestionWrap::' + supplementalQuestionWrap);
			System.debug('recordTypeName::' + recordTypeName);


			List<QuestionWrap> cnaQuestions = new List<QuestionWrap>();
			List<RecordType> rtList = [SELECT Id, Name FROM RecordType WHERE SobjectType = 'CNA__c'];
			Map<String, String> rtMap = new Map<String, String> ();
			for (RecordType rt : rtList)
			{
				rtMap.put(rt.Name, rt.Id);
			}
            obj1 = obj.clone();
            if (recordTypeName == 'CNA Prep Sheet') {
                obj1.RecordtypeId = rtMap.get('Questionnaire');
                obj.RecordtypeId = rtMap.get('CNA Prep');
                obj.Account__c = null;
                cnaQuestions = NewCNAController.getQuestions('General','CNA');
            }else{
                obj1.RecordtypeId = rtMap.get('CNA Prep');
                obj.RecordtypeId = rtMap.get('Questionnaire');
                obj1.Account__c = null;
                cnaQuestions = NewCNAController.getQuestions('General','CNA Prep Sheet');
            }
            
			/*if (recordTypeName == 'CNA Prep Sheet') {

				obj1 = obj.clone();
				obj1.RecordtypeId = rtMap.get('Questionnaire');
				cnaQuestions = NewCNAController.getQuestions('General','CNA');
				insert obj1;
				obj.RecordtypeId = rtMap.get('CNA Prep');
				obj.CNA_Link__c = obj1.ID;

			}
			else {
				obj.RecordtypeId = rtMap.get('Questionnaire');
			}*/

			if (!generalQuestionWrap.isEmpty() || !supplementalQuestionWrap.isEmpty()) {
				insert obj;
                obj1.CNA_Link__c = obj.Id;
                insert obj1;
                obj.CNA_Link__c = obj1.Id;
                update obj;
			}
			if (!supplementalQuestionWrap.isEmpty()) {
				generalQuestionWrap.addAll(supplementalQuestionWrap);
			}
			map<string, string> mapQuestion = new map<string, string> ();
			map<string, list<string>> mapQuestionToSelectedAnswer = new map<string, list<string>> ();
			list<Answer__c> lstAnswers = new list<Answer__c> ();
			set<string> setSelectedQOptions = new set<string> ();
			for (QuestionWrap objGeneral : generalQuestionWrap) {
				if (objGeneral.questionType == 'Picklist') {
					list<string> lstSelAns = new list<string> ();
					mapQuestionToSelectedAnswer.put(objGeneral.questionId, lstSelAns);
					if (objGeneral.strSelPicklistOption != null) {
						lstSelAns.add(objGeneral.strSelPicklistOption);
						setSelectedQOptions.add(objGeneral.strSelPicklistOption);
					}
					mapQuestionToSelectedAnswer.put(objGeneral.questionId, lstSelAns);
				} else if (objGeneral.questionType == 'Picklist (Multi-Select)') {
					list<string> lstSelAns = new list<string> ();
					mapQuestionToSelectedAnswer.put(objGeneral.questionId, lstSelAns);
					if (objGeneral.lstSelectedAanswers != null && objGeneral.lstSelectedAanswers.size() > 0) {
						for (string str : objGeneral.lstSelectedAanswers) {
							lstSelAns.add(str);
							setSelectedQOptions.add(str);
						}
					}
					mapQuestionToSelectedAnswer.put(objGeneral.questionId, lstSelAns);
				}
				mapQuestion.put(objGeneral.questionId, objGeneral.question);
			}
			map<Id, Question_Picklist_Value__c> mapSelQI = new map<Id, Question_Picklist_Value__c> ();
			if (!setSelectedQOptions.isEmpty()) {
				for (Question_Picklist_Value__c objQI :[select id, Name from Question_Picklist_Value__c where id in :setSelectedQOptions]) {
					mapSelQI.put(objQI.Id, objQI);
				}
			}
			for (QuestionWrap objGeneral : cnaQuestions) {
				Answer__c objAns = new Answer__c();
				String strQName = objGeneral.question;
				if (strQName.length() > 80)
				strQName = strQName.substring(0, 79);
				//objAns.Name   = strQName;
				if (objGeneral.questionType == 'Text') {
					objAns.Answer_With_Text__c = objGeneral.answer;
				}
				objAns.Questions__c = objGeneral.questionId;
				objAns.Question_Name__c = objGeneral.question;
				objAns.CNA__c = obj1.Id;
				lstAnswers.add(objAns);
			}
			System.debug(lstAnswers);
			System.debug('mapQuestionToSelectedAnswer::' + mapQuestionToSelectedAnswer);
			for (QuestionWrap objGeneral : generalQuestionWrap) {
				Answer__c objAns = new Answer__c();
				String strQName = objGeneral.question;
				if (strQName.length() > 80)
				strQName = strQName.substring(0, 79);
				//objAns.Name   = strQName;
				if (objGeneral.questionType == 'Text') {
					objAns.Answer_With_Text__c = objGeneral.answer;
				}
				objAns.Questions__c = objGeneral.questionId;
				objAns.Question_Name__c = objGeneral.question;
				objAns.CNA__c = obj.Id;
				lstAnswers.add(objAns);
			}
			System.debug(lstAnswers);

			map<string, Answer__c> mapQuestionToAnswer = new map<string, Answer__c> ();
			if (!lstAnswers.isEmpty()) {
				insert lstAnswers;
				for (Answer__c objAns : lstAnswers) {
					mapQuestionToAnswer.put(objAns.Questions__c, objAns);
				}
				if (!mapQuestionToSelectedAnswer.isEmpty()) {
					map<string, string> mapAnswerToAnswerOptions = new map<string, string> (); //updating Answer__c.Answer_Items__c with Combined selected answeroptions with ';'
					list<Answer_Picklist_Value__c> lstAI = new list<Answer_Picklist_Value__c> ();
					for (string str : mapQuestionToSelectedAnswer.keyset()) {
						list<string> lstSelAns = mapQuestionToSelectedAnswer.get(str);
						if (lstSelAns != null && !lstSelAns.isEmpty()) {
							for (string strSelOpt : lstSelAns) {

								Answer_Picklist_Value__c objAI = new Answer_Picklist_Value__c();
								String AnswerId = mapQuestionToAnswer.get(str).Id;
								objAI.Answer__c = AnswerId;
								String strSelectedQOptionName = mapSelQI.get(strSelOpt).Name;
								String strSelectedQOptionNames = mapSelQI.get(strSelOpt).Name + ';';
								if (mapAnswerToAnswerOptions.containskey(AnswerId))
								strSelectedQOptionNames += mapAnswerToAnswerOptions.get(AnswerId);
								mapAnswerToAnswerOptions.put(AnswerId, strSelectedQOptionNames);

								if (strSelectedQOptionName.length() > 80) {
									strSelectedQOptionName = strSelectedQOptionName.substring(0, 79);
								}
								objAI.Question_Name__c = mapQuestion.get(str);
								objAI.Name = strSelectedQOptionName;
								objAI.Selected_Question_Items__c = strSelOpt;
								lstAI.add(objAI);
							}
						}
					}
					if (!lstAI.isEmpty()) {
						insert lstAI;
						if (!mapAnswerToAnswerOptions.isEmpty()) {
							for (Answer__c objAns : lstAnswers) {
								objAns.Answer_Items__c = mapAnswerToAnswerOptions.get(objAns.Id);
							}
							update lstAnswers;
						}
					}
				}
			}
		} catch(DMLException ex) { //SRSF-4428 : Added DMLException Block
			System.debug(ex);			
			throw new DMLException(ex.getDmlMessage(0));
		} catch (Exception ex) { 
			System.debug(ex);
			throw new AuraHandledException(ex.getMessage()); //SRSF-4428 : Added AuraHandledException
		}
		return obj.Id;
	}

	//Questions and Answers related to the CNA (Editing existing Answers)
	@AuraEnabled
	public static list<AnswerForm> getAnswers(string strCNAId, string recordTypeName) {
		System.debug('strCNAId::' + strCNAId);
        System.debug('recordTypeName::' + recordTypeName);
        string relatedCNA = getRelatedCNA(strCNAId);
        System.debug('relatedCNA::' + relatedCNA);
        for(CNA__c objCNA : [select id,Recordtype.Name from CNA__c where id=:strCNAId OR id=:relatedCNA]){
            if(objCNA.Recordtype.Name == recordTypeName){
               strCNAId = objCNA.Id;
                break;
            }
        }
		list<Answer__c> lstAns = new List<Answer__c>();
		lstAns = [select Id, Name, Question_Name__c, Answer_With_Text__c, Answer_Items__c, Questions__c, Questions__r.Category__c, Questions__r.Question_Type__c, (select id, Selected_Question_Items__c, Selected_Question_Items__r.Name from Answer_Items__r) from Answer__c where CNA__c = :strCNAId order by Questions__r.Category__c];
		System.debug('recordTypeName' + recordTypeName);
		System.debug('lstAns' + lstAns);
		map<string, Answer__c> mapAnswer = new map<string, Answer__c> ();
		
		for (Answer__c objAns :[select Id, Name, Question_Name__c, Answer_With_Text__c, Answer_Items__c, Questions__c, Questions__r.Category__c, Questions__r.Question_Type__c from Answer__c where CNA__c = :strCNAId order by Questions__r.Category__c]) {
			mapAnswer.put(objAns.Id, objAns);
		}
		map<string, list<Question_Picklist_Value__c>> mapQToQI = new map<string, list<Question_Picklist_Value__c>> ();
		for (Answer__c objAns : lstAns) {
			System.debug('objAns.Answer_With_Text__c::' + objAns.Answer_With_Text__c);
			mapQToQI.put(objAns.Questions__c, null);
		}
		//Preparing all options related to Questions
		if (!mapQToQI.isEmpty()) {
			for (Questions__c objQuestion :[select Id, Name, Question__c, Question_Type__c, (select Option_Value__c from Question_Items__r order by Option_Value__c) from Questions__c where Id in :mapQToQI.keySet() order by Category__c]) {
				mapQToQI.put(objQuestion.Id, objQuestion.Question_Items__r);
			}
		}

		//Preparing Answer Wraper for each Answer
		list<AnswerForm> lstAF = new list<AnswerForm> ();
		for (Answer__c objAns : lstAns) {
			AnswerForm objAnsWrap = new AnswerForm();
			objAnsWrap.objAns = mapAnswer.get(objAns.Id);
			objAnsWrap.question = objAns.Question_Name__c;
			objAnsWrap.answer = objAns.Answer_With_Text__c; //Answer Text
			objAnsWrap.questionType = objAns.Questions__r.Question_Type__c; //Question Type(Text/Picklist/MultiselectPicklist)
			objAnsWrap.answerId = objAns.Id; //Answer RecordId
			if (objAnsWrap.questionType == 'Picklist' || objAnsWrap.questionType == 'Picklist (Multi-Select)') {
				list<Answer_Picklist_Value__c> lstAI = objAns.Answer_Items__r;
				if (lstAI != null && !lstAI.isEmpty()) {
					if (objAnsWrap.questionType == 'Picklist')
					objAnsWrap.strSelPicklistOption = lstAI[0].Selected_Question_Items__c;
					else {
						list<string> lstSelAI = new list<string> ();
						for (Answer_Picklist_Value__c objAI : lstAI) {
							System.debug(objAI.Selected_Question_Items__c);
							lstSelAI.add(objAI.Selected_Question_Items__c);
						}
						objAnsWrap.lstSelectedAanswers = lstSelAI;
						System.debug('lstSelAI::' + lstSelAI);
					}
				}
			}

			list<CustomSelectOptions> lstAnsPicklistOptions = new list<CustomSelectOptions> ();
			list<CustomSelectOptions> lstAnsMultiselPicklistOptions = new list<CustomSelectOptions> ();
			boolean isMultiPicklist = (objAns.Questions__r.Question_Type__c == 'Picklist (Multi-Select)');
			System.debug('isMultiPicklist::' + isMultiPicklist);
			list<Question_Picklist_Value__c> lstQI = mapQToQI.get(objAns.Questions__c);
			if (lstQI != null && !lstQI.isEmpty()) {
				for (Question_Picklist_Value__c objQI : lstQI) {
					//System.debug(pickListVal.getLabel() +' '+pickListVal.getValue());
					if (isMultiPicklist)
					lstAnsMultiselPicklistOptions.add(new CustomSelectOptions(objQI.Option_Value__c, objQI.Id));
					else {
						//lstAnsPicklistOptions.add(objQI.Option_Value__c);
						lstAnsPicklistOptions.add(new CustomSelectOptions(objQI.Option_Value__c, objQI.Id));
					}
				}
			}
			System.debug('lstAnsPicklistOptions::' + lstAnsPicklistOptions);
			System.debug('lstAnsMultiselPicklistOptions::' + lstAnsMultiselPicklistOptions);
			System.debug('objAnsWrap.lstSelectedAanswers::' + objAnsWrap.lstSelectedAanswers);
			objAnsWrap.lstAnsPicklistOptions = lstAnsPicklistOptions;
			objAnsWrap.lstAnsMultiselPicklistOptions = lstAnsMultiselPicklistOptions;
			//qw.answer = '';
			lstAF.add(objAnsWrap);
		}
		return lstAF;
	}

	//Questions and Answers related to the CNA
	@AuraEnabled
	public static list<AnswerForm> saveAnswers(string strCNAId, string answers, string strsupplementalQuestionWrap) {
		List<AnswerForm> lstAnswerWrap = new list<AnswerForm> ();
		try {
			System.debug(strsupplementalQuestionWrap);
			insertNewCategoryQuestionsAndAnswers(strCNAId, strsupplementalQuestionWrap);

			lstAnswerWrap = (List<AnswerForm>) JSON.deserialize(answers, List<AnswerForm>.class);
			set<string> setAnswer = new set<string> (); //set of Answerids to delete related items
			map<string, list<string>> mapAnsToOptions = new map<string, list<string>> ();
			for (AnswerForm objAF : lstAnswerWrap) {
				if (objAF.questionType == 'Picklist' || objAF.questionType == 'Picklist (Multi-Select)') {
					setAnswer.add(objAF.objAns.Id);
					list<string> lstAO = new list<string> ();
					if (objAF.questionType == 'Picklist') {
						lstAO.add(objAF.strSelPicklistOption);
					} else if (objAF.questionType == 'Picklist (Multi-Select)') {
						if (objAF.lstSelectedAanswers != null && !objAF.lstSelectedAanswers.isEmpty()) {
							for (string str : objAF.lstSelectedAanswers) {
								lstAO.add(str);
							}
						}
					}
					mapAnsToOptions.put(objAF.answerId, lstAO);
				}
			}
			System.debug('mapAnsToOptions::' + mapAnsToOptions);
			map<string, string> mapOption = new map<string, string> ();
			for (String str : mapAnsToOptions.keyset()) {
				list<string> lst = mapAnsToOptions.get(str);
				if (!lst.isEmpty()) {
					for (string optionItem : lst) {
						if (optionItem != null && optionItem != '')
						mapOption.put(optionItem, null);
					}
				}
			}
			if (!mapOption.isEmpty()) {
				for (Question_Picklist_Value__c objAI :[select id, Option_Value__c from Question_Picklist_Value__c where Id in :mapOption.keyset()]) {
					mapOption.put(objAI.Id, objAI.Option_Value__c);
				}
			}
			//deleting existing options
			if (!setAnswer.isEmpty()) {
				delete[select id from Answer_Picklist_Value__c where Answer__c in : setAnswer];
			}

			//preparing new options
			List<Answer__c> lstUpdateAnswers = new list<Answer__c> ();
			List<Answer_Picklist_Value__c> lstNewAnswerItem = new list<Answer_Picklist_Value__c> ();
			for (AnswerForm objAF : lstAnswerWrap) {
				if (objAF.questionType == 'Text') {
					objAF.objAns.Answer_With_Text__c = objAF.answer;
					objAF.objAns.Answer_Items__c = '';
				}
				if (objAF.questionType == 'Picklist') {
					Answer_Picklist_Value__c obj = new Answer_Picklist_Value__c();
					obj.Answer__c = objAF.answerId;
					obj.Selected_Question_Items__c = objAF.strSelPicklistOption;
					string ansitemtext = mapOption.get(objAF.strSelPicklistOption);
					if (ansitemtext.length() > 80)
					ansitemtext = ansitemtext.substring(0, 79);
					obj.Name = ansitemtext;
					lstNewAnswerItem.add(obj);
					objAF.objAns.Answer_With_Text__c = mapOption.get(objAF.strSelPicklistOption);
					objAF.objAns.Answer_Items__c = '';
				}
				if (objAF.questionType == 'Picklist (Multi-Select)') {
					if (objAF.lstSelectedAanswers != null && !objAF.lstSelectedAanswers.isEmpty()) {
						string strAns = '';
						for (string str : objAF.lstSelectedAanswers) {
							System.debug('str::' + str);
							if (mapOption.get(str) != null) {

								Answer_Picklist_Value__c obj = new Answer_Picklist_Value__c();
								obj.Answer__c = objAF.answerId;
								obj.Selected_Question_Items__c = str;
								string ansitemtext = mapOption.get(str);
								if (ansitemtext.length() > 80)
								ansitemtext = ansitemtext.substring(0, 79);
								obj.Name = ansitemtext;
								lstNewAnswerItem.add(obj);

								strAns += mapOption.get(str) + ';';
							}
						}
						System.debug('strAns::' + strAns);
						objAF.objAns.Answer_Items__c = strAns;
						objAF.objAns.Answer_With_Text__c = '';
					}
				}
				lstUpdateAnswers.add(objAF.objAns);
			}
			update lstUpdateAnswers;
			if (!lstNewAnswerItem.isEmpty())
			insert lstNewAnswerItem;
		} catch(Exception ex) {
			System.debug(ex);
		}
		return lstAnswerWrap;
	}

	public static void insertNewCategoryQuestionsAndAnswers(string strCNAId, String strsupplementalQuestionWrap) {
		List<QuestionWrap> supplementQuestionWrap = (List<QuestionWrap>) JSON.deserialize(strsupplementalQuestionWrap, List<QuestionWrap>.class);
		System.debug('strsupplementalQuestionWrap::' + strsupplementalQuestionWrap);
		map<string, string> mapQuestion = new map<string, string> ();
		map<string, list<string>> mapQuestionToSelectedAnswer = new map<string, list<string>> ();
		list<Answer__c> lstAnswers = new list<Answer__c> ();
		set<string> setSelectedQOptions = new set<string> ();
		for (QuestionWrap objGeneral : supplementQuestionWrap) {
			if (objGeneral.questionType == 'Picklist') {
				list<string> lstSelAns = new list<string> ();
				mapQuestionToSelectedAnswer.put(objGeneral.questionId, lstSelAns);
				if (objGeneral.strSelPicklistOption != null) {
					lstSelAns.add(objGeneral.strSelPicklistOption);
					setSelectedQOptions.add(objGeneral.strSelPicklistOption);
				}
				mapQuestionToSelectedAnswer.put(objGeneral.questionId, lstSelAns);
			} else if (objGeneral.questionType == 'Picklist (Multi-Select)') {
				list<string> lstSelAns = new list<string> ();
				mapQuestionToSelectedAnswer.put(objGeneral.questionId, lstSelAns);
				if (objGeneral.lstSelectedAanswers != null && objGeneral.lstSelectedAanswers.size() > 0) {
					for (string str : objGeneral.lstSelectedAanswers) {
						lstSelAns.add(str);
						setSelectedQOptions.add(str);
					}
				}
				mapQuestionToSelectedAnswer.put(objGeneral.questionId, lstSelAns);
			}
			mapQuestion.put(objGeneral.questionId, objGeneral.question);
		}
		map<Id, Question_Picklist_Value__c> mapSelQI = new map<Id, Question_Picklist_Value__c> ();
		if (!setSelectedQOptions.isEmpty()) {
			for (Question_Picklist_Value__c objQI :[select id, Name from Question_Picklist_Value__c where id in :setSelectedQOptions]) {
				mapSelQI.put(objQI.Id, objQI);
			}
		}

		System.debug('mapQuestionToSelectedAnswer::' + mapQuestionToSelectedAnswer);
		for (QuestionWrap objGeneral : supplementQuestionWrap) {
			Answer__c objAns = new Answer__c();
			String strQName = objGeneral.question;
			if (strQName.length() > 80)
			strQName = strQName.substring(0, 79);
			//objAns.Name   = strQName;
			if (objGeneral.questionType == 'Text') {
				objAns.Answer_With_Text__c = objGeneral.answer;
			}
			objAns.Questions__c = objGeneral.questionId;
			objAns.Question_Name__c = objGeneral.question;
			objAns.CNA__c = strCNAId;
			lstAnswers.add(objAns);
		}
		System.debug(lstAnswers);

		map<string, Answer__c> mapQuestionToAnswer = new map<string, Answer__c> ();
		if (!lstAnswers.isEmpty()) {
			insert lstAnswers;
			for (Answer__c objAns : lstAnswers) {
				mapQuestionToAnswer.put(objAns.Questions__c, objAns);
			}
			if (!mapQuestionToSelectedAnswer.isEmpty()) {
				map<string, string> mapAnswerToAnswerOptions = new map<string, string> (); //updating Answer__c.Answer_Items__c with Combined selected answeroptions with ';'
				list<Answer_Picklist_Value__c> lstAI = new list<Answer_Picklist_Value__c> ();
				for (string str : mapQuestionToSelectedAnswer.keyset()) {
					list<string> lstSelAns = mapQuestionToSelectedAnswer.get(str);
					if (lstSelAns != null && !lstSelAns.isEmpty()) {
						for (string strSelOpt : lstSelAns) {

							Answer_Picklist_Value__c objAI = new Answer_Picklist_Value__c();
							String AnswerId = mapQuestionToAnswer.get(str).Id;
							objAI.Answer__c = AnswerId;
							String strSelectedQOptionName = mapSelQI.get(strSelOpt).Name;
							String strSelectedQOptionNames = mapSelQI.get(strSelOpt).Name + ';';
							if (mapAnswerToAnswerOptions.containskey(AnswerId))
							strSelectedQOptionNames += mapAnswerToAnswerOptions.get(AnswerId);
							mapAnswerToAnswerOptions.put(AnswerId, strSelectedQOptionNames);

							if (strSelectedQOptionName.length() > 80) {
								strSelectedQOptionName = strSelectedQOptionName.substring(0, 79);
							}
							objAI.Question_Name__c = mapQuestion.get(str);
							objAI.Name = strSelectedQOptionName;
							objAI.Selected_Question_Items__c = strSelOpt;
							lstAI.add(objAI);
						}
					}
				}
				if (!lstAI.isEmpty()) {
					insert lstAI;
					if (!mapAnswerToAnswerOptions.isEmpty()) {
						for (Answer__c objAns : lstAnswers) {
							objAns.Answer_Items__c = mapAnswerToAnswerOptions.get(objAns.Id);
						}
						update lstAnswers;
					}
				}
			}
		}
	}
    public static List<QuestionWrap> generalQuestionWrap;
    
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
           //string emailAddress;
           //string setEmailRecipient;
            set<string> setEmailRecipient = new set<string>();
          //  setEmailRecipient.add(aeid);
            if(aeid!=null)
                setEmailRecipient.add(aeid);
           list<User> RecipientUsers=[SELECT Email FROM User WHERE ID in :setEmailRecipient ] ;
 			for(User objUser : RecipientUsers)
				emailAddress.add(objUser.Email);
            string subject = 'CNA Form';
            EmailHelper.sendEmailToListOfUsers(emailAddress,subject,strResult);
            
        }catch(Exception ex){
            System.debug('Exception :'+ex);
        }
        return issent;
    }

	//For Updating CNA Form
	public class AnswerForm {
		@AuraEnabled public Answer__c objAns; //Existing Answer
		@AuraEnabled public String qno; //question number
		@AuraEnabled public string question; //CNA_Questions__c.Question__c
		@AuraEnabled public string answer; //Answer Text
		@AuraEnabled public string questionType; //Question Type(Text/Picklist/MultiselectPicklist)
		@AuraEnabled public string answerId; //Answer RecordId
		@AuraEnabled public list<CustomSelectOptions> lstAnsPicklistOptions; //Picklist Answer Options
		@AuraEnabled public string strSelPicklistOption; //Picklist Answer Options
		@AuraEnabled public list<CustomSelectOptions> lstAnsMultiselPicklistOptions; //Multiselect Answer Options
		@AuraEnabled public list<string> lstSelectedAanswers; //Selected Answers
	}

	//For New CNA creation
	public class QuestionWrap {
		//@AuraEnabled public Questions__c objQuestion;//CNA_Questions__c.Question__c
		@AuraEnabled public string question; //CNA_Questions__c.Question__c
		@AuraEnabled public string answer; //Answer Text
		@AuraEnabled public string questionType; //Answer Text
		@AuraEnabled public string questionId; //Answer Text
		@AuraEnabled public list<CustomSelectOptions> lstAnsPicklistOptions; //Picklist Answer Options
		@AuraEnabled public string strSelPicklistOption; //Picklist Answer Options
		@AuraEnabled public list<CustomSelectOptions> lstAnsMultiselPicklistOptions; //Multiselect Answer Options
		@AuraEnabled public list<string> lstSelectedAanswers; //Selected Answers
	}

	public class CustomSelectOptions {
		@AuraEnabled public String label { get; set; }
		@AuraEnabled public String value { get; set; }

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