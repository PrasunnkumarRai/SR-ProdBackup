@IsTest(SeeAllData = false)
public class SponsorshipAdminUtilityControllerTest {
    
    Id totalRecordTypeId = Schema.SObjectType.Bulk_Sponsorship__c.getRecordTypeInfosByName().get('Total').getRecordTypeId();
    Id SoldRecordTypeId = Schema.SObjectType.Bulk_Sponsorship__c.getRecordTypeInfosByName().get('Sold').getRecordTypeId();
    Id totalNationalRecordTypeId = Schema.SObjectType.Bulk_Sponsorship__c.getRecordTypeInfosByName().get('National total').getRecordTypeId();
    Id SoldNationalRecordTypeId = Schema.SObjectType.Bulk_Sponsorship__c.getRecordTypeInfosByName().get('National sold').getRecordTypeId();

    public static String str = 'NAME,END DATE,INVENTORY TYPE,MVPD,DMA,NETWORK,START DATE,STATE,SYSCODE,SELLING AREA,SYSTEM TYPE,QUANTITY,RECORDTYPEID \n' + '6776 - Raleigh DMA - 7 Day Weather,2026-04-01,Billboard,Spectrum,Raleigh,S1RL,2020-12-28,NC,6776,Hard Interconnect,Hard Interconnect,48.00,totalRecordTypeId';
	public static String sold = 'NAME,END DATE,INVENTORY TYPE,MVPD,DMA,NETWORK,START DATE,STATE,SYSTEM TYPE,SELLING AREA,TIM SYSTEM,CLIENT NAME,TIM ID,RECORDTYPEID,QUANTITY \n'+'Weather on the Ones,2026-04-01,Billboard,Spectrum,Raleigh,2020-12-28,NC,Hard Interconnect,Hard Interconnect,6776,SRWA,Spectrum,123456789,SoldRecordTypeId,15.00';
    public static String nationalTotal = 'NAME,END DATE,INVENTORY TYPE,MVPD,DMA,SYSCODE,NETWORK,START DATE,STATE,SELLING AREA,SYSTEM TYPE,QUANTITY,RECORDTYPEID \n' + '6776 - Raleigh DMA - 7 Day Weather,2026-04-01,Billboard,Spectrum,Raleigh,S1RL,2020-12-28,NC,6776,Hard Interconnect,Hard Interconnect,48.00,totalNationalRecordTypeId';
    public static String nationalSold = 'NAME,DMA,SELLING AREA,SYSCODE,NETWORK,TIM SYSTEM,CLIENT NAME,AE NAME,QUANTITY,START DATE,END DATE,TIM ID,RECORDTYPEID \n' + '6776 - Raleigh DMA - 7 Day Weather,Raleigh,Hard Interconnect,6776,S1RL,SRWA,Spectrum,Test User,48.00,2020-12-28,2026-04-01,12345678,SoldNationalRecordTypeId';
    
