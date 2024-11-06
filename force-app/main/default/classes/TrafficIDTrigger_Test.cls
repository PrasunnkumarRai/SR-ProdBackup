@isTest (seeAlldata = false)
public class TrafficIDTrigger_Test{
		@IsTest(seeAlldata = false)
    static void TrafficIDInsertTest() {
        
        User u = TestDataHelper.getBoomiIntegrationUser();
        User newUser = TestDataHelper.createUser(true);
        System.debug('@@u Name '+u.Name);
        Account Advertiser=TestDataHelper.createAdvertiser('Advertiser Account Test','123 ABCD Plaza', 'Omaha', 'NE', '68130', 'USA');
		Advertiser.RecordTypeID = AccountUtils.localAdvertiserAccountRtId;
		Advertiser.OwnerId = newUser.Id;	                                
        insert Advertiser;

        System.assert(Advertiser != null);
        
		//Create account connenction	
    	AccountConnection__c accConnect = TestDataHelper.createAccountConnection(String.valueOf(Advertiser.id));
    	accConnect.Tim_ID__c = '1234';
    	accConnect.Tim_System__c = 'St. Louis Local';
    	insert accConnect;

    	System.assert(accConnect != null);	
        
		//Create an Agency account
        Account Agency=TestDataHelper.createAdvertiser('Agency Account Test','1 WrPlaza', 'Omaa', 'NE', '6041', 'USA');
        Agency.RecordTypeID = AccountUtils.agencyAccountRtId;  
        Agency.OwnerId = newUser.Id;                      
        insert Agency;

        System.assert(Agency != null);
        
        //Create account connenction	
    	AccountConnection__c agcConnect = TestDataHelper.createAccountConnection(String.valueOf(Agency.id));
    	agcConnect.AgencyTimID__c = '123';
    	agcConnect.Tim_System__c = 'St. Louis Local';
    	insert agcConnect;

    	System.assert(agcConnect != null);
        
        System.runAs(u){
        
        	UserConnection__c connection = TestDataHelper.createUserConnection('St. Louis Local','SFDCUser',UserInfo.getUserId(),'TIM','1');   
            insert connection;

            System.assert(connection != null);
            
	        //Create an account

	        /*
	        //Create an opportunity on the above created account
	        Opportunity opp = TestDataHelper.createopportunity('Test Opportunity',System.today(),'Planning','Pipeline',Advertiser.ID);       
	        insert opp;
	        
	        //create a proposal on above created Opportunity
	        Proposal__c proposal = TestDataHelper.createProposal('Test Opportunity Proposal',opp.id, '00000', true); 
	        proposal.Traffic_Order_Number__c  = '2222,3425';
	        proposal.Advertiser__c = Advertiser.ID;
	        insert proposal;
	       */
	       Test.startTest();
	        //create create Traffic Id Element for Account
	        Traffic_Id_Element__c trafficElementAcc = new Traffic_Id_Element__c();
			trafficElementAcc.Account_TIM_ID__c = '1234';
			//trafficElementAcc.User__c = u.ID;
        	trafficElementAcc.Export_System_Id__c = '1';
        	trafficElementAcc.Traffic_Id__c = '2';
	        trafficElementAcc.Tim_System__c = 'St. Louis Local';
	        trafficElementAcc.Traffic_Type__c = 'Account';
	        trafficElementAcc.Account_Type__c = 'Advertiser';
	        trafficElementAcc.ExportSystem_Name__c = 'St. Louis Local';
	        Insert trafficElementAcc;
			
			//create create Traffic Id Element for Account
	        Traffic_Id_Element__c trafficElementAgc = new Traffic_Id_Element__c();
			trafficElementAgc.Account_TIM_ID__c = '123';
			//trafficElementAgc.User__c = u.ID;
        	trafficElementAgc.AE_ID__c = 1;
        	trafficElementAgc.Traffic_Id__c = '44';
	        trafficElementAgc.Tim_System__c = 'St. Louis Local';
	        trafficElementAcc.Traffic_Type__c = 'Account';
	        trafficElementAgc.Account_Type__c = 'Agency';
	        trafficElementAgc.ExportSystem_Name__c = 'StLouis Local';
	        Insert trafficElementAgc;
	         
	        //create create Traffic Id Element for User
	        Traffic_Id_Element__c trafficElementUser = new Traffic_Id_Element__c();
			//trafficElementUser.Account_TIM_ID__c = Agency.ID;
			//trafficElementUser.AE_ID__c = u.ID;
			trafficElementUser.AE_ID__c = 1;
        	trafficElementUser.Export_System_Id__c = '1';
        	trafficElementUser.Traffic_Id__c = '2222212121';
	        trafficElementUser.Tim_System__c = 'St. Louis Local';
	        trafficElementUser.Traffic_Type__c = 'User';
	        //trafficElementUser.Account_Type__c = 'Advertiser';
	        trafficElementUser.ExportSystem_Name__c = 'St. Louis Local';
	        insert trafficElementUser;  
	        Test.stopTest();
        }        
    }
        
}