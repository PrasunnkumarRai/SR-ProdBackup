public class LookupSearchResult {
	private String id;
	private String sObjectType;
	private String icon;
	private String title;
	private String subtitle;

	public LookupSearchResult(
	                          String id,
	                          String sObjectType,
	                          String icon,
	                          String title,
	                          String subtitle
	) {
		this.id = id;
		this.sObjectType = sObjectType;
		this.icon = icon;
		this.title = title;
		this.subtitle = subtitle;
	}

	@AuraEnabled
	public String getId() {
		return id;
	}

	@AuraEnabled
	public String getSObjectType() {
		return sObjectType;
	}

	@AuraEnabled
	public String getIcon() {
		return icon;
	}

	@AuraEnabled
	public String getTitle() {
		return title;
	}

	@AuraEnabled
	public String getSubtitle() {
		return subtitle;
	}
}