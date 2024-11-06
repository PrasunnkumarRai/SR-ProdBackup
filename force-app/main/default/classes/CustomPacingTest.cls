@isTest(seeAlldata = false)
public  class CustomPacingTest {
   
    private static string FLIGHT_DATES           = '2020-05-01:2020-05-04;2020-05-06:2020-05-11;2020-05-13:2020-05-18;2020-05-21:2020-05-25;2020-05-27:2020-05-31;';
    private static Decimal IMPRESSIONS_DELIVERED = 25426;

    @testSetup
    static void CreateTestData(){

        RecordType recordType = [SELECT id, Name FROM RecordType 
                                 WHERE Name = 'New Ads Everywhere' 
                                 AND SobjectType = 'Digital_Campaign__c'
                                 LIMIT 1];
                                
        Account acct = new Account(Name ='Test Account');

        insert acct;

        Digital_Campaign__c dc  = new Digital_Campaign__c( 
            Status__c                = OMS_MiddlwareController.SubmittedDigOps, 
            Advertiser__c            = acct.id,
            RecordTypeId             = recordType.Id,
            Rep_Firm_Text__c         = '', 
            Product_Type__c          = 'National Addressable', 
            Campaign_Name__c         = 'Cox Toyota Ads E 2019 (December) - New Ads Everywhere',
            Campaign_Start_Date__c   =  Date.newInstance(2020, 5, 01), 
            Campaign_End_Date__c     =  Date.newInstance(2020, 5, 31),
            CustomZipCode__c         = true,
            AdsE_Genre_s__c          = 'All Networks',
            AdsE_Network__c          = 'AMC;HGTV;ESPN APP;FOX',
            Total_Impressions__c     = 100000,
            Delivered_Impressions__c = IMPRESSIONS_DELIVERED,
            Flight_Dates_Backend__c  = FLIGHT_DATES
        );

        insert dc;   

        Inventory_Source__c invSource1 = new Inventory_Source__c(
            Digital_Campaign__c        = dc.id,
            Inventory_Resource_Type__c = 'Freewheel-O&O/Affiliate/Direct',
            Impressions__c             = 2941
        );
           
        Inventory_Source__c invSource2 = new Inventory_Source__c(
            Digital_Campaign__c        = dc.id,
            Inventory_Resource_Type__c = 'Freewheel-FF OTT',
            Impressions__c             = 94
        );

        Inventory_Source__c invSource3 = new Inventory_Source__c(
            Digital_Campaign__c        = dc.id,
            Inventory_Resource_Type__c = 'Freewheel-FF TVE',
            Impressions__c             = 500
        );

        Inventory_Source__c invSource4 = new Inventory_Source__c(
            Digital_Campaign__c        = dc.id,
            Inventory_Resource_Type__c = 'TTD-CTV',
            Impressions__c             =  60000
        );
    
        List<Inventory_Source__c> invSourceLst = new List<Inventory_Source__c>();
        invSourceLst.add(invSource1);
        invSourceLst.add(invSource2);
        invSourceLst.add(invSource3);
        invSourceLst.add(invSource4);

        insert invSourceLst;

    }

    @isTest
    static void getDC_PassBadDcIdParam_CalculationsAreCorrect(){

        Test.startTest();

            Digital_Campaign__c dc = CustomPacing.getDC('xxx');
            System.assertEquals(null, dc);

        Test.stopTest();
    }

    private static string PREPLANNED_FLIGHT_DATES = '2020-12-01:2020-12-09;2020-12-09:2020-12-15;2020-12-15:2020-12-29;';

    @isTest
    static void getPrePlannedHaitus_PassDcIdParam_CalculationsAreCorrect(){

        Test.startTest();

            Digital_Campaign__c dc  = [SELECT id, 
                                    Total_Impressions__c, 
                                    Flight_Dates_Backend__c,
                                    Delivered_Impressions__c
                                    FROM Digital_Campaign__c LIMIT 1];

            string json = CustomPacing.getPrePlannedHaitus(dc.id, PREPLANNED_FLIGHT_DATES);

            CustomPacingClass customPacingClass = (CustomPacingClass)System.JSON.deserialize(json, CustomPacingClass.class); 
            
            Decimal DailyDelivery       = 3225.81;
            Decimal NumberOfDays        = 31;
            Decimal impressionDelivered = IMPRESSIONS_DELIVERED;

            System.assertEquals(dailyDelivery, customPacingClass.DailyDelivery, 'Actual Value is ' +  customPacingClass.DailyDelivery);
            System.assertEquals(numberOfDays, customPacingClass.NumberOfDays);
            System.assertEquals(impressionDelivered, customPacingClass.ImpressionsDelivered);


            List<FlightDatesClass> flightDates = customPacingClass.fligthDates;

            System.assertEquals(29.03, flightDates[0].PercentageGoal);
            System.assertEquals(51.61, flightDates[1].PercentageGoal);
            System.assertEquals(100, flightDates[2].PercentageGoal);

        Test.stopTest();
    }

