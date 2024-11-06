@isTest
private class UserApprovalGenerationTest {

    @IsTest(seeAlldata = false)
    static void AEViewTest() {

        //create AE User
            User userAE = TestUtil.prepareUser();
            Profile objProfile = [SELECT Id,Name FROM Profile WHERE Name = 'Master - Account Executive'];
            userAE.ProfileId = objProfile.Id;
            userAE.Username = 'testae@mands.com';
            userAE.Budget_type__c = 'Local';
            userAE.Budget_product_Lines__c = 'Linear/News/Sports;Digital;Production;';
            userAE.HR_Level__c = 5;
        	userAE.Division__c = 'Central';
            insert userAE;

            //Create second User
            User userAE2 = TestUtil.prepareUser();
            Profile objProfile2 = [SELECT Id,Name FROM Profile WHERE Name = 'Master - Account Executive'];
            userAE2.ProfileId = objProfile.Id;
            userAE2.Username = 'testae2@mands.com';
            userAE2.Budget_type__c = 'Local';
            userAE2.Budget_product_Lines__c = 'Linear/News/Sports;Digital;Production;';
            userAE2.HR_Level__c = 2;
        	userAE2.Division__c = 'Central';
            insert userAE2;

            Sales_Budget__c sb = new Sales_Budget__c();
            String approverID = userAE.Id;
            String approverID2 = userAE2.ID;
            String sbWorkflowId;
            String comments = 'comments';
            String approvedStatusValue = 'Approved';
            String approvedForecastStatusValue = 'Forecast Approved';
            String rejectedStatusValue = 'Rejected';
            String rejectedForecastStatusValue = 'Forecast Rejected';


            //Execute test as AE User
            System.runAs(userAE){

                //create Advertiser
                Account acc = TestUtil.getAccountRec();
            /* commented by Madhu on Aug 08-18 for Test class failure in Prod */
            //acc.Commodity_Codes__c =   'Auto Aftermarket';
        insert acc;


                //create PY Sales Revenue
                insert TestUtil.getSalesRevenueRec(userAE, acc, System.today().addYears(-1));

                //create CY Sales Revenue
                insert TestUtil.getSalesRevenueRec(userAE, acc, System.today());

                //create Sales Budget
                sb = TestUtil.getSalesBudgetRec(userAE, acc);
                insert sb;
                sbWorkflowId = sb.Id;

                //create Sales Budget Approval
                insert TestUtil.getSalesBudgetApprovalRec(userAE, sb);
                insert TestUtil.getSalesBudgetApprovalRec(userAE2, sb);

                //Create User Connection
                insert TestDataHelper.createUserConnection('St. Louis Local','SFDCUser',userAE.id,'TIM','1');

            //create Opportunity
            Opportunity opp = TestDataHelper.createopportunity('Test Opportunity',System.today(),'Planning','Pipeline',acc.ID);
            insert opp;

            //create Proposal
            Proposal__c p = TestDataHelper.createProposal('Test Opportunity Proposal',opp.id, '00000', true);
                p.RecordTypeId = TestDataHelper.oppBudgetRecTypeId;
                p.Start_Date__c = System.today();
                p.End_Date__c = System.today().addMonths(1);
                insert p;
            //Create SysCode
        Syscode__c sys = TestDataHelper.createSysCode(false);
                    insert sys;
            //create Proposal Zone
                Proposal_Zone__c propZone = TestDataHelper.createProposalZone('Test Proposal Zone',p.Id);
                propZone.Sys_Code__c = 'Linear/News/Sports';
                insert propZone;

        //create Proposal Zone Monthly Value
                Proposal_Zone_Monthly_Value__c propZoneMonthly = TestDataHelper.createProposalZoneMontly('Test Proposal Zone Monthly Value',acc.Id,propZone.Id);
                propZoneMonthly.Schedule_Type__c = 'Linear';
                propZoneMonthly.Proposal_Key_Index__c = p.Id;
                propZoneMonthly.Broadcast_Month_Date__c = System.today().adddays(1);
                insert propZoneMonthly;


                Test.startTest();
                System.debug('AEViewTest');
                BudgetingToolController btc = new BudgetingToolController ();
                String sep = BudgetingToolController.keySeparator;
                btc.JSONOutput = '{"IO":{},"Changes":[{"id":"AR1$AR2$AR3$'+sep+'Auto Aftermarket'+sep+acc.id+sep+'Digital'+sep+'2017","Changed":1,"Feb":"2","Mar":"3","Apr":"4","May":"5","Jun":"6","Jul":"7","Aug":"8","Sep":"9","Oct":"1","Nov":"2","Dec":"3"}]}';
                btc.saveGridData();

            String LedName = '2017 OTB';
            List<Integer> months = new List<Integer>{0,4000,6000,8000,4000,2000,6000,10000,5000,4000,8000,9000};
            String formula = ''; String id = '';
                    BudgetingToolModel.Items_Led tgmiLed =  new BudgetingToolModel.Items_Led();
                    tgmiLed.id = id;
                    tgmiLed.Account = LedName;
                    tgmiLed.Jan = months[0];
            tgmiLed.Feb = months[1];
            tgmiLed.Mar = months[2];
            tgmiLed.Apr = months[3];
            tgmiLed.May = months[4];
            tgmiLed.Jun = months[5];
            tgmiLed.Jul = months[6];
            tgmiLed.Aug = months[7];
            tgmiLed.Sep = months[8];
            tgmiLed.Oct = months[9];
            tgmiLed.Nov = months[10];
            tgmiLed.Dec = months[11];

            //tgmiLed.format('c');
            //tgmiLed.format('p');

            sb.Status__c = 'Submitted';
            sb.Type__c = 'Workflow';
            update sb;
            UserApprovalGeneration.updateForecastApprovalSubmission(sbWorkflowId);
            UserApprovalGeneration.updateBudgetApprovalSubmission(sbWorkflowId);
            UserApprovalGeneration.budgetProcess(approverID2, sbWorkflowId, comments, approvedStatusValue);
            UserApprovalGeneration.budgetProcess(approverID, sbWorkflowId, comments, approvedStatusValue);
            UserApprovalGeneration.budgetProcess(approverID, sbWorkflowId, comments, rejectedStatusValue);
            UserApprovalGeneration.forecastProcess(approverID, sbWorkflowId, comments, approvedForecastStatusValue);
            UserApprovalGeneration.forecastProcess(approverID, sbWorkflowId, comments, rejectedForecastStatusValue);
            UserApprovalGeneration.showapprovalUI(sbWorkflowId);
            Test.stopTest();
            }
    }

