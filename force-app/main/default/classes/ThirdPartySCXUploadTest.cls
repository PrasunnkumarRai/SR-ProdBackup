@isTest
public with sharing class ThirdPartySCXUploadTest {
    
    @testSetup    
    static void prepareTestData() {
        User u = TestDataHelper.createUser(true);
        u.isActive = true;
        update u;
        System.assert(u != null);

        List<Account> actList = new List<Account>();
        Account act1 = TestDataHelper.createAcc('Test Act1',null,null,null,null,null);
        actList.add(act1);
        Account act2 = TestDataHelper.createAcc('Test Act2',null,null,null,null,null);
        actList.add(act2);
        insert actList;

        List<AccountTeamMember> actMembers = new List<AccountTeamMember>();
        AccountTeamMember actMem1 = new AccountTeamMember(AccountId = actList[0].Id, TeamMemberRole = 'Coordinator', UserId = u.Id);
        actMembers.add(actMem1);
        insert actMembers;

        List<Opportunity> oppList = new List<Opportunity>();
        Opportunity opp1 = TestDataHelper.createopportunity('Test Opp1',null,null,null,actList[0].id);
        oppList.add(opp1);
        Opportunity opp2 = TestDataHelper.createopportunity('Test Opp2',null,null,null,actList[1].id);
        oppList.add(opp2);
        insert oppList;
 
        UserConnection__c userConn = TestDataHelper.createUserConnection('St. Louis Local','SFDCUser',UserInfo.getUserId(),'TIM','1');
        insert userConn;
    }

    static testMethod void doGetMethodPositivePathTest() {
        String response = ThirdPartySCXUpload.doGet();
        System.assert(response != null);
    }

    static testMethod void doPostMethodPositivePathTest1() {
        
        //prepareTestData();

        User u = [SELECT Id, Name FROM User WHERE isActive = true LIMIT 1];

        System.assert(u != null);

        UserConnection__c loggedInUser = [Select AE_Id__c, TIM_System__c, Username__c
                            from UserConnection__c
                            where User__c=: UserInfo.getUserId() and TIM_System__c ='St. Louis Local' limit 1];
        String timSystem = 'StLouisLocal';
        String partitionName = 'local.TIMAccess';
        Cache.OrgPartition newpart = new Cache.OrgPartition(partitionName);

        Map<String,TIMUserAccess.User> timuserMap = new Map<String,TIMUserAccess.User>();

        timuserMap.put('St. Louis Local', CacheManager.getTIMUser(loggedInUser.Username__c+timSystem,timSystem));

        newpart.put('StLouisLocal', timuserMap);

        Opportunity opp = [SELECT Id, Name FROM Opportunity LIMIT 1];

        String xmlString = '<?xml version=\'1.0\' encoding=\'UTF-8\'?><adx xsi:noNamespaceSchemaLocation=\'\' xmlns:xsi=\'http://www.w3.org/2001/XMLSchema-instance\'><document><schemaVersion>1.0</schemaVersion><name></name><date>2017-07-20</date><mediaType>Spotcable</mediaType><documentType/><documentCode/></document><campaign><key codeOwner=\'NCC\' codeDescription=\'CampaignID\'><id></id></key><key codeOwner=\'Strata\' codeDescription=\'DMA Override\'><id>0</id></key><key codeOwner=\'Strata\' codeDescription=\'Zone Pops\'><id>sum</id></key><key codeOwner=\'VIEW32\' codeDescription=\'CampaignName\'><id></id></key><key codeOwner=\'Strata\' codeDescription=\'distro\'><id>bc</id></key><dateRange><startDate>2017-07-24</startDate><endDate>2017-09-24</endDate></dateRange><company type=\'Rep\'><name></name><office><name></name><address><street/><city/><state code=\'__\'/><postalCode>00000</postalCode></address><phone type=\'voice\'></phone></office><contact role=\'AE\'><firstName/><lastName/><email/><phone type=\'voice\'/></contact></company><company type=\'Agency\'><name>0</name><contact role=\'Buyer\'><firstName/><lastName/><email/><phone type=\'voice\'></phone></contact><ID><code codeOwner=\'Agency\'></code></ID></company><advertiser><name>SCX import holding Advertiser</name><ID><code codeOwner=\'Agency\'></code></ID></advertiser><product><name></name><ID><code codeOwner=\'Agency\'></code></ID></product><estimate><desc>Testing</desc><ID><code codeOwner=\'Agency\'></code></ID></estimate><makeGoodPolicy><code/></makeGoodPolicy><demo demoRank=\'1\'><group>Households</group><ageFrom>0</ageFrom><ageTo>99</ageTo></demo><buyType>weekly</buyType><populations demoRank=\'1\'>97848</populations><order><key codeOwner=\'NCC\' codeDescription=\'Market\'><id>127</id></key><key codeOwner=\'\'><id/></key><key codeOwner=\'Strata\' codeDescription=\'Pops\'><id>zone</id></key><key codeOwner=\'Strata\' codeDescription=\'UseBroadcastWeeks\'><id>1</id></key><totals><cost>15000.00</cost><spots>3</spots></totals><market nsi_id=\'258\'><name>Green Bay</name></market><survey><ratingService/><geography/><shareBook/><PUTBook/><profile/><comment codeOwner=\'Spotcable\'>Jul16 DMA Nielsen Live+1</comment></survey><populations demoRank=\'1\'>97848</populations><comment/><systemOrder><key codeOwner=\'\'><id/></key><key codeOwner=\'Strata\' codeDescription=\'UseZonePop\'><id>true</id></key><comment></comment><system><name>DILA - Digital Los Angelas</name><syscode>8899</syscode></system><affiliateSplit/><populations demoRank=\'1\'>97848</populations><totals><cost>15000.00</cost><spots>3</spots></totals><weeks count=\'9\'><week number=\'1\' startDate=\'2017-07-24\'/><week number=\'2\' startDate=\'2017-07-31\'/><week number=\'3\' startDate=\'2017-08-07\'/><week number=\'4\' startDate=\'2017-08-14\'/><week number=\'5\' startDate=\'2017-08-21\'/><week number=\'6\' startDate=\'2017-08-28\'/><week number=\'7\' startDate=\'2017-09-04\'/><week number=\'8\' startDate=\'2017-09-11\'/><week number=\'9\' startDate=\'2017-09-18\'/></weeks><detailLine detailLineID=\'0\'><startTime>06:00:00</startTime><endTime>00:00:00</endTime><startDay>M</startDay><dayOfWeek><Monday>N</Monday><Tuesday>N</Tuesday><Wednesday>N</Wednesday><Thursday>N</Thursday><Friday>N</Friday><Saturday>N</Saturday><Sunday>Y</Sunday></dayOfWeek><length>PT30S</length><daypartCode>RT</daypartCode><program></program><comment>TP</comment><network><name>TDEV</name><ID><code codeOwner=\'Spotcable\' codeDescription=\'-1\'>TDEV</code></ID><ID><code codeOwner=\'Strata\' codeDescription=\'Station\'>TDEV</code></ID></network><spotCost currency=\'USD\'>1000.00</spotCost><demoValue demoRank=\'1\'><value type=\'Ratings\'>0.0</value><value type=\'Impressions\'>0</value></demoValue><totals><cost currency=\'USD\'>1000.00</cost><spots>1</spots></totals><spot><weekNumber>1</weekNumber><quantity>1</quantity></spot><spot><weekNumber>2</weekNumber><quantity>0</quantity></spot><spot><weekNumber>3</weekNumber><quantity>0</quantity></spot><spot><weekNumber>4</weekNumber><quantity>0</quantity></spot><spot><weekNumber>5</weekNumber><quantity>0</quantity></spot><spot><weekNumber>6</weekNumber><quantity>0</quantity></spot><spot><weekNumber>7</weekNumber><quantity>0</quantity></spot><spot><weekNumber>8</weekNumber><quantity>0</quantity></spot><spot><weekNumber>9</weekNumber><quantity>0</quantity></spot></detailLine><detailLine detailLineID=\'0\'><startTime>06:00:00</startTime><endTime>00:00:00</endTime><startDay>M</startDay><dayOfWeek><Monday>N</Monday><Tuesday>N</Tuesday><Wednesday>N</Wednesday><Thursday>N</Thursday><Friday>N</Friday><Saturday>N</Saturday><Sunday>Y</Sunday></dayOfWeek><length>PT30S</length><daypartCode>RT</daypartCode><program></program><comment>TP</comment><network><name>TDEV</name><ID><code codeOwner=\'Spotcable\' codeDescription=\'-1\'>TDEV</code></ID><ID><code codeOwner=\'Strata\' codeDescription=\'Station\'>TDEV</code></ID></network><spotCost currency=\'USD\'>7000.00</spotCost><demoValue demoRank=\'1\'><value type=\'Ratings\'>0.0</value><value type=\'Impressions\'>0</value></demoValue><totals><cost currency=\'USD\'>14000.00</cost><spots>2</spots></totals><spot><weekNumber>1</weekNumber><quantity>0</quantity></spot><spot><weekNumber>2</weekNumber><quantity>0</quantity></spot><spot><weekNumber>3</weekNumber><quantity>0</quantity></spot><spot><weekNumber>4</weekNumber><quantity>0</quantity></spot><spot><weekNumber>5</weekNumber><quantity>1</quantity></spot><spot><weekNumber>6</weekNumber><quantity>0</quantity></spot><spot><weekNumber>7</weekNumber><quantity>0</quantity></spot><spot><weekNumber>8</weekNumber><quantity>0</quantity></spot><spot><weekNumber>9</weekNumber><quantity>1</quantity></spot></detailLine></systemOrder></order></campaign></adx>';
        // String userID, String xml, String oppID
        ThirdPartySCXUpload.SCXUploadResponseWrapper response = ThirdPartySCXUpload.doPost(String.valueOf(u.Id), xmlString , String.valueOf(opp.Id), null,'2100');

        System.assert(response != null);
    }

    static testMethod void doPostMethodNegativePathTest1() {
        
        //prepareTestData();

        User u = [SELECT Id, Name FROM User WHERE isActive = true LIMIT 1];
        System.assert(u != null);

        Opportunity opp = [SELECT Id, Name FROM Opportunity LIMIT 1];

        String xmlString = '<?xml version=\'1.0\' encoding=\'UTF-8\'?><adx xsi:noNamespaceSchemaLocation=\'\' xmlns:xsi=\'http://www.w3.org/2001/XMLSchema-instance\'><document><schemaVersion>1.0</schemaVersion><name></name><date>2017-07-20</date><mediaType>Spotcable</mediaType><documentType/><documentCode/></document><campaign><key codeOwner=\'NCC\' codeDescription=\'CampaignID\'><id></id></key><key codeOwner=\'Strata\' codeDescription=\'DMA Override\'><id>0</id></key><key codeOwner=\'Strata\' codeDescription=\'Zone Pops\'><id>sum</id></key><key codeOwner=\'VIEW32\' codeDescription=\'CampaignName\'><id></id></key><key codeOwner=\'Strata\' codeDescription=\'distro\'><id>bc</id></key><dateRange><startDate>2017-07-24</startDate><endDate>2017-09-24</endDate></dateRange><company type=\'Rep\'><name></name><office><name></name><address><street/><city/><state code=\'__\'/><postalCode>00000</postalCode></address><phone type=\'voice\'></phone></office><contact role=\'AE\'><firstName/><lastName/><email/><phone type=\'voice\'/></contact></company><company type=\'Agency\'><name>0</name><contact role=\'Buyer\'><firstName/><lastName/><email/><phone type=\'voice\'></phone></contact><ID><code codeOwner=\'Agency\'></code></ID></company><advertiser><name>SCX import holding Advertiser</name><ID><code codeOwner=\'Agency\'></code></ID></advertiser><product><name></name><ID><code codeOwner=\'Agency\'></code></ID></product><estimate><desc>Testing</desc><ID><code codeOwner=\'Agency\'></code></ID></estimate><makeGoodPolicy><code/></makeGoodPolicy><demo demoRank=\'1\'><group>Households</group><ageFrom>0</ageFrom><ageTo>99</ageTo></demo><buyType>weekly</buyType><populations demoRank=\'1\'>97848</populations><order><key codeOwner=\'NCC\' codeDescription=\'Market\'><id>127</id></key><key codeOwner=\'\'><id/></key><key codeOwner=\'Strata\' codeDescription=\'Pops\'><id>zone</id></key><key codeOwner=\'Strata\' codeDescription=\'UseBroadcastWeeks\'><id>1</id></key><totals><cost>15000.00</cost><spots>3</spots></totals><market nsi_id=\'258\'><name>Green Bay</name></market><survey><ratingService/><geography/><shareBook/><PUTBook/><profile/><comment codeOwner=\'Spotcable\'>Jul16 DMA Nielsen Live+1</comment></survey><populations demoRank=\'1\'>97848</populations><comment/><systemOrder><key codeOwner=\'\'><id/></key><key codeOwner=\'Strata\' codeDescription=\'UseZonePop\'><id>true</id></key><comment></comment><system><name>DILA - Digital Los Angelas</name><syscode>8899</syscode></system><affiliateSplit/><populations demoRank=\'1\'>97848</populations><totals><cost>15000.00</cost><spots>3</spots></totals><weeks count=\'9\'><week number=\'1\' startDate=\'2017-07-24\'/><week number=\'2\' startDate=\'2017-07-31\'/><week number=\'3\' startDate=\'2017-08-07\'/><week number=\'4\' startDate=\'2017-08-14\'/><week number=\'5\' startDate=\'2017-08-21\'/><week number=\'6\' startDate=\'2017-08-28\'/><week number=\'7\' startDate=\'2017-09-04\'/><week number=\'8\' startDate=\'2017-09-11\'/><week number=\'9\' startDate=\'2017-09-18\'/></weeks><detailLine detailLineID=\'0\'><startTime>06:00:00</startTime><endTime>00:00:00</endTime><startDay>M</startDay><dayOfWeek><Monday>N</Monday><Tuesday>N</Tuesday><Wednesday>N</Wednesday><Thursday>N</Thursday><Friday>N</Friday><Saturday>N</Saturday><Sunday>Y</Sunday></dayOfWeek><length>PT30S</length><daypartCode>RT</daypartCode><program></program><comment>TP</comment><network><name>TDEV</name><ID><code codeOwner=\'Spotcable\' codeDescription=\'-1\'>TDEV</code></ID><ID><code codeOwner=\'Strata\' codeDescription=\'Station\'>TDEV</code></ID></network><spotCost currency=\'USD\'>1000.00</spotCost><demoValue demoRank=\'1\'><value type=\'Ratings\'>0.0</value><value type=\'Impressions\'>0</value></demoValue><totals><cost currency=\'USD\'>1000.00</cost><spots>1</spots></totals><spot><weekNumber>1</weekNumber><quantity>1</quantity></spot><spot><weekNumber>2</weekNumber><quantity>0</quantity></spot><spot><weekNumber>3</weekNumber><quantity>0</quantity></spot><spot><weekNumber>4</weekNumber><quantity>0</quantity></spot><spot><weekNumber>5</weekNumber><quantity>0</quantity></spot><spot><weekNumber>6</weekNumber><quantity>0</quantity></spot><spot><weekNumber>7</weekNumber><quantity>0</quantity></spot><spot><weekNumber>8</weekNumber><quantity>0</quantity></spot><spot><weekNumber>9</weekNumber><quantity>0</quantity></spot></detailLine><detailLine detailLineID=\'0\'><startTime>06:00:00</startTime><endTime>00:00:00</endTime><startDay>M</startDay><dayOfWeek><Monday>N</Monday><Tuesday>N</Tuesday><Wednesday>N</Wednesday><Thursday>N</Thursday><Friday>N</Friday><Saturday>N</Saturday><Sunday>Y</Sunday></dayOfWeek><length>PT30S</length><daypartCode>RT</daypartCode><program></program><comment>TP</comment><network><name>TDEV</name><ID><code codeOwner=\'Spotcable\' codeDescription=\'-1\'>TDEV</code></ID><ID><code codeOwner=\'Strata\' codeDescription=\'Station\'>TDEV</code></ID></network><spotCost currency=\'USD\'>7000.00</spotCost><demoValue demoRank=\'1\'><value type=\'Ratings\'>0.0</value><value type=\'Impressions\'>0</value></demoValue><totals><cost currency=\'USD\'>14000.00</cost><spots>2</spots></totals><spot><weekNumber>1</weekNumber><quantity>0</quantity></spot><spot><weekNumber>2</weekNumber><quantity>0</quantity></spot><spot><weekNumber>3</weekNumber><quantity>0</quantity></spot><spot><weekNumber>4</weekNumber><quantity>0</quantity></spot><spot><weekNumber>5</weekNumber><quantity>1</quantity></spot><spot><weekNumber>6</weekNumber><quantity>0</quantity></spot><spot><weekNumber>7</weekNumber><quantity>0</quantity></spot><spot><weekNumber>8</weekNumber><quantity>0</quantity></spot><spot><weekNumber>9</weekNumber><quantity>1</quantity></spot></detailLine></systemOrder></order></campaign></adx>';
        // String userID, String xml, String oppID
        ThirdPartySCXUpload.SCXUploadResponseWrapper response = ThirdPartySCXUpload.doPost(String.valueOf(u.Id), xmlString , String.valueOf(opp.Id), 'SPP',null);

        System.assert(response != null);
    }

    static testMethod void doPostMethodNegativePathTest2() {
        
        //prepareTestData();

        User u = [SELECT Id, Name FROM User WHERE isActive = true LIMIT 1];
        System.assert(u != null);

        //Opportunity opp = [SELECT Id, Name FROM Opportunity LIMIT 1];

        String xmlString = '';
        // String userID, String xml, String oppID
        ThirdPartySCXUpload.SCXUploadResponseWrapper response = ThirdPartySCXUpload.doPost(String.valueOf(u.Id), xmlString , null, 'SPP',null);

        System.assert(response != null);
    }

    static testMethod void doPostMethodNegativePathTest3() {
        
        //prepareTestData();

        User u = [SELECT Id, Name FROM User WHERE isActive = true LIMIT 1];
        System.assert(u != null);

        Opportunity opp = [SELECT Id, Name FROM Opportunity LIMIT 1];
        String xmlString = '';
        // String userID, String xml, String oppID
     // ThirdPartySCXUpload.SCXUploadResponseWrapper response = ThirdPartySCXUpload.doPost(String.valueOf(u.Id), xmlString , '0060U00000B0PBK',null,null);
     ThirdPartySCXUpload.SCXUploadResponseWrapper response = ThirdPartySCXUpload.doPost(String.valueOf(u.Id), xmlString, String.valueOf(opp.Id),null,null);

        System.assert(response != null);
    }

    static testMethod void doPostMethodNegativePathTest4() {

        User u = [SELECT Id, Name FROM User WHERE isActive = true LIMIT 1];
        System.assert(u != null);

        UserConnection__c loggedInUser = [Select AE_Id__c, TIM_System__c, Username__c
                            from UserConnection__c
                            where User__c=: UserInfo.getUserId() and TIM_System__c ='St. Louis Local' limit 1];
       
        loggedInUser.Is_Primary__c = false;
        update loggedInUser;
        Opportunity opp = [SELECT Id, Name FROM Opportunity LIMIT 1];
        ThirdPartySCXUpload.SCXUploadResponseWrapper response = ThirdPartySCXUpload.doPost(String.valueOf(u.Id), '' , String.valueOf(opp.Id), null,'2100');

        System.assert(response != null);
    }
}