@isTest
public with sharing class ThirdPartyAuthenticationTest {
	
    @IsTest(seeAlldata = false)
    static void doGetMethodPositivePathTest() {
        
        ThirdPartyAuthentication.doGet();
        //System.debug('get res::'+ThirdPartyAuthentication.doGet());

        System.assertEquals('SpectrumReachAuthenticate API is Alive!', ThirdPartyAuthentication.doGet());
    }
    
    @IsTest(seeAlldata = false)
    static void doPostMethodPositivePathTest() {
        
        String usrId = ThirdPartyAuthentication.doPost('ssinghal@osius.com');

        System.assert(usrId != null);
    }
    
    @IsTest(seeAlldata = false)
    static void doPostMethodNegativePathTest() {
        
        String msg = ThirdPartyAuthentication.doPost('');
        System.assert(msg != null);
    }
}