    private static string PAUSE_FLIGHT_DATES = '2020-07-01:2020-07-04;2020-07-06:2020-07-11;2020-07-13:2020-07-18;2020-07-21:2020-07-27;2020-07-28:2020-07-31;';

    @isTest
    static void getPauseNowStartDate_PassDcIdAndFlightDatesParam_CalculationsAreCorrect(){
      
        Test.startTest();

         Digital_Campaign__c dc  = [SELECT id, 
                                    Total_Impressions__c, 
                                    Flight_Dates_Backend__c,
                                    Delivered_Impressions__c
                                    FROM Digital_Campaign__c LIMIT 1];

         string json = CustomPacing.getPauseNowStartDate(dc.id, PAUSE_FLIGHT_DATES, '');

          CustomPacingClass customPacingClass = (CustomPacingClass)System.JSON.deserialize(json, CustomPacingClass.class); 

          Decimal newDailyDelivery    = 3242.35;
          Decimal numberOfDays        = 23;   
          Decimal impressionDelivered = IMPRESSIONS_DELIVERED;

          System.assertEquals(NewDailyDelivery, customPacingClass.NewDailyDelivery, 'Actual Value is ' +  customPacingClass.NewDailyDelivery);
          System.assertEquals(numberOfDays, customPacingClass.NumberOfDays);
          System.assertEquals(impressionDelivered, customPacingClass.ImpressionsDelivered);    

          List<FlightDatesClass> flightDates = customPacingClass.fligthDates;

          System.assertEquals(25.43, flightDates[0].PercentageGoal);
       
        Test.stopTest();
    }

    @isTest
    static void getPauseNowStartDate_PassDcIdAndNoFlightDatesParam_CalculationsAreCorrect(){
      
        Test.startTest();

         Digital_Campaign__c dc  = [SELECT id, 
                                    Total_Impressions__c, 
                                    Flight_Dates_Backend__c,
                                    Delivered_Impressions__c
                                    FROM Digital_Campaign__c LIMIT 1];

         string json = CustomPacing.getPauseNowStartDate(dc.id, '', '');

         CustomPacingClass customPacingClass = (CustomPacingClass)System.JSON.deserialize(json, CustomPacingClass.class); 

          String  numberOfDaysDeliver               = 'N/A';
          Decimal impressionsDeliverFirstPauseDate  = 0;
          Decimal newDailyDelivery                  = 0;

          System.assertEquals(numberOfDaysDeliver, customPacingClass.NumberOfDaysDeliver);
          System.assertEquals(impressionsDeliverFirstPauseDate, customPacingClass.ImpressionsDeliverByFirstPauseDate);
          System.assertEquals(newDailyDelivery, customPacingClass.NewDailyDelivery); 
          
        Test.stopTest();
    }

    @isTest
    static void getPauseLaterStartDate_PassDcIdAndFlightDatesParam_CalculationAreCorrect(){

      Test.startTest();  

        Digital_Campaign__c dc  = [SELECT id, 
                                    Total_Impressions__c, 
                                    Flight_Dates_Backend__c,
                                    Delivered_Impressions__c
                                    FROM Digital_Campaign__c LIMIT 1];

        CustomPacing.DateOverride = Date.newInstance(2020, 07, 08);

        string json = CustomPacing.getPauseLaterStartDate(dc.id, PAUSE_FLIGHT_DATES, '');

        CustomPacingClass customPacingClass = (CustomPacingClass)System.JSON.deserialize(json, CustomPacingClass.class); 

        Decimal newDailyDelivery    = 3716.12;
        Decimal numberOfDays        = 23;   
        Decimal impressionDelivered = IMPRESSIONS_DELIVERED;

        System.assertEquals(newDailyDelivery, customPacingClass.NewDailyDelivery, 'Actual Value is ' +  customPacingClass.NewDailyDelivery);
        System.assertEquals(numberOfDays, customPacingClass.NumberOfDays);
        System.assertEquals(impressionDelivered, customPacingClass.ImpressionsDelivered);

        List<FlightDatesClass> flightDates = customPacingClass.fligthDates;

        System.assertEquals(14.53, flightDates[0].PercentageGoal);
        
        Test.stopTest();
    }

