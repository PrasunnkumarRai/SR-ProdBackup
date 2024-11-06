@RestResource(urlMapping='/SpectrumReachAuthenticate/*')
global with sharing class ThirdPartyAuthentication{
	
	@HttpGet
	global static String doGet() {
		return 'SpectrumReachAuthenticate API is Alive!';
	}
	
	@HttpPost
	global static String doPost(String userEmail) {
		
		User result = new User();
		User blankUser = new User();		
		try{
			result = [SELECT Id, Name FROM User WHERE email =:userEmail and isActive = true limit 1];
			
			if(result == blankUser){
				return 'This User does not exist or is inactive.'+userEmail;
			}
		}
		catch(Exception ex){
			return 'This User does not exist or is inactive.'+userEmail;
		}
		
		return result.Id;
	}
}