    public static testmethod void csvFileReadTest(){
        Id totalRecordTypeId = Schema.SObjectType.Bulk_Sponsorship__c.getRecordTypeInfosByName().get('Total').getRecordTypeId();
        Id SoldRecordTypeId = Schema.SObjectType.Bulk_Sponsorship__c.getRecordTypeInfosByName().get('Sold').getRecordTypeId();
    	Id totalNationalRecordTypeId = Schema.SObjectType.Bulk_Sponsorship__c.getRecordTypeInfosByName().get('National total').getRecordTypeId();
    	Id SoldNationalRecordTypeId = Schema.SObjectType.Bulk_Sponsorship__c.getRecordTypeInfosByName().get('National sold').getRecordTypeId();
        List<Bulk_Sponsorship__c> totalLocalSponsorship = new List<Bulk_Sponsorship__c>();
        List<Bulk_Sponsorship__c> soldLocalSponsorship = new List<Bulk_Sponsorship__c>();
        List<Bulk_Sponsorship__c> nationalSponsorship = new List<Bulk_Sponsorship__c>();
        List<Bulk_Sponsorship__c> nationalSoldSponsorship = new List<Bulk_Sponsorship__c>();
        
        Bulk_Sponsorship__c sponsorshipData = new Bulk_Sponsorship__c(Name = '6776 - Raleigh DMA - 7 Day Weather',End_Date__c = date.parse('1/4/2026'),Inventory_Type__c ='Billboard',MVPD__c = 'Spectrum',DMA__c = 'Raleigh',Network__c = 'S1RL',Start_Date__c = date.parse('12/28/2020'),State__c = 'NC',Syscode__c = '6776',Selling_area__c = 'Hard Interconnect',System_Type__c = 'Hard Interconnect',Quantity__c = 48.00,RecordTypeId = totalRecordTypeId);
        insert sponsorshipData;
        ContentVersion contentVersionInsert = new ContentVersion(
            Title = 'Test',
            PathOnClient = 'Test.csv',
            VersionData = Blob.valueOf(str),
            IsMajorVersion = true
        );
        insert contentVersionInsert;
        Id getId = [Select ContentDocumentId From ContentVersion Where Id =:contentVersionInsert.id and isLatest=true].ContentDocumentId;
        
        Bulk_Sponsorship__c soldSponsorshipData = new Bulk_Sponsorship__c(Name = 'Weather on the Ones',End_Date__c = date.parse('12/28/2020'),Inventory_Type__c ='Billboard',MVPD__c = 'Spectrum',DMA__c = 'Raleigh',Network__c = 'S1RL',Start_Date__c = date.parse('12/28/2020'),State__c = 'NC',System_Type__c = 'Hard Interconnect',Selling_area__c = 'Hard Interconnect',Syscode__c = '6776',TIM_System__c = 'SRWA',Client_Name__c ='Spectrum',TIMID__c='123456789',RecordTypeId = totalNationalRecordTypeId,Quantity__c = 48.00);
        insert soldSponsorshipData;
        ContentVersion contentVersionInsert2 = new ContentVersion(
            Title = 'TestSold',
            PathOnClient = 'TestSold.csv',
            VersionData = Blob.valueOf(sold),
            IsMajorVersion = true
        );
        insert contentVersionInsert2;
        Id getSoldId = [Select ContentDocumentId From ContentVersion Where Id =:contentVersionInsert2.id and isLatest=true].ContentDocumentId;
        
        Bulk_Sponsorship__c sponsorshipNationalData = new Bulk_Sponsorship__c(Name = '6776 - Raleigh DMA - 7 Day Weather',End_Date__c = date.parse('1/4/2026'),Inventory_Type__c ='Billboard',MVPD__c = 'Spectrum',DMA__c = 'Raleigh',Syscode__c = '6776',Network__c = 'S1RL',Start_Date__c = date.parse('12/28/2020'),State__c = 'NC',Selling_area__c = 'Hard Interconnect',System_Type__c = 'Hard Interconnect',Quantity__c = 48.00,RecordTypeId = totalRecordTypeId);
        insert sponsorshipNationalData;
        ContentVersion contentVersionInsert3 = new ContentVersion(
            Title = 'TestNationalTotal',
            PathOnClient = 'TestNationalTotal.csv',
            VersionData = Blob.valueOf(nationalTotal),
            IsMajorVersion = true
        );
        insert contentVersionInsert3;
        Id getNationalTotalId = [Select ContentDocumentId From ContentVersion Where Id =:contentVersionInsert3.id and isLatest=true].ContentDocumentId;
        
        Bulk_Sponsorship__c sponsorshipNationalSoldData = new Bulk_Sponsorship__c(Name = '6776 - Raleigh DMA - 7 Day Weather',DMA__c='Raleigh',Selling_area__c ='Hard Interconnect',SysCode__c='6776',Network__c='S1RL',TIM_System__c='SRWA',Client_Name__c='Spectrum',AE_Name__c='Test User',Quantity__c=48.00,Start_Date__c=date.parse('12/28/2020'),End_Date__c= date.parse('1/4/2026'),TIMID__c='123456789',RecordTypeId = SoldNationalRecordTypeId);
        insert sponsorshipNationalSoldData;
        ContentVersion contentVersionInsert4 = new ContentVersion(
            Title = 'TestNationalSold',
            PathOnClient = 'TestNationalSold.csv',
            VersionData = Blob.valueOf(nationalSold),
            IsMajorVersion = true
        );
        insert contentVersionInsert4;
        Id getNationalSoldId = [Select ContentDocumentId From ContentVersion Where Id =:contentVersionInsert4.id and isLatest=true].ContentDocumentId;
        
        Bulk_Sponsorship__c sponsorshipData3 = new Bulk_Sponsorship__c(Name = '6776 - Raleigh DMA - 7 Day Weather',End_Date__c = date.parse('1/4/2026'),Inventory_Type__c ='Billboard',MVPD__c = 'Spectrum',DMA__c = 'Raleigh',Network__c = 'S1RL',Start_Date__c = date.parse('12/28/2020'),State__c = 'NC',Syscode__c = '6776',Selling_area__c = 'Hard Interconnect',System_Type__c = 'Hard Interconnect',Quantity__c = 48.00,RecordTypeId = totalRecordTypeId);
       	totalLocalSponsorship.add(sponsorshipData3);
        Bulk_Sponsorship__c sponsorshipData2 = new Bulk_Sponsorship__c(Name = '6776 - Raleigh DMA - 7 Day Weather --2',End_Date__c = date.parse('1/4/2026'),Inventory_Type__c ='Billboard',MVPD__c = 'Spectrum',DMA__c = 'Raleigh',Network__c = 'S1RL',Start_Date__c = date.parse('12/28/2020'),State__c = 'NC',Syscode__c = '6776',Selling_area__c = 'Hard Interconnect',System_Type__c = 'Hard Interconnect',Quantity__c = 48.00,RecordTypeId = totalRecordTypeId);
        totalLocalSponsorship.add(sponsorshipData2);
        
        Bulk_Sponsorship__c soldSponsorshipData2 = new Bulk_Sponsorship__c(Name = 'Weather on the Ones--1',End_Date__c = date.parse('12/28/2020'),Inventory_Type__c ='Billboard',MVPD__c = 'Spectrum',DMA__c = 'Raleigh',Network__c = 'S1RL',Start_Date__c = date.parse('12/28/2020'),State__c = 'NC',System_Type__c = 'Hard Interconnect',Selling_area__c = 'Hard Interconnect',Syscode__c = '6776',TIM_System__c = 'SRWA',Client_Name__c ='Spectrum',TIMID__c='123456789',RecordTypeId = totalNationalRecordTypeId,Quantity__c = 48.00);
        soldLocalSponsorship.add(soldSponsorshipData2);
		Bulk_Sponsorship__c soldSponsorshipData3 = new Bulk_Sponsorship__c(Name = 'Weather on the Ones--2',End_Date__c = date.parse('12/28/2020'),Inventory_Type__c ='Billboard',MVPD__c = 'Spectrum',DMA__c = 'Raleigh',Network__c = 'S1RL',Start_Date__c = date.parse('12/28/2020'),State__c = 'NC',System_Type__c = 'Hard Interconnect',Selling_area__c = 'Hard Interconnect',Syscode__c = '6776',TIM_System__c = 'SRWA',Client_Name__c ='Spectrum',TIMID__c='123456789',RecordTypeId = totalNationalRecordTypeId,Quantity__c = 48.00);
        soldLocalSponsorship.add(soldSponsorshipData3);
        
        Bulk_Sponsorship__c sponsorshipNationalData2 = new Bulk_Sponsorship__c(Name = '6776 - Raleigh DMA - 7 Day Weather',End_Date__c = date.parse('1/4/2026'),Inventory_Type__c ='Billboard',MVPD__c = 'Spectrum',DMA__c = 'Raleigh',Syscode__c = '6776',Network__c = 'S1RL',Start_Date__c = date.parse('12/28/2020'),State__c = 'NC',Selling_area__c = 'Hard Interconnect',System_Type__c = 'Hard Interconnect',Quantity__c = 48.00,RecordTypeId = totalRecordTypeId);
       	nationalSponsorship.add(sponsorshipNationalData2);
        Bulk_Sponsorship__c sponsorshipNationalData3 = new Bulk_Sponsorship__c(Name = '6776 - Raleigh DMA - 7 Day Weather--2',End_Date__c = date.parse('1/4/2026'),Inventory_Type__c ='Billboard',MVPD__c = 'Spectrum',DMA__c = 'Raleigh',Syscode__c = '6776',Network__c = 'S1RL',Start_Date__c = date.parse('12/28/2020'),State__c = 'NC',Selling_area__c = 'Hard Interconnect',System_Type__c = 'Hard Interconnect',Quantity__c = 48.00,RecordTypeId = totalRecordTypeId);
        nationalSponsorship.add(sponsorshipNationalData3);
        
        Bulk_Sponsorship__c sponsorshipNationalSoldData2 = new Bulk_Sponsorship__c(Name = '6776 - Raleigh DMA - 7 Day Weather',DMA__c='Raleigh',Selling_area__c ='Hard Interconnect',SysCode__c='6776',Network__c='S1RL',TIM_System__c='SRWA',Client_Name__c='Spectrum',AE_Name__c='Test User',Quantity__c=48.00,Start_Date__c=date.parse('12/28/2020'),End_Date__c= date.parse('1/4/2026'),TIMID__c='123456789',RecordTypeId = SoldNationalRecordTypeId);
       	nationalSoldSponsorship.add(sponsorshipNationalSoldData2);
        Bulk_Sponsorship__c sponsorshipNationalSoldData3 = new Bulk_Sponsorship__c(Name = '6776 - Raleigh DMA - 7 Day Weather--2',DMA__c='Raleigh',Selling_area__c ='Hard Interconnect',SysCode__c='6776',Network__c='S1RL',TIM_System__c='SRWA',Client_Name__c='Spectrum',AE_Name__c='Test User',Quantity__c=48.00,Start_Date__c=date.parse('12/28/2020'),End_Date__c= date.parse('1/4/2026'),TIMID__c='123456789',RecordTypeId = SoldNationalRecordTypeId);
        nationalSoldSponsorship.add(sponsorshipNationalSoldData3);
        
        Test.startTest();
        SponsorshipAdminUtilityController.csvFileRead(getId,'TotalLocalSponsorship');
        SponsorshipAdminUtilityController.createBulkSposorships(totalLocalSponsorship,'TotalLocalSponsorship' );
        SponsorshipAdminUtilityController.csvFileRead(getSoldId,'SoldLocalSponsorship');
        SponsorshipAdminUtilityController.createBulkSposorships(soldLocalSponsorship,'SoldLocalSponsorship' );
        SponsorshipAdminUtilityController.csvFileRead(getNationalTotalId,'TotalNationalSponsorship');
        SponsorshipAdminUtilityController.createBulkSposorships(nationalSponsorship,'TotalNationalSponsorship' );
        SponsorshipAdminUtilityController.csvFileRead(getNationalSoldId,'SoldNationalSponsorship');
        SponsorshipAdminUtilityController.createBulkSposorships(nationalSoldSponsorship,'SoldNationalSponsorship' );
        Test.stopTest();

    }

