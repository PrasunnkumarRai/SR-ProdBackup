/*
###########################################################################
# File..................: BoomiWebServiceHelperTest.cls
# Version...............: 
# Created by............: Anusha Rao
# Created Date..........: 27-June-2016
# Last Modified by......:  
# Last Modified Date....: 
# Description...........: Test class for BoomiWebServiceHelper 
# TAO Ref#..............: NA
# Change Log:               
#
#
############################################################################*/
@isTest
private class BoomiWebServiceHelperTest {
    static Opportunity opp;
    static Proposal__c prop;
    static Account acc;
    static Account agency;
    static Account agencyAcc;
    static Account advAcc;
    static Account repFirmAcc;
    static List<Account> accTimName;
    static List<Proposal__c> propList;
    static Proposal_Zone__c propZone;
    static Group__c gr;
    static Group_Status__c groupstatus;
    static Group_Status__c grpstatusApp;
    static Group_Status__c grpstatusRej;
    static UserConnection__c connection;
    static BoomiWebServiceHelper helper;
    static String xmlString;
    public static Id repFirmRecTypeId = [SELECT Id FROM RecordType WHERE DeveloperName='Rep_Firm' AND SobjectType = 'Account' LIMIT 1].Id;
    
   // @IsTest(seeAlldata = false)
    static void prepareTestData() { 
        TestDataHelper.createTIMIntegrationCustomSettings();    
        //User u = [select Id, Name from User where Name = 'Boomi Integration User'];
        User u = TestDataHelper.getBoomiIntegrationUser();
        
        System.runAs(u){
            
        //    agency = TestDataHelper.createAgency('Agency Account', 'Manikonda', 'Hyderabad', 'Andhra Pradesh', '500084', 'India');                        
       //    insert agency; 

            List<Account> accountList = new List<Account>();
            agencyAcc = TestDataHelper.createAgency('Test Agency Account', 'Manikonda', 'Hyderabad', 'Andhra Pradesh', '500084', 'India');                                    
            //insert agencyAcc;  
            //accTimName = [SELECT id,Account_Tim_Name__c FROM Account where id=:agencyAcc.Id];
            accountList.add(agencyAcc);

            advAcc = TestDataHelper.createAdvertiser('Test Adv Account', 'KPHB', 'Hyderabad', 'Andhra Pradesh', '500084', 'India');                        
            accountList.add(advAcc);

            //insert advAcc;

            repFirmAcc = TestDataHelper.createAcc('RepFirm Account', 'Ameerpet', 'Hyderabad', 'Andhra Pradesh', '500084', 'India');                        
            repFirmAcc.RecordTypeId = repFirmRecTypeId;
            accountList.add(repFirmAcc);
            //insert repFirmAcc;

            insert accountList;
            accountList = [SELECT Id,Account_Tim_Name__c,BillingCity,Phone,BillingState,BillingPostalCode FROM Account ORDER By CreatedDate LIMIT 3];
            agencyAcc = accountList.get(0);
            advAcc = accountList.get(1);
            repFirmAcc = accountList.get(2);
            //accTimName = agencyAcc;

            AccountConnection__c accConn =  TestDataHelper.createAccountConnection(advAcc.Id);           
            
            opp = TestDataHelper.createopportunity('Test Opportunity',System.today(),'Planning','Pipeline',advAcc.ID);        
            opp.Agency_Account__c=agencyAcc.Id;
            opp.Rep_Firm__c=repFirmAcc.Id;
            insert opp;

            System.assert(opp != null);  
            
            propList = new List<Proposal__c>();
            Proposal__c prp = new Proposal__c(Name = 'Test Proposal',Opportunity__c =opp.Id,TIM_Id__c='76877',
                active__c=true,TIM_Status__c='Proposal');                        
            propList.add(prp);
            insert propList;

            prop = TestDataHelper.createProposal('Test Proposal',opp.Id,'76877',True); 
            prop.TIM_Status__c = 'Proposal';              
            insert prop;

            propZone = TestDataHelper.createProposalZone('Test Proposal Zone',prop.Id);
            propZone.TIM_Status__c = 'Proposal'; 
            insert propZone;

            gr = TestDataHelper.createGroup('Test Group');
            insert gr;

            grpstatusApp = TestDataHelper.createGroupStatus('Approved by Traffic', gr.Id);
            grpstatusApp.Status_Id__c = '234';
            grpstatusApp.Is_Active__c = true;
            grpstatusApp.Is_Rejection__c = false;
            insert grpstatusApp;

            grpstatusRej = TestDataHelper.createGroupStatus('Rejected by Traffic', gr.Id);
            grpstatusRej.Is_Active__c = true;
            grpstatusRej.Status_Id__c = '345';
            grpstatusRej.Is_Rejection__c = true;
            insert grpstatusRej;

            groupstatus = TestDataHelper.createGroupStatus('Proposal', gr.Id);
            groupstatus.Is_Active__c = true;
            groupstatus.Is_Entry__c = false;
            groupstatus.Is_Exit__c = true;
            groupstatus.Is_Rejection__c = false;
            groupstatus.Approval_Status__c=grpstatusApp.Id;
            groupstatus.Rejection_Status__c = grpstatusRej.Id;
            groupstatus.Status_Id__c = '123';
            insert groupstatus;
            xmlString = '<?xml version="1.0" encoding="UTF-8"?><adx xsi:noNamespaceSchemaLocation="http://www.spotcable.com/schema/spotcableOrder_101.xsd" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"><document><schemaVersion>1.0</schemaVersion><name>Hello SCX Order</name><date>2015-05-21</date><mediaType>Spotcable</mediaType><documentType/><documentCode/></document><campaign><key codeOwner="NCC" codeDescription="CampaignID"><id></id></key><key codeOwner="Strata" codeDescription="DMA Override"><id>0</id></key><key codeOwner="Strata" codeDescription="Zone Pops"><id>sum</id></key><key codeOwner="VIEW32" codeDescription="CampaignName"><id></id></key><key codeOwner="Strata" codeDescription="distro"><id>bc</id></key><dateRange><startDate>2014-12-29</startDate><endDate>2015-12-27</endDate></dateRange><company type="Rep"><name></name><office><name></name><address><street/><city/><state code="__"/><postalCode>00000</postalCode></address><phone type="voice"></phone></office><contact role="AE"><firstName/><lastName/><email/><phone type="voice"/></contact></company><company type="Agency"><name>THE TOLAND GROUP INC - AGY38598</name><contact role="Buyer"><firstName/><lastName/><email/><phone type="voice"></phone></contact><ID><code codeOwner="Agency"></code></ID></company><advertiser><name>101 Market - 14510</name><ID><code codeOwner="Agency"></code></ID></advertiser><product><name></name><ID><code codeOwner="Agency"></code></ID></product><estimate><desc>Hello SCX Order</desc><ID><code codeOwner="Agency"></code></ID></estimate><makeGoodPolicy><code/></makeGoodPolicy><demo demoRank="1"><group>Households</group><ageFrom>0</ageFrom><ageTo>99</ageTo></demo><buyType>weekly</buyType><populations demoRank="1">40425</populations><order><key codeOwner="NCC" codeDescription="Market"><id>180</id></key><key codeOwner=""><id/></key><key codeOwner="Strata" codeDescription="Pops"><id>zone</id></key><key codeOwner="Strata" codeDescription="UseBroadcastWeeks"><id>1</id></key><totals><cost>12000.00</cost><spots>11</spots></totals><market nsi_id="269"><name>Madison</name></market><survey><ratingService/><geography/><shareBook/><PUTBook/><profile/><comment codeOwner="Spotcable">Feb15 C-DMA Custom Live+1</comment></survey><populations demoRank="1">40425</populations><comment/><systemOrder><key codeOwner=""><id/></key><key codeOwner="Strata" codeDescription="UseZonePop"><id>true</id></key><comment></comment><system><name>Madison East, WI</name><syscode>0397</syscode></system><affiliateSplit/><populations demoRank="1">40425</populations><totals><cost>12000.00</cost><spots>11</spots></totals><weeks count="52"><week number="1" startDate="2014-12-29"/><week number="2" startDate="2015-01-05"/><week number="3" startDate="2015-01-12"/><week number="4" startDate="2015-01-19"/><week number="5" startDate="2015-01-26"/><week number="6" startDate="2015-02-02"/><week number="7" startDate="2015-02-09"/><week number="8" startDate="2015-02-16"/><week number="9" startDate="2015-02-23"/><week number="10" startDate="2015-03-02"/><week number="11" startDate="2015-03-09"/><week number="12" startDate="2015-03-16"/><week number="13" startDate="2015-03-23"/><week number="14" startDate="2015-03-30"/><week number="15" startDate="2015-04-06"/><week number="16" startDate="2015-04-13"/><week number="17" startDate="2015-04-20"/><week number="18" startDate="2015-04-27"/><week number="19" startDate="2015-05-04"/><week number="20" startDate="2015-05-11"/><week number="21" startDate="2015-05-18"/><week number="22" startDate="2015-05-25"/><week number="23" startDate="2015-06-01"/><week number="24" startDate="2015-06-08"/><week number="25" startDate="2015-06-15"/><week number="26" startDate="2015-06-22"/><week number="27" startDate="2015-06-29"/><week number="28" startDate="2015-07-06"/><week number="29" startDate="2015-07-13"/><week number="30" startDate="2015-07-20"/><week number="31" startDate="2015-07-27"/><week number="32" startDate="2015-08-03"/><week number="33" startDate="2015-08-10"/><week number="34" startDate="2015-08-17"/><week number="35" startDate="2015-08-24"/><week number="36" startDate="2015-08-31"/><week number="37" startDate="2015-09-07"/><week number="38" startDate="2015-09-14"/><week number="39" startDate="2015-09-21"/><week number="40" startDate="2015-09-28"/><week number="41" startDate="2015-10-05"/><week number="42" startDate="2015-10-12"/><week number="43" startDate="2015-10-19"/><week number="44" startDate="2015-10-26"/><week number="45" startDate="2015-11-02"/><week number="46" startDate="2015-11-09"/><week number="47" startDate="2015-11-16"/><week number="48" startDate="2015-11-23"/><week number="49" startDate="2015-11-30"/><week number="50" startDate="2015-12-07"/><week number="51" startDate="2015-12-14"/><week number="52" startDate="2015-12-21"/></weeks><detailLine detailLineID="0"><startTime>06:00:00</startTime><endTime>00:00:00</endTime><startDay>M</startDay><dayOfWeek><Monday>N</Monday><Tuesday>N</Tuesday><Wednesday>N</Wednesday><Thursday>N</Thursday><Friday>N</Friday><Saturday>N</Saturday><Sunday>Y</Sunday></dayOfWeek><length>PT30S</length><daypartCode>RT</daypartCode><program></program><comment>TP</comment><network><name>TACV</name><ID><code codeOwner="Spotcable" codeDescription="-1">TACV</code></ID><ID><code codeOwner="Strata" codeDescription="Station">TACV</code></ID></network><spotCost currency="USD">1000.00</spotCost><demoValue demoRank="1"><value type="Ratings">0.0</value><value type="Impressions">0</value></demoValue><totals><cost currency="USD">7000.00</cost><spots>7</spots></totals><spot><weekNumber>1</weekNumber><quantity>0</quantity></spot><spot><weekNumber>2</weekNumber><quantity>0</quantity></spot><spot><weekNumber>3</weekNumber><quantity>0</quantity></spot><spot><weekNumber>4</weekNumber><quantity>0</quantity></spot><spot><weekNumber>5</weekNumber><quantity>0</quantity></spot><spot><weekNumber>6</weekNumber><quantity>0</quantity></spot><spot><weekNumber>7</weekNumber><quantity>0</quantity></spot><spot><weekNumber>8</weekNumber><quantity>0</quantity></spot><spot><weekNumber>9</weekNumber><quantity>0</quantity></spot><spot><weekNumber>10</weekNumber><quantity>0</quantity></spot><spot><weekNumber>11</weekNumber><quantity>0</quantity></spot><spot><weekNumber>12</weekNumber><quantity>0</quantity></spot><spot><weekNumber>13</weekNumber><quantity>0</quantity></spot><spot><weekNumber>14</weekNumber><quantity>0</quantity></spot><spot><weekNumber>15</weekNumber><quantity>0</quantity></spot><spot><weekNumber>16</weekNumber><quantity>0</quantity></spot><spot><weekNumber>17</weekNumber><quantity>0</quantity></spot><spot><weekNumber>18</weekNumber><quantity>0</quantity></spot><spot><weekNumber>19</weekNumber><quantity>0</quantity></spot><spot><weekNumber>20</weekNumber><quantity>0</quantity></spot><spot><weekNumber>21</weekNumber><quantity>0</quantity></spot><spot><weekNumber>22</weekNumber><quantity>0</quantity></spot><spot><weekNumber>23</weekNumber><quantity>0</quantity></spot><spot><weekNumber>24</weekNumber><quantity>0</quantity></spot><spot><weekNumber>25</weekNumber><quantity>0</quantity></spot><spot><weekNumber>26</weekNumber><quantity>1</quantity></spot><spot><weekNumber>27</weekNumber><quantity>0</quantity></spot><spot><weekNumber>28</weekNumber><quantity>0</quantity></spot><spot><weekNumber>29</weekNumber><quantity>0</quantity></spot><spot><weekNumber>30</weekNumber><quantity>1</quantity></spot><spot><weekNumber>31</weekNumber><quantity>0</quantity></spot><spot><weekNumber>32</weekNumber><quantity>0</quantity></spot><spot><weekNumber>33</weekNumber><quantity>0</quantity></spot><spot><weekNumber>34</weekNumber><quantity>0</quantity></spot><spot><weekNumber>35</weekNumber><quantity>1</quantity></spot><spot><weekNumber>36</weekNumber><quantity>0</quantity></spot><spot><weekNumber>37</weekNumber><quantity>0</quantity></spot><spot><weekNumber>38</weekNumber><quantity>0</quantity></spot><spot><weekNumber>39</weekNumber><quantity>1</quantity></spot><spot><weekNumber>40</weekNumber><quantity>0</quantity></spot><spot><weekNumber>41</weekNumber><quantity>0</quantity></spot><spot><weekNumber>42</weekNumber><quantity>0</quantity></spot><spot><weekNumber>43</weekNumber><quantity>1</quantity></spot><spot><weekNumber>44</weekNumber><quantity>0</quantity></spot><spot><weekNumber>45</weekNumber><quantity>0</quantity></spot><spot><weekNumber>46</weekNumber><quantity>0</quantity></spot><spot><weekNumber>47</weekNumber><quantity>0</quantity></spot><spot><weekNumber>48</weekNumber><quantity>1</quantity></spot><spot><weekNumber>49</weekNumber><quantity>0</quantity></spot><spot><weekNumber>50</weekNumber><quantity>0</quantity></spot><spot><weekNumber>51</weekNumber><quantity>0</quantity></spot><spot><weekNumber>52</weekNumber><quantity>1</quantity></spot></detailLine><detailLine detailLineID="0"><startTime>06:00:00</startTime><endTime>00:00:00</endTime><startDay>M</startDay><dayOfWeek><Monday>N</Monday><Tuesday>N</Tuesday><Wednesday>N</Wednesday><Thursday>N</Thursday><Friday>N</Friday><Saturday>N</Saturday><Sunday>Y</Sunday></dayOfWeek><length>PT30S</length><daypartCode>RT</daypartCode><program></program><comment>TP</comment><network><name>TACV</name><ID><code codeOwner="Spotcable" codeDescription="-1">TACV</code></ID><ID><code codeOwner="Strata" codeDescription="Station">TACV</code></ID></network><spotCost currency="USD">2000.00</spotCost><demoValue demoRank="1"><value type="Ratings">0.0</value><value type="Impressions">0</value></demoValue><totals><cost currency="USD">2000.00</cost><spots>1</spots></totals><spot><weekNumber>1</weekNumber><quantity>0</quantity></spot><spot><weekNumber>2</weekNumber><quantity>0</quantity></spot><spot><weekNumber>3</weekNumber><quantity>0</quantity></spot><spot><weekNumber>4</weekNumber><quantity>0</quantity></spot><spot><weekNumber>5</weekNumber><quantity>0</quantity></spot><spot><weekNumber>6</weekNumber><quantity>0</quantity></spot><spot><weekNumber>7</weekNumber><quantity>0</quantity></spot><spot><weekNumber>8</weekNumber><quantity>0</quantity></spot><spot><weekNumber>9</weekNumber><quantity>0</quantity></spot><spot><weekNumber>10</weekNumber><quantity>0</quantity></spot><spot><weekNumber>11</weekNumber><quantity>0</quantity></spot><spot><weekNumber>12</weekNumber><quantity>0</quantity></spot><spot><weekNumber>13</weekNumber><quantity>0</quantity></spot><spot><weekNumber>14</weekNumber><quantity>0</quantity></spot><spot><weekNumber>15</weekNumber><quantity>0</quantity></spot><spot><weekNumber>16</weekNumber><quantity>0</quantity></spot><spot><weekNumber>17</weekNumber><quantity>0</quantity></spot><spot><weekNumber>18</weekNumber><quantity>0</quantity></spot><spot><weekNumber>19</weekNumber><quantity>0</quantity></spot><spot><weekNumber>20</weekNumber><quantity>0</quantity></spot><spot><weekNumber>21</weekNumber><quantity>0</quantity></spot><spot><weekNumber>22</weekNumber><quantity>0</quantity></spot><spot><weekNumber>23</weekNumber><quantity>0</quantity></spot><spot><weekNumber>24</weekNumber><quantity>0</quantity></spot><spot><weekNumber>25</weekNumber><quantity>0</quantity></spot><spot><weekNumber>26</weekNumber><quantity>1</quantity></spot><spot><weekNumber>27</weekNumber><quantity>0</quantity></spot><spot><weekNumber>28</weekNumber><quantity>0</quantity></spot><spot><weekNumber>29</weekNumber><quantity>0</quantity></spot><spot><weekNumber>30</weekNumber><quantity>0</quantity></spot><spot><weekNumber>31</weekNumber><quantity>0</quantity></spot><spot><weekNumber>32</weekNumber><quantity>0</quantity></spot><spot><weekNumber>33</weekNumber><quantity>0</quantity></spot><spot><weekNumber>34</weekNumber><quantity>0</quantity></spot><spot><weekNumber>35</weekNumber><quantity>0</quantity></spot><spot><weekNumber>36</weekNumber><quantity>0</quantity></spot><spot><weekNumber>37</weekNumber><quantity>0</quantity></spot><spot><weekNumber>38</weekNumber><quantity>0</quantity></spot><spot><weekNumber>39</weekNumber><quantity>0</quantity></spot><spot><weekNumber>40</weekNumber><quantity>0</quantity></spot><spot><weekNumber>41</weekNumber><quantity>0</quantity></spot><spot><weekNumber>42</weekNumber><quantity>0</quantity></spot><spot><weekNumber>43</weekNumber><quantity>0</quantity></spot><spot><weekNumber>44</weekNumber><quantity>0</quantity></spot><spot><weekNumber>45</weekNumber><quantity>0</quantity></spot><spot><weekNumber>46</weekNumber><quantity>0</quantity></spot><spot><weekNumber>47</weekNumber><quantity>0</quantity></spot><spot><weekNumber>48</weekNumber><quantity>0</quantity></spot><spot><weekNumber>49</weekNumber><quantity>0</quantity></spot><spot><weekNumber>50</weekNumber><quantity>0</quantity></spot><spot><weekNumber>51</weekNumber><quantity>0</quantity></spot><spot><weekNumber>52</weekNumber><quantity>0</quantity></spot></detailLine><detailLine detailLineID="0"><startTime>06:00:00</startTime><endTime>00:00:00</endTime><startDay>M</startDay><dayOfWeek><Monday>N</Monday><Tuesday>N</Tuesday><Wednesday>N</Wednesday><Thursday>N</Thursday><Friday>N</Friday><Saturday>N</Saturday><Sunday>Y</Sunday></dayOfWeek><length>PT30S</length><daypartCode>RT</daypartCode><program></program><comment>TP</comment><network><name>VDAN</name><ID><code codeOwner="Spotcable" codeDescription="-1">VDAN</code></ID><ID><code codeOwner="Strata" codeDescription="Station">VDAN</code></ID></network><spotCost currency="USD">1000.00</spotCost><demoValue demoRank="1"><value type="Ratings">0.0</value><value type="Impressions">0</value></demoValue><totals><cost currency="USD">3000.00</cost><spots>3</spots></totals><spot><weekNumber>1</weekNumber><quantity>0</quantity></spot><spot><weekNumber>2</weekNumber><quantity>0</quantity></spot><spot><weekNumber>3</weekNumber><quantity>0</quantity></spot><spot><weekNumber>4</weekNumber><quantity>0</quantity></spot><spot><weekNumber>5</weekNumber><quantity>0</quantity></spot><spot><weekNumber>6</weekNumber><quantity>0</quantity></spot><spot><weekNumber>7</weekNumber><quantity>0</quantity></spot><spot><weekNumber>8</weekNumber><quantity>0</quantity></spot><spot><weekNumber>9</weekNumber><quantity>0</quantity></spot><spot><weekNumber>10</weekNumber><quantity>0</quantity></spot><spot><weekNumber>11</weekNumber><quantity>0</quantity></spot><spot><weekNumber>12</weekNumber><quantity>0</quantity></spot><spot><weekNumber>13</weekNumber><quantity>0</quantity></spot><spot><weekNumber>14</weekNumber><quantity>0</quantity></spot><spot><weekNumber>15</weekNumber><quantity>0</quantity></spot><spot><weekNumber>16</weekNumber><quantity>0</quantity></spot><spot><weekNumber>17</weekNumber><quantity>0</quantity></spot><spot><weekNumber>18</weekNumber><quantity>0</quantity></spot><spot><weekNumber>19</weekNumber><quantity>0</quantity></spot><spot><weekNumber>20</weekNumber><quantity>0</quantity></spot><spot><weekNumber>21</weekNumber><quantity>0</quantity></spot><spot><weekNumber>22</weekNumber><quantity>0</quantity></spot><spot><weekNumber>23</weekNumber><quantity>0</quantity></spot><spot><weekNumber>24</weekNumber><quantity>0</quantity></spot><spot><weekNumber>25</weekNumber><quantity>0</quantity></spot><spot><weekNumber>26</weekNumber><quantity>1</quantity></spot><spot><weekNumber>27</weekNumber><quantity>0</quantity></spot><spot><weekNumber>28</weekNumber><quantity>0</quantity></spot><spot><weekNumber>29</weekNumber><quantity>0</quantity></spot><spot><weekNumber>30</weekNumber><quantity>1</quantity></spot><spot><weekNumber>31</weekNumber><quantity>0</quantity></spot><spot><weekNumber>32</weekNumber><quantity>0</quantity></spot><spot><weekNumber>33</weekNumber><quantity>0</quantity></spot><spot><weekNumber>34</weekNumber><quantity>0</quantity></spot><spot><weekNumber>35</weekNumber><quantity>1</quantity></spot><spot><weekNumber>36</weekNumber><quantity>0</quantity></spot><spot><weekNumber>37</weekNumber><quantity>0</quantity></spot><spot><weekNumber>38</weekNumber><quantity>0</quantity></spot><spot><weekNumber>39</weekNumber><quantity>0</quantity></spot><spot><weekNumber>40</weekNumber><quantity>0</quantity></spot><spot><weekNumber>41</weekNumber><quantity>0</quantity></spot><spot><weekNumber>42</weekNumber><quantity>0</quantity></spot><spot><weekNumber>43</weekNumber><quantity>0</quantity></spot><spot><weekNumber>44</weekNumber><quantity>0</quantity></spot><spot><weekNumber>45</weekNumber><quantity>0</quantity></spot><spot><weekNumber>46</weekNumber><quantity>0</quantity></spot><spot><weekNumber>47</weekNumber><quantity>0</quantity></spot><spot><weekNumber>48</weekNumber><quantity>0</quantity></spot><spot><weekNumber>49</weekNumber><quantity>0</quantity></spot><spot><weekNumber>50</weekNumber><quantity>0</quantity></spot><spot><weekNumber>51</weekNumber><quantity>0</quantity></spot><spot><weekNumber>52</weekNumber><quantity>0</quantity></spot></detailLine></systemOrder></order></campaign></adx>';
        }

        connection = TestDataHelper.createUserConnection('St. Louis Local','SFDCUser',UserInfo.getUserId(),'TIM','1');   
        insert connection;
        System.assert(connection != null);

/*        String timSystem = 'StLouisLocal';
        String partitionName = 'local.TIMAccess';
        Cache.OrgPartition newpart = new Cache.OrgPartition(partitionName);

        Map<String,TIMUserAccess.User> timuserMap = new Map<String,TIMUserAccess.User>();

        timuserMap.put('St. Louis Local', CacheManager.getTIMUser(connection.Username__c+timSystem,timSystem));

        newpart.put('StLouisLocal', timuserMap);*/

    }


