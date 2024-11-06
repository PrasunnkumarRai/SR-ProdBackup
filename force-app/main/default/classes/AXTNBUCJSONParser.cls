/*
###########################################################################
# File..................: AXTNBUCJSONParser.cls
# Version...............: 1
# Created by............: James Dean
# Created Date..........: 24-Sep-2018
# Last Modified by......:
# Last Modified Date....:
# Description...........: This class contains JSON parser methods for managing AccountTransferTool page
# TAO Ref#..............: NA
# Test Class............: 
# Change Log............:
#
#
############################################################################*/

public class AXTNBUCJSONParser {

	public String FromUserID {get;set;} 
	public String ToUserID {get;set;} 
	public String Type_Z {get;set;} // in json: Type
	public String ProductLine {get;set;} 
	public String OldProductLine {get;set;} 
	public String BroadcastDate {get;set;} 
	public String MonthID {get;set;} 
	public String DMA {get;set;} 
	public Integer DMAContri {get;set;} 
	public Integer Percentage {get;set;} 
	public String commodity {get;set;} 
	public Integer CommodityContri {get;set;} 
	public String UniqueKey {get;set;} 

	public AXTNBUCJSONParser(JSONParser parser) {
		while (parser.nextToken() != System.JSONToken.END_OBJECT) {
			if (parser.getCurrentToken() == System.JSONToken.FIELD_NAME) {
				String text = parser.getText();
				if (parser.nextToken() != System.JSONToken.VALUE_NULL) {
					if (text == 'FromUserID') {
						FromUserID = parser.getText();
					} else if (text == 'ToUserID') {
						ToUserID = parser.getText();
					} else if (text == 'Type') {
						Type_Z = parser.getText();
					} else if (text == 'ProductLine') {
						ProductLine = parser.getText();
					} else if (text == 'oldProductLine') {
						OldProductLine = parser.getText();
					} else if (text == 'BroadcastDate') {
						BroadcastDate = parser.getText();
					} else if (text == 'MonthID') {
						MonthID = parser.getText();
					} else if (text == 'DMA') {
						DMA = parser.getText();
					} else if (text == 'DMAContri') {
						DMAContri = parser.getIntegerValue();
					} else if (text == 'Percentage') {
						Percentage = parser.getIntegerValue();
					} else if (text == 'commodity') {
						commodity = parser.getText();
					} else if (text == 'CommodityContri') {
						CommodityContri = parser.getIntegerValue();
					} else if (text == 'UniqueKey') {
						UniqueKey = parser.getText();
					} else {
						System.debug(LoggingLevel.WARN, 'JSON2Apex consuming unrecognized property: '+text);
						consumeObject(parser);
					}
				}
			}
		}
	}
	
	
	public static List<AXTNBUCJSONParser> parse(String json) {
		System.JSONParser parser = System.JSON.createParser(json);
		return arrayOfJSON2Apex(parser);
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
	





    private static List<AXTNBUCJSONParser> arrayOfJSON2Apex(System.JSONParser p) {
        List<AXTNBUCJSONParser> res = new List<AXTNBUCJSONParser>();
        if (p.getCurrentToken() == null) p.nextToken();
        while (p.nextToken() != System.JSONToken.END_ARRAY) {
            res.add(new AXTNBUCJSONParser(p));
        }
        return res;
    }


	

}