    public static testmethod void createTotalLocalSponsorships(){
        Id totalRecordTypeId = Schema.SObjectType.Bulk_Sponsorship__c.getRecordTypeInfosByName().get('Total').getRecordTypeId();

        Syscode_and_Network__c syscodes = new Syscode_and_Network__c();
        syscodes.Name = '6776';
        syscodes.Market__c = 'Raleigh';
        syscodes.State__c = 'NC';
        syscodes.System_Name__c = 'Raleigh Interconnect';
        syscodes.System_type__c = 'Hard Interconnect';
        syscodes.External_Id__c = 'Raleigh6776';
        syscodes.MVPD__c = 'Spectrum';
        syscodes.Externa_Id_System_Name__c = 'Raleigh Interconnect6776';
        syscodes.Network_Code__c = 'S1RL';
        insert syscodes;
        
        Bulk_Sponsorship__c sponsorshipData = new Bulk_Sponsorship__c();
        sponsorshipData.Name = '6776 - Raleigh DMA - 7 Day Weather';
        sponsorshipData.RecordTypeId = totalRecordTypeId;
        sponsorshipData.End_Date__c = date.parse('2/28/2021');
        sponsorshipData.Inventory_Type__c ='Billboard';
        sponsorshipData.MVPD__c = 'Spectrum';
        sponsorshipData.DMA__c = 'Raleigh';
        sponsorshipData.Network__c = 'S1RL';
        sponsorshipData.SysCode__c = '6776';
        sponsorshipData.Start_Date__c = date.parse('12/28/2020');
        sponsorshipData.State__c = 'NC';
        sponsorshipData.System_Type__c = 'Hard Interconnect';
        sponsorshipData.Quantity__c = 48.00;
        sponsorshipData.isSuccess__c = false;
        insert sponsorshipData;
        
        Bulk_Sponsorship__c sponsorshipData2 = new Bulk_Sponsorship__c();
        sponsorshipData2.Name = '6776 - Raleigh DMA - 7 Day Weather---2';
        sponsorshipData2.RecordTypeId = totalRecordTypeId;
        sponsorshipData2.End_Date__c = date.parse('2/28/2021');
        sponsorshipData2.Inventory_Type__c ='Billboard';
        sponsorshipData2.Start_Date__c = date.parse('12/28/2020');
        sponsorshipData2.Quantity__c = 48.00;
        sponsorshipData2.isSuccess__c = false;
        insert sponsorshipData2;
        
		        
        List<Bulk_Sponsorship__c> spon = [SELECT ID, DMA__c, Selling_area__c, SysCode__c, Start_Date__c, End_Date__c, Network__c, System_Type__c, Quantity__c, Inventory_Type__c, TimID__c, is_Errored__c, 
        Error_Message__c, isSuccess__c, tim_System__c, recordType.Name, Name FROM bulk_sponsorship__c WHERE (RecordType.Name = 'Total' AND CreatedDate = today AND (isSuccess__c = FALSE OR isSuccess__c = NULL) 
        AND (Id IN (:sponsorshipData.Id, :sponsorshipData2.Id)))];
        System.debug('Data for created Sponsorship: '+ spon);


        Test.startTest();
        SponsorshipAdminUtilityController adminController = new SponsorshipAdminUtilityController();
        adminController.createTotalLocalSponsorships(Datetime.now().Date());
        Test.stopTest();
    }
    