    public static testMethod void getProcessData() {        
        prepareTestData();
        TestDataHelper.createBoomiEndpointData(); 
        Map<String,BoomiIntegration__c> dataCenterValues = BoomiIntegration__c.getAll();
        String endpoint = dataCenterValues.get('Default DataCenter').Endpoint__c;
        System.debug('@@endpoint '+endpoint); 
        BoomiWebServiceMock.name = 'BoomiDashboardController';
        Test.startTest();
        Test.setMock(WebServiceMock.class, new StratagTimService_Mock());
        Test.setMock(HttpCalloutMock.class, new BoomiWebServiceMock());  

        List<UserConnection__c> userConnections = [SELECT User__c, AE_Id__c, TIM_System__c, Username__c
                            FROM UserConnection__c
                            WHERE User__c=: UserInfo.getUserId() AND Is_Primary__c = true LIMIT 1];   
        System.assert(userConnections.size() > 0);
        System.assertEquals(userConnections[0].User__c, UserInfo.getUserId());

        BoomiWebServiceHelper.RestServGetProcessData(endpoint);
        BoomiWebServiceHelper.RestServiceGetStub(endpoint);                
        Test.stopTest();        
    } 
    
    public static testMethod void authentication() {        
        prepareTestData();                
        BoomiWebServiceMock.name = 'BoomiDashboardController';
        //BoomiWebServiceMock.name = 'BoomiResponse';
        Test.startTest();
        Test.setMock(WebServiceMock.class, new StratagTimService_Mock());
        Test.setMock(HttpCalloutMock.class, new BoomiWebServiceMock()); 
        helper = new BoomiWebServiceHelper();

        List<UserConnection__c> userConnections = [SELECT User__c, AE_Id__c, TIM_System__c, Username__c
                            FROM UserConnection__c
                            WHERE User__c=: UserInfo.getUserId() AND Is_Primary__c = true LIMIT 1];   
        System.assert(userConnections.size() > 0);
        System.assertEquals(userConnections[0].User__c, UserInfo.getUserId());

        helper.authenticate();
        helper.authenticateAE();            
        Test.stopTest(); 
    }

