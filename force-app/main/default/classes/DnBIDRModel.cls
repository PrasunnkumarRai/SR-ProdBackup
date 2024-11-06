public class DnBIDRModel {

	public class TradeStyleNames {
		public String name;
		public Integer priority;
	}

	public class PrimaryAddress {
		public AddressCountry addressCountry;
		public AddressLocality addressLocality;
		public AddressRegion addressRegion;
		public String postalCode;
		public String postalCodeExtension;
		public StreetAddress streetAddress;
	}

	public class Organization {
		public String duns;
		public DunsControlStatus dunsControlStatus;
		public String primaryName;
		public List<Telephone> telephone;
		public PrimaryAddress primaryAddress;
		public MailingAddress mailingAddress;
		public List<MostSeniorPrincipals> mostSeniorPrincipals;
		public Boolean isStandalone;
		public CorporateLinkage corporateLinkage;
	}

	public class Address {
		public String countryISOAlpha2Code;
	}

	public class Telephone {
		public String telephoneNumber;
		public Boolean isUnreachable;
	}

	public String Authorization;
	public TransactionDetail transactionDetail;
	public InquiryDetail inquiryDetail;
	public Integer candidatesMatchedQuantity;
	public String matchDataCriteria;
	public List<MatchCandidates> matchCandidates;

	public class AddressCountry {
		public String isoAlpha2Code;
		public String name;
	}

	public class MatchQualityInformation {
		public Integer confidenceCode;
		public String matchGrade;
		public Integer matchGradeComponentsCount;
		public List<MatchGradeComponents> matchGradeComponents;
		public String matchDataProfile;
		public Integer matchDataProfileComponentsCount;
		public List<MatchDataProfileComponents> matchDataProfileComponents;
		public Integer nameMatchScore;
	}

	public class OperatingStatus {
		public String description;
		public Integer dnbCode;
	}

	public class TransactionDetail {
		public String transactionID;
		public String transactionTimestamp;
		public String inLanguage;
		public String serviceVersion;
	}

	public class AddressRegion {
		public String abbreviatedName;
	}

	public class MatchDataProfileComponents {
		public String componentType;
		public String componentValue;
	}

	public class MatchCandidates {
		public Integer displaySequence;
		public Organization organization;
		public MatchQualityInformation matchQualityInformation;
	}

	public class MailingAddress_Y {
		public AddressCountry addressCountry;
		public AddressLocality addressLocality;
		public AddressRegion addressRegion;
		public String postalCode;
		public StreetAddress streetAddress;
	}

	public class DunsControlStatus {
		public OperatingStatus operatingStatus;
		public Boolean isMailUndeliverable;
	}

	public class MailingAddress_Z {
		public AddressCountry addressCountry;
	}

	public class AddressLocality {
		public String name;
	}

	public class Organization_Y {
		public String duns;
		public DunsControlStatus dunsControlStatus;
		public String primaryName;
		public List<Telephone> telephone;
		public PrimaryAddress primaryAddress;
		public MailingAddress_Y mailingAddress;
		public List<MostSeniorPrincipals> mostSeniorPrincipals;
		public Boolean isStandalone;
	}

	public class Organization_X {
		public String duns;
		public DunsControlStatus dunsControlStatus;
		public String primaryName;
		public List<Telephone> telephone;
		public PrimaryAddress primaryAddress;
		public MailingAddress_Z mailingAddress;
		public Boolean isStandalone;
	}

	public class MailingAddress {
		public AddressCountry addressCountry;
		public String postalCode;
	}

	public class Organization_Z {
		public String duns;
		public DunsControlStatus dunsControlStatus;
		public String primaryName;
		public List<Telephone> telephone;
		public PrimaryAddress primaryAddress;
		public MailingAddress_Z mailingAddress;
		public List<MostSeniorPrincipals> mostSeniorPrincipals;
		public Boolean isStandalone;
	}

	public class MostSeniorPrincipals {
		public String fullName;
	}

	public class Organization_W {
		public String duns;
		public DunsControlStatus dunsControlStatus;
		public String primaryName;
		public List<TradeStyleNames> tradeStyleNames;
		public List<Telephone> telephone;
		public PrimaryAddress primaryAddress;
		public MailingAddress_Z mailingAddress;
		public List<MostSeniorPrincipals> mostSeniorPrincipals;
		public Boolean isStandalone;
	}

	public class StreetAddress {
		public String line1;
	}

	public class InquiryDetail {
		public String name;
		public Address address;
	}

	public class CorporateLinkage {
		public List<OperatingStatus> familytreeRolesPlayed;
	}

	public class MatchGradeComponents {
		public String componentType;
		public String componentRating;
	}


	public static DnBIDRModel parse(String json) {
		return(DnBIDRModel) System.JSON.deserialize(json, DnBIDRModel.class);
	}
}