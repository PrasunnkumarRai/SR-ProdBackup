/*
  Author          :  Jose
  Date            :  Sep 05-19
  Description     :  Wraper class for OMS_NetworkExController 
              
  Modification History : 
*/
public with sharing class AuraSelectOptions {
    @AuraEnabled public String label {get;set;}
  @AuraEnabled public String value {get;set;}

  public AuraSelectOptions() {
    this.label = '';
    this.value = '';
  }

  public AuraSelectOptions(String lab, String val) {
    this.label = lab;
    this.value = val;
  }
}