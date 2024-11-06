public with sharing class SyscodeHelper {

	public class Zone_3_5 {
		public String ZoneID;
		public String Description;
		public String SysCode;
		public String IsRegion;
		public String RatePct;
		public String AvailClassID;
		public String InventoryTypeID;
		public String OrderTypeID;
		public String MarketID;
		public String IsActive;
		public String IsProduction;
	}

	
	public ZoneList ZoneList;
	

	public class ZoneList {
		public List<Zone_3_5> Zone_3_5;
	}

	
	public static SyscodeHelper parse(String json) {
		return (SyscodeHelper) System.JSON.deserialize(json, SyscodeHelper.class);
	}
    
}