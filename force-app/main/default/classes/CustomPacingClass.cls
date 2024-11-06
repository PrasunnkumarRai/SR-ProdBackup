public class CustomPacingClass {
    public String Title {get; set;}
    public Decimal DailyDelivery {get; set;}
    public Decimal AverageDelivery {get; set;}
    public Decimal NewDailyDelivery {get; set;}
    public Integer NumberOfDays {get; set;}   
    public Boolean ShowImpressionDelivered {get; set;}
    public String Notes {get; set;}
    public String YesterydaysDate {get; set;}
    public String NumberOfDaysDeliver {get; set;}
    public Integer TotalImpressions {get; set;}
    public Decimal ImpressionsDelivered {get; set;}
    public Decimal InventoryImpressionsDelivered {get; set;}
    public Decimal RemaingImpressions {get; set;}
    public Decimal ImpressionsDeliverByFirstPauseDate {get; set;}
    public Decimal ImpressionsRemainingByFirstPauseDate {get; set;}
    public List<FlightDatesClass> fligthDates {get; set;}
    public List<CustomPacingPresentationClass> presentation {get; set;}
    public Boolean isAudienceTrack {get; set;}
    public Decimal DailyGoal {get; set;}
}