public class BoomiResponse {
	public static void consumeObject(JSONParser parser) {
		Integer depth = 0;
		do {
			JSONToken curr = parser.getCurrentToken();
			if (curr == JSONToken.START_OBJECT || 
				curr == JSONToken.START_ARRAY) {
				depth++;
			} else if (curr == JSONToken.END_OBJECT ||
				curr == JSONToken.END_ARRAY) {
				depth--;
			}
		} while (depth > 0 && parser.nextToken() != null);
	}

	public class Response {
		public String success {get;set;} 
		public List<Error> error {get;set;} 
		public Metadata metadata {get;set;} 

		public Response(JSONParser parser) {
			while (parser.nextToken() != JSONToken.END_OBJECT) {
				if (parser.getCurrentToken() == JSONToken.FIELD_NAME) {
					String text = parser.getText();
					if (parser.nextToken() != JSONToken.VALUE_NULL) {
						if (text == 'success') {
							success = parser.getText();
						} else if (text == 'error') {
							error = new List<Error>();
							while (parser.nextToken() != JSONToken.END_ARRAY) {
								error.add(new Error(parser));
							}
						} else if (text == 'metadata') {
							metadata = new Metadata(parser);
						} else {
							System.debug(LoggingLevel.WARN, 'Response consuming unrecognized property: '+text);
							consumeObject(parser);
						}
					}
				}
			}
		}
	}
	
	public class Metadata {
		public String executionId {get;set;} 
		public String datex {get;set;} 
		public String System_Z {get;set;} // in json: System
		public String processName {get;set;} 

		public Metadata(JSONParser parser) {
			while (parser.nextToken() != JSONToken.END_OBJECT) {
				if (parser.getCurrentToken() == JSONToken.FIELD_NAME) {
					String text = parser.getText();
					if (parser.nextToken() != JSONToken.VALUE_NULL) {
						if (text == 'executionId') {
							executionId = parser.getText();
						} else if (text == 'date') {
							datex = parser.getText();
						} else if (text == 'System') {
							System_Z = parser.getText();
						} else if (text == 'processName') {
							processName = parser.getText();
						} else {
							System.debug(LoggingLevel.WARN, 'Metadata consuming unrecognized property: '+text);
							consumeObject(parser);
						}
					}
				}
			}
		}
	}
	
	public class Error {
		public String message {get;set;} 
		public String cause {get;set;} 

		public Error(JSONParser parser) {
			while (parser.nextToken() != JSONToken.END_OBJECT) {
				if (parser.getCurrentToken() == JSONToken.FIELD_NAME) {
					String text = parser.getText();
					if (parser.nextToken() != JSONToken.VALUE_NULL) {
						if (text == 'message') {
							message = parser.getText();
						} else if (text == 'cause') {
							cause = parser.getText();
						} else {
							System.debug(LoggingLevel.WARN, 'Error consuming unrecognized property: '+text);
							consumeObject(parser);
						}
					}
				}
			}
		}
	}
	
	public class BoomiJSONResponse {
		public Response Response {get;set;} 

		public BoomiJSONResponse(JSONParser parser) {
			while (parser.nextToken() != JSONToken.END_OBJECT) {
				if (parser.getCurrentToken() == JSONToken.FIELD_NAME) {
					String text = parser.getText();
					if (parser.nextToken() != JSONToken.VALUE_NULL) {
						if (text == 'Response') {
							Response = new Response(parser);
						} else {
							System.debug(LoggingLevel.WARN, 'BoomiResponse consuming unrecognized property: '+text);
							consumeObject(parser);
						}
					}
				}
			}
		}
	}
		
	public static BoomiJSONResponse parse(String json) {
		return new BoomiJSONResponse(System.JSON.createParser(json));
	}
}