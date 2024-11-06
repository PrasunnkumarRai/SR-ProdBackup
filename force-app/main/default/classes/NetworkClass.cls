/*
  Author          :  Jose
  Date            :  Sep 05-19
  Description     :  Wraper class for OMS_NetworkExController 
              
  Modification History : 
*/
public with sharing class NetworkClass {

    public List<AuraSelectOptions> Networks {get; set;}
    public List<string> KidsNetworks {get; set;}
    public List<string> TuneInNetworks {get; set;}
    public List<string> NewsNetworks {get; set;}
    public Digital_Campaign__c objDC {get;set;}
    public List<string> NetworkExSelectedNetworks {get; set;}
  
}