    @isTest
    static void getPauseLaterStartDate_PassDCIDParam_CalculationAreCorrect_NoFlightDates(){

        Test.startTest();

            Digital_Campaign__c dc  = [SELECT id, 
                                        Total_Impressions__c, 
                                        Flight_Dates_Backend__c,
                                        Delivered_Impressions__c
                                        FROM Digital_Campaign__c LIMIT 1];

            CustomPacing.DateOverride = Date.newInstance(2020, 05, 08);

            string json = CustomPacing.getPauseLaterStartDate(dc.id, '', '');

            CustomPacingClass customPacingClass = (CustomPacingClass)System.JSON.deserialize(json, CustomPacingClass.class); 

            System.assertEquals('N/A', customPacingClass.NumberOfDaysDeliver);
            System.assertEquals(0,  customPacingClass.ImpressionsDeliverByFirstPauseDate);

        Test.stopTest();
    }

    @isTest
    static void setPrePlanPresentationData_ZeroImpression_ReturnEmptyFlightDates(){

        Test.startTest();

            List<FlightDatesClass> flightDateList = new List<FlightDatesClass>();

            Decimal dailyDelivery   = 0;
            Decimal TotalImpression = 0;

            List<CustomPacingPresentationClass> customPacingPresentationClass = CustomPacing.setPrePlanPresentationData(flightDateList, dailyDelivery, TotalImpression);

            System.assertEquals(0, customPacingPresentationClass.size());

        Test.stopTest();
    }

    @isTest
    static void setPausePresentation_ZeroImpression_ReturnEmptyFlightDates(){

        Test.startTest();

            List<FlightDatesClass> flightDateList = new List<FlightDatesClass>();

            Decimal dailyDelivery   = 0;
            Decimal TotalImpression = 0;

            List<CustomPacingPresentationClass> customPacingPresentationClass = new List<CustomPacingPresentationClass>();

            CustomPacingClass params = new CustomPacingClass();
            params.TotalImpressions = 0;

            customPacingPresentationClass = CustomPacing.setPausePresentation(params, CustomPacing.CalculationType.NORMAL);

            System.assertEquals(0, customPacingPresentationClass.size());

        Test.stopTest();
    }

    @isTest
    static void setFirstFlightDate_CalculatedField_ReturnDelivedDivideImpressionGoal(){

        Test.startTest();
       
            Decimal impressionGoal      = 100;
            Decimal deliveredExpression = 10;

            Decimal expected = (deliveredExpression / impressionGoal);
            Decimal result   = CustomPacing.setFirstFlightDate(impressionGoal, deliveredExpression);

            System.assertEquals(expected, result);

        Test.stopTest();
    }

    @isTest
    static void getDC_PassDigitalCampaginId_GetDcTotalImpressionsAndFlightDates(){
        
        Test.startTest();

            Digital_Campaign__c dc  = [SELECT id, 
                                    Total_Impressions__c, 
                                    Flight_Dates_Backend__c 
                                    FROM Digital_Campaign__c LIMIT 1];

            Digital_Campaign__c customDc = CustomPacing.getDC(dc.id);

            System.assertEquals(dc.Total_Impressions__c, customDc.Total_Impressions__c);
            System.assertEquals(dc.Flight_Dates_Backend__c, customDc.Flight_Dates_Backend__c);

        Test.stopTest();
    }

    @isTest
    static void createFlightDatesObject_GetFlightStartAndEndDates_ConvertStringToObject(){

        Test.startTest();

            List<FlightDatesClass> flightDateObject = CustomPacing.createFlightDatesObject(FLIGHT_DATES);

            System.assertEquals('2020-05-01', flightDateObject[0].StartDate);
            System.assertEquals('2020-05-04', flightDateObject[0].EndDate);
            System.assertEquals('2020-05-06', flightDateObject[1].StartDate);
            System.assertEquals('2020-05-11', flightDateObject[1].EndDate);
            System.assertEquals('2020-05-13', flightDateObject[2].StartDate);
            System.assertEquals('2020-05-18', flightDateObject[2].EndDate);
            System.assertEquals('2020-05-21', flightDateObject[3].StartDate);
            System.assertEquals('2020-05-25', flightDateObject[3].EndDate);
            System.assertEquals('2020-05-27', flightDateObject[4].StartDate);
            System.assertEquals('2020-05-31', flightDateObject[4].EndDate); 
        
            Test.stopTest();
    }

    @isTest
    static void createFlightDatesObject_NoFlightDates_ConvertStringToObject(){

        Test.startTest();

            List<FlightDatesClass> flightDateObject = CustomPacing.createFlightDatesObject('');
            System.assertEquals(0, flightDateObject.size()); 

        Test.stopTest();
    }

