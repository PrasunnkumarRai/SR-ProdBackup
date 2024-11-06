public with sharing class CustomPacing {
    
    public static final string PRE_PLANNED_HAITUS  = 'PrePlanned Hiatus';
    public static final string PAUSE_NOW           = 'Pause Now with Plan Start Date';
    public static final string PAUSE_LATER         = 'Pause Later with Plan Start Date';
    public static final string AUDIENCE_TRAK       = 'AudienceTrak';
    private static final string AUDIENCE_TRAK_CTV  = 'TTD-CTV';



    public enum CalculationType {NORMAL, PAUSE_NOW, PAUSE_LATER}

    public enum CustomPacingType {PrePlannedHiatus, PauseNowStartDate, PauseLaterStartDate, AudienceTrak}

    

    public static Date DateOverride;

    @AuraEnabled(cacheable=false)
    public static string getPrePlannedHaitus(string id, string flightDates){
        
        System.debug(LoggingLevel.INFO, 'DC id ' + id);

        Digital_Campaign__c dc = getDC(id);

        List<FlightDatesClass> flightDateClassList = createFlightDatesObject(flightDates);
    
        Integer numberOfDays        = getTotalFlightDays(flightDateClassList, CalculationType.NORMAL);
        Integer deliveredImpression = (dc.Delivered_Impressions__c == null) ? 0 : dc.Delivered_Impressions__c.intValue();
        Integer TotalImpressions    = (dc.Total_Impressions__c == null) ? 0 : dc.Total_Impressions__c.intValue();
        Decimal dailyDelivery       = getDailyDeliveryCalculation(TotalImpressions, numberOfDays, 0);

        CustomPacingClass customPacingClass = new CustomPacingClass(); 
        customPacingClass.isAudienceTrack         = false;
        customPacingClass.Title                   = PRE_PLANNED_HAITUS;
        customPacingClass.DailyDelivery           = dailyDelivery.setScale(2);
        customPacingClass.NumberOfDays            = numberOfDays;
        customPacingClass.ImpressionsDelivered    = deliveredImpression;
        CustomPacingClass.TotalImpressions        = TotalImpressions;
        customPacingClass.RemaingImpressions      = customPacingClass.TotalImpressions;
        customPacingClass.presentation            = setPrePlanPresentationData(flightDateClassList, dailyDelivery, CustomPacingClass.TotalImpressions);   //setPrePlanPresentationData(flightDateClassList, dailyDelivery, CustomPacingClass.TotalImpressions);
        customPacingClass.fligthDates             = flightDateClassList;
        customPacingClass.ShowImpressionDelivered = true;
        customPacingClass.Notes                   = '<ul><li>(Impression Goal / Number of Day) = <strong><i>Daily Delivery</i></strong><strong><br />' +
                                                    '( ' + CustomPacingClass.TotalImpressions  + ' / ' +  numberOfDays + ' ) = ' + customPacingClass.DailyDelivery  + '</strong></li></ul>';

        System.debug('Title: ' + customPacingClass.Title + 
        ', Daily Delivery : ' + customPacingClass.DailyDelivery  +
        ', Number Of Days : ' + customPacingClass.NumberOfDays  +
        ', Total Impressions : ' + customPacingClass.TotalImpressions);

 
        return JSON.serialize(customPacingClass);
    }

    @AuraEnabled(cacheable=false)
    public static string getPauseNowStartDate(string id, string flightDates, string InventorySourceType){
        
        System.debug(LoggingLevel.INFO, 'DC id ' + id);

        Digital_Campaign__c dc = getDC(id);

        CustomPacingClass customPacingClass = new CustomPacingClass(); 

        Integer deliveredImpression               = (dc.Delivered_Impressions__c == null) ? 0 : dc.Delivered_Impressions__c.intValue();
        Integer TotalImpressions                  = (dc.Total_Impressions__c == null) ? 0 : dc.Total_Impressions__c.intValue();
        customPacingClass.TotalImpressions        = TotalImpressions;

        List<Inventory_Source__c> invSourceLst =  getInventoryImpression(dc.id, InventorySourceType);
        string ImpressionGoal                  = 'Impression Goal';
 
        if (invSourceLst.size() > 0){
            customPacingClass.TotalImpressions   = (invSourceLst[0].Impressions__c == null) ? 0 : invSourceLst[0].Impressions__c .intValue();
            ImpressionGoal = 'Inventory Impression Goal';
        }

        List<FlightDatesClass> flightDateClassList = createFlightDatesObject(flightDates);   
        Integer numberOfDays                       = getTotalFlightDays(flightDateClassList, CalculationType.PAUSE_NOW);
        Decimal dailyDelivery                      = getDailyDeliveryCalculation(customPacingClass.TotalImpressions, numberOfDays, deliveredImpression);

        System.debug('Pause Now New Daily Delivery ' + dailyDelivery);
        System.debug('Pause Now New Daily Delivery 2 Decimal Places' + dailyDelivery.setScale(2));

        customPacingClass.Title                   = PAUSE_NOW;
        customPacingClass.DailyDelivery           = dailyDelivery.setScale(2);
        customPacingClass.NumberOfDays            = numberOfDays;
        customPacingClass.ImpressionsDelivered    = deliveredImpression;
        customPacingClass.RemaingImpressions      = calculateRemaingExpression(customPacingClass.TotalImpressions,customPacingClass.ImpressionsDelivered.intValue());
        customPacingClass.fligthDates             = flightDateClassList;
        customPacingClass.ShowImpressionDelivered = true;


        Decimal firstImpressionGoal = getPauseNowCumulativePercentGoal(customPacingClass, 1, 0, 0);
            
        customPacingClass.Notes =  '<ul><li>The first date period is excluded in Total Number of Days </li>' +
                                   '<li>(' + ImpressionGoal + ' - Impression Delivered) / Total Number of Days  = <strong><i>New Daily Delivery <br />' + 
                                   '( ' + CustomPacingClass.TotalImpressions   + ' - ' +  customPacingClass.ImpressionsDelivered  + ' / ' +  numberOfDays + ') = ' + customPacingClass.DailyDelivery  + '</strong></i></li> <li>' +
                                   'The first percentage budget is calculated by Impression Delivered divided by Impression Goal<br /><strong><i>' + 
                                   '( ' + customPacingClass.ImpressionsDelivered + ' / ' + customPacingClass.TotalImpressions + '  ) = ' +  (firstImpressionGoal * 100).setScale(2) + 
                                   '%</i></strong></li></ul>';

        customPacingClass.presentation = setPausePresentation(customPacingClass, CalculationType.PAUSE_NOW);
 
        System.debug('Title: ' + customPacingClass.Title + 
                     ', Daily Delivery : ' + customPacingClass.DailyDelivery  +
                     ', Number Of Days : ' + customPacingClass.NumberOfDays  +
                     ', Total Impressions : ' + customPacingClass.TotalImpressions);

        if (flightDateClassList.size() > 0){
            customPacingClass.NewDailyDelivery = customPacingClass.DailyDelivery;
    
        }else{
            customPacingClass.NumberOfDaysDeliver                 = 'N/A';
            customPacingClass.ImpressionsDeliverByFirstPauseDate  = 0;
            customPacingClass.NewDailyDelivery                    = 0;
        }


        return JSON.serialize(customPacingClass);
    }

    @AuraEnabled(cacheable=false)
    public static string getPauseLaterStartDate(string id, string flightDates, string InventorySourceType){

        System.debug(LoggingLevel.INFO, 'DC id ' + id);

        Digital_Campaign__c dc              = getDC(id);
        CustomPacingClass customPacingClass = new CustomPacingClass(); 
        customPacingClass.isAudienceTrack   = false;

        Integer deliveredImpression               = (dc.Delivered_Impressions__c == null) ? 0 : dc.Delivered_Impressions__c.intValue();
        Integer TotalImpressions                  = (dc.Total_Impressions__c == null) ? 0 : dc.Total_Impressions__c.intValue();
        customPacingClass.TotalImpressions        = TotalImpressions;

        List<Inventory_Source__c> invSourceLst =  getInventoryImpression(dc.id, InventorySourceType);
        string ImpressionGoal                  = 'Impression Goal';
 
        if (invSourceLst.size() > 0){
            customPacingClass.TotalImpressions   = (invSourceLst[0].Impressions__c == null) ? 0 : invSourceLst[0].Impressions__c .intValue();
            ImpressionGoal = 'Inventory Impression Goal';
        }


        List<FlightDatesClass> flightDateClassList = createFlightDatesObject(flightDates);
        Integer numberOfDays                       = getTotalFlightDays(flightDateClassList, CalculationType.PAUSE_LATER);
        Decimal dailyDelivery                      = getDailyDeliveryCalculation(customPacingClass.TotalImpressions, numberOfDays, deliveredImpression);
        customPacingClass.Title                    = PAUSE_LATER;
        customPacingClass.DailyDelivery            = dailyDelivery.setScale(2);
        customPacingClass.NumberOfDays             = numberOfDays;
        customPacingClass.ImpressionsDelivered     = deliveredImpression;
        
        customPacingClass.RemaingImpressions      = calculateRemaingExpression(customPacingClass.TotalImpressions,customPacingClass.ImpressionsDelivered.intValue());
        customPacingClass.fligthDates             = flightDateClassList;
        customPacingClass.ShowImpressionDelivered = true;

                                                  
        Date currentDate =  Date.today(); 
        String yesterdaysDate;
        String yesterdaysDateUSFormat;

        yesterdaysDate         = currentDate.addDays(-1).format();    
        yesterdaysDateUSFormat = currentDate.addDays(-1).format();  

        if(Test.isRunningTest()){
            yesterdaysDate         = DateOverride.addDays(-1).format();    
            yesterdaysDateUSFormat = DateOverride.addDays(-1).format(); 
        }  


        System.debug('Yesterday\'s Date' + yesterdaysDate);
        System.debug('Yesterday\'s Date US Format' + yesterdaysDateUSFormat);

        customPacingClass.YesterydaysDate    = yesterdaysDateUSFormat;
        String startDateFormat               = 'N/A'; 
        Integer NumberOfDayFirstFligthDates  = 0;

        if (flightDateClassList.size() > 0){
           
            NumberOfDayFirstFligthDates                            = flightDateClassList[0].NumberOfDays;
            String startDate                                       = flightDateClassList[0].StartDate;
            startDateFormat                                        = parseDate(startDate).format();
            Integer numberOfDaysDeliver                            = getNumberOfDays(startDate, yesterdaysDate);
            customPacingClass.NumberOfDaysDeliver                  = String.valueOf(numberOfDaysDeliver);
            customPacingClass.AverageDelivery                      = calculateAverageDelivery(customPacingClass.ImpressionsDelivered, numberOfDaysDeliver);        // (customPacingClass.ImpressionsDelivered / numberOfDaysDeliver).setScale(2);
            customPacingClass.ImpressionsDeliverByFirstPauseDate   = calculateImpressionsDeliverByFirstPauseDate(customPacingClass.AverageDelivery, flightDateClassList[0].NumberOfDays);   //(customPacingClass.AverageDelivery * flightDateClassList[0].NumberOfDays).setScale(2);
            customPacingClass.ImpressionsRemainingByFirstPauseDate = calculateImpressionsRemainingByFirstPauseDate(customPacingClass.TotalImpressions, customPacingClass.ImpressionsDeliverByFirstPauseDate);                // (customPacingClass.TotalImpressions - customPacingClass.ImpressionsDeliverByFirstPauseDate).setScale(2);
            customPacingClass.NewDailyDelivery                     = calculatePauseLaterNewDailyDelivery(customPacingClass.ImpressionsRemainingByFirstPauseDate, customPacingClass.NumberOfDays);  //(customPacingClass.ImpressionsRemainingByFirstPauseDate / customPacingClass.NumberOfDays).setScale(2);//
           }else{
            customPacingClass.NumberOfDaysDeliver                  = 'N/A';
            customPacingClass.ImpressionsDeliverByFirstPauseDate   = 0;
            customPacingClass.NewDailyDelivery                     = 0;
            customPacingClass.ImpressionsRemainingByFirstPauseDate = 0;
            customPacingClass.AverageDelivery                      = 0;     
        }

   
     
        Decimal firstImpressionGoal = getPauseLaterCumulativePercentGoal(customPacingClass, 1, 0, 0);

         customPacingClass.presentation = setPausePresentation(customPacingClass, CalculationType.PAUSE_LATER);
         customPacingClass.Notes        = '<ul>' +
                                             '<li><i><strong>Day\'s Already Delivered</strong></i> is from first Start Flight Date to Yesterday\'s Date <br /><strong>' +
                                              startDateFormat + ' to ' + yesterdaysDateUSFormat + ' = ' + customPacingClass.NumberOfDaysDeliver + '</strong><br /></li>' +
                                             '<li> ( Impression Delivered ' + ' / Day\'s Already Delivered ) = <strong><i>Average Daily Delivery</i></strong><br ><strong> ' + 
                                             '( ' + customPacingClass.ImpressionsDelivered  + ' / ' + customPacingClass.NumberOfDaysDeliver + ' ) = ' + customPacingClass.AverageDelivery  +
                                             '</strong></li> ' +                                          
                                             '<li>(Average Daily Delivery * Total Number of First Flight Date) = <i><strong>Impressions we will deliver by first pause date </strong></i> <br />' +
                                             '<strong>( ' + customPacingClass.AverageDelivery + ' * ' +  NumberOfDayFirstFligthDates + ' ) = '  + customPacingClass.ImpressionsDeliverByFirstPauseDate  +   '</strong></li>' +
                                             '<li>(' + ImpressionGoal + ' - Impressions we will deliver by first pause date) = <strong><i>Remaining Impressions after first pause date</i></strong><br /><strong>' +
                                             '( ' + customPacingClass.TotalImpressions + ' - ' + customPacingClass.ImpressionsDeliverByFirstPauseDate  + ' ) = ' + customPacingClass.ImpressionsRemainingByFirstPauseDate  +  '</strong></li>' +      
                                             '<li>The first date period is excluded in Total Number of Days <br /> ' +
                                             '(Remaining Impressions after first pause date / Total Number Of Days ) = <strong><i>New Daily Delivery</i></strong> <br />' +  
                                             '<strong> ( ' + customPacingClass.ImpressionsRemainingByFirstPauseDate  + ' / ' + customPacingClass.NumberOfDays +' ) = ' + customPacingClass.NewDailyDelivery  + '</strong></li>' +
                                             '<li>The first percentage budget is calculated by <strong>Impression Deliver by First Pause Date</strong> divided by <strong>Impression Goal</strong><br /><strong><i>' + 
                                             '( ' + customPacingClass.ImpressionsDeliverByFirstPauseDate + ' / ' +   customPacingClass.TotalImpressions +' ) = ' +  (firstImpressionGoal * 100).setScale(2) + '</li>' +
                                             '</ul>';

        System.debug('Title: ' + customPacingClass.Title + 
                     ', New Daily Delivery : ' + customPacingClass.NewDailyDelivery  +
                     ', Number Of Days : ' + customPacingClass.NumberOfDays  +
                     ', Total Impressions : ' + customPacingClass.TotalImpressions);

        String json = JSON.serialize(customPacingClass);
        System.debug(json);
   

        return json;
    }

    @AuraEnabled(cacheable=false)
    public static string getAudienceTrak(string id, string flightDates){

        System.debug(LoggingLevel.INFO, 'DC id ' + id);

        Digital_Campaign__c dc = getDC(id);


        List<Inventory_Source__c> invSourceLst =  getInventoryImpression(dc.id, AUDIENCE_TRAK_CTV);
     
        CustomPacingClass customPacingClass = new CustomPacingClass(); 
        customPacingClass.isAudienceTrack      = true;
        customPacingClass.Title                = AUDIENCE_TRAK;
        customPacingClass.TotalImpressions     = (dc.Total_Impressions__c == null) ? 0 : dc.Total_Impressions__c.intValue();
        customPacingClass.ImpressionsDelivered = (dc.Delivered_Impressions__c == null) ? 0 : dc.Delivered_Impressions__c.intValue();
        

        if (invSourceLst.size() > 0){
            customPacingClass.TotalImpressions = (invSourceLst[0].Impressions__c == null) ? 0 : invSourceLst[0].Impressions__c .intValue();
        }


        List<FlightDatesClass> flightDateClassList = createFlightDatesObject(flightDates); 
        customPacingClass.fligthDates              = flightDateClassList;
        customPacingClass.NumberOfDays             = getTotalFlightDays(flightDateClassList, CalculationType.NORMAL);       
        customPacingClass.DailyGoal                = (customPacingClass.NumberOfDays != 0) ? (customPacingClass.TotalImpressions / getTotalFlightDays(flightDateClassList, CalculationType.NORMAL)) : 0;

        customPacingClass.Notes   = '<ul><li>Impression Goal - Total Number of Days  = <strong>Daily Goal</strong><br />'  +  
                                    '<strong>(' +  customPacingClass.TotalImpressions +  ' / ' +  customPacingClass.NumberOfDays  + ') = ' + customPacingClass.DailyGoal.ROUND(System.RoundingMode.CEILING)   + '</strong></li></ul>';
    
         customPacingClass.presentation = setAudienceTrakPresentation(customPacingClass, customPacingClass.DailyGoal);




         customPacingClass.DailyGoal = customPacingClass.DailyGoal.ROUND(System.RoundingMode.CEILING);

        String json = JSON.serialize(customPacingClass);
        System.debug(json);

        

        return json;
    } 

    @AuraEnabled(cacheable=false)
    public static string getImpressions(string id){

        List<Inventory_Source__c> impressionSource = [SELECT id, Impressions__c, Digital_Campaign__c, Inventory_Resource_Type__c FROM Inventory_Source__c 
                                                     WHERE Digital_Campaign__c =: id AND Inventory_Resource_Type__c !=: AUDIENCE_TRAK_CTV ];
        
        
        String json = JSON.serialize(impressionSource);
        System.debug(json);
   
        return json;
    }

    private static List<Inventory_Source__c> getInventoryImpression(string id, string InventorySourceType){

        List<Inventory_Source__c> inventoryResource = [SELECT id, Inventory_Resource_Type__c , Impressions__c FROM Inventory_Source__c 
                                                        WHERE Digital_Campaign__c =: id  AND Inventory_Resource_Type__c =: InventorySourceType];

        return inventoryResource;
    }



    @TestVisible
    private static Digital_Campaign__c getDC(string id){

        List<Digital_Campaign__c> dc = [SELECT Id, Total_Impressions__c, 
                                                   Flight_Dates_Backend__c, 
                                                   Delivered_Impressions__c
                                        FROM Digital_Campaign__c 
                                        WHERE id =: id LIMIT 1];

        if (dc.size() > 0){
            return dc[0];
        }

        return null;
    }

    @TestVisible 
    private static Decimal getDailyDeliveryCalculation(Decimal TotalImpression, Integer numberOfDays, Decimal deliveredExpression){
        return (numberOfDays == 0) ? numberOfDays : ((TotalImpression  - deliveredExpression) / numberOfDays);
    }
 
    @TestVisible
    public static List<FlightDatesClass> createFlightDatesObject(string flighDatesRawData){

        List<FlightDatesClass> flighDateClassList = new List<FlightDatesClass>();

        if (flighDatesRawData == null || flighDatesRawData == ''){
            return flighDateClassList;
        }

        List<string> flightDateList  =  flighDatesRawData.split(';');
    
        for(string flightDatesCommaDelimited : flightDateList){

             List<string> dates = flightDatesCommaDelimited.split(':');

             string startDate     = (dates.size() >= 1) ? dates[0] : '';
             string endDate       = (dates.size() >= 2) ? dates[1] : '';

             Integer numberOfDays = getNumberOfDays(startDate, endDate);

             FlightDatesClass flighDateClass = new FlightDatesClass();
             flighDateClass.StartDate     = startDate;
             flighDateClass.EndDate       = endDate;
             flighDateClass.NumberOfDays  = numberOfDays;

             System.debug(LoggingLevel.INFO, 'StartDate: ' + startDate + ' EndDate: ' + endDate + ' Number of Days: ' +  flighDateClass.NumberOfDays);

             flighDateClassList.add(flighDateClass);         
        }

        return flighDateClassList;
    }

    @TestVisible
    private static Integer getNumberOfDays(string startDate, string endDate){
        
        Integer numberofDays = 0;

        try{

            Date startDt = parseDate(startDate);
            Date endDt   = parseDate(endDate);

            numberofDays = startDt.daysBetween(endDt.addDays(1));    
    
        }catch (Exception e){            
            return 0;
        }

        return numberofDays;
    }

    @TestVisible
    private static Integer calculateRemaingExpression(Integer TotalImpression, Integer ImpressionsDelivered){
        return (TotalImpression - ImpressionsDelivered);
    }

    @TestVisible
    private static Date parseDate(String inDate) {
        Date dateRes        = null;
        //  1 - Try locale specific mm/dd/yyyy or dd/mm/yyyy    
        try {
            String candDate = inDate.substring(0,Math.min(10,inDate.length()));// grab date portion only m[m]/d[d]/yyyy , ignore time
            dateRes         = Date.parse(candDate);
        }
        catch (Exception e) {
            System.debug(e.getMessage());
        }
    
        if (dateRes == null) {
        //  2 - Try yyyy-mm-dd          
            try {
                String candDate     = inDate.substring(0,10);           // grab date portion only, ignore time, if any
                dateRes             = Date.valueOf(candDate);
            }
            catch (Exception e) {
                System.debug(e.getMessage());
            } 
        }
        
        return dateRes;
    }

    @TestVisible
    public static Integer getTotalFlightDays(List<FlightDatesClass> flightDayClassList, CalculationType calcType){

        Integer total = 0;
        Integer index = 0;

        for(FlightDatesClass flightDate : flightDayClassList){

            if ((index == 0) && (calcType == CalculationType.PAUSE_NOW  || calcType == CalculationType.PAUSE_LATER)){
                ++index;
                continue;
            }

            total += (flightDate.NumberOfDays != null) ? flightDate.NumberOfDays : 0;

            ++index;
        }

        return  total;
    }
 
    @TestVisible
    private static List<CustomPacingPresentationClass> setPrePlanPresentationData(List<FlightDatesClass> flightDateClassList, Decimal dailyDelivery, 
                                                                           Decimal totalImpression){

        Decimal cumulativePercentageGoal = 0;
        Integer presentationId         = 0;

        List<CustomPacingPresentationClass> presentation = new List<CustomPacingPresentationClass>();

        if (totalImpression == 0){
            return presentation;
        }

        for(FlightDatesClass flightDate : flightDateClassList){

            Decimal result =  (dailyDelivery * flightDate.NumberOfDays) / totalImpression;
            Decimal format =  (result * 100);

            flightDate.ActualPercentageGoal =  format.setScale(2);
            
            Integer currrentPresentationId = ++presentationId;

            CustomPacingPresentationClass startFightPresentation = new CustomPacingPresentationClass();
            startFightPresentation.Id               = currrentPresentationId;
            startFightPresentation.PrecentageBudget = '0% of Budget On '; 
            startFightPresentation.FligthDateInfo   = parseDate(flightDate.StartDate).addDays(-1).format()  + ((currrentPresentationId == 1)  ? ' 12:00 AM' : ' 11:59 PM');
            startFightPresentation.NumberOfDays     = 0;
        
            presentation.add(startFightPresentation);

            cumulativePercentageGoal = (flightDate.ActualPercentageGoal + cumulativePercentageGoal);

            flightDate.PercentageGoal = cumulativePercentageGoal.setScale(2);

            CustomPacingPresentationClass endFightPresentation = new CustomPacingPresentationClass();
            endFightPresentation.Id               = ++presentationId;
            endFightPresentation.PrecentageBudget = cumulativePercentageGoal + '% of Budget On '; 
            endFightPresentation.FligthDateInfo   = parseDate(flightDate.EndDate).format()  + ' 11:59 PM';
            endFightPresentation.NumberOfDays     = flightDate.NumberOfDays;

            presentation.add(endFightPresentation); 

        }

        return presentation;
    }

    @TestVisible
    private static List<CustomPacingPresentationClass> setPausePresentation(CustomPacingClass params, CalculationType calcType){

        Decimal cumulativePercentageGoal = 0;
        Integer presentationId         = 0;

        List<CustomPacingPresentationClass> presentation = new List<CustomPacingPresentationClass>();

        if (params.TotalImpressions == 0){
            return presentation;
        }


        for(FlightDatesClass flightDate : params.fligthDates){

            Decimal result =  (params.dailyDelivery * flightDate.NumberOfDays) / params.TotalImpressions;
            Decimal format =  (result * 100);

            flightDate.ActualPercentageGoal =  format.setScale(2);
            
            Integer currrentPresentationId = ++presentationId;

            CustomPacingPresentationClass startFightPresentation = new CustomPacingPresentationClass();
            startFightPresentation.Id               = currrentPresentationId;
            startFightPresentation.PrecentageBudget = '0% of Budget On '; 
            startFightPresentation.FligthDateInfo   = parseDate(flightDate.StartDate).addDays(-1).format() + ((currrentPresentationId == 1)  ? ' 12:00 AM' : ' 11:59 PM'); 
            startFightPresentation.NumberOfDays     = 0;
        
            presentation.add(startFightPresentation);

            if (calcType == CalculationType.PAUSE_LATER){
                cumulativePercentageGoal = getPauseLaterCumulativePercentGoal(params, currrentPresentationId, flightDate.NumberOfDays, cumulativePercentageGoal);
            }
       
            if (calcType == CalculationType.PAUSE_NOW){
                cumulativePercentageGoal = getPauseNowCumulativePercentGoal(params, currrentPresentationId, flightDate.NumberOfDays, cumulativePercentageGoal);
            }


            flightDate.PercentageGoal = (cumulativePercentageGoal * 100).setScale(2);

            CustomPacingPresentationClass endFightPresentation = new CustomPacingPresentationClass();
            endFightPresentation.Id               = ++presentationId;
            endFightPresentation.PrecentageBudget = flightDate.PercentageGoal + '% of Budget On '; 
            endFightPresentation.FligthDateInfo   = parseDate(flightDate.EndDate).format()  + ' 11:59 PM';
            endFightPresentation.NumberOfDays     = flightDate.NumberOfDays;

            presentation.add(endFightPresentation); 

        }

        return presentation;
    }

    @TestVisible 
    private static List<CustomPacingPresentationClass> setAudienceTrakPresentation(CustomPacingClass params, Decimal dailyGoals){

     
        Integer presentationId = 0;

        List<CustomPacingPresentationClass> presentationLst = new List<CustomPacingPresentationClass>();

    

        for(FlightDatesClass flightDate : params.fligthDates){
         
            Integer currrentPresentationId = ++presentationId;

            CustomPacingPresentationClass presentation = new CustomPacingPresentationClass();
        
            presentation.Id           = currrentPresentationId;
            presentation.StartDate    = parseDate(flightDate.StartDate).format();
            presentation.EndDate      = parseDate(flightDate.EndDate).format(); 
            presentation.NumberOfDays = flightDate.NumberOfDays;    
            presentation.Imps         =  (presentation.NumberOfDays * dailyGoals);
            
            presentationLst.add(presentation);
        }

        return presentationLst;
    }

    @TestVisible
    private static Decimal getPauseNowCumulativePercentGoal(CustomPacingClass params, Integer currrentPresentationId, Integer numberOfDays, Decimal cumulativePercentageGoal){

        Decimal result;

        if (currrentPresentationId == 1){
            result = (params.TotalImpressions == 0) ? 0 : (params.ImpressionsDelivered / params.TotalImpressions);
        }else{
            result = (params.dailyDelivery.setScale(2) *  numberOfDays) / params.TotalImpressions + cumulativePercentageGoal; 
        }

        System.debug('Puase Now Result ' + result + ' currrentPresentationId ' + currrentPresentationId);

        return result;
    }
    
    @TestVisible
    private static Decimal getPauseLaterCumulativePercentGoal(CustomPacingClass params, Integer currrentPresentationId, Integer numberOfDays, Decimal cumulativePercentageGoal){
        Decimal result;
    
        if (currrentPresentationId == 1){
             result  = (params.TotalImpressions == 0) ? 0 : (params.ImpressionsDeliverByFirstPauseDate / params.TotalImpressions);
        }
        else{
             result  = (params.TotalImpressions == 0) ? 0 : ((params.NewDailyDelivery * numberOfDays) / params.TotalImpressions ) + cumulativePercentageGoal;   
        }

        System.debug('Puase Later Result ' + result + ' currrentPresentationId ' + currrentPresentationId);

        return result;
    }

    @TestVisible
    private static Decimal setFirstFlightDate(Decimal ImpressionGoal, Decimal DeliveredExpression){

        return (ImpressionGoal != 0) ? (DeliveredExpression / ImpressionGoal ) : ImpressionGoal;
    }

    @TestVisible
    private static Decimal calculateAverageDelivery(Decimal ImpressionsDelivered, Integer numberOfDaysDeliver){

        Decimal result =  (numberOfDaysDeliver == 0) ? 0 : (ImpressionsDelivered / numberOfDaysDeliver).setScale(2);

        System.debug('calculateAverageDelivery result ' + result);

        return result;
    }

    @TestVisible
    private static Decimal calculateImpressionsDeliverByFirstPauseDate(Decimal AverageDelivery, Integer NumberOfDays){

        Decimal result = (AverageDelivery * NumberOfDays).setScale(2);

        System.debug('calculateImpressionsDeliverByFirstPauseDate result ' + result);

        return result;
    }          
    
    @TestVisible
    private static Decimal calculateImpressionsRemainingByFirstPauseDate(Integer TotalImpressions, Decimal ImpressionsDeliverByFirstPauseDate){

        Decimal result = (TotalImpressions - ImpressionsDeliverByFirstPauseDate).setScale(2);

        System.debug('calculateImpressionsRemainingByFirstPauseDate result ' + result);

        return result;
    }

    @TestVisible
    private static Decimal calculatePauseLaterNewDailyDelivery(Decimal ImpressionsRemainingByFirstPauseDate, Integer NumberOfDays){

        Decimal result = (NumberOfDays == 0) ? 0 : (ImpressionsRemainingByFirstPauseDate / NumberOfDays).setScale(2);

        System.debug('calculatePauseLaterNewDailyDelivery result ' + result);

        return result;
    }
}