//public class MultiRequestMock implements HttpCalloutMock {
public without sharing class MultiRequestMock implements HttpCalloutMock {
	public class CommonException extends Exception {}
	public Map<String, HttpCalloutMock> requests;
	public Set<String> usedEndpoints = new Set<String>();

	public MultiRequestMock(Map<String, HttpCalloutMock> requests) {
		System.debug('MultiRequestMock requests: ' + requests);
		this.requests = requests;
	}

	public HTTPResponse respond(HTTPRequest req) {
		//System.debtMock mock = requests.get(req.getEndpoint());
        //System.debug('mock: ' + mock);
		//return mock.respond(req);
		HttpCalloutMock mock = requests.get(req.getEndpoint());
        usedEndpoints.add(req.getEndpoint());

        if (mock != null) {
            return mock.respond(req);
        } 

        throw new CommonException('Mock for end point not found: ' + req.getEndpoint());
    }

    public void addRequestMock(String url, HttpCalloutMock mock) {
        requests.put(url, mock);
    }
	
	
}