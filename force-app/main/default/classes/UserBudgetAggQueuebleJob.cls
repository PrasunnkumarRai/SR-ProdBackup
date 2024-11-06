public class UserBudgetAggQueuebleJob implements Queueable, Database.AllowsCallouts {
	private List<String> userIds;

	public UserBudgetAggQueuebleJob(List<String> userIds) {
		this.userIds = userIds;
	}

	public void execute(QueueableContext context) {
		if (!this.userIds.isEmpty()) {
			BoomiBudgetAggregate body = new BoomiBudgetAggregate();
			body.userList = this.userIds;
			System.debug('setuserIds: ' + this.userIds);
			String baseUrl = Label.BoomiUserSBAggrURL;
			HttpRequest httpRequest = new HttpRequest();
			httpRequest.setEndpoint(baseUrl);
			httpRequest.setMethod('POST');
			httpRequest.setHeader('Accept', 'application/json');
			httpRequest.setHeader('Content-type', 'application/json; charset=UTF-8');
			httpRequest.setHeader('Authorization', Label.BoomiUserSBAggrProcessUser);
			httpRequest.setTimeout(120000);
			httpRequest.setBody(JSON.serialize(body, true));
			Http http = new Http();
			System.debug('httpRequest ' + httpRequest);
			HttpResponse httpResponse = http.send(httpRequest);
			System.debug('@@httpResponse: ' + httpResponse);
		}

	}
}