    @isTest
    static void getNumberOfDays_PassTwoDatesFormatYYYYMMDDFormat_GetTheNumberOfDaysFromTo() {

        Test.startTest();

            Integer NumberOfDays = CustomPacing.getNumberOfDays('2020-05-01', '2020-05-04');
            System.assertEquals(4, NumberOfDays); 

        Test.stopTest();
    }   

    @isTest
    static void getNumberOfDays_PassBadDateValues_Return0Days(){

        Test.startTest();

            Integer NumberOfDays = CustomPacing.getNumberOfDays('bad-start-date', 'bad-end-date');
            System.assertEquals(0, NumberOfDays);

        Test.stopTest();
    }
    
    @isTest
    static void parseDate_PassFormatYYYYMMDDFormat_ConvertStringToDate()  {

        Test.startTest();

            Date dateField = CustomPacing.parseDate('2020-05-01');
            System.assertEquals(Date.newInstance(2020, 05, 01), dateField);

        Test.stopTest();
    } 


    @isTest
    static void getDailyDeliveryCalculation_PassParamNumberOfDayAndTotalImpression_DivideTotalImpressionToNumberOfDays(){

        Test.startTest();

            Decimal TotalImpression     = 10000;
            Decimal numberOfDays        = 10;
            Decimal DeliveredExpression = 0;

            Decimal actual = CustomPacing.getDailyDeliveryCalculation(TotalImpression.intValue(), numberOfDays.intValue(), DeliveredExpression.intValue());

            System.assertEquals(1000, actual);

        Test.stopTest();
    }

    @isTest
    static void calculateRemaingExpression_PassTwoParam_GetCorrectCalculation(){

        Test.startTest();

            Integer NumberOfImpressions = 10;
            Integer ImpressionDelivered = 5;
            Integer ExpectedValue       = 5;

            Integer actualResult = CustomPacing.calculateRemaingExpression(NumberOfImpressions, ImpressionDelivered);

            System.assertEquals(ExpectedValue, actualResult);

        Test.stopTest();
    }

    @isTest
    static void calculateAverageDelivery_PassTwoParam_GetCorrectCalculation(){

        Test.startTest();

            Integer ImpressionDelivered = 50;
            Integer NumberOfDaysDeliver = 5;
            Decimal ExpectedValue       = 10.00;

            Decimal actualResult = CustomPacing.calculateAverageDelivery(ImpressionDelivered, numberOfDaysDeliver);

            System.assertEquals(ExpectedValue, actualResult);

        Test.stopTest();
    }

    @isTest
    static void calculateImpressionsDeliverByFirstPauseDate_PassTwoParam_GetCorrectCalculation(){

        Test.startTest();

            Integer AverageDelivery     = 50;
            Integer NumberOfDaysDeliver = 5;
            Decimal ExpectedValue       = 250.00;

            Decimal actualResult = CustomPacing.calculateImpressionsDeliverByFirstPauseDate(AverageDelivery, numberOfDaysDeliver);

            System.assertEquals(ExpectedValue, actualResult);

        Test.stopTest();
    }

    @isTest
    static void calculateImpressionsRemainingByFirstPauseDate_PassTwoParam_GetCorrectCalculation(){

        Test.startTest();

            Integer TotalImpressions                   = 20;
            Integer ImpressionsDeliverByFirstPauseDate = 5;
            Decimal ExpectedValue                      = 15.00;

            Decimal actualResult = CustomPacing.calculateImpressionsRemainingByFirstPauseDate(TotalImpressions, ImpressionsDeliverByFirstPauseDate);

            System.assertEquals(ExpectedValue, actualResult);

        Test.stopTest();
    }

    @isTest
    static void calculatePauseLaterNewDailyDelivery_PassTwoParam_GetCorrectCalculation(){

        Test.startTest();

            Integer ImpressionsRemainingByFirstPauseDate = 20;
            Integer NumberOfDays                         = 5;
            Decimal ExpectedValue                        = 4.00;

            Decimal actualResult = CustomPacing.calculatePauseLaterNewDailyDelivery(ImpressionsRemainingByFirstPauseDate, NumberOfDays);

            System.assertEquals(ExpectedValue, actualResult); 
        
        Test.stopTest();
    }

