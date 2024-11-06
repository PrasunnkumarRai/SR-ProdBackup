@IsTest
public class SyscodeControllerTest {
    @testSetup
    
    static void testData() {
        
        Syscode_and_Network__c syscodeDetails= new Syscode_and_Network__c();
        syscodeDetails.Name = '2086';
        syscodeDetails.Market__c = 'Tampa';
        syscodeDetails.Network_Code__c = 'S1TP';
        syscodeDetails.State__c = 'FL';
        syscodeDetails.System_Name__c = 'East Hillsborough';
        syscodeDetails.System_type__c = 'Cable System';
        syscodeDetails.MVPD__c = 'Spectrum';
        syscodeDetails.External_Id__c = 'Tampa2086';
        syscodeDetails.Syscode__c = '2086';
        syscodeDetails.Is_Duplicate__c = false;
        insert syscodeDetails;
        
        
        Templates__c temp = new Templates__c();
        temp.News_Syscode__c = syscodeDetails.Id;
        temp.Name = 'Weather on the Ones - 1';
        temp.Total_Quantity__c = 10;
        temp.Start_Date__c = date.parse('8/28/2020');
        temp.End_Date__c = date.parse('8/29/2020');
        temp.Syscode__c = '2838';
        temp.Network_Code__c = 'S1LA';
        insert temp;
        
        //BookedSponsorshipTriggerHandler.isRun = false;
        
        
        
        Booked_Sponsorship__c bookedSponsorship = new Booked_Sponsorship__c();
        Opportunity details = new Opportunity();
        Account acc = new Account();
        acc.Name = 'Test Account';
        acc.Primary_Commodity__c = 'Alcoholic Beverages';
        acc.Commodity_Codes__c = 'ALC_BEV -- Beer and Wine';
        acc.BillingCity = 'Secaucus';
        acc.BillingCountry = 'US';
        acc.BillingPostalCode = '07094';
        acc.BillingState = 'NJ';
        acc.BillingStreet = 'PO Box 2516';
        insert acc;
        
        details.Name = 'INW TDA Olympics Digital';
        details.AccountId = acc.Id;
        details.Owner_Division__c = 'West';
        details.Owner_Region__c = 'Big West';
        details.Owner_Sales_Office__c = 'Kennewick';
        details.StageName = 'Identification';
        details.CloseDate = date.parse('8/28/2016');
        insert details;
        
        Id NationalTemplateId = Schema.SObjectType.Templates__c.getRecordTypeInfosByName().get('National').getRecordTypeId();
        
        //Booking Record Types
        Id BookingRecordTypeId = Schema.SObjectType.Sponsorship_Booking__c.getRecordTypeInfosByName().get('Updated').getRecordTypeId();
        Id OriginalRecordTypeId = Schema.SObjectType.Sponsorship_Booking__c.getRecordTypeInfosByName().get('Original').getRecordTypeId();
        
        Template_Inventory__c inventory = new Template_Inventory__c();
        inventory.Template__c = temp.Id;
        inventory.Total_Quantity__c = 10;
        inventory.Inventory_Type__c = 'Billboard';
        inventory.Booked_Inventory__c = 2;
        insert inventory;
        
        bookedSponsorship.Opportunity__c = details.Id;
        bookedSponsorship.Status__c = 'New';
        bookedSponsorship.Right_to_First_Refusal__c = true;
        insert bookedSponsorship;
        
        
        Sponsorship_Booking__c booking = new Sponsorship_Booking__c();
        booking.Template__c = temp.Id;
        booking.Start_Date__c = date.parse('12/28/2020');
        booking.End_Date__c = date.parse('12/29/2020');
        booking.Booked_Sponsorship__c = bookedSponsorship.Id;
        insert booking;
        
    }
    
    @isTest
    public static void syscodeDetailsTest(){
       //Syscode_and_Network__c  syscodeDetail = [Select ID,Name,Market__c,Network_Code__c,State__c,System_Name__c,System_Type__c,MVPD__c,External_Id__c,Syscode__c,Is_Duplicate__c from Syscode_and_Network__c LIMIT 1];
       // SyscodeController.syscodeDetails(syscodeDetail.ID);
       //System.debug('syscodeDetails+++++' +syscodeDetails.size());
       Syscode_and_Network__c testSyscode = new Syscode_and_Network__c(
         Name = 'Test Syscode',
         Market__c = 'Test Market',
         Network_Code__c =  'S1LA',
         State__c = 'CA',
         System_Name__c = 'Central LA',
         MVPD__c = 'Test',
         External_Id__c = 'TestId',
         Syscode__c =   'Test',
         Is_Duplicate__c = false
       );
         Insert testSyscode;
     Syscode_and_Network__c resultSyscode = SyscodeController.syscodeDetails(testSyscode.Id);
    }
    
    
    
    @isTest
    public static void updateSyscodeTest(){
        Syscode_and_Network__c syscodeDetails = [Select ID,Name,Market__c,Network_Code__c,State__c,System_Name__c,System_Type__c,MVPD__c,External_Id__c,Syscode__c,Is_Duplicate__c from Syscode_and_Network__c LIMIT 1];
        SyscodeController.updateSyscode(syscodeDetails.Id,'2087',syscodeDetails.MVPD__c,syscodeDetails.External_Id__c, syscodeDetails.System_Type__c, syscodeDetails.Market__c,syscodeDetails.System_Name__c, syscodeDetails.State__c, syscodeDetails.Network_Code__c,syscodeDetails.Syscode__c, syscodeDetails.Is_Duplicate__c);
    }
    
    @isTest
    public static void syscodeValidationTest(){
        Syscode_and_Network__c syscodeDetails = [Select ID,Name,Market__c,Network_Code__c,State__c,System_Name__c,System_Type__c,MVPD__c,External_Id__c,Syscode__c,Is_Duplicate__c from Syscode_and_Network__c LIMIT 1];
        SyscodeController.syscodeValidation(syscodeDetails.Name);
    }
    
    @isTest
    public static void mergeSyscodeProcessTest(){
        Syscode_and_Network__c syscodeDetails = [Select ID,Name,Market__c,Network_Code__c,State__c,System_Name__c,System_Type__c,MVPD__c,External_Id__c,Syscode__c,Is_Duplicate__c from Syscode_and_Network__c LIMIT 1];
        SyscodeController.mergeSyscodeProcess(String.valueOf(syscodeDetails.Id),syscodeDetails.Name, syscodeDetails.External_Id__c, syscodeDetails.System_Type__c, syscodeDetails.Market__c, syscodeDetails.System_Name__c, syscodeDetails.State__c, syscodeDetails.Network_Code__c,syscodeDetails.Is_Duplicate__c,String.valueOf(syscodeDetails.Id));
        
    }
    
    
    @isTest
    public static void SponsorshipDetailsTest(){
        Templates__c template = [Select Id, Name, Start_Date__c, End_Date__c,News_Syscode__r.Name from Templates__c  LIMIT 1];
        SyscodeController.SponsorshipDetails(template.News_Syscode__c);
        
    }
	@isTest
    public static void UpdateAllSponsorshipDuringMergeTest(){
        Templates__c template = [Select Id, Name, Start_Date__c,News_Syscode__c, End_Date__c,News_Syscode__r.Name from Templates__c  LIMIT 1];
        
      System.debug('template.News_Syscode__r.name::'+template.News_Syscode__r.name);
        SyscodeController.UpdateAllSponsorshipDuringMerge((String)template.News_Syscode__r.Id,'2087',(String)template.News_Syscode__c);
        
    }    
    
}