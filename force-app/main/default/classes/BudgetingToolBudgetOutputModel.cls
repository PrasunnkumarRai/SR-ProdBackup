public with sharing class BudgetingToolBudgetOutputModel {
	
	public class Change {
		public String id;
		public Integer Changed;
		public String Jan;
		public String Feb;
		public String Mar;
		public String Apr;
		public String May;
		public String Jun;
		public String Jul;
		public String Aug;
		public String Sep;
		public String Oct;
		public String Nov;
		public String Dec;
		public String ChurnIndicator;
	}

	public class IO {
	}

	public IO IO;
	public List<Change> Changes;

	
	public static BudgetingToolBudgetOutputModel parse(String json) {
		return (BudgetingToolBudgetOutputModel) System.JSON.deserialize(json, BudgetingToolBudgetOutputModel.class);
	}    
}