    public static testmethod void createSoldLocalSponsorships(){
       Id SoldRecordTypeId = Schema.SObjectType.Bulk_Sponsorship__c.getRecordTypeInfosByName().get('Sold').getRecordTypeId(); 
        
        List<String> bookingList = new List<String> ();
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
        //details.Owner.Name = 'Christine Erb';
        insert details;

        Templates__c temp = new Templates__c();
        temp.Name = 'Weather on the Ones';
        temp.Total_Quantity__c = 10;
        temp.Start_Date__c = date.parse('8/28/2020');
        temp.End_Date__c = date.parse('8/28/2021');
        temp.Syscode__c = '2838';
        temp.Network_Code__c = 'S1LA';
        insert temp;
        
        Bulk_Sponsorship__c sponsorshipData = new Bulk_Sponsorship__c();
        sponsorshipData.Name = 'Weather on the Ones';
        sponsorshipData.RecordTypeId = SoldRecordTypeId;
        sponsorshipData.End_Date__c = date.parse('12/28/2020');
        sponsorshipData.AE_Name__c ='Test User';
        sponsorshipData.Client_Name__c = 'Spectrum';
        sponsorshipData.TIMID__c = '9874757';
        sponsorshipData.SysCode__c = '2838';
        sponsorshipData.Start_Date__c = date.parse('8/28/2020');
        sponsorshipData.TIM_System__c = 'SRNA';
        sponsorshipData.Selling_area__c = 'Hard Interconnect';
        sponsorshipData.isSuccess__c = false;
        insert sponsorshipData;
        
        Test.startTest();
        SponsorshipAdminUtilityController adminController = new SponsorshipAdminUtilityController();
        adminController.createSoldLocalSponsorships(Datetime.now().Date());
        Test.stopTest();
    }
    
