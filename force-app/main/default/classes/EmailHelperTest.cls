@isTest
public class EmailHelperTest {    
    public static testmethod void EmailHelperTest(){
        
        List <EmailTemplate> template;
        List <Lead> lList;
        List<String> managerName = new List<String>();
        managerName.add(Userinfo.getUserEmail());
        Id userid = Userinfo.getUserId();
        Lead objLead = new Lead (FirstName='TestFirstName',LastName = 'TestLastName', Email = 'test@gmail.com',  Company = 'Test company',OwnerId=userid,
                                 phone = '+1234567890',Rating='Hot',Description='Test Lead Description');
        // LastTransferDate  = TODAY-1,
        // LastActivityDate =TODAY,
        insert objLead; 

        //Test data for Account
        Account acc = new Account();
        acc.Name = 'Test Account';
        acc.Primary_Commodity__c = 'Alcoholic Beverages';
		acc.Commodity_Codes__c = 'ALC_BEV -- Beer and Wine';
        acc.BillingCity = 'Secaucus';
        acc.BillingCountry = 'US';
        acc.BillingPostalCode = '07094';
        acc.BillingState = 'NJ';
        acc.BillingStreet = 'PO Box 2516';
		insert acc;

        //Test data for Opportunity
        Opportunity oppData = new Opportunity();
        oppData.Name = 'INW TDA Olympics Digital';
		oppData.AccountId = acc.Id;
		oppData.Owner_Division__c = 'West';
		oppData.Owner_Region__c = 'Big West';
		oppData.Owner_Sales_Office__c = 'Kennewick';
		oppData.StageName = 'Identification';
		oppData.CloseDate = date.parse('8/28/2016');
		insert oppData;

        lList = [Select Id, name, OwnerId, Owner_Manager__c, of_days_since_Activity__c, Rating, Company, Description, LastTransferDate, LastActivityDate, Owner.Name from Lead where Id=:objLead.Id];
        template=[Select Id, Subject, HTMLValue, Body from EmailTemplate where name = 'No Activity 7 Days +'];
        /*
        EmailHelper.sendEmail(Id.valueOf('00541000004Mz8f'),managerName,
                              template[0].Id, template[0].Subject, template[0].HTMLValue, template[0].Body,lList);
        EmailTemplate et = new EmailTemplate(Body='phone home');
        EmailHelper.sendEmailToUsers('00541000004Mz8f','006m0000008BAH4',et,'Lead');*/
        
        EmailHelper.sendEmail(userid,managerName,
                              template[0].Id, template[0].Subject, template[0].HTMLValue, template[0].Body,lList);
        EmailTemplate et = new EmailTemplate(Body='phone home');
        EmailHelper.sendEmailToUsers(userid,oppData.Id,et,'Lead');
    }


    @isTest
    public static void TestMethod_sendEmailToUser(){
        
        User user = new User(Alias = 'standt', Email='test@charter.com', 
                        EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
                        UserName='test@charter.com');
        String subject = 'Test Subject';
        String body = 'Test Body';


        EmailHelper.sendEmailToUser(user.Id, subject, body);
    }
    
    @isTest
    public static void TestMethod_sendEmailToListOfUsers(){
        
        String subject = 'Test Subject';
        String body = 'Test Body';
        List<String> emails =  new List<String>();
        emails.Add('test@test.com');
        emails.Add('test2@test.com');

        EmailHelper.sendEmailToListOfUsers(emails, subject, body);
    }

    
}