@IsTest
public class DnBResponseErrorController_Test {

	static testMethod void testParse() {
		String json = '{\"transactionDetail\":{\"transactionID\":\"rrt-0fdd84aee4fb62114-d-ea-31862-305932239-61\",\"transactionTimestamp\":\"2021-02-15T11:09:50.195Z\",\"inLanguage\":\"en-US\",\"serviceVersion\":\"v1\"},\"error\":{\"errorCode\":\"20505\",\"errorMessage\":\"No Match found for the given input criteria\"},\"inquiryDetail\":{\"name\":\"Cateye�fe\",\"address\":{\"countryISOAlpha2Code\":\"US\",\"addressLocality\":\"Bozeman\",\"addressRegion\":\"MT\",\"postalCode\":\"59715\",\"streetAddressLine\":{\"line1\":\"\"}}},\"candidatesMatchedQuantity\":0,\"matchDataCriteria\":\"Name and Address Lookup\",\"matchCandidates\":[],\"cleanseAndStandardizeInformation\":{}}';
		DnBResponseErrorController obj = DnBResponseErrorController.parse(json);
		System.assert(obj != null);
	}
}