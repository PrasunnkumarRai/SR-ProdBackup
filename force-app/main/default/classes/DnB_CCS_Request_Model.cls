public class DnB_CCS_Request_Model {

	public List<String> dunsList;
	public Integer pageSize;
	public Integer pageNumber;

	
	public static DnB_CCS_Request_Model parse(String json) {
		return (DnB_CCS_Request_Model) System.JSON.deserialize(json, DnB_CCS_Request_Model.class);
	}
}