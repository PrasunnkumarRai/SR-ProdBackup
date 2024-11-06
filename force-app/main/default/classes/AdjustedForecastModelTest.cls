@IsTest
public class AdjustedForecastModelTest {
   @IsTest
    static void testAdjustedForecasteModelParsing(){
        string json = '[{"monthKey":"2023-07","monthAmount":100,"netAmount":80,"scheduleType":"Type A","accountId":"001"},{"monthKey":"2023-08","monthAmount":200,"netAmount":160,"scheduleType":"Type B","accountId":"002"}]';

      List<AdjustedForecastModel> parsedModels = AdjustedForecastModel.parse(json);
    }
    
   @IsTest
    static void testConsumeObject(){
        string json = '{"field1": "value1", "field2": {"subField1": "subValue1", "subField2": [1, 2, 3]},"field3": ["item1", "item2"]}';
    
      system.JSONParser parser = system.JSON.createParser(json);
      AdjustedForecastModel.consumeObject(parser);
    }

}