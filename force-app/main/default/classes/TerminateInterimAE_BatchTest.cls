@isTest
private class TerminateInterimAE_BatchTest 
{
	@testSetup
    static void prepareData() 
    {
    	User admin = TestDataHelper.createSystemAdminUser(true);
    	User userLSM = TestDataHelper.createLSMUser(true);
    	User primaryAE = TestDataHelper.createAEUser(true, 'primaryAE@charter.com', userLSM.Id);
		User interimAE = TestDataHelper.createAEUser(true, 'interimAE@charter.com', userLSM.Id);			

		System.runAs(admin)
		{
	        //Create an account
	        List<Account> accList = new List<Account>();
	        for(Integer i = 1; i <= 5;  i++) 
	        {
	        	 Account acc=TestDataHelper.createAdvertiser('TestAdv','123 Wright Plaza', 'Hyderabad', 'Andhra Pradesh', '500084', 'India');
	        	 acc.Name = acc.Name + i;
	        	 accList.add(acc);
	        }
	        INSERT accList;

	        //Interim AE 
	        List<AccountTeammember> atmList = new List<AccountTeammember>();
	        for(Integer i = 0; i < 5;  i++)
	        {
		        AccountTeammember atm = new AccountTeammember();
				atm.AccountId = accList[i].Id;
				atm.UserId = interimAE.Id;		
				atm.Teammemberrole = 'Interim AE';
				atmList.add(atm);
			}
			INSERT atmList;

			List<Opportunity> oppList = new List<Opportunity>();	
	        for(Integer i = 1; i <= 5;  i++) 
	        {
		        Opportunity opp= TestDataHelper.createopportunity('TestOpp'+i,System.today(),'Planning','Pipeline',accList[i-1].Id);
		        opp.OwnerId = primaryAE.Id;
		        oppList.add(opp);
		    }
		    INSERT oppList;   

	        List<OpportunityTeamMember> otmList = new List<OpportunityTeamMember>();
	        for(Integer i = 0; i < 5;  i++)
	        {
		        OpportunityTeamMember otm = new OpportunityTeamMember();
		        otm.OpportunityId= oppList[i].Id;
		        otm.UserId = interimAE.Id;	
		        otm.TeamMemberRole = 'Interim AE';
		        otmList.add(otm);
	      	}
	        INSERT otmList;

	        Map<String,String> TestData = TestDataHelper.fetchDivisions();
	        List<Interim_AE_Account__c> interimAEList = new List<Interim_AE_Account__c>();
	        for(Integer i = 0; i < 5;  i++) 
	        {
		        Interim_AE_Account__c interimAcc = new Interim_AE_Account__c();
				interimAcc.Account__c = accList[i].Id;
				interimAcc.Primary_AE__c = primaryAE.Id;
				interimAcc.Interim_AE__c = interimAE.Id;
				if(i==3) //For renewal record
				{
					interimAcc.StartDate__c = Date.today().addDays(2);
					interimAcc.EndDate__c =  Date.today().addDays(30);
				}				
				else {
					interimAcc.StartDate__c = Date.newInstance(2021, 5, 31);
					interimAcc.EndDate__c =  Date.newInstance(2021, 6, 27);
				}
				interimAcc.InitiatedBy__c = userLSM.Id;
		        interimAcc.From_LSM__c = userLSM.Id;
		        interimAcc.To_LSM__c = userLSM.Id;
				interimAcc.From_Region2__c = 'Northeast';
				interimAcc.From_Division2__c = TestData.get('Division_c_1');
				interimAcc.To_Region2__c = 'Northeast';		
				interimAcc.To_Division2__c = TestData.get('Division_c_1');
				interimAcc.Status__c = 'Approved';
				interimAcc.Processed__c = TRUE;
				interimAEList.add(interimAcc);
			}
			INSERT interimAEList;
		}
    } 

    @isTest 
    static void terminateInterimAETest() 
    {
    	// Before deleting records count if temporary AE service expired
    	Integer atmCnt = [SELECT count() FROM AccountTeammember WHERE TeamMemberRole = 'Interim AE'];
    	Integer otmCnt = [SELECT count() FROM OpportunityTeamMember WHERE TeamMemberRole = 'Interim AE'];
    	System.assertEquals(5, atmCnt);
    	System.assertEquals(5, otmCnt);

    	List<Interim_AE_Account__c> interimAEList = [SELECT Id, Ended__c FROM Interim_AE_Account__c LIMIT 5];
    	for(Interim_AE_Account__c interimAE : interimAEList)
    	{
    		System.assert(!interimAE.Ended__c);
    	}

    	Test.startTest();
    	ScheduleTerminateInterimAE batchsch=new ScheduleTerminateInterimAE();
        Datetime dt = Datetime.now().addMinutes(1);
        String cronExp = '0 '+ dt.minute() + ' * ' + dt.day() + ' ' + dt.month() + ' ? ' + dt.year();
		System.schedule('Test Terminate Interim AE', cronExp, batchsch); 
		Database.executeBatch(new TerminateInterimAE_Batch());	
		Test.stopTest();		

    	// If temporary AE service expires,ATM & OTM records should be deleted and marks InterimAEAccount as Ended
    	Integer updatedATMCnt = [SELECT count() FROM AccountTeammember WHERE TeamMemberRole = 'Interim AE'];
    	Integer updatedOTMCnt = [SELECT count() FROM OpportunityTeamMember WHERE TeamMemberRole = 'Interim AE'];  
    	System.assertEquals(1, updatedATMCnt);
    	System.assertEquals(1, updatedOTMCnt);  

    	List<Interim_AE_Account__c> updatedInterimAELst =[SELECT Id, Ended__c, Account__r.Name FROM Interim_AE_Account__c LIMIT 5];
    	for(Interim_AE_Account__c eachIinterimAE : updatedInterimAELst)
    	{
    		if(eachIinterimAE.Account__r.Name != 'TestAdv4') {
    			System.assert(eachIinterimAE.Ended__c);
    		}
    		else {
    			System.assert(!eachIinterimAE.Ended__c); 
    		}
    	}    	

    }
}