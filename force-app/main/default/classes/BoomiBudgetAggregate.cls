public class BoomiBudgetAggregate {

	public List<String> userList;


	public static BoomiBudgetAggregate parse(String json) {
		return(BoomiBudgetAggregate) System.JSON.deserialize(json, BoomiBudgetAggregate.class);
	}
}