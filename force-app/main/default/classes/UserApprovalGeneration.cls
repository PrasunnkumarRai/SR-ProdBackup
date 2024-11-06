public with sharing class UserApprovalGeneration {

    public static void userApprovalAssignment(String userID, String sbWorkflowId){
        System.debug('User ID/sbWorkflowId: '+userID+'/'+sbWorkflowId);
        Map<Id,Id> userMap = new Map<Id,Id>();
        Map<Id,String> nsmUserMap = new Map<Id,String>();
        List<Sales_Budget_Approval__c> sbaList = new List<Sales_Budget_Approval__c>();
        List<User> userList = [Select Id, HR_Manager__c, Budget_Type__c from User where HR_Level__c != null];
        List<Sales_Budget_Approval__c> sbaListCheck = new List<Sales_Budget_Approval__c>();

          //Checking for NSM User for self approval
          //Adding All Budgeting users to map for Budget Approval Records
          for(User u : userList){
            userMap.put(u.Id,u.HR_Manager__c);

            System.debug('UserId/Budget Type: '+ u.Id+' '+u.Budget_Type__c); 
            //Handling National User Insert
            if(u.Id == userID && u.Budget_Type__c == 'National'){
              Sales_Budget_Approval__c sba = new Sales_Budget_Approval__c();
              sba.Sales_Budget__c = sbWorkflowId;
              sba.Approver__c = userID;
              sbaList.add(sba);
            }
          }
          sbaListCheck = [Select Id from Sales_Budget_Approval__c where Sales_Budget__c =: sbWorkflowId];

          //Inserting Sales Budget Approval Records
          if(sbaListCheck.size()==0){
           
            do{
              Sales_Budget_Approval__c sba = new Sales_Budget_Approval__c();
              sba.Sales_Budget__c = sbWorkflowId;
              sba.Approver__c = userMap.get(userID);
              sbaList.add(sba);

              //Updating userID to be latest inserted HR Manager
              userID = sba.Approver__c;

            }while(userMap.get(userID) != null && userMap.get(userID) != System.Label.RVP);

            
            System.debug('List of SBAs '+ sbaList);
			
            insert sbaList;
      }
    }

    //Method to handle Budget Approve/Reject Process
    public static void budgetProcess(String approverID, String sbWorkflowId, String comments, String statusValue){
      System.debug('ApproverID/sbWorkflowId/comments: '+approverID+' | '+sbWorkflowId+' | '+comments+' | '+statusValue);
        List<Sales_Budget_Approval__c> sbaList = [Select Id, Status__c, Comments__c, Date_Time_Approved__c, HR_Level__c, Approver__c from Sales_Budget_Approval__c where Sales_Budget__c =: sbWorkflowId];
        String intermidateApproval = 'Intermediate Approval';
        String finalApproval = 'Final Approval';
        Integer countApprovals = 0;
        System.debug('SBA List from budgeProcess '+ sbaList);

        //Process for 'Approved' Budget
        if(statusValue == 'Approved'){
          Sales_Budget__c sbw = new Sales_Budget__c();

          for(Sales_Budget_Approval__c sba: sbaList){
            //Update Parent Sales Budget Workflow Record
            if(sba.Approver__c == approverID){
              if(sbWorkflowId != null){
                 sbw.Id = sbWorkflowId;
                 sbw.Status__c = finalApproval;
                 sbw.Comments__c = comments;
                 update sbw;
            }
            //Update Child Sales Budget Approval Record
                sba.Status__c = statusValue;
                sba.Comments__c = comments;
                sba.Date_Time_Approved__c = Datetime.now();
                update sba;
          }
          //Checking and Updating for final approval
          if(sba.Status__c != 'Approved'){
            countApprovals ++;
          }
          if(sba.Status__c == 'Approved' && sba.HR_Level__c == 2){
            countApprovals = 0;
            System.debug('Checking Tier 1: '+ countApprovals);
          }
          System.debug('Counting: '+countApprovals);
          if(countApprovals == 0){
            sbw.Status__c = finalApproval;
          }else{
            sbw.Status__c = finalApproval;
          }
            sbw.Id = sbWorkflowId;
            update sbw;
      }
    }
      //Process for 'Rejected' Budget
        if(statusValue == 'Rejected'){
          Sales_Budget__c sbw = new Sales_Budget__c();
          for(Sales_Budget_Approval__c sba: sbaList){

            //Update Parent Sales Budget Workflow Record
            if(sba.Approver__c == approverID){
    		    if(sbWorkflowId != null){
    			       sbw.Id = sbWorkflowId;
    			       sbw.Status__c = statusValue;
    			       sbw.Comments__c = comments;
    			       update sbw;
            }
            //Update Child Sales Budget Approval Record
                sba.Status__c = statusValue;
                sba.Comments__c = comments;
                sba.Date_Time_Approved__c = Datetime.now();
                update sba;
        }
      }
    }
  }

  public static void forecastProcess(String approverID, String sbWorkflowId, String comments, String statusValue){
    System.debug('ApproverID/sbWorkflowId/comments: '+approverID+' | '+sbWorkflowId+' | '+comments+' | '+statusValue);
      List<Sales_Budget_Approval__c> sbaList = [Select Id, Status__c, Comments__c, Date_Time_Approved__c, Approver__c, HR_Level__c from Sales_Budget_Approval__c where Sales_Budget__c =: sbWorkflowId];
      String intermidateApproval = 'Forecast Intermediate Approval';
      String finalApproval = 'Forecast Final Approval';
      Integer countApprovals = 0;

      //Process for 'Approved' Forecast
      if(statusValue == 'Forecast Approved'){
        for(Sales_Budget_Approval__c sba: sbaList){
          Sales_Budget__c sbw = new Sales_Budget__c();
          //Update Parent Sales Budget Workflow Record
          if(sba.Approver__c == approverID){
          if(sbWorkflowId != null){
               sbw.Id = sbWorkflowId;
               sbw.Status__c = finalApproval;
               sbw.Comments__c = comments;
               update sbw;
          }
          //Update Child Sales Budget Approval Record
              sba.Status__c = statusValue;
              sba.Comments__c = comments;
              sba.Date_Time_Approved__c = Datetime.now();
              update sba;

        }
        //Checking and Updating for final approval
        System.debug('SBA Status/SBA HR level:'+ sba.Status__c+' / '+sba.HR_Level__c);

          if(sba.Status__c != 'Forecast Approved'){
          countApprovals ++;
        }
        if(sba.Status__c == 'Forecast Approved' && sba.HR_Level__c == 2){
            countApprovals = 0;
            System.debug('Checking Tier 1: '+ countApprovals);
          }

        System.debug('Counting: '+countApprovals);
        if(countApprovals == 0){
          sbw.Status__c = finalApproval;
        }else{
          sbw.Status__c = finalApproval;
        }
          sbw.Id = sbWorkflowId;
          update sbw;
      }
    }
    //Process for 'Rejected' Forecast
      if(statusValue == 'Forecast Rejected'){
        for(Sales_Budget_Approval__c sba: sbaList){
          Sales_Budget__c sbw = new Sales_Budget__c();

          //Update Parent Sales Budget Workflow Record
          if(sba.Approver__c == approverID){
          if(sbWorkflowId != null){
               sbw.Id = sbWorkflowId;
               sbw.Status__c = statusValue;
               sbw.Comments__c = comments;
               update sbw;
          }
          //Update Child Sales Budget Approval Record

              sba.Status__c = statusValue;
              sba.Comments__c = comments;
              sba.Date_Time_Approved__c = Datetime.now();
              update sba;
          }
        }
      }
    }

    public static Boolean showapprovalUI(String sbWorkflowId){
      System.debug('WorkflowID/hrLevel: '+ sbWorkflowId);
      List<Sales_Budget_Approval__c> approverList = new List<Sales_Budget_Approval__c>();
      Id loggedinApproverId = UserInfo.getUserId();
      List<User> loggedinApprover = [Select HR_Level__c from User where Id =: loggedinApproverId];
      // System.debug('Approver HR Level: '+loggedinApprover);
      Boolean showApproval = true;

      approverList = [Select Id, HR_Level__c, Status__c from Sales_Budget_Approval__c where Sales_Budget__c =: sbWorkflowId order by lastmodifieddate asc];

      System.debug('approverList: '+ approverList);
        for(Sales_Budget_Approval__c sba : approverList){
          if(sba.Status__c == 'Approved' && sba.HR_Level__c <= loggedinApprover[0].HR_Level__c){
            showApproval = false;
          }
          if(sba.Status__c == 'Forecast Approved' && sba.HR_Level__c <= loggedinApprover[0].HR_Level__c){
            showApproval = false;
          }
          if(sba.Status__c == 'Rejected' || sba.Status__c == 'Forecast Rejected'){
            showApproval = false;
          }
        }

      return showApproval;
    }
    public static void updateBudgetApprovalSubmission(String sbWorkflowId){
      List<Sales_Budget_Approval__c> sbaList = [Select Id, Status__c from Sales_Budget_Approval__c where Sales_Budget__c =: sbWorkflowId];
      String budgetStatusStart = 'Budget Pending';

      for(Sales_Budget_Approval__c sba : sbaList){
        sba.Status__c = budgetStatusStart;
        update sba;
      }

    }
    public static void updateForecastApprovalSubmission(String sbWorkflowId){
      List<Sales_Budget_Approval__c> sbaList = [Select Id, Status__c from Sales_Budget_Approval__c where Sales_Budget__c =: sbWorkflowId];
      String forecastStatusStart = 'Forecast Pending';

      for(Sales_Budget_Approval__c sba : sbaList){
        sba.Status__c = forecastStatusStart;
        update sba;
      }

    }
}