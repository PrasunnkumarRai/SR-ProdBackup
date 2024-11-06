@isTest
private class EventTriggerHandlerTest {

    @isTest static void testOutOfBusinessAccEvent(){

        Test.startTest();  

        Account acc = TestUtil.getAccountRec();
        acc.primary_commodity__c = 'Auto Aftermarket';
        acc.Out_of_Business__c = TRUE;
        INSERT acc; 
        
        Event evt = new Event();
        evt.WhatId=acc.Id;
        evt.StartDateTime = System.Today();
        evt.EndDateTime = System.Today()+5;        
        
        try
        {
            INSERT evt;       
        }
        catch(Exception ex)
        {
            String errMesg = String.format(System.Label.Prevent_Activity_creation_on_Out_Of_Business_Accounts, new List<String> {'Event'}); 
            System.assertEquals(TRUE, ex.getMessage().contains(errMesg));               
        }
        Test.stopTest();  
    }
}