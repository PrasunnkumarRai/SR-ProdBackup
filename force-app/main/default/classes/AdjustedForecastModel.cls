public with sharing class AdjustedForecastModel {
    public String monthKey {get;set;} 
	public Integer monthAmount {get;set;} 
	public Integer netAmount {get;set;} 
	public String scheduleType {get;set;} 
	public String accountId {get;set;} 

	public AdjustedForecastModel(JSONParser parser) {
		while (parser.nextToken() != System.JSONToken.END_OBJECT) {
			if (parser.getCurrentToken() == System.JSONToken.FIELD_NAME) {
				String text = parser.getText();
				if (parser.nextToken() != System.JSONToken.VALUE_NULL) {
					if (text == 'monthKey') {
						monthKey = parser.getText();
					} else if (text == 'monthAmount') {
						monthAmount = parser.getIntegerValue();
					} else if (text == 'netAmount') {
						netAmount = parser.getIntegerValue();
					} else if (text == 'scheduleType') {
						scheduleType = parser.getText();
					} else if (text == 'accountId') {
						accountId = parser.getText();
					} else {
						System.debug(LoggingLevel.WARN, 'AdjustedForecastModel consuming unrecognized property: '+text);
						consumeObject(parser);
					}
				}
			}
		}
	}
	
	
	public static List<AdjustedForecastModel> parse(String json) {
		System.JSONParser parser = System.JSON.createParser(json);
		return arrayOfAdjustedForecastModel(parser);
	}
	
	public static void consumeObject(System.JSONParser parser) {
		Integer depth = 0;
		do {
			System.JSONToken curr = parser.getCurrentToken();
			if (curr == System.JSONToken.START_OBJECT || 
				curr == System.JSONToken.START_ARRAY) {
				depth++;
			} else if (curr == System.JSONToken.END_OBJECT ||
				curr == System.JSONToken.END_ARRAY) {
				depth--;
			}
		} while (depth > 0 && parser.nextToken() != null);
	}
	


    private static List<AdjustedForecastModel> arrayOfAdjustedForecastModel(System.JSONParser p) {
        List<AdjustedForecastModel> res = new List<AdjustedForecastModel>();
        if (p.getCurrentToken() == null) p.nextToken();
        while (p.nextToken() != System.JSONToken.END_ARRAY) {
            res.add(new AdjustedForecastModel(p));
        }
        return res;
    }
}