public class GetFolderContentJSONParser {
	public Integer SyncpointId;
	public String FolderId;
	public String VirtualPath;
	public String Name;
	public Integer Status;
	public List<Files> Files;
	public List<Folders> Folders;
	public String ParentFolderId;

	public class Folders {
		public String SyncpointId;
		public String FolderId;
		public String VirtualPath;
		public String Name;
		public Integer Status;
		public List<Files> Folders;
		public String ParentFolderId;
	}

	public class Files {
		public String SyncpointId;
		public String FileId;
		public String Filename;
		public String Length;
		public Integer Status;
		public String FolderId;
	}


	public static GetFolderContentJSONParser parse(String json) {
		System.debug('GetFolderContentJSONParser JSON: ' + json);
		return(GetFolderContentJSONParser) System.JSON.deserialize(json, GetFolderContentJSONParser.class);
	}
}