    public static testmethod void createNationalTotalSponsorships(){
      Id totalNationalRecordTypeId = Schema.SObjectType.Bulk_Sponsorship__c.getRecordTypeInfosByName().get('National total').getRecordTypeId();  
      
        Syscode_and_Network__c syscodes = new Syscode_and_Network__c();
        syscodes.Name = '6776';
        syscodes.Market__c = 'Raleigh';
        syscodes.State__c = 'NC';
        syscodes.System_Name__c = 'Raleigh Interconnect';
        syscodes.System_type__c = 'Hard Interconnect';
        syscodes.External_Id__c = 'Raleigh6776';
        syscodes.MVPD__c = 'Spectrum';
        syscodes.Externa_Id_System_Name__c = 'Raleigh Interconnect6776';
        syscodes.Network_Code__c = 'S1RL';
        insert syscodes;
        
        Bulk_Sponsorship__c sponsorshipData = new Bulk_Sponsorship__c();
        sponsorshipData.Name = '6776 - Raleigh DMA - 7 Day Weather - National';
        sponsorshipData.RecordTypeId = totalNationalRecordTypeId;
        sponsorshipData.End_Date__c = date.parse('2/4/2021');
        sponsorshipData.Inventory_Type__c ='Billboard';
        sponsorshipData.MVPD__c = 'Spectrum';
        sponsorshipData.DMA__c = 'Raleigh';
        sponsorshipData.Network__c = 'S1RL';
        sponsorshipData.SysCode__c = '6776';
        sponsorshipData.Start_Date__c = date.parse('12/28/2020');
        sponsorshipData.State__c = 'NC';
        sponsorshipData.System_Type__c = 'Hard Interconnect';
        sponsorshipData.Quantity__c = 48.00;
        sponsorshipData.isSuccess__c = false;
        insert sponsorshipData;
        
        Bulk_Sponsorship__c sponsorshipData2 = new Bulk_Sponsorship__c();
        sponsorshipData2.Name = '6776 - Raleigh DMA - 7 Day Weather - National--2';
        sponsorshipData2.RecordTypeId = totalNationalRecordTypeId;
        sponsorshipData2.End_Date__c = date.parse('2/4/2021');
        sponsorshipData2.Start_Date__c = date.parse('12/28/2020');
        sponsorshipData2.Quantity__c = 48.00;
        sponsorshipData2.isSuccess__c = false;
        insert sponsorshipData2;
        
        Test.startTest();
        SponsorshipAdminUtilityController adminController = new SponsorshipAdminUtilityController();
        adminController.createTotalNationalSponsorships(Datetime.now().Date());
        Test.stopTest();
      
    }
    
