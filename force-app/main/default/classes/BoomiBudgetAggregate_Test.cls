@IsTest
public class BoomiBudgetAggregate_Test {

	static testMethod void testParse() {
		String json = '{' +
		'  \"userList\": [' +
		'    \"00541000003nneXAAQ\",' +
		'    \"00541000004MAO7AAO\"' +
		'  ]' +
		'}';
		BoomiBudgetAggregate obj = BoomiBudgetAggregate.parse(json);
		System.assert(obj != null);
	}
}