    public static testMethod void authentication2() {        
        prepareTestData();                
        BoomiWebServiceMock.name = 'BoomiWebServiceHelperTest';     
        Test.startTest();
        Test.setMock(WebServiceMock.class, new StratagTimService_Mock());
        Test.setMock(HttpCalloutMock.class, new BoomiWebServiceMock()); 
        helper = new BoomiWebServiceHelper(); 

        List<UserConnection__c> userConnections = [SELECT User__c, AE_Id__c, TIM_System__c, Username__c
                            FROM UserConnection__c
                            WHERE User__c=: UserInfo.getUserId() AND Is_Primary__c = true LIMIT 1];   
        System.assert(userConnections.size() > 0);
        System.assertEquals(userConnections[0].User__c, UserInfo.getUserId());

        helper.authenticate();        
        helper.authenticateAE();        
        Test.stopTest();         
    }   
    
    public static testMethod void saveAdvertiserTest() {        
        prepareTestData();          
        AccountConnection__c accConn =  TestDataHelper.createAccountConnection(advAcc.Id);         
        //accConn.Account__r.BillingStreet = 'Add BillingStreet greater than 50 characters, so that we can cover one scenario in BoomiWebServiceHelper calss';
        insert accConn;
        
        System.assert(accConn != null);  

        AccountConnection__c accConn1 = [SELECT ID,Name,Account__r.Account_Tim_Name__c,Account__r.BillingStreet,
        Account__r.BillingCity,Account__r.BillingState,Account__r.BillingPostalCode,Account__r.Phone,Account__r.Active__c
        FROM AccountConnection__c LIMIT 1];
        System.debug('accConn1::'+accConn1);
        
        Map<Id,Account> acctMap = new Map<Id,Account>([SELECT Id,Name,Recordtype.Name,Account_Tim_Name__c,BillingState,BillingCity,BillingStreet,Phone,BillingPostalCode,ShippingState,ShippingCity,ShippingStreet,ShippingPostalCode FROM Account WHERE Recordtype.DeveloperName != 'Rep_Firm']);
        advAcc.BillingStreet = 'Add BillingStreet greater than 50 characters, so that we can cover one scenario in BoomiWebServiceHelper calss';       

        Test.startTest();
        Test.setMock(WebServiceMock.class, new StratagTimService_Mock());
        Test.setMock(HttpCalloutMock.class, new BoomiWebServiceMock()); 
        helper = new BoomiWebServiceHelper(); 
        helper.confirmCreateAcc = true;
        helper.saveAdvertiser(advAcc);
        helper.authenticateAETIMSystem(accConn.TIM_System__c);
        helper.verifyAccountTimIds(opp,acctMap,connection);        
        
        //Code changes starts here
        List<RecordType> accountRepFirmRTId = [SELECT Id, Developername FROM Recordtype WHERE SobjectType = 'Account' AND Developername = 'Rep_Firm'];
        for(Account acc : acctMap.values() ){
            acc.RecordTypeId = accountRepFirmRTId[0].Id;
        }

        update acctMap.values();
        helper.verifyAccountRecordType(opp,acctMap);

        acctMap = new Map<Id,Account>([SELECT Id,Name,Recordtype.Name,Account_Tim_Name__c,BillingState,
         BillingCity,BillingStreet,Phone,BillingPostalCode,ShippingState,ShippingCity,ShippingStreet,ShippingPostalCode FROM Account WHERE recordtype.DeveloperName = 'Rep_Firm' ]);

        List<RecordType> accountAgncyFirmRTId = [SELECT Id, Developername FROM Recordtype WHERE SobjectType = 'Account' AND developername = 'Agency_Account'];
        for(Account acc : acctMap.values() ){
            acc.RecordTypeId = accountAgncyFirmRTId[0].Id;
        }
        update acctMap.values();
        System.debug('acctMap::::'+acctMap);
        helper.verifyAccountRecordType(opp,acctMap);
        //Changes ends here

        helper.verifyAccountTimIds(opp,acctMap,connection);        
        helper.mapAccountToAdvertiserBoomi(advAcc,'309');
        helper.saveAgency(accConn);
        helper.mapAccountToAgency(advAcc);
        helper.saveRepFirm(accConn);
        //accConn.Account__r.BillingStreet = 'Add BillingStreet greater than 50 characters, so that we can cover one scenario in BoomiWebServiceHelper calss';
        helper.mapAccountToRepFirm(accConn1);
        helper.isFrmSCXUpload = TRUE;
        helper.syncProposalLineItems(prop,connection);
        String responseSample = '{ "GetEstimateHeaders_Result" : { "EstimateHeader" : [ { "EstimateID" : 387544, "Description" : "Testing Opportunity Jan09", "AdvertiserID" : 83926, "AgencyID" : 0, "ProductID" : 1203, "FlightStart" : "6/25/2018", "FlightEnd" : "7/29/2018", "Weeks" : 5, "AEID" : 1, "CreatedBy" : "SFDCUser", "Comments" : "Order File Loaded: Electronic SCX Transfer", "EdiClient" : "704134", "EdiProduct" : "6", "EdiEstimate" : "2514", "EdiInvoice" : "true", "ExternalOrderNo" : "A795572A-D2EC-40F9-97EF-BE5D2FAD3690", "BroadcastValues" : { "BroadcastValue" : [ { "YearMonth" : "2018.07", "TotalSpots" : 188, "TotalCost" : 832 } ] }, "Networks" : "BET;BRVO;DISC;FOOD;FRFM;HGTV;HIST;TLC;USA", "NetworkCount" : 9, "Status" : "Proposal", "IsDeleted" : "NotDeleted", "SurveyVersions" : { "SurveyVersion" : [ { "SurveyID" : 611868, "VersionNumber" : 1 } ] }, "ScheduleItems" : { "ScheduleItem_4_6" : [ { "SysCodes" : "2100", "Zones" : "Spectrum/DISH- I+ Huntsville/Decatur, AL, 2100", "Markets" : "Huntsville", "BroadcastValues" : { "BroadcastValue" : [ { "YearMonth" : "2018.07", "TotalSpots" : 188, "TotalCost" : 832 } ] }, "OrderStatus" : "Proposal", "ScheduleType" : "Linear" } ] } } ] } }';
        BoomiHelper.BoomiHelper1 bhelper =  BoomiHelper.parseBoomiHelper1(responseSample);
        BoomiHelper.EstimateHeader estHeader =  bhelper.GetEstimateHeaders_Result.EstimateHeader[0];
        helper.processEstimateHeaderDetailsResponse(estHeader, prop);
        helper.activateProposals(propList); //Attemp to deference a null Object
        helper.syncSyscodes();
        helper.mapAccountToAdvertiserBoomi_saveAdvertiser(advAcc, '78688', '309');
        helper.mapAccountToAgencyBoomi_Update(advAcc, 309);
        List<UserConnection__c> userConnections = [SELECT Id, Name FROM UserConnection__c LIMIT 1];
        helper = new BoomiWebServiceHelper(userConnections[0]); 
        Test.stopTest(); 
    } 


