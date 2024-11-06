/*
    Author : MAndS 
    Date   : 11/05/2017
    Description : Hepler/Wraper class for Geography Target Component Section  
    Modification History :
*/
public with sharing class GeographyTargetHelper {
public list<string> lstCongr{get;set;} //Congressional District
public list<string> lstDMA {get;set;}//DMA
public list<string> lstZone {get;set;}//Spectrum Reach Zone
public list<string> lstDigAZone {get;set;}
public Boolean showDMA {get;set;}//DMA rendering
public Boolean showSRZ {get;set;}//Spectrum Reach Zone rendering
public Boolean showCD {get;set;}//Congressional District rendering
public Digital_Campaign__c objDCampaign{get;set;}
public string strZipcode {get;set;}
public string strMsg {get;set;}//Result after Digital Campaign DML
public Boolean lockRecord {get;set;}
public string strLblDMA{get;set;}//DMA Label
public string strLblSRZone {get;set;}//Spectrum Reach Zone Label
public string strLblCongDist {get;set;}//Congressional District Label
}