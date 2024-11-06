public with sharing class ListViewResponseModel {
    public Integer size;
	public List<Records> records;
	public String label;
	public String id;
	public Boolean done;
	public String developerName;
	public List<Columns_Z> columns;

	public class Columns {
		public String value;
		public String fieldNameOrPath;
	}

	public class Records {
		public List<Columns> columns;
	}

	public class Columns_Z {
		public String type;
		public Boolean sortable;
		public Integer sortIndex;
		public String sortDirection;
		public String selectListItem;
		public Boolean searchable;
		public String label;
		public Boolean hidden;
		public String fieldNameOrPath;
		public String descendingLabel;
		public String ascendingLabel;
	}

	
	public static ListViewResponseModel parse(String json) {
		return (ListViewResponseModel) System.JSON.deserialize(json, ListViewResponseModel.class);
	}
}