    public static @isTest void testsyncAccountBilling(){
        prepareTestData();          
        AccountConnection__c accConn =  TestDataHelper.createAccountConnection(advAcc.Id);         
        //accConn.Account__r.BillingStreet = 'Add BillingStreet greater than 50 characters, so that we can cover one scenario in BoomiWebServiceHelper calss';
        insert accConn;
        
        system.assert(accConn != null);  

        AccountConnection__c accConn1 = [SELECT ID,Name,Account__r.Account_Tim_Name__c,Account__r.BillingStreet, Account__r.BillingCity,Account__r.BillingState,Account__r.BillingPostalCode,Account__r.Phone,Account__r.Active__c FROM AccountConnection__c LIMIT 1];
        System.debug('accConn1::'+accConn1);
        
        Map<Id,Account> acctMap = new Map<Id,Account>([Select Id,Name,Recordtype.Name,Account_Tim_Name__c,BillingState, BillingCity,BillingStreet,Phone,BillingPostalCode,ShippingState,ShippingCity,ShippingStreet,ShippingPostalCode FROM Account LIMIT 5]);
        advAcc.BillingStreet = 'Add BillingStreet greater than 50 characters, so that we can cover one scenario in BoomiWebServiceHelper calss';       

        Test.startTest();
        Test.setMock(WebServiceMock.class, new StratagTimService_Mock());
        Test.setMock(HttpCalloutMock.class, new BoomiWebServiceMock()); 
        helper = new BoomiWebServiceHelper(); 
        List<Account> accountList = [SELECT Id, Name FROM Account LIMIT 1];
        Map<String,TIMIntegration__c> custSettMap = TIMIntegration__c.getAll();
        List<AccountConnection__c> accConList = [Select ID,Name, Tim_ID__c,TIM_System__c,AgencyTIMID__c FROM AccountConnection__c LIMIT 5];
        helper.syncAccountBilling(custSettMap.get('St. Louis Local').boomi_Endpoint__c,'Advertiser',accountList[0],accConList[0].TIM_ID__c , accConList[0].AgencyTIMID__c);
        helper.syncAccountBilling(custSettMap.get('St. Louis Local').boomi_Endpoint__c,'Agency',accountList[0],accConList[0].TIM_ID__c , accConList[0].AgencyTIMID__c);
        Test.stopTest(); 
    }
    
