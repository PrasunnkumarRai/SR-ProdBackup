@isTest
public class DCCReadyForTraffickingControllerTest {
    /*  @testSetup
public static void createTestData(){
map<String, Id> mapRecordTypeId = new map<String, Id>();
for( RecordType accRT : [SELECT Id, DeveloperName FROM RecordType WHERE SObjectType='Account' AND ( DeveloperName='Agency_Account' OR DeveloperName='Advertiser_Account' OR DeveloperName='Rep_Firm')]){
mapRecordTypeId.put( accRT.DeveloperName, accRT.Id );
}

User userObj = TestUtil.prepareUser();
userObj.Approving_Manager__c = UserInfo.getUserId();
userObj.Sales_Office__c = 'Charlotte - DOS';
userObj.Region__c = 'Florida';
userObj.Division__c = 'South';
insert userObj;

Proposal__c testProposal;
Account AdsAccount;
Account AgencyAccount;
Opportunity testOppty;

System.runAs( userObj ){
AdsAccount = new Account(Name='Test Ads Account', RecordTypeId=mapRecordTypeId.get('Advertiser_Account'), BillingStreet = '235 High St',
BillingCity = 'Morgantown', BillingState = 'WV', BillingPostalCode = '26505',
BillingCountry = 'USA', ShippingStreet = '235 High St', ShippingCity = 'Morgantown', ShippingState = 'WV',
ShippingPostalCode = '26505', ShippingCountry = 'USA', Legal_Entity_Name__c='Test Legal Name' );

AgencyAccount = new Account(Name='Test Agency Account', RecordTypeId=mapRecordTypeId.get('Agency_Account'), BillingStreet = '235 High St',
BillingCity = 'Morgantown', BillingState = 'WV', BillingPostalCode = '26505',
BillingCountry = 'USA', ShippingStreet = '235 High St', ShippingCity = 'Morgantown', ShippingState = 'WV',
ShippingPostalCode = '26505', ShippingCountry = 'USA' );

insert new list<Account>{ AdsAccount, AgencyAccount };

RecordType opptyRT = [SELECT Id FROM RecordType WHERE SObjectType='Opportunity' AND DeveloperName='Opportunity' limit 1];
testOppty = new Opportunity();
testOppty.Name = 'Test Opportunity';
testOppty.RecordTypeId = opptyRT.Id;
testOppty.StageName='Proposal Presentation';
testOppty.CloseDate = System.Today().addDays( 30 );
testOppty.AccountId = AdsAccount.id;
testOppty.Agency_Account__c = AgencyAccount.Id;
insert testOppty;

RecordType proposalRT = [SELECT Id FROM RecordType WHERE SobjectType='Proposal__c' AND DeveloperName='Linear' limit 1];
testProposal = new Proposal__c();
testProposal.Name = 'Test Proposal';
testProposal.TIM_System__c = 'Dallas';
testProposal.Start_Date__c = SYstem.Today();
testProposal.End_Date__c = System.Today().addDays( 7 );
testProposal.Opportunity__c = testOppty.Id;
testProposal.Advertiser__c = AdsAccount.Id; 
testProposal.RecordTypeId = proposalRT.Id;
insert testProposal;

RecordType dcRT = [SELECT Id, DeveloperName FROM RecordType WHERE SObjectType='Digital_Campaign__c' AND DeveloperName='New_Ads_Everywhere' limit 1];
Digital_Campaign__c dcampaign = new Digital_Campaign__c();
dcampaign.Proposal__c = testProposal.Id;
dcampaign.RecordTypeId = dcRT.Id;
dcampaign.Status__c = 'Draft Plan';
dcampaign.Campaign_Name__c = testProposal.Name+' - Ads Everywhere ';
dcampaign.Advertiser__c = AdsAccount.Id;
dcampaign.Agency__c = AgencyAccount.id;
dcampaign.Opportunity__c = testOppty.Id;
dcampaign.Desired_Budget__c = 500;
dcampaign.Campaign_Start_Date__c = date.today();
dcampaign.Campaign_End_Date__c = date.today();
dcampaign.Max_Trafficked_Creative_End_Date__c = date.today();
insert dcampaign;

RecordType dccRT = [SELECT Id, DeveloperName FROM RecordType WHERE SObjectType='Digital_Creative__c' AND DeveloperName='Addressable_AdsE' limit 1];
Digital_Creative__c dCreative = new Digital_Creative__c();
dCreative.Digital_Campaign__c = dcampaign.Id;
dCreative.Creative_Start_Date__c = date.today();
dCreative.Creative_End_Date__c = date.today() + 30;
dCreative.Status__c = '05 Trafficked by Digital Ops';
dCreative.Creative_Type__c = 'Digital';
insert dCreative;
}     
}
*/
    @isTest
    public static void myUnitTest() {
        
        Opportunity opp = TestDataHelper.createopportunity(null,System.Today(),null,null,null);
        insert opp;
        Proposal__c prop = TestDataHelper.createProposal(null,opp.Id,null,null);
        insert prop;
        
        Account acc = new Account();
        acc.Name = 'testName';
        insert acc;
        
        Account accObj = new Account();
        accObj.Name = 'tName';
        insert accObj;
        
        Digital_Campaign__c dcampaign = new Digital_Campaign__c();
        dcampaign.Proposal__c = prop.Id;
        //dcampaign.RecordTypeId = dcRT.Id;
        dcampaign.Status__c = '05 Trafficked by Digital Ops';
        dcampaign.Campaign_Name__c = 'cName';//testProposal.Name+' - Ads Everywhere ';
        dcampaign.Advertiser__c = acc.Id;
        dcampaign.Agency__c = accObj.id;
        dcampaign.Opportunity__c = opp.Id;
        dcampaign.Desired_Budget__c = 500;
        dcampaign.Campaign_Start_Date__c = date.today();
        dcampaign.Campaign_End_Date__c = date.today();
        dcampaign.Max_Trafficked_Creative_End_Date__c = date.today();
        insert dcampaign;
        
        Test.startTest();
        DCCReadyForTraffickingController.getDigitalCreatives(dcampaign.Id);
        Test.stopTest();
    }
    
}