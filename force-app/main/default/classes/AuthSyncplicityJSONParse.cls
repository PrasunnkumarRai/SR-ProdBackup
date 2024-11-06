public class AuthSyncplicityJSONParse {

	public String access_token { get; set; }
	public String token_type { get; set; }
	public Integer expires_in { get; set; }
	public String scope { get; set; }
	public String user_email { get; set; }
	public String user_id { get; set; }
	public String user_company_name { get; set; }
	public String backend_token_type { get; set; }
	public String issued_at { get; set; }
	public String client_id { get; set; }
	public String user_company_id { get; set; }

	public AuthSyncplicityJSONParse(JSONParser parser) {
		while (parser.nextToken() != System.JSONToken.END_OBJECT) {
			if (parser.getCurrentToken() == System.JSONToken.FIELD_NAME) {
				String text = parser.getText();
				if (parser.nextToken() != System.JSONToken.VALUE_NULL) {
					if (text == 'access_token') {
						access_token = parser.getText();
					} else if (text == 'token_type') {
						token_type = parser.getText();
					} else if (text == 'expires_in') {
						expires_in = parser.getIntegerValue();
					} else if (text == 'scope') {
						scope = parser.getText();
					} else if (text == 'user_email') {
						user_email = parser.getText();
					} else if (text == 'user_id') {
						user_id = parser.getText();
					} else if (text == 'user_company_name') {
						user_company_name = parser.getText();
					} else if (text == 'backend_token_type') {
						backend_token_type = parser.getText();
					} else if (text == 'issued_at') {
						issued_at = parser.getText();
					} else if (text == 'client_id') {
						client_id = parser.getText();
					} else if (text == 'user_company_id') {
						user_company_id = parser.getText();
					} else {
						System.debug(LoggingLevel.WARN, 'AuthSyncplicityJSONParse consuming unrecognized property: ' + text);
						consumeObject(parser);
					}
				}
			}
		}
	}


	public static AuthSyncplicityJSONParse parse(String json) {
		System.debug('AuthSyncplicityJSONParse JSON: ' + json);
		System.JSONParser parser = System.JSON.createParser(json);
		return new AuthSyncplicityJSONParse(parser);
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
}