    @isTest
    static void getImpressions_PassDcIdParam_GetInventoryValues(){

        Test.startTest();

            Digital_Campaign__c dc  = [SELECT id FROM Digital_Campaign__c LIMIT 1];

            string json = CustomPacing.getImpressions(dc.id);

            List<Inventory_Source__c> inventory = (List<Inventory_Source__c>)System.JSON.deserialize(json, List<Inventory_Source__c>.class); 

            System.assertEquals('Freewheel-O&O/Affiliate/Direct',  inventory[0].Inventory_Resource_Type__c);
            System.assertEquals('Freewheel-FF OTT',  inventory[1].Inventory_Resource_Type__c);
            System.assertEquals('Freewheel-FF TVE',  inventory[2].Inventory_Resource_Type__c);  

        Test.stopTest();
    }

    private static string INVENTORY_TYPE = 'Freewheel-O&O/Affiliate/Direct';

    @isTest
    static void getPauseNowStartDate_PassDcIdAndFlightDatesParamAndInventorySource_CalculationsAreCorrect(){
         
        Test.startTest();

            Digital_Campaign__c dc  = [SELECT id, 
                                        Total_Impressions__c, 
                                        Flight_Dates_Backend__c,
                                        Delivered_Impressions__c
                                        FROM Digital_Campaign__c LIMIT 1];

            string json = CustomPacing.getPauseNowStartDate(dc.id, PAUSE_FLIGHT_DATES, INVENTORY_TYPE);

            CustomPacingClass customPacingClass = (CustomPacingClass)System.JSON.deserialize(json, CustomPacingClass.class); 

            Decimal newDailyDelivery    = -977.61;
            Decimal numberOfDays        = 23;   
            Decimal impressionDelivered = IMPRESSIONS_DELIVERED;

            System.assertEquals(newDailyDelivery, customPacingClass.NewDailyDelivery, 'Actual Value is ' +  customPacingClass.NewDailyDelivery);
            System.assertEquals(numberOfDays, customPacingClass.NumberOfDays);
            System.assertEquals(impressionDelivered, customPacingClass.ImpressionsDelivered);    

            List<FlightDatesClass> flightDates = customPacingClass.fligthDates;

            System.assertEquals(864.54, flightDates[0].PercentageGoal);

            Test.stopTest();

    }

    @isTest
    static void getPauseLaterStartDate_PassDcIdAndFlightDatesParamAndInventorySource_CalculationAreCorrect(){

        Test.startTest();

            Digital_Campaign__c dc  = [SELECT id, 
                                        Total_Impressions__c, 
                                        Flight_Dates_Backend__c,
                                        Delivered_Impressions__c
                                        FROM Digital_Campaign__c LIMIT 1];

            CustomPacing.DateOverride = Date.newInstance(2020, 07, 08);

            string json = CustomPacing.getPauseLaterStartDate(dc.id, PAUSE_FLIGHT_DATES, INVENTORY_TYPE);

            CustomPacingClass customPacingClass = (CustomPacingClass)System.JSON.deserialize(json, CustomPacingClass.class); 

        
            Decimal newDailyDelivery    = -503.83;
            Decimal numberOfDays        = 23;   
            Decimal impressionDelivered = IMPRESSIONS_DELIVERED;

            System.assertEquals(newDailyDelivery, customPacingClass.NewDailyDelivery, 'Actual Value is ' +  customPacingClass.NewDailyDelivery);
            System.assertEquals(numberOfDays, customPacingClass.NumberOfDays);
            System.assertEquals(impressionDelivered, customPacingClass.ImpressionsDelivered);

            List<FlightDatesClass> flightDates = customPacingClass.fligthDates;

            System.assertEquals(494.02 , flightDates[0].PercentageGoal);  
        
        Test.stopTest();

    }

    private static final string AUDIENCE_TRAK_DATES = '2021-03-01:2021-04-05;2021-04-13:2021-04-25;2021-05-01:2021-05-15;2021-05-19:2021-05-22;2021-06-01:2021-06-12;2021-07-01:2021-07-28;2021-08-01:2021-08-10;2021-09-15:2021-09-28;';

    @isTest
    static void getAudienceTrak_PassDcIdAndFlightDates_CalculationsAreCorrect(){

        Test.startTest();
        
            Digital_Campaign__c dc  = [SELECT id, 
                                        Total_Impressions__c, 
                                        Flight_Dates_Backend__c,
                                        Delivered_Impressions__c
                                        FROM Digital_Campaign__c LIMIT 1];


            string json                         = CustomPacing.getAudienceTrak(dc.id, AUDIENCE_TRAK_DATES);
            CustomPacingClass customPacingClass = (CustomPacingClass)System.JSON.deserialize(json, CustomPacingClass.class); 

            Decimal DailyGoals = 454;

            System.assertEquals(DailyGoals , customPacingClass.DailyGoal);  
            
        Test.stopTest();
    }

}