   /* 
    public static testMethod void verifyAccountTimIdsTest() {  
        Map<ID,Account> mapAccount = new Map<ID,Account>();      
        prepareTestData();
        mapAccount.put( opp.Account.ID, opp.Account); 
    //  mapAccount.put( opp.Agency__c, agency);
        mapAccount.put( opp.Agency_Account__c, agencyAcc); 
        mapAccount.put( opp.Rep_Firm__c, repFirmAcc); 
        System.debug('mapAccount>>>'+mapAccount.values());
        Test.startTest();
        Test.setMock(WebServiceMock.class, new StratagTimService_Mock());
        Test.setMock(HttpCalloutMock.class, new BoomiWebServiceMock()); 
        helper = new BoomiWebServiceHelper();    
        helper.verifyAccountTimIds(opp,mapAccount,connection);
        Test.stopTest(); 
    }  
   */ 
    
    public static testMethod void approveProposalsTest() { 
        prepareTestData();
        List<Proposal_Zone__c> propList = new List<Proposal_Zone__c> ();
        propList.add(propZone);

        System.assertEquals(propZone,propList[0]);

        Map<String,Group_Status__c> groupStatusMap = new Map<String,Group_Status__c> ();
        groupStatusMap.put(groupstatus.Name,groupstatus);
        groupStatusMap.put(grpstatusApp.Name, grpstatusApp);
        groupStatusMap.put(grpstatusRej.Name,grpstatusRej);
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new BoomiWebServiceMock()); 
        helper = new BoomiWebServiceHelper();    
        helper.approveProposals(propList, 'Test Approval', groupStatusMap, 'Approve');
        Test.stopTest(); 
    }
       
    
    public static testMethod void syncAeToTimTest() { 
        prepareTestData(); 
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new BoomiWebServiceMock()); 
        helper = new BoomiWebServiceHelper(); 
        List<UserConnection__c> userConnections = [SELECT User__c,AE_Id__c, TIM_System__c, Username__c
                            FROM UserConnection__c WHERE User__c=: UserInfo.getUserId() AND Is_Primary__c = true LIMIT 1];   
        System.assert(userConnections.size() > 0);
        System.assertEquals(userConnections[0].User__c, UserInfo.getUserId());

        helper.syncAeToTim();        
        Test.stopTest(); 
    } 
    public static testMethod void importSCXTest() { 
        prepareTestData();
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new BoomiWebServiceMock()); 
        helper = new BoomiWebServiceHelper(); 

        List<UserConnection__c> userConnections = [SELECT User__c,AE_Id__c, TIM_System__c, Username__c
                            FROM UserConnection__c
                            WHERE User__c=: UserInfo.getUserId() AND Is_Primary__c = true LIMIT 1];   
        System.assert(userConnections.size() > 0);
        System.assertEquals(userConnections[0].User__c, UserInfo.getUserId());

        helper.importSCX(xmlString, 'Charlotte','99','123','1',null);
        Test.stopTest(); 
    }
     
    public static testMethod void transferOwnershipTest(){
        prepareTestData();
        
        Test.startTest();
        
        Test.setMock(WebServiceMock.class, new StratagTimService_Mock());
        Test.setMock(HttpCalloutMock.class, new BoomiWebServiceMock());  
        List<UserConnection__c> userConnections = [SELECT User__c,AE_Id__c, TIM_System__c, Username__c
                            FROM UserConnection__c WHERE User__c=: UserInfo.getUserId() AND Is_Primary__c = true LIMIT 1];   
        System.assert(userConnections.size() > 0);
        System.assertEquals(userConnections[0].User__c, UserInfo.getUserId());
        
        String timSystem = 'StLouisLocal';
        String partitionName = 'local.TIMAccess';
        Cache.OrgPartition newpart = new Cache.OrgPartition(partitionName);

        Map<String,TIMUserAccess.User> timuserMap = new Map<String,TIMUserAccess.User>();

        timuserMap.put('St. Louis Local', CacheManager.getTIMUser(userConnections[0].Username__c+timSystem,timSystem));

        newpart.put('StLouisLocal', timuserMap);

        helper = new BoomiWebServiceHelper(connection);

        String result = helper.transferOwnership(prop, userConnections[0]);
        Test.stopTest();
    }

    public static testMethod void inActivateProposals() {        
        prepareTestData();                
        BoomiWebServiceMock.name = 'BoomiWebServiceHelperTest';     
        Test.startTest();
        Test.setMock(WebServiceMock.class, new StratagTimService_Mock());
        Test.setMock(HttpCalloutMock.class, new BoomiWebServiceMock()); 
        helper = new BoomiWebServiceHelper(); 

        List<UserConnection__c> userConnections = [SELECT User__c,AE_Id__c, TIM_System__c, Username__c
                            FROM UserConnection__c
                            WHERE User__c=: UserInfo.getUserId() AND Is_Primary__c = true LIMIT 1];   
        System.assert(userConnections.size() > 0);
        System.assertEquals(userConnections[0].User__c, UserInfo.getUserId());

        helper.authenticate();        
        helper.authenticateAE();
        List<Proposal__c> props = [SELECT Id,Active__c,TIM_Id__c FROM Proposal__c LIMIT 5];
        helper.InActivateProposals(props);
        
        Test.stopTest();         
    }
}