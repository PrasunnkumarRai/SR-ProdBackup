public class DnBResponseErrorController {

	public class MatchCandidates {
	}

	public class Address {
		public String countryISOAlpha2Code;
		public String addressLocality;
		public String addressRegion;
		public String postalCode;
		public StreetAddressLine streetAddressLine;
	}

	public class StreetAddressLine {
		public String line1;
	}

	public class InquiryDetail {
		public String name;
		public Address address;
	}

	public class cls_fault {
		public String faultstring; //Execution returned an error result
		public cls_detail detail;
	}
	public class cls_detail {
		public String errorcode; //flow.execution.ExecutionReturnedFailure
	}
	public class Error {
		public String errorCode;
		public String errorMessage;
		public Boolean isDataError;
	}

	public class TransactionDetail {
		public String transactionID;
		public String transactionTimestamp;
		public String inLanguage;
		public String serviceVersion;
	}

	public TransactionDetail transactionDetail;
	public Error error;
	public InquiryDetail inquiryDetail;
	public Integer candidatesMatchedQuantity;
	public String matchDataCriteria;
	public List<MatchCandidates> matchCandidates;
	public MatchCandidates cleanseAndStandardizeInformation;
	Public cls_fault fault;

	public static DnBResponseErrorController parse(String json) {
		return(DnBResponseErrorController) System.JSON.deserialize(json, DnBResponseErrorController.class);
	}
}