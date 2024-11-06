/*
###########################################################################
# File..................: AccountTransferToolController.cls
# Version...............: 1
# Created by............: James Dean
# Created Date..........: 24-Sep-2018
# Last Modified by......:
# Last Modified Date....:
# Description...........: This class contains controller methods for managing AccountTransferTool page
# TAO Ref#..............: NA
# Test Class............: 
# Change Log............:
#
#
############################################################################*/
public with sharing class AccountTransferToolController {
  Map < String, Decimal > amtBefore = new Map < String, Integer > ();
  Decimal janBefore = 0;
  public List < User > userTemp = new List < User > ();
  public Map < Id, String > userMapDOS {
      get;
      set;
  }
  public Map < Id, String > toUserMapDOS {
      get;
      set;
  }
  public List < User > userTempTo = new List < User > ();

  public Account accountMerge {
      get;
      set;
  }
  public Account accountMergeTo {
      get;
      set;
  }
  public User loggedInUser {
      get;
      set;
  }
  public String loggedInUserProfile {
      get;
      set;
  }
  public Boolean isDOS {
      get;
      set;
  }
  public Boolean isLAUser {
      get;
      set;
  }
  public Boolean isLSM {
      get;
      set;
  }
  public Boolean isApprover {
      get;
      set;
  }
  public Boolean isTransfer {
      get;
      set;
  }
  public Boolean isTransferProgress {
      get;
      set;
  }
  public Boolean approvalInProgress {
      get;
      set;
  }
  public String pageId {
      get;
      set;
  }
  public Integer currentYear {
      get;
      set;
  }
  public Integer nextYear {
      get;
      set;
  }
  public String NewBusinessChurnId {
      get;
      set;
  }
  public List < String > dmaList {
      get;
      set;
  }
  public List < Product_Line_Order__mdt > prdOrderList;
  public Map < String, Decimal > prdOrderMap {
      get;
      set;
  }
  public List < String > lsmProfiles;
  public List < String > financeLSMProfiles;
  public Account_Transfer_Tool__c attSimulation;
  public Map < String, List < String >> ucMap;
  //Transfer All Accounts
  public Boolean transferAllAcc {
      get;
      set;
  }
  public Boolean transferNBUC {
      get;
      set;
  }


  /**
   * This constructor gets called on page load
   * 
   */
  public AccountTransferToolController(ApexPages.StandardController controller) {
      isDOS = false;
      isTransfer = false;
      isApprover = false;
      accountMerge = new Account();
      accountMergeTo = new Account();
      dmaList = new List < String > ();
      isTransferProgress = approvalInProgress = false;
      currentYear = Datetime.now().year();
      prdOrderMap = new Map < String, Decimal > ();
      ucMap = new Map < String, List < String >> ();
      transferAllAcc = false;
      nextYear = currentYear + 1;
      loggedInUser = [Select Id, Name, Profile.Name, Division__c, Sales_Office__c from User where Id =: UserInfo.getUserId()];
      attSimulation = new Account_Transfer_Tool__c();
      pageId = ApexPages.currentPage().getParameters().get('id');
      system.debug('pageId ' + pageId);
      lsmProfiles = new List < String > ();
      financeLSMProfiles = new List < String > ();
      for (UserClassification__mdt uc: [Select Id, DeveloperName, User_profiles__c from UserClassification__mdt]) {
          if (uc.user_profiles__c.contains(loggedInUser.Profile.Name)) {
              loggedInUserProfile = uc.DeveloperName;
          }
          if (uc.DeveloperName != 'Admin' && uc.DeveloperName != 'Finance') {
              for (String up: uc.User_profiles__c.split(',')) {
                  lsmProfiles.add(up);
                  if (uc.DeveloperName == 'LSM' || uc.DeveloperName == 'NSM' || uc.DeveloperName == 'DOS') {
                      financeLSMProfiles.add(up);
                  }
              }
          }
          ucMap.put(uc.DeveloperName, uc.user_profiles__c.indexOf(',') > 0 ? uc.user_profiles__c.split(',') : new list < String > {
              uc.user_profiles__c
          });
      }

      //Custom metadata for Product Line ordering.
      prdOrderList = [Select MasterLabel, DeveloperName, Order__c from Product_Line_Order__mdt order by Order__c asc];
      for (Product_Line_Order__mdt pd: prdOrderList) {
          if (pd.DeveloperName.indexOf('/') > 0)
              pd.DeveloperName = pd.MasterLabel.replace('/', '_');
          if (pd.MasterLabel.indexOf(' ') > 0)
              pd.MasterLabel = pd.MasterLabel.replace(' ', '_');
          prdOrderMap.put(pd.MasterLabel, pd.Order__c);
      }
      system.debug(prdOrderMap);
      initializeController();

      List < ProcessInstanceWorkitem > btnWorkItemLst = [SELECT Id, ActorId FROM ProcessInstanceWorkitem WHERE processInstance.TargetObjectId =: pageId limit 1];
      List < Profile > profileID = [SELECT Id, Name FROM Profile WHERE Id =: userinfo.getProfileId() LIMIT 1];

      if (btnWorkItemLst.size() > 0) {
          if (btnWorkItemLst[0].ActorId == UserInfo.getUserId() || profileID[0].Name == 'System Administrator') {
              isApprover = true;
          } else if (((String) btnWorkItemLst[0].ActorId).startsWithIgnoreCase('00G')) //OOG is standard prefix for Queue across all instances
          {
              List < GroupMember > grpMem = [Select UserOrGroupId From GroupMember where GroupId =: btnWorkItemLst[0].ActorId];
              for (GroupMember grp: grpMem) {
                  if (grp.UserOrGroupId == UserInfo.getUserId())
                      isApprover = true;
              }
          }
      }
  }

  /**
   * This methods gets called on from constructor to initalize the page variables
   * 
   * @return (void)
   */
  public void initializeController() {

      //Edit Mode
      system.debug(pageId);
      if (String.isNotBlank(pageId))
          attSimulation = [Select ID, Status__c, Transfer_All_Accounts__c from Account_Transfer_Tool__c where ID =: pageId];

      //From LSM Handling    
      if (loggedInUserProfile == 'LSM') {
          isLSM = true;
          System.debug('isLSM: ' + isLSM);
          accountMerge.LSM_Selection__c = loggedInUser.Id;
          if (loggedInUser.Sales_Office__c == 'LA Interconnect') {
              isLAUser = true;
              isDOS = true;
              User dos = [Select ID, Name, Division__c, Region__c from User where ID =: UserInfo.getUserID()];
              string dosDivision = '%' + dos.Division__c;
              userMapDOS = new Map < Id, String > ();
              toUserMapDOS = new Map < Id, String > ();
              userMapDOS.put(loggedInUser.Id, loggedInUser.Name);
              toUserMapDOS.put(loggedInUser.Id, loggedInUser.Name);
              for (User u: [Select Name, Id from User where(Division__c like: dosDivision) AND(Region__c =: dos.Region__c) AND Profile.Name IN: financeLSMProfiles AND Budget_Type__c != null AND Budget_Product_Lines__c != null AND Budget_DMA__c != null]) {
                  userMapDOS.put(u.Id, u.Name);
              }
              for (User u: [Select Name, Id from User where(Division__c like: dosDivision)  AND Profile.Name IN: financeLSMProfiles AND Budget_Type__c != null AND Budget_Product_Lines__c != null AND Budget_DMA__c != null]) {
                  toUserMapDOS.put(u.Id, u.Name);
              }
          }
      } else if (loggedInUserProfile == 'DOS') {
          isDOS = true;
          accountMerge.LSM_Selection__c = loggedInUser.Id;
          User dos = [Select ID, Name, Division__c, Region__c from User where ID =: UserInfo.getUserID()];
          string dosDivision = '%' + dos.Division__c;
          userMapDOS = new Map < Id, String > ();
          toUserMapDOS = new Map < Id, String > ();
          userMapDOS.put(loggedInUser.Id, loggedInUser.Name);
          for (User u: [Select Name, Id from User where HR_Manager__c =: accountMerge.LSM_Selection__c AND Profile.Name IN: financeLSMProfiles AND Budget_Type__c != null AND Budget_Product_Lines__c != null AND Budget_DMA__c != null]) {
              userMapDOS.put(u.Id, u.Name);
          }
          // ( Division__c =: dos.Division__c) AND 
          toUserMapDOS.put(loggedInUser.Id, loggedInUser.Name);
          for (User u: [Select Name, Id from User where(Division__c like: dosDivision)  AND Profile.Name IN: financeLSMProfiles AND Budget_Type__c != null AND Budget_Product_Lines__c != null AND Budget_DMA__c != null]) {
              toUserMapDOS.put(u.Id, u.Name);
          }
          System.debug(' toUserMapDOS ' + toUserMapDOS);
      } else if (loggedInUserProfile == 'Admin' && attSimulation.status__c == 'Approved') {
          isTransfer = true;
      }
      /* For Finance User */
      else if (loggedInUserProfile == 'Finance') {
          User sdof = [Select ID, Name, Division__c from User where ID =: UserInfo.getUserID()];
          isDOS = true;
          string dosDivision = '%' + sdof.Division__c;
          accountMerge.LSM_Selection__c = loggedInUser.Id;
          userMapDOS = new Map < Id, String > ();
          toUserMapDOS = new Map < Id, String > ();
          //userMapDOS.put(loggedInUser.Id,loggedInUser.Name);
          for (User u: [Select Name, Id from User where(Division__c like: dosDivision) AND Profile.Name IN: financeLSMProfiles AND Budget_Type__c != null AND Budget_Product_Lines__c != null AND Budget_DMA__c != null]) {
              userMapDOS.put(u.Id, u.Name);
              toUserMapDOS.put(u.Id, u.Name);
          }
      }
      //Edit Mode
      if (attSimulation != null) {
          transferAllAcc = attSimulation.Transfer_All_Accounts__c;
          if (attSimulation.Status__c == 'Transfer In Progress' || attSimulation.Status__c == 'Transfer Completed')
              isTransferProgress = true;
          else if (attSimulation.Status__c == 'In Process')
              approvalInProgress = true;
          NewBusinessChurnId = Label.BudgetNewBusinessAcountId;
          transferAllAcc = attSimulation.Transfer_All_Accounts__c;
      }
  }

  /**
   * This methods gets called when loading an existing Account Transfer Simulation in Edit Mode 
   * 
   * @Parameter (string) (pageEditId)
   * @return (string) (JSON format Account details)
   */
  @RemoteAction
  public static String initializeFromEdit(String pageEditId) {

      List < Account_Transfer_Mapping__c > atmList;
      String frUser = '';
      String frUserJSON = '';
      String frAccJSON = '';
      String toUser = '';
      String toUserJSON = '';
      String mappedSimlation = '';
      String selForUser = '';
      Id frMgrId;
      Id toMgrId;
      String transferDate = '';
      Map < String, String > mappedFrUsers = new Map < String, String > ();
      Map < String, String > allFrUsersMap = new Map < String, String > ();
      Map < String, String > mappedFrAcc = new Map < String, String > ();
      Map < String, String > mappedFrUserAcc = new Map < String, String > ();
      Map < String, String > mappedToUsers = new Map < String, String > ();
      Map < Integer, String > monthMap = new Map < Integer, String > ();
      String[] stringListUser = new String[0];
      monthMap.put(1, 'Jan');
      monthMap.put(2, 'Feb');
      monthMap.put(3, 'Mar');
      monthMap.put(4, 'Apr');
      monthMap.put(5, 'May');
      monthMap.put(6, 'Jun');
      monthMap.put(7, 'Jul');
      monthMap.put(8, 'Aug');
      monthMap.put(9, 'Sep');
      monthMap.put(10, 'Oct');
      monthMap.put(11, 'Nov');
      monthMap.put(12, 'Dec');
      string nbucAccName = 'New Business Account';
      try {
          if (pageEditId != null && pageEditId.length() > 0) {
              atmList = [select Account__c, Account__r.Name, Name, Account_Transfer_Simulation__c, Account_Transfer_Simulation__r.Status__c, Account_Transfer_Simulation__r.From_LSM__c, Account_Transfer_Simulation__r.To_LSM__c,
                  Account_Transfer_Simulation__r.From_LSM__r.Name, Account_Transfer_Simulation__r.To_LSM__r.name, Account_Transfer_Simulation__r.Transfer_Effective_Date__c, Account_Transfer_Simulation__r.Transfer_All_Accounts__c,
                  Account_Transfer_Simulation__r.NCC__c, External_ID__c, From_User__c, From_User__r.Name, To_User__c, To_User__r.Name, Account_Transfer_Simulation__r.Transfer_NBUC__c, Account_Transfer_Simulation__r.Transfer_NBUC_Select__c from Account_Transfer_Mapping__c
                  where Account_Transfer_Simulation__c =: pageEditId
              ];

              System.Debug('Acount Transfer Mapping List: ' + atmList);
              if (atmList.size() > 0) {
                  User u = [Select Id, HR_Manager__c, HR_Manager__r.Name, Name from User where Id =: atmList[0].From_User__c][0];
                  frMgrId = atmList[0].Account_Transfer_Simulation__r.From_LSM__c;
                  User u2 = [Select Id, HR_Manager__c, HR_Manager__r.Name, Name from User where Id =: atmList[0].To_User__c][0];
                  toMgrId = atmList[0].Account_Transfer_Simulation__r.To_LSM__c;
                  frUser = atmList[0].Account_Transfer_Simulation__r.From_LSM__r.Name;
                  toUser = atmList[0].Account_Transfer_Simulation__r.To_LSM__r.name;
                  if (atmList[0].Account_Transfer_Simulation__r.Transfer_NBUC__c) {
                      selForUser = atmList[0].From_User__c;
                      mappedFrAcc.put((String) Label.BudgetNewBusinessAcountId, 'New Business Account');
                      mappedFrUserAcc.put((String) Label.BudgetNewBusinessAcountId + (String) atmList[0].From_User__c, (String) atmList[0].To_User__c);
                  }
                  for (Account_Transfer_Mapping__c atm: atmList) {
                      mappedFrUsers.put((String) atm.From_User__c, atm.From_User__r.Name);
                      mappedFrAcc.put((String) atm.Account__c, atm.Account__r.Name);
                      mappedToUsers.put((String) atm.To_User__c, atm.To_User__r.Name);
                      mappedFrUserAcc.put((String) atm.Account__c + (String) atm.From_User__c, (String) atm.To_User__c);

                      // build out mappings section
                      if (mappedSimlation.length() > 0) {
                          mappedSimlation += ',,,';
                      }
                      mappedSimlation += atm.To_User__c + ':::' + atm.To_User__r.Name;
                  }
              }

              //Build FROM LSM User List, dynamically select those used in Mappings -- use .multiselect('dataprovider', data) from above REF
              frUserJSON = '[';
              List < User > allFrUsers = [Select Id, Name from User where HR_Manager__c =: frMgrId];
              Boolean lsmCounted = false;
              List < User > allSelectedFrUsers = new List < User > ();
              if (mappedFrUsers.containsKey(frMgrId) && !lsmCounted) {
                  /*
                  user lsmUser = new User();
                  lsmUser.ID = frMgrId;
                  lsmUser.name = frUser;
                  allSelectedFrUsers.add(lsmuser);
                  */
                  lsmCounted = true;
                  allFrUsersMap.put(frMgrId, frUser);
                  frUserJSON += ' { "label": "' + frUser.replace('"', '\\"').replace('\'', '’') + '", "value": "' + frMgrId + ':::' + frUser.replace('"', '\\"').replace('\'', '’') + '"' + (mappedFrUsers.containsKey(frMgrId) ? ', "selected": true' : '') + '} ';
              }
              for (User u: allFrUsers) {

                  allFrUsersMap.put(u.Id, u.Name);
                  if (frUserJSON != '[') {
                      frUserJSON += ', ';
                  }
                  frUserJSON += ' { "label": "' + u.Name.replace('"', '\\"').replace('\'', '’') + '", "value": "' + u.Id + ':::' + u.Name.replace('"', '\\"').replace('\'', '’') + '"' + (mappedFrUsers.containsKey(u.Id) ? ', "selected": true' : '') + '} ';
                  if (mappedFrUsers.containsKey(u.Id)) {
                      allSelectedFrUsers.add(u);
                  }
              }
              frUserJSON += ']';


              //Build TO LSM User List, dynamically select those used in Mappings
              lsmCounted = false;
              system.debug('Manager check ' + mappedToUsers.containsKey(toMgrId) + '_' + toMgrId + '-' + mappedToUsers.keySet());
              toUserJSON = '[';
              if (mappedToUsers.containsKey(toMgrId) && !lsmCounted) {
                  lsmCounted = true;
                  toUserJSON += ' { "label": "' + toUser.replace('"', '\\"').replace('\'', '’') + '", "value": "' + toMgrId + ':::' + toUser.replace('"', '\\"').replace('\'', '’') + '"' + (mappedToUsers.containsKey(toMgrId) ? ', "selected": true' : '') + '} ';
              }
              system.debug('toUserJSON1 ' + toUserJSON);
              for (User u: [Select Id, Name from User where(HR_Manager__c =: toMgrId OR HR_Manager__r.HR_Manager__c =: toMgrId OR HR_Manager__r.HR_Manager__r.HR_Manager__c =: toMgrId)]) {

                  if (toUserJSON != '[') {
                      toUserJSON += ', ';
                  }
                  toUserJSON += ' { "label": "' + u.Name.replace('"', '\\"').replace('\'', '’') + '", "value": "' + u.Id + ':::' + u.Name.replace('"', '\\"').replace('\'', '’') + '"' + (mappedToUsers.containsKey(u.Id) ? ', "selected": true' : '') + '} ';
              }
              toUserJSON += ']';
              system.debug('toUserJSON ' + toUserJSON);
              //Build FROM Account List, dynamically select those used in Mappings
              frAccJSON += '[';
              String delim = '"';
              String[] stringList = new String[0];
              Map < String, String > accountNameMap = new Map < String, String > ();
              for (AccountTeamMember atm: [Select Id, AccountID, Account.Name, Account.SAM_Designation__c, Account.Eclipse_Id__c, UserId, TeamMemberRole from AccountTeamMember where UserId IN: allSelectedFrUsers OR UserID =: mappedFrUsers.containsKey(frMgrId) ? frMgrId : null OR accountId =: Label.BudgetNewBusinessAcountId]) {
                  String accName = atm.Account.Name.replace('\\', '\\\\').replace('"', '\\"').replace('\'', '’');
                  String teamRole = '';
                  accountNameMap.put(String.valueOf(atm.AccountId) + String.valueOf(atm.UserId), atm.AccountId);
                  switch on atm.TeamMemberRole {
                      when 'Sales Manager' {
                          teamRole = 'MGR';
                      }

                      when 'Account Executive' {
                          teamRole = 'AE';
                      }
                  }
                  String accNameNew = ('[' + allFrUsersMap.get(atm.UserId) + ']-[' + teamRole + '] ' + accName).replace('\\', '\\\\').replace('"', '\\"').replace('\'', '’');
                  stringList.add('{' + delim + 'label' + delim + ':' + delim + accNameNew + delim + ',' + delim + 'value' + delim + ':' + delim + atm.AccountId + '|||' + accName + '|||' + atm.UserId + ':::' + allFrUsersMap.get(atm.UserId) + '|||' + atm.Account.SAM_Designation__c + '|||' + atm.Account.Eclipse_Id__c + delim + (mappedFrUserAcc.containsKey((string) atm.AccountId + (string) atm.UserId) ? ',' + delim + 'selected' + delim + ': true' : '') + '}');

              }
              if (atmList[0].Account_Transfer_Simulation__r.Transfer_NBUC__c) {
                  stringList.add('{' + delim + 'label' + delim + ':' + delim + nbucAccName + delim + ',' + delim + 'value' + delim + ':' + delim + Label.BudgetNewBusinessAcountId + '|||' + nbucAccName + '|||' + selForUser + ':::' + frUser + '|||' + null + '|||' + null + delim + (mappedFrUserAcc.containsKey((string) Label.BudgetNewBusinessAcountId + selForUser) ? ',' + delim + 'selected' + delim + ': true' : '') + '}');
              }
              //Fetch All Accounts for which user has SalesBudgets
              for (Sales_Budget__c sb: [Select ID, Advertiser__c, Advertiser__r.Name, Budget_User__c, Budget_User__r.Name, Advertiser__r.Sam_Designation__c, Advertiser__r.Eclipse_id__c from Sales_Budget__c
                      where(Budget_User__c IN: allSelectedFrUsers OR Budget_User__c =: mappedFrUsers.containsKey(frMgrId) ? frMgrId : null) AND Type__c = 'Data'
                      and Broadcast_Month_Date__c >= This_Year
                  ]) {
                  if (!accountNameMap.containsKey(String.valueOf(sb.Advertiser__c) + String.valueOf(sb.Budget_User__c))) {
                      String accName = sb.Advertiser__r.Name.replace('\\', '\\\\').replace('"', '\\"').replace('\'', '’');
                      String teamRole = 'SB';
                      accountNameMap.put(String.valueOf(sb.Advertiser__c) + String.valueOf(sb.Budget_User__c), sb.Advertiser__c);
                      String accNameNew = ('[' + allFrUsersMap.get(sb.Budget_User__c) + ']-[' + teamRole + '] ' + accName).replace('\\', '\\\\').replace('"', '\\"').replace('\'', '’');
                      stringList.add('{' + delim + 'label' + delim + ':' + delim + accNameNew + delim + ',' + delim + 'value' + delim + ':' + delim + sb.Advertiser__c + '|||' + accName + '|||' + sb.Budget_User__c + ':::' + allFrUsersMap.get(sb.Budget_User__c) + '|||' + sb.Advertiser__r.SAM_Designation__c + '|||' + sb.Advertiser__r.Eclipse_Id__c + delim + (mappedFrUserAcc.containsKey((string) sb.Advertiser__c + (string) sb.Budget_User__c) ? ',' + delim + 'selected' + delim + ': true' : '') + '}');
                  }
              }
              /*for(String userId: mappedFrUsers.keySet()) {
                  String accName = 'New Business/Churn';
                  String accNameNew = ('['+mappedFrUsers.get(userId)+']-'+accName).replace('\\','\\\\').replace('"','\\"').replace('\'','’');
                  stringListUser.add('{'+delim+'label'+delim+':'+delim+accNameNew +delim+','+delim+'value'+delim+':'+delim+ Label.BudgetNewBusinessAcountId +'|||'+accName + '|||' + userId + ':::' + allFrUsersMap.get(userId)+'||||||'+delim+(mappedFrAcc.containsKey(Label.BudgetNewBusinessAcountId) ? ','+delim+'selected'+delim+': true' : '')+'}');
              }*/

              frAccJSON += (stringListUser.size() > 0 ? String.join(stringListUser, ',') + ',' : '') + String.join(stringList, ',') + ']';
              System.debug('frAccJSON ' + frAccJSON);
          }
          string returnString = frUser + ';;;' + toUser + ';;;' + atmList[0].Account_Transfer_Simulation__r.Transfer_Effective_Date__c.year();
          returnString += monthMap.get(atmList[0].Account_Transfer_Simulation__r.Transfer_Effective_Date__c.month()) + ';;;' + frUserJSON + ';;;' + toUserJSON + ';;;' + frAccJSON + ';;;';
          returnString += mappedSimlation + ';;;' + atmList[0].Account_Transfer_Simulation__r.NCC__c + ';;;' + atmList[0].Account_Transfer_Simulation__r.Transfer_All_Accounts__c + ';;;';
          returnString += atmList[0].Account_Transfer_Simulation__r.Transfer_NBUC__c + ';;;' + atmList[0].Account_Transfer_Simulation__r.Transfer_NBUC_Select__c;
          return returnString;
      } catch (Exception ex) {
          Log4SF.logMessage('AccountTransferController', 'initializeFromEdit', ex.getMessage(), ex, UserInfo.getUserId(), atmList[0].Account_Transfer_Simulation__c, '');
          return null;
      }
  }

  /**
   * This methods gets called to load mapping of NCC/Direct National and Local Product Lines 
   * 
   * @return (Map<string, AXT_Product_Line_Mapping__c>) (Map of metadata values)
   */
  @RemoteAction
  public static Map < string, AXT_Product_Line_Mapping__c > getProductlineMap() {
      Map < string, AXT_Product_Line_Mapping__c > plMap = AXT_Product_Line_Mapping__c.getAll();
      return plMap;
  }

  /**
   * This methods gets called to load Eclipse Ids 
   * 
   * @return (String) (list of Eclipse Ids)
   */
  @RemoteAction
  public static String loadEclipseIDs(String accountIdStr) {
      List < String > accountIdList = accountIdStr.split(';;;');
      String retVal = '';
      for (Traffic_Id_Element__c tie: [Select Account__r.Name, Traffic_Id__c, TIM_System__c, ExportSystem_Name__c, Account__c from Traffic_Id_Element__c where Account__c IN: accountIdList]) {
          if (retVal.length() > 0) {
              retVal += ';;;';
          }
          retVal += tie.Account__r.Name.replace('\\', '\\\\').replace('"', '\\"').replace('\'', '’') + '|||' + tie.Traffic_Id__c + '|||' + tie.TIM_System__c + '|||' + tie.ExportSystem_Name__c + '|||' + tie.Account__c;
      }
      return retVal;
  }

  /**
   * This methods gets called to load list of AE's 
   * 
   * @return (String) (list of Eclipse Ids)
   */
  //TODO: Add the LSM/NSM if they have an Account.
  @RemoteAction
  public static String getmyuserlistRemote(String oID, String dosLSMs) {
      try {
          List < String > userList = new List < String > ();
          Map < String, String > userMap = new Map < String, String > ();
          Map < String, String > userMapDOS = new Map < String, String > ();
          List < String > userDOSList = new List < String > ();
          List < User > userTemp = new List < User > ();
          List < User > userTempDOS = new List < User > ();
          List < String > lsmProfiles = new List < String > ();

          for (UserClassification__mdt uc: [Select Id, DeveloperName, User_profiles__c from UserClassification__mdt]) {
              if (uc.DeveloperName != 'Admin') {
                  for (String up: uc.User_profiles__c.split(',')) {
                      lsmProfiles.add(up);
                  }
              }
          }
          System.debug('LSM List: ' + lsmProfiles);
          //System.debug('Checking Call');
          System.debug('Checking LSM field ' + oID);
          Id uID = null;
          User userLSM;
          String retStr = '';
          Set < String > lsmProfilesSet = new Set < String > (lsmProfiles);
          if (dosLSMs.length() == 0) {
              if (oID == null || oID.length() == 0) {
                  return '';
              }
              userLSM = [Select Name, Id, Budget_Type__c from User where Name =: oID];
              uID = userLSM.Id;
              userTemp = [Select Name, Id, Budget_Type__c from User where HR_Manager__c =: uID AND Profile.Name IN: lsmProfiles AND Budget_Type__c != null AND Budget_Product_Lines__c != null AND Budget_DMA__c != null limit 200];
              if (userTemp.size() > 0)
                  userTemp.add(0, userLSM);
              else
                  userTemp.add(userLSM);
          } else {
              if (dosLSMs.indexOf(';;;') > 0) {
                  userDOSList = dosLSMs.split(';;;');
              } else
                  userDOSList.add(dosLSMs);
              system.debug('userDOSList ' + userDOSList);
              userTempDOS = [Select Name, Id, Budget_Type__c from User where ID in: userDOSList];
              system.debug('userTempDOS ' + userTempDOS);
              userTemp = [Select Name, Id, Profile.Name, Budget_Type__c from User where HR_Manager__c IN: userDOSList AND Profile.Name IN: lsmProfiles AND Budget_Type__c != null AND Budget_Product_Lines__c != null AND Budget_DMA__c != null limit 200];
              integer i = 0;
              for (User usr: userTempDOS) {
                  if (userTemp.size() > 0)
                      userTemp.add(i, usr);
                  else
                      userTemp.add(usr);
                  i++;
              }
          }

          for (User u: userTemp) {
              if (retStr.length() > 0) {
                  retStr += ',,,';
              }
              retStr += u.Budget_Type__c + ']]]' + u.Id + ':::' + u.Name + ';;;' + u.Name;
              userList.add(u.Name);
              userMap.put(u.Id + ':::' + u.Name, u.Name);
          }
          System.debug(userList);
          return retStr;
      } catch (Exception ex) {
          Log4SF.logMessage('AccountTransferController', 'getmyuserlistRemote', ex.getMessage(), ex, UserInfo.getUserId(), oID, '');
          return null;
      }
  }

  /**
   * This methods gets called to load list of AE's Accounts
   * 
   * @return (String) (list of Accounts)
   */
  @RemoteAction
  public static String getmyuserAccountsList(String aeString) {
      List < String > accountList = new List < String > ();

      List < String > aeIDs = new List < String > ();
      List < String > aeNames = new List < String > ();
      List < String > aeNameIDPairs = new List < String > ();
      Map < String, String > aeNameIDMap = new Map < String, String > ();
      List < Account > accounts = new List < Account > ();
      String accountNames = '';
      if (aeString != null) {
          aeNameIDPairs = aeString.replace('[', '').replace(']', '').split(', ');
          for (String s: aeNameIDPairs) {
              aeIDs.add(s.split(':::')[0]);
              aeNames.add(s.split(':::')[1]);
              aeNameIDMap.put(s.split(':::')[0], s);
              if (accountNames.length() > 0) {
                  accountNames += ',,,';
              }
          }
      }
      Map < String, string > accountNameMap = new Map < String, string > ();
      if (aeIDs.size() > 0) {
          List < Accountteammember > atmList = [Select Id, AccountID, Account.Name, Account.SAM_Designation__c, Account.Eclipse_Id__c, UserId, TeamMemberRole from Accountteammember where UserId IN: aeIDs
              AND(TeamMemberRole = 'Account Executive'
                  OR TeamMemberRole = 'Sales Manager')
          ];
          if (atmList != null && atmList.size() > 0) {

              //search for account list using aeIDs List
              for (Accountteammember atm: atmList) {
                  accountNameMap.put(String.valueOf(atm.AccountId) + String.valueOf(atm.UserId), atm.AccountId);
                  if (accountNames.length() > 0) {
                      accountNames += ',,,';
                  }
                  accountNames += atm.AccountId + '|||' + atm.Account.Name.replace('\'', '') + '|||' + (String) aeNameIDMap.get((String) atm.UserId) + '|||' + atm.Account.SAM_Designation__c + '|||' + atm.Account.Eclipse_Id__c + ';;;' + atm.Account.Name.replace('\'', '') + '|||' + atm.TeamMemberRole;
              }
          }
          for (Sales_Budget__c sb: [Select ID, Advertiser__c, Advertiser__r.Name, Budget_User__c, Budget_User__r.Name, Advertiser__r.Sam_Designation__c, Advertiser__r.Eclipse_id__c from
                  Sales_Budget__c where Budget_User__c IN: aeIDs AND Type__c = 'Data'
                  and Broadcast_Month_Date__c >= This_Year
              ]) {
              if (!accountNameMap.containsKey(String.valueOf(sb.Advertiser__c) + String.valueOf(sb.Budget_User__c))) {
                  String accName = sb.Advertiser__r.Name.replace('\\', ' ');
                  String teamRole = 'Account Executive';
                  System.debug('Checking SalesBudgetAccounts: ' + sb);
                  accountNameMap.put(String.valueOf(sb.Advertiser__c) + String.valueOf(sb.Budget_User__c), sb.Advertiser__c);
                  if (accountNames.length() > 0) {
                      accountNames += ',,,';
                  }
                  accountNames += sb.Advertiser__c + '|||' + accName + '|||' + (String) aeNameIDMap.get((String) sb.Budget_User__c) + '|||' + sb.Advertiser__r.Sam_Designation__c + '|||' + sb.Advertiser__r.Eclipse_Id__c + ';;;' + accName + '|||' + teamRole;
              }
          }
      }
      System.debug('Checking accountList: ' + aeIDs);
      return accountNames;
  }

  @RemoteAction
  public static String gethandleSimulateClick(String frLSM, String frAEs, String frAccounts, String frMonthYear, String toLSM, String toAEs) {

      Id uIdFrom = [SELECT Id from User where Name =: frLSM LIMIT 1][0].Id;
      Id uIdTo = [SELECT Id from User where Name =: toLSM LIMIT 1][0].Id;
      List < String > frAEList = getListFromString(frAEs, ',');
      List < String > frAccountList = getListFromString(frAccounts, ',');
      List < String > toAEList = getListFromString(toAEs, ',');
      // use above 5 IDs/Lists and frMonthYear to Simulate

      String retVal = 'Values passed were: frLSM="' + uIdFrom + '", frAEs="' + frAEs + '", frAccounts="' + frAccounts + '", frMonthYear="' + frMonthYear + '", toLSM="' + uIdTo + '", toAEs="' + toAEs + '"'; //, toAccounts="'+toAccounts+'", toMonthYear="'+toMonthYear+'"';

      return retVal;

  }

  private static List < String > getListFromString(String str, String delim) {
      return str.split(delim);
  }


  @RemoteAction
  public static String atmDupeCheck(String accSimRecords, String atsID) {
      String retVal = '';
      System.Debug('accSimRecords: ' + accSimRecords);

      //'accSimRecords' String format:   fromUserId ;;; fromAccId ;;; fromUserMonthYear ;;; toUserId ;;; uiRowNum ||| (repeat)
      List < String > mappingList = accSimRecords.split('\\|\\|\\|');
      List < String > mappingListNoUI = new List < String > ();
      Map < String, String > mappingMap = new Map < String, String > ();
      Map < String, String > mappingMapRev = new Map < String, String > ();
      for (String s: mappingList) {
          mappingMap.put(s.split(';;;')[4], s.split(';;;')[0] + ';;;' + s.split(';;;')[1] + ';;;' + s.split(';;;')[2] + ';;;' + s.split(';;;')[3]);
          mappingMapRev.put(s.split(';;;')[0] + ';;;' + s.split(';;;')[1] + ';;;' + s.split(';;;')[2] + ';;;' + s.split(';;;')[3], s.split(';;;')[4]);
      }
      for (Account_Transfer_Mapping__c atm: [select External_ID__c, Account_Transfer_Simulation__c, Account_Transfer_Simulation__r.Name from Account_Transfer_Mapping__c where External_ID__c IN: mappingMap.values()]) {
          if (atsID != atm.Account_Transfer_Simulation__c) {
              if (retVal != '') {
                  retVal += '|||';
              }
              retVal += mappingMapRev.get(atm.External_ID__c) + ';;;' + atm.Account_Transfer_Simulation__r.Name + ';;;' + atm.Account_Transfer_Simulation__c;
          }
      }
      //retVal = '1;;;ATS Name 1;;;id1|||3;;;ATS Name 2;;;id2'; //hardcoded test to appear for 2nd and 4th mapping

      return retVal;
  }

  //check CrossTeam
  @RemoteAction
  public static String checkCrossTeam(string fromUser, string toUser) {
      Map < String, Boolean > nationaluserMap = new Map < String, Boolean > ();
      List < String > toUserList = new List < String > ();
      List < String > fromUserList = new List < String > ();
      if (fromUser.indexOf(';') > 0)
          fromUserList = fromUser.split(';');
      if (toUser.indexOf(';') > 0)
          toUserList = toUser.split(';');

      List < User > userList = [Select ID, Budget_Type__c from User where(id in: toUserList OR id in: fromUserList)];
      for (User usr: userList) {
          //Check if user is National User
          nationaluserMap.put(usr.ID, usr.Budget_Type__c == 'National' ? true : false);
      }
      return JSON.serialize(nationalUserMap);
  }

  @RemoteAction
  public static String accTransferList(String accSimRecords, String toLSM, String pageEditId, string isAll, Boolean isNBUC, string nbucTransfer) {
      //'accSimRecords' i.e.  simulate|||fromUserId1;;;fromAccId1;;;2018Jan;;;toUserId1|||fromUserId2;;;fromAccId2;;;fromUserMonthYear2;;;toUserId2|||...
      Account_Transfer_Tool__c att = new Account_Transfer_Tool__c();
      List < Account_Transfer_Mapping__c > atmList = new List < Account_Transfer_Mapping__c > ();
      List < Account_Transfer_Mapping__c > atmPriorList = new List < Account_Transfer_Mapping__c > ();
      List < String > mapString = new List < String > ();
      string ncc = '';
      String atsID;
      User lsmId;
      USer lsmToId;
      System.debug('accSimRecords ' + accSimRecords);
      String effectiveDateString;
      String yearString;
      String monthString;
      Date effectiveDate;
      Map < String, Integer > mapDate = new Map < String, Integer > ();
      Map < String, String > divisionMap = new Map < String, String > ();
      //Map<String,String> regionMap = new Map<String, String>();
      //List <SDOF_Assignment__mdt> sdofLS = [Select Region__c, SDOF_ID__c from SDOF_Assignment__mdt];
      List < SDOF_Division__mdt > sdofLS = [Select Divisoin__c, SDOF_ID__c from SDOF_Division__mdt];
      Map < String, String > localRegionMap = new Map < String, String > ();
      List < Local_Region_RVP__mdt > localRVPLS = [Select Region__c, Local_Region_RVP__c from Local_Region_RVP__mdt];
      String frmLSM, toLSMSel = '';
      mapDate.put('Jan', 01);
      mapDate.put('Feb', 02);
      mapDate.put('Mar', 03);
      mapDate.put('Apr', 04);
      mapDate.put('May', 05);
      mapDate.put('Jun', 06);
      mapDate.put('Jul', 07);
      mapDate.put('Aug', 08);
      mapDate.put('Sep', 09);
      mapDate.put('Oct', 10);
      mapDate.put('Nov', 11);
      mapDate.put('Dec', 12);

      if (accSimRecords != null && accSimRecords != '' && accSimRecords.split(';;;').size() > 1) {
          effectiveDateString = accSimRecords.split(';;;')[2];
          yearString = effectiveDateString.substring(0, 4);
          monthString = effectiveDateString.substring(4, 7);
          effectiveDate = Date.valueOf(yearString + '-' + mapDate.get(monthString) + '-' + '15');
      }


      System.debug('Date: ' + effectiveDateString);
      System.debug('Date Year: ' + yearString);
      System.debug('Date Month: ' + monthString);
      System.debug('Date: ' + effectiveDate);
      if (accSimRecords != null && accSimRecords != '') {
          for (String s: accSimRecords.split('\\|\\|\\|')) {
              mapString.add(s);
          }
          if (accSimRecords.indexOf('>>>>') > 0)
              ncc = accSimRecords.substringBetween('>>>>', '|||');
          if (accSimRecords.indexOf('_') > 0) {
              frmLSM = accSimRecords.split('_')[1];
              toLSMSel = accSimRecords.split('_')[2];
              toLSMSel = accSimRecords.indexOf('>>>>') > 0 ? toLSMSel.substring(0, toLSMSel.indexOf('>>>>')) : toLSMSel.substring(0, toLSMSel.indexOf('|||'));
          }
      }

      System.debug('List of Mappings' + mapString);
      if (mapString != null & mapString.size() > 1) {
          System.debug('From User ID: ' + mapString[1].split(';;;')[0]);
      } else {
          return null;
      }
      //for(SDOF_Assignment__mdt sdof : sdofLS){
      for (SDOF_Division__mdt sdof: sdofLS) {
          divisionMap.put(sdof.Divisoin__c, sdof.SDOF_ID__c);
      }
      for (Local_Region_RVP__mdt localRVP: localRVPLS) {
          localRegionMap.put(localRVP.Region__c, localRVP.Local_Region_RVP__c);
      }
      atsID = pageEditId;
      system.debug(mapString[1].split(';;;')[0] + ' To ' + toLSMSel);

      system.debug('frmLSM: ' + frmLSM);
      system.debug('toLSMSel: ' + toLSMSel);
      lsmId = [Select Id, HR_Manager__r.Region__c, HR_Manager__r.Division__c, Division__c from User where Name =: frmLSM Or ID =: frmLSM limit 1];
      lsmToId = [Select Id, Region__c, Division__c, HR_Manager__r.Region__c from User where Name =: toLSMSel OR ID =: toLSMSel limit 1];
      atmPriorList = [Select Id, From_User__c, To_User__c, External_ID__c, Account__c, Account__r.OwnerId, Account_Transfer_Simulation__c, Account_Transfer_Simulation__r.Id, Account_Transfer_Simulation__r.Status__c, Account_Transfer_Simulation__r.Transfer_Effective_Date__c from Account_Transfer_Mapping__c where Account_Transfer_Simulation__c =: pageEditId];

      System.Debug('atmPriorList: ' + atmPriorList);
      System.Debug('pageEditId: ' + pageEditId);


      if (pageEditId == null || pageEditId == '') {
          att.Transfer_Effective_Date__c = effectiveDate;
          accSimRecords = accSimRecords.length() > 32768 ? accSimRecords.substring(0, 32766) : accSimRecords;
          att.Raw_Transfer_String__c = accSimRecords;
          att.Region__c = lsmId.HR_Manager__r.Region__c;
          att.Division__c = lsmId.HR_Manager__r.Division__c;
          att.To_Region__c = lsmToId.Region__c;
          att.To_Division__c = lsmToId.Division__c;
          att.Transfer_All_Accounts__c = Boolean.valueOf(isAll);
          att.Transfer_NBUC__c = Boolean.valueOf(isNBUC);
          if (att.Transfer_NBUC__c)
              att.Transfer_NBUC_Select__c = nbucTransfer.replace('_', ' ');
          att.NCC__c = ncc;
          att.From_LSM__c = lsmId.Id;
          att.To_LSM__c = lsmToId.Id;
          //att.recordTypeID = null;


          /*if(regionMap.containsKey(lsmId.HR_Manager__r.Region__c)){
            att.SDOF__c = regionMap.get(lsmId.HR_Manager__r.Region__c);
          }*/
          if (divisionMap.containsKey(lsmId.HR_Manager__r.Division__c)) {
              att.SDOF__c = divisionMap.get(lsmId.HR_Manager__r.Division__c);
          } else {
              att.SDOF__c = divisionMap.get(lsmId.Division__c);
          }
          if (localRegionMap.containsKey(lsmToId.HR_Manager__r.Region__c)) {
              att.Local_Region_RVP__c = localRegionMap.get(lsmToId.HR_Manager__r.Region__c);
          }
          insert att;

          atsID = att.Id;
          for (String atmString: mapString) {
              System.Debug('atmString: ' + atmString);
              if (!atmString.contains('simulate') && !atmString.contains('transfer')) {
                  Account_Transfer_Mapping__c atm = new Account_Transfer_Mapping__c();
                  atm.Account_Transfer_Simulation__c = atsID;
                  atm.From_User__c = atmString.split(';;;')[0];
                  atm.To_User__c = atmString.split(';;;')[3];
                  atm.External_ID__c = atmString;
                  atm.Account__c = atmString.split(';;;')[1];
                  atmList.add(atm);
              }
          }
          Savepoint spATMInsert = Database.setSavepoint();
          try {
              insert atmList;
          } catch (Exception e) {
              Database.rollback(spATMInsert);
              System.debug('Error from Inserting Account Transfer Mapping: ' + e);
          }
      }
      System.Debug('atsID: ' + atsID);
      if (atmPriorList.size() != 0) {
          try {
              att = new Account_Transfer_Tool__c();
              att.Transfer_Effective_Date__c = effectiveDate;
              att.Id = atmPriorList[0].Account_Transfer_Simulation__r.Id;
              //if(regionMap.containsKey(lsmId.HR_Manager__r.Region__c)){
              //att.SDOF__c = regionMap.get(lsmId.HR_Manager__r.Region__c);
              //}
              if (divisionMap.containsKey(lsmId.HR_Manager__r.Division__c)) {
                  att.SDOF__c = divisionMap.get(lsmId.HR_Manager__r.Division__c);
              }
              if (localRegionMap.containsKey(lsmToId.HR_Manager__r.Region__c)) {
                  att.Local_Region_RVP__c = localRegionMap.get(lsmToId.HR_Manager__r.Region__c);
              }
              update att;
          } catch (Exception ex) {
              Log4SF.logMessage('AccountTransferController', 'accTransferList', ex.getMessage(), null, UserInfo.getUserId(), null, '');
          }

      }
      return atsID;
  }


  @RemoteAction
  public static string analysisResult(String frmUser, String frmAcc, String toUser, String monthYear, String frmAccountToUser, string attID) {

      System.debug('frmAccountToUser: ' + frmAccountToUser);
      try {
          List < String > frmUserList = frmUser.split(',');
          List < String > frmAccList = frmAcc.split(',');
          List < String > toUserList = toUser.split(',');
          boolean nationalUser = false;
          List < String > frmAccountToUserList = frmAccountToUser.split('\\|\\|\\|');
          Map < String, String > toUserIdNameMap = new Map < String, String > ();
          Map < String, String > fromUserIdNameMap = new Map < String, String > ();
          Map < String, String > fromAccountToUserIdMap = new Map < String, String > ();
          Map < String, List < String >> toUserIdFromAccountMap = new Map < String, List < String >> ();

          List < String > monthMap = new List < String > ();
          monthMap.add('jan');
          monthMap.add('feb');
          monthMap.add('mar');
          monthMap.add('apr');
          monthMap.add('may');
          monthMap.add('jun');
          monthMap.add('jul');
          monthMap.add('aug');
          monthMap.add('sep');
          monthMap.add('oct');
          monthMap.add('nov');
          monthMap.add('dec');

          for (String s: frmAccountToUserList) {
              String fromAccIdTemp = s.split(';;;')[0];
              String toUserIdTemp = s.split(';;;')[1];
              String toUserNameTemp = s.split(';;;')[2];
              if (!toUserIdNameMap.containsKey(toUserIdTemp)) {
                  toUserIdNameMap.put(toUserIdTemp, toUserNameTemp);
                  toUserIdFromAccountMap.put(toUserIdTemp, new List < String > ());
              }
              List < String > ltemp = toUserIdFromAccountMap.get(toUserIdTemp);
              ltemp.add(fromAccIdTemp);
              toUserIdFromAccountMap.put(toUserIdTemp, ltemp);
              fromAccountToUserIdMap.put(fromAccIdTemp, toUserIdTemp);
          }


          for (User u: [Select Id, Name FROM User where Id IN: frmUserList]) {
              fromUserIdNameMap.put((String) u.Id, u.Name);
          }

          Map < String, String > tempMapAcc = New Map < String, String > ();
          List < Decimal > monthfrmNumbers = new List < Decimal > ();
          List < userBudget > ub = new List < userBudget > ();
          Map < Id, userBudget > ubFromMap = new Map < Id, userBudget > ();
          Map < Id, userBudget > ubToMap = new Map < Id, userBudget > ();
          //Code changes - For budgets
          Map < Id, Map < String, userBudget >> ubfromTypeMap = new Map < Id, Map < String, userBudget >> ();
          Map < Id, Map < String, userBudget >> ubToTypeMap = new Map < Id, Map < String, userBudget >> ();


          for (Integer i = 0; i < 12; i++) {
              monthfrmNumbers.add(0);
          }
          /*
          Get the Budget Lines for all the users
          */
          Boolean isNBUCTransfer = false;
          List < Account_Transfer_Tool__c > attList = [Select ID, Transfer_All_Accounts__c, Transfer_NBUC__c, Transfer_NBUC_Select__c from Account_Transfer_Tool__c where ID =: attID];
          if (attList.size() > 0) {
              if (attList[0].Transfer_All_Accounts__c || (attList[0].Transfer_NBUC__c && attList[0].Transfer_NBUC_Select__c == 'Transfer All NBUC')) {
                  isNBUCTransfer = true;
              }
          }

          Set < String > budgetLines = new Set < String > ();
          Map < String, Boolean > nationaluserMap = new Map < String, Boolean > ();
          List < User > userList = [Select ID, Budget_Product_Lines__c, Budget_Type__c from User where(id in: toUserList OR id in: frmUserList) order by Name desc];
          System.debug(userList);
          for (User usr: userList) {
              //Check if user is National User
              if (!nationalUser)
                  nationalUser = usr.Budget_Type__c == 'National' ? true : false;
              if (String.isNotEmpty(usr.Budget_Product_Lines__c)) {
                  for (string str: usr.Budget_Product_Lines__c.split(';')) {
                      budgetLines.add(str);
                  }
              }
              nationaluserMap.put(usr.Id, usr.Budget_Type__c == 'National' ? true : false);
          }
          Map < String, Decimal > prdOrderMap = new Map < String, Decimal > ();
          List < Product_Line_Order__mdt > prdOrderList = [Select MasterLabel, DeveloperName, Order__c from Product_Line_Order__mdt order by Order__c asc];
          for (Product_Line_Order__mdt pd: prdOrderList) {
              if (pd.DeveloperName.indexOf('/') > 0)
                  pd.DeveloperName = pd.MasterLabel.replace('/', '_');
              if (pd.MasterLabel.indexOf(' ') > 0)
                  pd.MasterLabel = pd.MasterLabel.replace(' ', '_');
              prdOrderMap.put(pd.MasterLabel, pd.Order__c);
          }
          //List<User> userList = [Select ID, Budget_Product_Lines__c, Budget_Type__c from User where (id in : toUserList OR id in: frmUserList)];
          System.debug(userList);
          for (User usr: userList) {
              //Check if user is National User
              Boolean userExistsInMap = ubfromTypeMap.containsKey(usr.Id);
              if (!userExistsInMap) {
                  userBudget ubTemp = new userBudget();

                  ubTemp.userId = usr.Id;
                  if (fromUserIdNameMap.containsKey(usr.Id))
                      ubTemp.userName = fromUserIdNameMap.get(usr.Id);
                  else
                      ubTemp.userName = toUserIdNameMap.get(usr.Id);
                  ubTemp.amountType = 'Pending & Forecast';
                  ubfromTypeMap.put(usr.Id, new Map < String, userBudget > {
                      ubtemp.amountType => ubTemp
                  });
                  /*
                  ubTemp = new userBudget();
                  ubTemp.userId = usr.Id;
                  if(fromUserIdNameMap.containsKey(usr.Id))
                      ubTemp.userName =fromUserIdNameMap.get(usr.Id);
                  else
                      ubTemp.userName =toUserIdNameMap.get(usr.Id);
                  ubTemp.amountType = 'Forecast';
                  //ubFromMap.put(usr.Id, ubTemp);
                  ubfromTypeMap.get(usr.Id).put(ubtemp.amountType, ubTemp);
                  */
                  ubTemp = new userBudget();
                  ubTemp.userId = usr.Id;
                  if (fromUserIdNameMap.containsKey(usr.Id))
                      ubTemp.userName = fromUserIdNameMap.get(usr.Id);
                  else
                      ubTemp.userName = toUserIdNameMap.get(usr.Id);
                  //ubTemp.userName = fromUserIdNameMap.get(usr.Id);
                  ubTemp.amountType = 'Revenue';
                  ubFromMap.put(usr.Id, ubTemp);
                  ubfromTypeMap.get(usr.Id).put(ubtemp.amountType, ubTemp);

                  ubTemp = new userBudget();
                  ubTemp.userId = usr.Id;
                  if (fromUserIdNameMap.containsKey(usr.Id))
                      ubTemp.userName = fromUserIdNameMap.get(usr.Id);
                  else
                      ubTemp.userName = toUserIdNameMap.get(usr.Id);
                  ubTemp.amountType = 'Budget';
                  ubfromTypeMap.get(usr.Id).put(ubtemp.amountType, ubTemp);

                  List < String > budgetLinesList = new List < String > ();
                  budgetLinesList.addAll(budgetLines);
                  if (budgetLinesList.size() > 0) {
                      List < String > strList = String.isNotEmpty(usr.Budget_Product_Lines__c) ? usr.Budget_Product_Lines__c.split(';') : budgetLinesList;
                      //nationalUser ? budgetLinesList :usr.Budget_Product_Lines__c.split(';')
                      for (integer i = strList.size() - 1; i >= 0; i--) {
                          //Unknown Churn
                          ubTemp = new userBudget();
                          ubTemp.userId = usr.id;
                          if (fromUserIdNameMap.containsKey(usr.Id))
                              ubTemp.userName = fromUserIdNameMap.get(usr.Id);
                          else
                              ubTemp.userName = toUserIdNameMap.get(usr.Id);
                          ubTemp.amountType = 'Unknown Churn';
                          ubTemp.productLine = strList[i];
                          ubfromTypeMap.get(usr.id).put(ubtemp.amountType + '-' + strList[i], ubTemp);
                      }
                      for (integer i = strList.size() - 1; i >= 0; i--) {
                          //New Business
                          ubTemp = new userBudget();
                          ubTemp.userId = usr.id;
                          if (fromUserIdNameMap.containsKey(usr.Id))
                              ubTemp.userName = fromUserIdNameMap.get(usr.Id);
                          else
                              ubTemp.userName = toUserIdNameMap.get(usr.Id);
                          ubTemp.amountType = 'New Business';
                          ubTemp.productLine = strList[i];
                          ubfromTypeMap.get(usr.id).put(ubtemp.amountType + '-' + strList[i], ubTemp);
                      }
                      /*
              for(string str: String.isNotEmpty(usr.Budget_Product_Lines__c) ? usr.Budget_Product_Lines__c.split(';'): budgetLinesList )
              {
                system.debug(usr.Budget_Product_Lines__c);
                system.debug(budgetLinesList);
                system.debug(prdOrderMap);
                system.debug(str);
                ubTemp = new userBudget();
                ubTemp.userId = usr.id;
                if(fromUserIdNameMap.containsKey(usr.Id))
                    ubTemp.userName =fromUserIdNameMap.get(usr.Id);
                 else
                    ubTemp.userName =toUserIdNameMap.get(usr.Id);
                ubTemp.amountType = 'New Business';
        ubTemp.productLine = str;
                ubfromTypeMap.get(usr.id).put(ubtemp.amountType + '-' +str, ubTemp);  

              }
              
              
              for(string str: String.isNotEmpty(usr.Budget_Product_Lines__c) ? usr.Budget_Product_Lines__c.split(';'): budgetLinesList )
              {
                ubTemp = new userBudget();
                ubTemp.userId = usr.id;
                if(fromUserIdNameMap.containsKey(usr.Id))
                    ubTemp.userName =fromUserIdNameMap.get(usr.Id);
                else
                    ubTemp.userName =toUserIdNameMap.get(usr.Id);
                ubTemp.amountType = 'Unknown Churn';
                ubTemp.productLine = str;
                ubfromTypeMap.get(usr.id).put(ubtemp.amountType + '-' + str, ubTemp);
              }
              */
                  }

              }
          }
          System.debug(ubfromTypeMap);
          Map < String, Integer > mapDate = new Map < String, Integer > ();
          mapDate.put('Jan', 01);
          mapDate.put('Feb', 02);
          mapDate.put('Mar', 03);
          mapDate.put('Apr', 04);
          mapDate.put('May', 05);
          mapDate.put('Jun', 06);
          mapDate.put('Jul', 07);
          mapDate.put('Aug', 08);
          mapDate.put('Sep', 09);
          mapDate.put('Oct', 10);
          mapDate.put('Nov', 11);
          mapDate.put('Dec', 12);
          String yearString = monthYear.substring(0, 4);
          String monthString = monthYear.substring(4, 7);
          Date effectiveDate = Date.valueOf(yearString + '-' + mapDate.get(monthString) + '-' + '15');

          //After aka "Requested Change"
          System.debug('agrListFrom');
          System.debug(frmAccList);
          System.debug(frmUserList);
          System.debug(toUserList);
          //System.debug(agrListFrom);

          //Before aka "Existing Total" Revenue

          List < AggregateResult > rAggListExistingTo = [Select SalesRevenue_AccountExecutive__c aeid, SalesRevenue_AccountExecutive__r.Name aename, sum(January_Revenue__c) jan, sum(February_Revenue__c) feb, sum(March_Revenue__c) mar, sum(April_Revenue__c) apr, sum(May_Revenue__c) may,
              sum(June_Revenue__c) jun, sum(July_Revenue__c) jul, sum(August_Revenue__c) aug, sum(September_Revenue__c) sep, sum(October_Revenue__c) oct, sum(November_Revenue__c) nov, sum(December_Revenue__c) dec, SalesRevenue_Advertiser__c adv from Sales_Revenue_Aggregate__c where(SalesRevenue_AccountExecutive__c IN: frmUserList OR SalesRevenue_AccountExecutive__c IN: toUserList) AND Broadcast_Year__c =: String.valueOf(effectiveDate.year()) Group By SalesRevenue_AccountExecutive__c, SalesRevenue_AccountExecutive__r.Name, SalesRevenue_Advertiser__c
          ];


          //Before aka "Existing Total" Budgets
          List < AggregateResult > bAggListExisting = [Select Account_Executive__c aeid, Account_Executive__r.Name aename, sum(January_Budget__c) jan, sum(February_Budget__c) feb, sum(March_Budget__c) mar, sum(April_Budget__c) apr, sum(May_Budget__c) may, sum(June_Budget__c) jun,
              sum(July_Budget__c) jul, sum(August_Budget__c) aug, sum(September_Budget__c) sep, sum(October_Budget__c) oct, sum(November_Budget__c) nov, sum(December_Budget__c) dec, SalesBudget_Advertiser__c adv from Sales_Budget_Aggregate__c where(Account_Executive__c IN: frmUserList OR Account_Executive__c IN: toUserList) AND Broadcast_Year__c =: String.valueOf(effectiveDate.year()) Group By Account_Executive__c, Account_Executive__r.Name, SalesBudget_Advertiser__c
          ];

          DateTime effectiveDateTime = effectiveDate;
          //Fetch New Business and Unknown Curn 
          AggregateResult[] newBusUnknownChurn = [Select Budget_User__c accEx, Sum(Amount__c) rAmt, CALENDAR_MONTH(Broadcast_Month_Date__c) bMonth, New_Business_Churn__c churn, Product_Line__c prdLine, Commodity__c cm, DMA__c dma from Sales_Budget__c
              where(New_Business_Churn__c = 'New Business'
                  OR New_Business_Churn__c = 'Unknown Churn') AND(Budget_User__c in: fromUserIdNameMap.keyset() or Budget_User__c in: toUserIdNameMap.keyset())
              AND CALENDAR_YEAR(Broadcast_Month_Date__c) =: effectiveDate.year() AND Amount__c != 0 AND Broadcast_Month_Date__c >=: effectiveDate AND type__c = 'DOS'
              group by CALENDAR_MONTH(Broadcast_Month_Date__c), Budget_User__c, New_Business_Churn__c, Product_Line__c, Commodity__c, DMA__c order by CALENDAR_MONTH(Broadcast_Month_Date__c)
          ];
          //AND CALENDAR_YEAR(Broadcast_Month_Date__c) =: CALENDAR_YEAR(effectiveDateTime)
          system.debug(' newBusUnknownChurn ' + newBusUnknownChurn);
          AggregateResult[] newBusChurnSimulated = [Select Budget_User__c accEx, From_Budget_user__c frmUser, Sum(Amount__c) rAmt, CALENDAR_MONTH(Broadcast_Month_Date__c) bMonth, New_Business_Churn__c churn, Product_Line__c prdLine,
              Commodity__c cm, DMA__c dma, Old_Product_Line__c oldPrdLine from Sales_Budget_Simulation__c
              where(New_Business_Churn__c = 'New Business'
                  OR New_Business_Churn__c = 'Unknown Churn') and Account_Transfer_Simulation__c =: attID AND type__c = 'Simulation'
              AND CALENDAR_YEAR(Broadcast_Month_Date__c) =: effectiveDate.year()
              group by CALENDAR_MONTH(Broadcast_Month_Date__c), Budget_User__c, From_Budget_user__c, New_Business_Churn__c, Product_Line__c, Commodity__c, DMA__c, Old_Product_Line__c order by CALENDAR_MONTH(Broadcast_Month_Date__c)
          ];
          //TODO: DMA Splits will happen at the time of Transfer.
          if (newBusUnknownChurn.size() > 0) {
              List < UserBudget > frCast = new List < UserBudget > ();
              for (AggregateResult agr: newBusUnknownChurn) {
                  userBudget ubTemp;
                  Decimal amnt = 0;
                  //userBudget ubInAmntTemp;   
                  String nbChurn = (String) agr.get('churn');
                  String prdLine = (String) agr.get('prdLine');
                  String cmPrd = (String) agr.get('cm');
                  Id aeId = (Id) agr.get('accEx');
                  Boolean userExistsInMap = ubfromTypeMap.containsKey(aeId);
                  system.debug(' userExistsInMap ' + userExistsInMap + ubfromTypeMap.get(aeId).containsKey(nbChurn + '-' + prdLine));

                  if (userExistsInMap && ubfromTypeMap.get(aeId).containsKey(nbChurn + '-' + prdLine)) {
                      ubTemp = ubfromTypeMap.get(aeId).get(nbChurn + '-' + prdLine);
                  } else {
                      ubTemp = new userBudget();
                      ubTemp.amountType = nbChurn;
                      ubTemp.userId = aeId;
                      ubTemp.productLine = prdLine;
                      if (fromUserIdNameMap.containsKey((Id) agr.get('accEx')))
                          ubTemp.userName = fromUserIdNameMap.get((Id) agr.get('accEx'));
                      else
                          ubTemp.userName = toUserIdNameMap.get((Id) agr.get('accEx'));
                      if (userExistsInMap)
                          ubfromTypeMap.get(aeId).put(ubtemp.amountType + '-' + prdLine, ubTemp);
                      else
                          ubfromTypeMap.put(aeId, new Map < String, userBudget > {
                              ubtemp.amountType + '-' + prdLine => ubTemp
                          });
                  }

                  decimal nbucAmnt = agr.get('rAmt') == null ? 0 : (Decimal) agr.get('rAmt');
                  //if(nbChurn == 'Unknown Churn')
                  //nbucAmnt = math.abs(nbucAmnt);
                  system.debug('ubTemp ' + ubfromTypeMap.get(aeId));
                  ubTemp.productLine = prdLine;
                  system.debug('agr ' + agr);
                  //Calculate contributions of each 
                  ubTemp.existingList[((Integer) agr.get('bMonth')) - 1] += nbucAmnt;
                  ubTemp.isNational = false;
                  if (!ubTemp.commodityDetails.containsKey((Integer) agr.get('bMonth'))) {
                      Map < String, Decimal > mapMonthAmnt = new Map < String, Decimal > ();
                      mapMonthAmnt.put(cmPrd + '#' + String.valueOf(nbucAmnt), 100);
                      ubTemp.commodityDetails.put((Integer) agr.get('bMonth'), mapMonthAmnt);

                  } else {
                      //system.debug(cmPrd+ prdLine + ubTemp.existingList[((Integer)agr.get('bMonth'))-1]);
                      Map < String, Decimal > mapMonthAmnt = new Map < String, Decimal > ();
                      mapMonthAmnt = ubTemp.commodityDetails.get((Integer) agr.get('bMonth'));
                      Decimal actAmount = 0;
                      Boolean comExists = false;
                      system.debug('mapMonthAmnt ' + mapMonthAmnt);
                      for (String str: mapMonthAmnt.keySet()) {
                          if (cmPrd == str.split('#')[0]) {
                              mapMonthAmnt.remove(str);
                              comExists = true;
                              actAmount += Decimal.valueOf(str.split('#')[1]) + nbucAmnt;
                              str = str.split('#')[0] + '#' + String.valueof(actAmount);
                          }
                          system.debug('str1 ' + str);
                          system.debug('str ' + str + (Integer) agr.get('bMonth') + str.split('#')[1]);
                          if (ubTemp.existingList[((Integer) agr.get('bMonth')) - 1] != 0) {
                              mapMonthAmnt.put(str, (Decimal.valueOf(str.split('#')[1]) / ubTemp.existingList[((Integer) agr.get('bMonth')) - 1]) * 100);
                          } else {
                              mapMonthAmnt.put(str, 0.00);
                          }
                      }
                      if (!comExists) {
                          if (ubTemp.existingList[((Integer) agr.get('bMonth')) - 1] != 0) {
                              mapMonthAmnt.put(cmPrd + '#' + String.valueOf(nbucAmnt), (nbucAmnt / ubTemp.existingList[((Integer) agr.get('bMonth')) - 1]) * 100);
                          } else {
                              mapMonthAmnt.put(cmPrd + '#' + String.valueOf(nbucAmnt), 0);
                          }
                      }
                      ubTemp.commodityDetails.put((Integer) agr.get('bMonth'), mapMonthAmnt);
                  }
                  if (agr.get('dma') != null) {
                      string dma = (String) agr.get('dma');
                      //ubTemp.isNational = true;
                      system.debug('inside DMA ');

                      if (!ubTemp.dmaDetails.containsKey((Integer) agr.get('bMonth'))) {
                          Map < String, Decimal > mapMonthAmnt = new Map < String, Decimal > ();
                          mapMonthAmnt.put(dma + '_' + cmPrd + '#' + String.valueOf(nbucAmnt), 100);
                          ubTemp.dmaDetails.put((Integer) agr.get('bMonth'), mapMonthAmnt);

                      } else {
                          //system.debug(cmPrd+ prdLine + ubTemp.existingList[((Integer)agr.get('bMonth'))#1]);
                          Map < String, Decimal > mapMonthAmnt = new Map < String, Decimal > ();
                          mapMonthAmnt = ubTemp.dmaDetails.get((Integer) agr.get('bMonth'));
                          Decimal actAmount = 0;
                          Boolean dmaExists = false;
                          for (String str: mapMonthAmnt.keySet()) {
                              if (dma + '_' + cmPrd == str.split('#')[0]) {
                                  mapMonthAmnt.remove(str);
                                  dmaExists = true;
                                  actAmount += Decimal.valueOf(str.split('#')[1]) + nbucAmnt;
                                  str = str.split('#')[0] + '#' + String.valueof(actAmount);

                              }
                              if (ubTemp.existingList[((Integer) agr.get('bMonth')) - 1] != 0) {
                                  mapMonthAmnt.put(str, (Decimal.valueOf(str.split('#')[1]) / ubTemp.existingList[((Integer) agr.get('bMonth')) - 1]) * 100);
                              } else {
                                  mapMonthAmnt.put(str, 0.00);
                              }
                          }
                          if (!dmaExists) {
                              if (ubTemp.existingList[((Integer) agr.get('bMonth')) - 1] != 0) {
                                  mapMonthAmnt.put(dma + '_' + cmPrd + '#' + String.valueOf(nbucAmnt), (nbucAmnt / ubTemp.existingList[((Integer) agr.get('bMonth')) - 1]) * 100);
                              } else {
                                  mapMonthAmnt.put(dma + '_' + cmPrd + '#' + String.valueOf(nbucAmnt), 0);
                              }
                          }

                          ubTemp.dmaDetails.put((Integer) agr.get('bMonth'), mapMonthAmnt);

                      }
                      system.debug('inside DMA ' + ubtemp);
                  } else {
                      Log4SF.logMessage('AccountTransferController', 'analysisResult', 'No DMA found for the User ' + ubTemp.userName, null, UserInfo.getUserId(), null, '');
                      ubfromTypeMap = null;
                      break;
                  }

                  ubFromMap.put(aeId, ubTemp);
                  ubfromTypeMap.get(aeId).put(ubtemp.amountType + '-' + prdLine, ubTemp);
                  system.debug('ubfromTypeMap in NBUC ' + ubfromTypeMap.get(aeId).get(ubtemp.amountType + '-' + prdLine));
                  //Add the changed amount to Budgets too - 
                  UserBudget ubBud = new UserBudget();
                  UserBudget ubBudOut = new UserBudget();
                  Boolean budgetExists = false;
                  if (ubfromTypeMap.get(aeId).containsKey('Budget')) {
                      ubBud = ubfromTypeMap.get(aeId).get('Budget');
                      ubBud.existingList[((Integer) agr.get('bMonth')) - 1] += nbucAmnt;
                      system.debug('ubBud added in NBUC ' + ubBud);
                  }
                  if (isNBUCTransfer && ubfromTypeMap.get(aeId).containsKey('Budget') && fromUserIdNameMap.containsKey(aeID)) {
                      ubBud = ubfromTypeMap.get(aeId).get('Budget');
                      ubBud.outList[((Integer) agr.get('bMonth')) - 1] += nbucAmnt;
                      for (ID usrID: toUserIdNameMap.keySet()) {
                          if (toUserIdNameMap.containsKey(usrId)) {
                              ubBudOut = ubfromTypeMap.get(usrId).get('Budget');
                              ubBudOut.inList[((Integer) agr.get('bMonth')) - 1] += nbucAmnt;
                              ubfromTypeMap.get(usrID).put('Budget', ubBudOut);
                          }
                      }
                  }

                  /*
                  if(budgetExists)
                  {
                    ubBud = ubfromTypeMap.get(aeId).get('Budget');
                    ubBud.existingList[((Integer)agr.get('bMonth'))-1] += nbucAmnt; 
                    
                  }
                  else
                  {
                    ubBud =  (UserBudget)JSON.deserialize(JSON.serialize(ubTemp), UserBudget.class);
                    ubBud.existingList[((Integer)agr.get('bMonth'))-1] += nbucAmnt;
                    system.debug('ubBud added in NBUC ' +  ubBud);
                    ubBud.amountType = 'Budget';
                  }
                  */
                  //system.debug('ubud '+ubBud);

                  //  ubTemp.inList[((Integer)agr.get('bMonth'))-1] += agr.get('rAmt') == null ? 0 : (Decimal)agr.get('rAmt');
                  ubfromTypeMap.get(aeId).put('Budget', ubBud);

                  system.debug('ubfromTypeMap ' + ubfromTypeMap.get(aeId).keySet());
                  //New Business and Churn Movement added to Budgets.
              }
          }
          //End



          //Simulated New Business and Unknown Churn data
          if (newBusChurnSimulated.size() > 0) {
              List < UserBudget > frCast = new List < UserBudget > ();
              for (AggregateResult agr: newBusChurnSimulated) {
                  userBudget ubTemp;
                  userBudget ubInAmntTemp;
                  String nbChurn = (String) agr.get('churn');
                  Id aeId = (Id) agr.get('accEx');
                  Id fromAEID = (Id) agr.get('frmUser');
                  Boolean userExistsInMap = ubfromTypeMap.containsKey(aeId);
                  decimal nbucAmnt = agr.get('rAmt') == null ? 0 : (Decimal) agr.get('rAmt');
                  String prdLine = (String) agr.get('prdLine');
                  String oldPrdLine = agr.get('oldPrdLine') != null ? (String) agr.get('oldPrdLine') : prdLine;

                  String cmPrd = (String) agr.get('cm');
                  system.debug('agr in NBUC ' + agr);
                  if (userExistsInMap && ubfromTypeMap.get(aeId).containsKey(nbChurn + '-' + prdLine)) {
                      system.debug('ubTemp1 ' + ubfromTypeMap.get(aeId).get(nbChurn + '-' + prdLine));
                      ubTemp = ubfromTypeMap.get(aeId).get(nbChurn + '-' + prdLine);
                  } else {
                      ubTemp = new userBudget();
                      ubTemp.amountType = nbChurn;
                      ubTemp.userId = aeId;
                      ubTemp.productLine = prdLine;
                      if (fromUserIdNameMap.containsKey((Id) agr.get('accEx')))
                          ubTemp.userName = fromUserIdNameMap.get((Id) agr.get('accEx'));
                      else
                          ubTemp.userName = toUserIdNameMap.get((Id) agr.get('accEx'));
                      if (userExistsInMap)
                          ubfromTypeMap.get(aeId).put(ubtemp.amountType + '-' + prdLine, ubTemp);
                      else
                          ubfromTypeMap.put(aeId, new Map < String, userBudget > {
                              ubtemp.amountType + '-' + prdLine => ubTemp
                          });
                      system.debug('ubTemp2 ' + ubfromTypeMap.get(aeId));
                  }
                  system.debug('ubTemp ' + ubfromTypeMap.get(aeId).keySet());
                  ubTemp.productLine = prdLine;
                  ubTemp.fromUser = fromAEID;
                  if (ubfromTypeMap.containsKey(fromAEID) && ubfromTypeMap.get(fromAEID).containsKey(nbChurn + '-' + oldPrdLine)) {
                      ubInAmntTemp = ubfromTypeMap.get(fromAEID).get(nbChurn + '-' + oldPrdLine);
                  } else {
                      ubInAmntTemp = new userBudget();
                      ubInAmntTemp.amountType = nbChurn;
                      ubInAmntTemp.userId = fromAEID;
                      ubInAmntTemp.productLine = oldPrdLine;
                      if (fromUserIdNameMap.containsKey(fromAEID))
                          ubInAmntTemp.userName = fromUserIdNameMap.get(fromAEID);
                      else
                          ubInAmntTemp.userName = toUserIdNameMap.get(fromAEID);
                      if (ubfromTypeMap.containsKey(fromAEID))
                          ubfromTypeMap.get(fromAEID).put(ubInAmntTemp.amountType + '-' + oldPrdLine, ubTemp);
                      else
                          ubfromTypeMap.put(fromAEID, new Map < String, userBudget > {
                              ubInAmntTemp.amountType + '-' + oldPrdLine => ubInAmntTemp
                          });
                  }
                  ubInAmntTemp.fromUser = aeId;
                  ubInAmntTemp.outList[((Integer) agr.get('bMonth')) - 1] += nbucAmnt;
                  ubTemp.inList[((Integer) agr.get('bMonth')) - 1] += nbucAmnt;
                  ubFromMap.put(aeId, ubTemp);
                  ubfromTypeMap.get(fromAEID).put(ubInAmntTemp.amountType + '-' + oldPrdLine, ubInAmntTemp);
                  system.debug('fromAEID ' + ubfromTypeMap.get(fromAEID).get(ubInAmntTemp.amountType + '-' + oldPrdLine));

                  ubfromTypeMap.get(aeId).put(ubtemp.amountType + '-' + prdLine, ubTemp);
                  system.debug('aeId ' + ubfromTypeMap.get(aeId).get(ubtemp.amountType + '-' + prdLine));
                  //Add the changed amount to Budgets too - 
                  UserBudget ubBud = new UserBudget();
                  Boolean budgetExists = false;
                  if (ubfromTypeMap.get(aeId).containsKey('Budget')) {
                      ubBud = ubfromTypeMap.get(aeId).get('Budget');
                      ubBud.inList[((Integer) agr.get('bMonth')) - 1] += nbucAmnt;
                      system.debug('ubBud added in NBUC ' + ubBud);
                  }
                  //if(nbChurn == 'Unknown Churn')
                  //  ubTemp.inList[((Integer)agr.get('bMonth'))-1] += agr.get('rAmt') == null ? 0 : nbucAmnt;
                  ubfromTypeMap.get(aeId).put(ubBud.amountType, ubBud);
                  UserBudget ubBudOut = new UserBudget();
                  if (ubfromTypeMap.get(fromAEID).containsKey('Budget')) {
                      ubBudOut = ubfromTypeMap.get(fromAEID).get('Budget');
                      ubBudOut.outList[((Integer) agr.get('bMonth')) - 1] += nbucAmnt;
                      system.debug('ubBud added in NBUC ' + ubBudOut);
                  }
                  ubfromTypeMap.get(fromAEID).put(ubBudOut.amountType, ubBudOut);
                  system.debug('aeID ' + ubfromTypeMap.get(aeId).keySet());
                  system.debug('fromAEID ' + ubfromTypeMap.get(fromAEID).keySet());
                  //New Business and Churn Movement added to Budgets.
              }
          }


          // Simulated data end
          //Revenue Aggregation
          for (AggregateResult agr: rAggListExistingTo) {
              System.debug('agr Revenue ' + agr);
              try {
                  userBudget ubTemp;
                  userBudget ubInAmntTemp;
                  Id aeId = (Id) agr.get('aeid');
                  Boolean userExistsInMap = ubfromTypeMap.containsKey(aeId);
                  if (userExistsInMap) {
                      if (ubfromTypeMap.get(aeId).containsKey('Revenue'))
                          ubTemp = ubfromTypeMap.get(aeId).get('Revenue');
                  } else {
                      ubTemp = new userBudget();
                      ubTemp.amountType = 'Revenue';
                      ubTemp.userId = aeId;
                      ubTemp.userName = (String) agr.get('aename');
                      ubfromTypeMap.put(aeId, new Map < String, userBudget > {
                          ubtemp.amountType => ubTemp
                      });
                  }
                  System.debug(fromAccountToUserIdMap.get((String) agr.get('adv')));
                  boolean outAcc = fromAccountToUserIdMap.containsKey((String) agr.get('adv'));
                  boolean outUser = ubfromTypeMap.containsKey(fromAccountToUserIdMap.get((String) agr.get('adv')));
                  system.debug('outAcc outUser' + outAcc + '  ' + outUser);
                  if (outAcc) {
                      if (outUser) {
                          if (ubfromTypeMap.get(fromAccountToUserIdMap.get((String) agr.get('adv'))).containsKey('Revenue'))
                              ubInAmntTemp = ubfromTypeMap.get(fromAccountToUserIdMap.get((String) agr.get('adv'))).get('Revenue');
                      } else {
                          ubInAmntTemp = new userBudget();
                          ubInAmntTemp.amountType = 'Revenue';
                          ubInAmntTemp.userId = fromAccountToUserIdMap.get((String) agr.get('adv'));
                          ubInAmntTemp.userName = toUserIdNameMap.get(fromAccountToUserIdMap.get((String) agr.get('adv')));
                          ubfromTypeMap.put(aeId, new Map < String, userBudget > {
                              ubtemp.amountType => ubInAmntTemp
                          });
                      }

                  }
                  for (Integer i = effectiveDate.month() - 1; i < 12; i++) {
                      ubTemp.existingList[i] += agr.get(monthMap[i]) == null ? 0 : (Decimal) agr.get(monthMap[i]);
                      if (outAcc) {
                          ubTemp.outList[i] += agr.get(monthMap[i]) == null ? 0 : (Decimal) agr.get(monthMap[i]);
                          ubInAmntTemp.inList[i] += agr.get(monthMap[i]) == null ? 0 : (Decimal) agr.get(monthMap[i]);
                      }
                  }
                  system.debug('ubInAmntTemp ' + ubInAmntTemp);
                  ubFromMap.put(aeId, ubTemp);
                  ubfromTypeMap.get(aeId).put(ubtemp.amountType, ubTemp);
                  if (outAcc)
                      ubfromTypeMap.get(ubInAmntTemp.userId).put(ubInAmntTemp.amountType, ubInAmntTemp);
              } catch (Exception ex) {
                  Log4SF.logMessage('AccountTransferToolController', 'AnalysisResult - RevenueAGg', ex.getMessage(), ex, UserInfo.getUserId(), attID, '');
              }
          }
          //End - Revenue
          //User Budget
          for (AggregateResult agr: bAggListExisting) {
              try {
                  System.debug('agr budget ' + agr);
                  userBudget ubTemp;
                  userBudget ubInAmntTemp;
                  Id aeId = (Id) agr.get('aeid');
                  Boolean userExistsInMap = ubfromTypeMap.containsKey(aeId);
                  if (userExistsInMap) {
                      system.debug('ubfromTypeMap in Budget ' + ubfromTypeMap.get(aeId));
                      if (ubfromTypeMap.get(aeId).containsKey('Budget'))
                          ubTemp = ubfromTypeMap.get(aeId).get('Budget');
                      system.debug('ubTemp in Budget ' + ubTemp);
                  } else {
                      ubTemp = new userBudget();
                      ubTemp.amountType = 'Budget';
                      ubTemp.userId = aeId;
                      ubTemp.userName = (String) agr.get('aename');
                      ubfromTypeMap.put(aeId, new Map < String, userBudget > {
                          ubtemp.amountType => ubTemp
                      });
                  }
                  System.debug(fromAccountToUserIdMap.get((String) agr.get('adv')));
                  boolean outAcc = fromAccountToUserIdMap.containsKey((String) agr.get('adv'));
                  boolean outUser = ubfromTypeMap.containsKey(fromAccountToUserIdMap.get((String) agr.get('adv')));
                  system.debug('outAcc outUser' + outAcc + '  ' + outUser);
                  if (outAcc) {
                      if (outUser) {
                          if (ubfromTypeMap.get(fromAccountToUserIdMap.get((String) agr.get('adv'))).containsKey('Budget'))
                              ubInAmntTemp = ubfromTypeMap.get(fromAccountToUserIdMap.get((String) agr.get('adv'))).get('Budget');
                      } else {ubInAmntTemp = new userBudget();  ubInAmntTemp.amountType = 'Budget';
                          ubInAmntTemp.userId = fromAccountToUserIdMap.get((String) agr.get('adv'));
                          ubInAmntTemp.userName = toUserIdNameMap.get(fromAccountToUserIdMap.get((String) agr.get('adv')));
                          ubfromTypeMap.put(aeId, new Map < String, userBudget > {
                              ubtemp.amountType => ubInAmntTemp
                          });
                      }

                  }
                  for (Integer i = effectiveDate.month() - 1; i < 12; i++) {
                      ubTemp.existingList[i] += agr.get(monthMap[i]) == null ? 0 : (Decimal) agr.get(monthMap[i]);
                      if (outAcc) {
                          ubTemp.outList[i] += agr.get(monthMap[i]) == null ? 0 : (Decimal) agr.get(monthMap[i]);
                          ubInAmntTemp.inList[i] += agr.get(monthMap[i]) == null ? 0 : (Decimal) agr.get(monthMap[i]);
                      }
                  }
                  system.debug('ubInAmntTemp ' + ubInAmntTemp);
                  ubFromMap.put(aeId, ubTemp);
                  ubfromTypeMap.get(aeId).put(ubtemp.amountType, ubTemp);
                  if (outAcc)
                      ubfromTypeMap.get(ubInAmntTemp.userId).put(ubInAmntTemp.amountType, ubInAmntTemp);
              } catch (Exception ex) {
                  Log4SF.logMessage('AccountTransferToolController', 'AnalysisResult - RevenueAGg', ex.getMessage(), ex, UserInfo.getUserId(), attID, '');
              }
          }
          // To User Budget

          system.debug('ubfromTypeMap ' + ubfromTypeMap);

          //Fetch Pending amount 
          system.debug(' effectiveDate  ' + effectiveDate);
          system.debug(' toUserIdNameMap.keyset()  ' + toUserIdNameMap.keyset());
          system.debug(' fromUserIdNameMap.keyset()   ' + fromUserIdNameMap.keyset());

          system.debug(' fromAccountToUserIdMap.keyset()  ' + fromAccountToUserIdMap.keyset());

          RecordType oppBudgetRT = [select id from RecordType where name = 'Opportunity Budget'];
          AggregateResult[] propZMVResults = [Select CALENDAR_MONTH(Broadcast_Month_Date__c) bMonth, Sum(Net_Amount__c) rAmt, Proposal_Zone__r.Proposal__r.Opportunity__r.OwnerID accEx, Advertiser__c adv from Proposal_Zone_Monthly_Value__c
              where(Proposal_Zone__r.Proposal__r.Opportunity__r.OwnerID IN: fromUserIdNameMap.keyset() OR Proposal_Zone__r.Proposal__r.Opportunity__r.OwnerID IN: toUserIdNameMap.keyset())
              AND Broadcast_Month_Date__c >=: effectiveDate AND Advertiser__c in: fromAccountToUserIdMap.keyset() AND CALENDAR_YEAR(Broadcast_Month_Date__c) =: effectiveDate.year()
              AND Proposal_Zone__r.Proposal__r.RecordTypeId !=: oppBudgetRT.Id AND Proposal_Zone__r.Status_Type__c = 'Pending'
              AND Proposal_Zone__r.Proposal__r.Active__c = True //Todo : Active flag for Proposals, RecordType does not matter.
              Group By CALENDAR_MONTH(Broadcast_Month_Date__c), Proposal_Zone__r.Proposal__r.Opportunity__r.OwnerID, Advertiser__c Order By CALENDAR_MONTH(Broadcast_Month_Date__c)
          ];

          system.debug(' propZMVResults ' + propZMVResults);
          if (propZMVResults.size() > 0) {
              List < UserBudget > frCast = new List < UserBudget > ();
              for (AggregateResult agr: propZMVResults) {
                  userBudget ubTemp;
                  userBudget ubInAmntTemp;
                  Id aeId = (Id) agr.get('accEx');
                  Boolean userExistsInMap = ubfromTypeMap.containsKey(aeId);
                  if (userExistsInMap && ubfromTypeMap.get(aeId).containsKey('Pending & Forecast')) {
                      ubTemp = ubfromTypeMap.get(aeId).get('Pending & Forecast');
                  } else { ubTemp = new userBudget();   ubTemp.amountType = 'Pending & Forecast'; ubTemp.userId = aeId;
                      if (fromUserIdNameMap.containsKey((Id) agr.get('accEx')))
                          ubTemp.userName = fromUserIdNameMap.get((Id) agr.get('accEx'));
                      else
                          ubTemp.userName = toUserIdNameMap.get((Id) agr.get('accEx'));
                      ubfromTypeMap.put(aeId, new Map < String, userBudget > {
                          ubtemp.amountType => ubTemp
                      });
                  }
                  boolean outAcc = fromAccountToUserIdMap.containsKey((String) agr.get('adv'));
                  boolean outUser = ubfromTypeMap.containsKey(fromAccountToUserIdMap.get((String) agr.get('adv')));
                  system.debug('outAcc outUser' + outAcc + '  ' + outUser);
                  if (outAcc) {
                      if (outUser) {
                          if (ubfromTypeMap.get(fromAccountToUserIdMap.get((String) agr.get('adv'))).containsKey('Pending & Forecast'))
                              ubInAmntTemp = ubfromTypeMap.get(fromAccountToUserIdMap.get((String) agr.get('adv'))).get('Pending & Forecast');
                      } else { ubInAmntTemp = new userBudget();  ubInAmntTemp.amountType = 'Pending & Forecast';  ubInAmntTemp.userId = fromAccountToUserIdMap.get((String) agr.get('adv')); ubInAmntTemp.userName = toUserIdNameMap.get(fromAccountToUserIdMap.get((String) agr.get('adv')));
                          ubfromTypeMap.put(ubInAmntTemp.userId, new Map < String, userBudget > {
                              ubtemp.amountType => ubInAmntTemp
                          });
                      }
                      ubTemp.outList[((Integer) agr.get('bMonth')) - 1] += agr.get('rAmt') == null ? 0 : (Decimal) agr.get('rAmt');
                      ubInAmntTemp.inList[((Integer) agr.get('bMonth')) - 1] += agr.get('rAmt') == null ? 0 : (Decimal) agr.get('rAmt');
                      ubfromTypeMap.get(ubInAmntTemp.userId).put(ubInAmntTemp.amountType, ubInAmntTemp);
                  }
                  system.debug('ubTemp ' + ubTemp);

                  ubTemp.existingList[((Integer) agr.get('bMonth')) - 1] += agr.get('rAmt') == null ? 0 : (Decimal) agr.get('rAmt');
                  ubFromMap.put(aeId, ubTemp);
                  ubfromTypeMap.get(aeId).put(ubtemp.amountType, ubTemp);
              }
          }
          //Fetch Forecast amount 

          //RecordType oppBudgetRT = [select id from RecordType where name='Opportunity Budget'];  
          AggregateResult[] propZMOppBudgetResults = [Select CALENDAR_MONTH(Broadcast_Month_Date__c) bMonth, Sum(Net_Amount__c) rAmt, Proposal_Zone__r.Proposal__r.Opportunity__r.OwnerID accEx, Advertiser__c adv from Proposal_Zone_Monthly_Value__c
              where(Proposal_Zone__r.Proposal__r.Opportunity__r.OwnerID IN: fromUserIdNameMap.keyset() OR Proposal_Zone__r.Proposal__r.Opportunity__r.OwnerID IN: toUserIdNameMap.keyset())
              AND Broadcast_Month_Date__c >=: effectiveDate AND Advertiser__c in: fromAccountToUserIdMap.keyset()
              AND Proposal_Zone__r.Proposal__r.RecordTypeId =: oppBudgetRT.Id AND CALENDAR_YEAR(Broadcast_Month_Date__c) =: effectiveDate.year() AND Proposal_Zone__r.Proposal__r.Active__c = True
              Group By CALENDAR_MONTH(Broadcast_Month_Date__c), Proposal_Zone__r.Proposal__r.Opportunity__r.OwnerID, Advertiser__c Order By CALENDAR_MONTH(Broadcast_Month_Date__c)
          ];

          system.debug(' propZMVResults ' + propZMOppBudgetResults);
          if (propZMOppBudgetResults.size() > 0) {
              List < UserBudget > frCast = new List < UserBudget > ();
              for (AggregateResult agr: propZMOppBudgetResults) {
                  userBudget ubTemp;
                  userBudget ubInAmntTemp;
                  Id aeId = (Id) agr.get('accEx');
                  Boolean userExistsInMap = ubfromTypeMap.containsKey(aeId);
                  if (userExistsInMap && ubfromTypeMap.get(aeId).containsKey('Pending & Forecast')) {
                      ubTemp = ubfromTypeMap.get(aeId).get('Pending & Forecast');
                  } else { ubTemp = new userBudget();  ubTemp.amountType = 'Pending & Forecast';  ubTemp.userId = aeId;
                      if (fromUserIdNameMap.containsKey((Id) agr.get('accEx')))
                          ubTemp.userName = fromUserIdNameMap.get((Id) agr.get('accEx'));
                      else
                          ubTemp.userName = toUserIdNameMap.get((Id) agr.get('accEx'));
                      ubfromTypeMap.put(aeId, new Map < String, userBudget > {
                          ubtemp.amountType => ubTemp
                      });
                  }
                  boolean outAcc = fromAccountToUserIdMap.containsKey((String) agr.get('adv'));
                  boolean outUser = ubfromTypeMap.containsKey(fromAccountToUserIdMap.get((String) agr.get('adv')));
                  //system.debug('outAcc outUser' + outAcc+'  '+outUser);
                  if (outAcc) {
                      if (outUser) {
                          if (ubfromTypeMap.get(fromAccountToUserIdMap.get((String) agr.get('adv'))).containsKey('Pending & Forecast'))
                              ubInAmntTemp = ubfromTypeMap.get(fromAccountToUserIdMap.get((String) agr.get('adv'))).get('Pending & Forecast');
                      } else {  ubInAmntTemp = new userBudget(); ubInAmntTemp.amountType = 'Pending & Forecast'; ubInAmntTemp.userId = fromAccountToUserIdMap.get((String) agr.get('adv')); ubInAmntTemp.userName = toUserIdNameMap.get(fromAccountToUserIdMap.get((String) agr.get('adv')));
                          ubfromTypeMap.put(ubInAmntTemp.userId, new Map < String, userBudget > {
                              ubtemp.amountType => ubInAmntTemp
                          });
                      }
                      ubTemp.outList[((Integer) agr.get('bMonth')) - 1] += agr.get('rAmt') == null ? 0 : (Decimal) agr.get('rAmt');
                      ubInAmntTemp.inList[((Integer) agr.get('bMonth')) - 1] += agr.get('rAmt') == null ? 0 : (Decimal) agr.get('rAmt');
                      ubfromTypeMap.get(ubInAmntTemp.userId).put(ubInAmntTemp.amountType, ubInAmntTemp);
                  }
                  //system.debug('ubTemp ' + ubTemp);

                  ubTemp.existingList[((Integer) agr.get('bMonth')) - 1] += agr.get('rAmt') == null ? 0 : (Decimal) agr.get('rAmt');
                  ubFromMap.put(aeId, ubTemp);
                  ubfromTypeMap.get(aeId).put(ubtemp.amountType, ubTemp);
              }
          }
          //end fetching pending amounts

          ub.addAll(ubFromMap.values());
          //  ub.addAll(ubToMap.values());
          system.debug(' ubfromTypeMap ' + ubfromTypeMap);
          return JSON.serialize(ubfromTypeMap);
      } catch (Exception ex) {
          Log4SF.logMessage('AccountTransferController', 'analysisResult', ex.getMessage(), ex, UserInfo.getUserId(), attID, '');
          system.debug('ex ' + ex.getStackTraceString());
          return null;
      }
  }

  public class userBudget {
      @AuraEnabled public Id userId;
      @AuraEnabled public String userName;
      @AuraEnabled public List < Decimal > existingList;
      @AuraEnabled public List < Decimal > outList;
      @AuraEnabled public List < Decimal > inList;
      @AuraEnabled public string fromUser;

      @AuraEnabled public string amountType;
      @AuraEnabled public string productLine;
      @AuraEnabled public Boolean isNational;
      @AuraEnabled public Map < Integer, Map < String, Decimal >> commodityDetails;
      @AuraEnabled public Map < Integer, Map < String, List < String >>> commodityDMA;
      @AuraEnabled public Map < Integer, Map < String, Decimal >> DMADetails;
      public userBudget() {
          existingList = new List < Decimal > ();
          outList = new List < Decimal > ();
          inList = new List < Decimal > ();
          productLine = '';
          isNational = false;
          fromUser = '';
          commodityDetails = new Map < Integer, Map < String, Decimal >> ();
          commodityDMA = new Map < Integer, Map < String, List < String >>> ();
          DMADetails = new Map < Integer, Map < String, Decimal >> ();
          for (Integer i = 0; i < 12; i++) {
              existingList.add(0);
              outList.add(0);
              inList.add(0);
          }
      }
  }

  //Create Partial New Business and Unknown Churn records
  @RemoteAction
  public static string createNBUC(string simulateID, string jsonNBUC) {
      try {

          if (String.isNotBlank(jsonNBUC)) {
              List < Sales_Budget_Simulation__c > currentNBUC = [Select ID from Sales_Budget_Simulation__c where Account_Transfer_Simulation__c =: simulateID];
              if (currentNBUC.size() > 0)
                  delete currentNBUC;
              Set < String > userSet = new Set < String > ();
              List < AXTNBUCJSONParser > sbSimulationList = AXTNBUCJSONParser.parse(jsonNBUC);

              List < Sales_Budget_Simulation__c > sbNew = new List < Sales_Budget_Simulation__c > ();
              Map < String, Sales_Budget_Simulation__c > mapSBNew = new Map < String, Sales_Budget_Simulation__c > ();

              for (AXTNBUCJSONParser par: sbSimulationList) {
                  Sales_Budget_Simulation__c sb = new Sales_Budget_Simulation__c();
                  sb.From_Budget_user__c = par.FromUserID;
                  sb.Budget_user__c = par.ToUserID;
                  sb.Commodity__c = par.Commodity;
                  sb.DMA__c = par.DMA;
                  sb.Product_Line__c = par.ProductLine;
                  sb.Old_Product_Line__c = par.OldProductLine;
                  sb.Type__c = 'Simulation';
                  sb.New_Business_Churn__c = par.Type_Z;
                  sb.Broadcast_Month_Date__c = Date.parse(par.BroadcastDate);
                  sb.External_Id__c = par.ToUserID + ':' + par.UniqueKey + simulateID;
                  sb.Account_Transfer_Simulation__c = simulateID;
                  if (String.isNotEmpty(par.DMA))
                      sb.Amount__c = par.DMAContri;
                  else
                      sb.Amount__c = par.CommodityContri;
                  system.debug('par.Type_Z ' + par.Type_Z);
                  system.debug('sb.Amount__c ' + sb.Amount__c);
                  if (par.Type_Z.trim() == 'Unknown Churn' && sb.Amount__c > 0) {
                      sb.Amount__c = -sb.Amount__c;
                      system.debug('sb ' + sb.Amount__c);
                  }
                  sbNew.add(sb);
                  userSet.add(par.FromUserID);
                  mapSBNew.put(sb.External_Id__c, sb);
                  //userSet.add(par.ToUserID);

              }
              if (sbNew.size() > 0)
                  insert mapSBNew.values();
          }
          return '';
      } catch (Exception ex) {
          Log4SF.logMessage('AccountTransferController', 'createNBUC', ex.getMessage(), ex, UserInfo.getUserId(), simulateID, '');
          system.debug('ex ' + ex.getStackTraceString());
          return null;
      }

  }


  @RemoteAction
  public static string accountTransfer(string simulateID) {
      List < String > AccountIds = new List < String > ();
      List < ID > newUserID = new List < ID > ();
      List < ID > oldUserId = new List < ID > ();
      Map < ID, Map < Id, Id >> toFromUser = new Map < ID, Map < Id, Id >> ();
      string effectiveDate = '';
      Map < String, List < String >> mapAccount = new Map < String, List < String >> ();
      Map < String, String > mapTransfer = new Map < String, String > ();
      try {
          if (string.isNotBlank(simulateID)) {
              List < Account_Transfer_Tool__c > attSimulate = [Select ID, Transfer_Effective_Date__c, Status__c,
                  (Select ID, Account__c, From_User__r.ID, To_User__r.Id from Account_Transfer_Mappings__r where To_User__r.Id != null)
                  from Account_Transfer_Tool__c
                  where Id =: simulateID
              ];
              if (attSimulate.size() > 0) {
                  List < Account_Transfer_Mapping__c > accTransfer = attSimulate[0].Account_Transfer_Mappings__r;
                  if (attSimulate[0].Status__c != 'Transfer In Progress') {
                      attSimulate[0].Status__c = 'Transfer In Progress';
                      update attSimulate[0];
                  }
                  simulateID = JSON.Serialize(attSimulate[0]);
                  for (Account_Transfer_Mapping__c att: accTransfer) {
                      AccountIds.add(att.Account__c);
                      newUserId.add(att.To_User__c);
                      oldUserId.add(att.From_User__c);
                      string key = String.valueOf(att.From_User__r.Id) + '-' + String.valueOf(att.To_User__r.Id);
                      if (!mapAccount.containsKey(key)) {
                          List < String > strList = new List < String > ();
                          strList.add(att.Account__c);
                          mapAccount.put(key, strList);
                          mapTransfer.put(key, att.ID);
                      } else {
                          List < String > strList = new List < String > ();
                          strList = mapAccount.get(key);
                          strList.add(att.Account__c);
                          mapAccount.put(key, strList);
                      }
                  }
                  effectiveDate = String.valueOf(attSimulate[0].Transfer_Effective_Date__c);
              }

              if (mapAccount != null && mapAccount.keySet().size() > 0) {
                  for (string mapKey: mapAccount.keySet()) {
                      string newUser = mapKey.split('-')[1];
                      string oldUser = mapKey.split('-')[0];
                      List < New_AETransferToolController.OppProposalWrapper > oppProposalWrapList = New_AETransferToolController.showOpportunities(mapAccount.get(mapKey), effectiveDate, oldUser);
                      for (New_AETransferToolController.OppProposalWrapper oppWrap: oppProposalWrapList) {
                          oppWrap.chckBx = true;
                          System.debug('Record:::' + oppWrap);
                      }

                      String JSONString = JSON.serialize(oppProposalWrapList);
                      createAdminLogs(JSONString, ID.valueOf(newUser), Id.valueOf(oldUser), mapAccount.get(mapKey), effectiveDate, mapTransfer.get(mapKey));
                  }
              }
          }
      } catch (Exception ex) {
          Log4SF.logMessage('AccountTransferController', 'accountTransfer', ex.getMessage(), ex, UserInfo.getUserId(), simulateId, '');
      }

      return simulateId;
  }

  @future
  public static void createAdminLogs(string JSONString, Id newUserId, Id oldUserId, List < String > AccountIds, string effectiveDate, string transferID) {
      String adminsummaryId = New_AETransferToolController.AEtransfer(JSONString, newUserId, oldUserId, AccountIds, effectiveDate, transferID);
      Admin_Tool_Status_Summary__c adminSummaryRecord = New_AETransferToolController.returnAdminToolStatus(adminsummaryId);
      adminSummaryRecord.Processed__c = true;
      update adminSummaryRecord;
  }

  @RemoteAction
  public static Boolean submitATSApproval(String atsID) {
      try {
          Id userId = UserInfo.getUserId();
          Approval.ProcessSubmitRequest req = new Approval.ProcessSubmitRequest();
          req.setObjectId(atsID);
          req.setProcessDefinitionNameOrId(System.Label.ATS_Approval_Process_ID);
          req.setSubmitterId(userId);
          req.setSkipEntryCriteria(true);
          Approval.ProcessResult result = Approval.process(req);
          return result.isSuccess();
      } catch (Exception ex) {
          Log4SF.logMessage('AccountTransferController', 'submitATSApproval', ex.getMessage(), ex, UserInfo.getUserId(), atsID, '');
          return null;
      }
  }
  @RemoteAction
  public static String executeSBAggBatch(String userId) {
      AdminUtility admUtility = new AdminUtility();
      try {
          Set < ID > userIDs = new Set < ID > ();
          for (string usrID: userId.split(';')) {
              userIDs.add(Id.valueOf(usrID));
          }

          if (!Test.isRunningTest()) {
              admUtility.executeSalesBudgetAgg('', userIDs, false);
          }
          return 'Success';
      } catch (Exception ex) {
          Log4SF.logMessage('AccountTransferController', 'executeSBAggBatch', ex.getMessage(), ex, UserInfo.getUserId(), userId, '');
          return null;
      }

  }

  @RemoteAction
  public static String generateApprovalURL(String atsID) {
      String url = '';

      List < ProcessInstanceWorkitem > workItemLst = [SELECT Id FROM ProcessInstanceWorkitem WHERE processInstance.TargetObjectId =: atsID];

      if (workItemLst.size() > 0) {
          url = 'https://' + System.URL.getSalesforceBaseUrl().getHost() + '/p/process/ProcessInstanceWorkitemWizardStageManager?id=' + workItemLst[0].id;
      }
      return url;
  }
}