    @IsTest(seeAlldata = false)
    static void AEViewTest2() {

        //create AE User
        User userAE = TestUtil.prepareUser();
            Profile objProfile = [SELECT Id,Name FROM Profile WHERE Name = 'Master - Account Executive'];
    userAE.ProfileId = objProfile.Id;
            userAE.Username = 'testae@mands.com';
            userAE.budget_type__c = 'Local';
            userAE.budget_product_Lines__c = 'Linear/News/Sports;Digital;Production;';
        	userAE.Division__c = 'Central';
            insert userAE;
            Sales_Budget__c sb = new Sales_Budget__c();
            String approverID = userAE.Id;
            String sbWorkflowId;
            String comments = 'comments';
            String approvedStatusValue = 'Approved';


            //Execute test as AE User
            System.runAs(userAE){

                //create Advertiser
                Account acc = TestUtil.getAccountRec();
            /* commented by Madhu on Aug 08-18 for Test class failure in Prod */
            //acc.Commodity_Codes__c =   'Auto Aftermarket';
        insert acc;


                //create PY Sales Revenue
                insert TestUtil.getSalesRevenueRec(userAE, acc, System.today().addYears(-1));

                //create CY Sales Revenue
                insert TestUtil.getSalesRevenueRec(userAE, acc, System.today());

                //create Sales Budget
                sb = TestUtil.getSalesBudgetRec(userAE, acc);
                insert sb;
                sbWorkflowId = sb.Id;

                //create Sales Budget Approval
                //insert TestUtil.getSalesBudgetApprovalRec(userAE, sb);

                //Create User Connection
                insert TestDataHelper.createUserConnection('St. Louis Local','SFDCUser',userAE.id,'TIM','1');

            //create Opportunity
            Opportunity opp = TestDataHelper.createopportunity('Test Opportunity',System.today(),'Planning','Pipeline',acc.ID);
            insert opp;

            //create Proposal
            Proposal__c p = TestDataHelper.createProposal('Test Opportunity Proposal',opp.id, '00000', true);
                p.RecordTypeId = TestDataHelper.oppBudgetRecTypeId;
                p.Start_Date__c = System.today();
                p.End_Date__c = System.today().addMonths(1);
                insert p;

            //Create SysCode
        Syscode__c sys = TestDataHelper.createSysCode(false);
                    insert sys;
            //create Proposal Zone
                Proposal_Zone__c propZone = TestDataHelper.createProposalZone('Test Proposal Zone',p.Id);
                propZone.Sys_Code__c = 'Linear/News/Sports';
                insert propZone;

        //create Proposal Zone Monthly Value
                Proposal_Zone_Monthly_Value__c propZoneMonthly = TestDataHelper.createProposalZoneMontly('Test Proposal Zone Monthly Value',acc.Id,propZone.Id);
                propZoneMonthly.Schedule_Type__c = 'Linear';
                propZoneMonthly.Proposal_Key_Index__c = p.Id;
                propZoneMonthly.Broadcast_Month_Date__c = System.today().adddays(1);
                insert propZoneMonthly;


                Test.startTest();
                System.debug('AEViewTest');
                BudgetingToolController btc = new BudgetingToolController ();
                String sep = BudgetingToolController.keySeparator;
                btc.JSONOutput = '{"IO":{},"Changes":[{"id":"AR1$AR2$AR3$'+sep+'Auto Aftermarket'+sep+acc.id+sep+'Digital'+sep+'2017","Changed":1,"Feb":"2","Mar":"3","Apr":"4","May":"5","Jun":"6","Jul":"7","Aug":"8","Sep":"9","Oct":"1","Nov":"2","Dec":"3"}]}';
                btc.saveGridData();

            String LedName = '2017 OTB';
            List<Integer> months = new List<Integer>{0,4000,6000,8000,4000,2000,6000,10000,5000,4000,8000,9000};
            String formula = ''; String id = '';
                    BudgetingToolModel.Items_Led tgmiLed =  new BudgetingToolModel.Items_Led();
                    tgmiLed.id = id;
                    tgmiLed.Account = LedName;
                    tgmiLed.Jan = months[0];
            tgmiLed.Feb = months[1];
            tgmiLed.Mar = months[2];
            tgmiLed.Apr = months[3];
            tgmiLed.May = months[4];
            tgmiLed.Jun = months[5];
            tgmiLed.Jul = months[6];
            tgmiLed.Aug = months[7];
            tgmiLed.Sep = months[8];
            tgmiLed.Oct = months[9];
            tgmiLed.Nov = months[10];
            tgmiLed.Dec = months[11];

        //  tgmiLed.format('c');
        //  tgmiLed.format('p');

            sb.Status__c = 'Submitted';
            sb.Type__c = 'Workflow';
            update sb;
            UserApprovalGeneration.budgetProcess(approverID, sbWorkflowId, comments, approvedStatusValue);
            Test.stopTest();
            }
    }

}