     public static testmethod void createNationalSoldSponsorships(){
         
        Opportunity details = new Opportunity();
        Account acc = new Account();
        acc.Name = 'Test Account';
        //acc.RecordType= Account_Request;
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
        //details.Owner.Name = 'Christine Erb';
        insert details;
         
      	Id SoldNationalRecordTypeId = Schema.SObjectType.Bulk_Sponsorship__c.getRecordTypeInfosByName().get('National sold').getRecordTypeId();
        Id nationalRecordTypeId = Schema.SObjectType.Templates__c.getRecordTypeInfosByName().get('National').getRecordTypeId();
      
        Syscode_and_Network__c syscodes = new Syscode_and_Network__c();
        syscodes.Name = '6776';
        syscodes.Market__c = 'Raleigh';
        syscodes.State__c = 'NC';
        syscodes.System_Name__c = 'Raleigh Interconnect';
        syscodes.System_type__c = 'Hard Interconnect';
        syscodes.External_Id__c = 'Raleigh6776';
        syscodes.MVPD__c = 'Spectrum';
        syscodes.Externa_Id_System_Name__c = 'Raleigh Interconnect6776';
        syscodes.Network_Code__c = 'S1RL';
        insert syscodes;

        Templates__c temp3 = new Templates__c();
        temp3.Name = 'Weather on the Ones - 1 - National';
        temp3.Total_Quantity__c = 20;
        temp3.Start_Date__c = date.parse('9/28/2020');
        temp3.End_Date__c = date.parse('9/28/2022');
        temp3.Syscode__c = '2838';
        temp3.Network_Code__c = 'S1LA';
        temp3.Inventory_Type__c = 'Integration';
        temp3.RecordTypeId = nationalRecordTypeId;
        insert temp3;

        Template_Inventory__c tempInventory2 = new Template_Inventory__c();
        tempInventory2.Template__c = temp3.Id;
        tempInventory2.Total_Quantity__c = 20;
        tempInventory2.Inventory_Type__c = 'Integration';
        tempInventory2.Booked_Inventory__c = 5;
        insert tempInventory2;
         
        Bulk_Sponsorship__c sponsorshipData = new Bulk_Sponsorship__c();
        sponsorshipData.Name = 'Weather on the Ones - 1 - National';
        sponsorshipData.RecordTypeId = SoldNationalRecordTypeId;
        sponsorshipData.End_Date__c = date.parse('4/28/2021');
        sponsorshipData.AE_Name__c ='Test User';
        sponsorshipData.Client_Name__c = 'Spectrum';
        sponsorshipData.TIMID__c = '9874757';
        sponsorshipData.SysCode__c = '2838';
        sponsorshipData.Start_Date__c = date.parse('12/28/2020');
        sponsorshipData.TIM_System__c = 'SRNA';
        sponsorshipData.Booked_Quantity__c = 10.00;
        sponsorshipData.Selling_area__c = 'Hard Interconnect';
        sponsorshipData.isSuccess__c = false;
        insert sponsorshipData;
        
        Test.startTest();
        SponsorshipAdminUtilityController adminController = new SponsorshipAdminUtilityController();
        adminController.createSoldNationalSponsorships(Datetime.now().Date());
        Test.stopTest();
      
    }
    
    
}