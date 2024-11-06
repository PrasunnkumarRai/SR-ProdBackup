/*
###########################################################################
# File..................: BudgetController.cls
# Version...............: 1.1
# Created by............: Sanchit Singhal 
# Created Date..........: 21-June-2017
# Last Modified by......: Puneet Khosla
# Last Modified Date....: 5-Apr-2018
# Description...........: This is the controller class for Budget Management Screen
# Change Log:               
# 1. Puneet Khosla - SRSF-958 - Budget Management Fix

############################################################################*/
global without sharing class  BudgetController {
    
    /* Map to hold Budget Records per User/Account */
    public transient static Map<String,Budget__c> budgetMap = new Map<String,Budget__c>();
    /* String hold selected Budget year */
    public String chosenFiscalYear{get; set;}
    /* String hold selected Budget User */
    public String chosenUser{get; set;}
    /* Set describing Role wise extra Budget rows */
    private transient static Set<String> BUDGET_LEVEL_CHECK = new Set<String>{'LSM','LSM Budget Override','Digital','Linear','Prod','SRNews','RSN'};
    /* Map to hold the parent user against which data is being aggregated for display */
    private transient static Map<String,String> globalParentChildUserMap = new Map<String,String>();
    /* Boolean flag to show Budget Approval button */
    public boolean isApprover {get;set;}
    /* Boolean flag to show Budget Approval Submit button */
    public boolean isSubmitter {get;set;}
    /* Boolean flag to show Save button */
    public boolean showSave {get;set;}
    /* String to store current loggedin User Id */
    public String loggeduserId {get;set;}
    /* User record for which Budgets are being viewed currently */
    private User currUsr;
    /* User record for currently logged in user */
    private User loggedInUser;
    /* String to hold value of year for which currently Budget entry is allowed */
    private static String budgetYr = Budget_Entry_Year__c.getAll().get('Budget_Year') != null && Budget_Entry_Year__c.getAll().get('Budget_Year').value__c != null ? Budget_Entry_Year__c.getAll().get('Budget_Year').value__c : '';
    private static Set<String> filteredDesignation = new Set<String>{'AP','AC','AE'};
    /*All User list*/
    public List<SelectOption> userList1{get;set;}
    public List<SelectOption> userList2{get;set;}
    public List<SelectOption> userList3{get;set;}
    public List<BudgetRow> budgetAllRows{get;set;}
    
    public String pageMsg{get;set;}
    
    public List<String> monthList{get;set;}
    
    /*
        Class Constructor
    */
    public BudgetController(){
        System.debug('@@budgetRows '+budgetAllRows);
		budgetAllRows = new List<BudgetRow>();
        //Check to see if the values are specified as parameters if not then set the default as current year and logged in user 
        chosenUser = ApexPages.currentPage().getParameters().get('userId');
        System.debug('@@chosenUser '+chosenUser);
        pageMsg = '';
        chosenFiscalYear = ApexPages.currentPage().getParameters().get('selYear');
        loggeduserId = UserInfo.getUserId();
        if (null == chosenUser || chosenUser == ''){
            chosenUser = loggeduserId;
        }
        if (null == chosenFiscalYear || chosenFiscalYear == ''){
            chosenFiscalYear = String.valueOf(Date.today().year());
        }
        currUsr = [SELECT Id, Name,UserRoleId,UserRole.Name,Job_Share_User__c FROM User WHERE Id = :chosenUser LIMIT 1];
        loggedInUser = [SELECT Id, Name,UserRoleId,UserRole.Name,Profile.Name,ManagerId FROM User WHERE Id = :loggeduserId LIMIT 1];
                /*Job Share changes start*/
		if(currUsr.Job_Share_User__c != null)
        {
    		currUsr = [SELECT Id, Name,UserRoleId,UserRole.Name FROM User WHERE Id = :currUsr.Job_Share_User__c LIMIT 1];
    		//selUser = currUser.id;
    		chosenUser = currUsr.id;
        }
        /*Job Share changes end*/
        List<User> subUsers = [SELECT Id FROM User WHERE UserRole.ParentRoleID != NULL AND isActive = true AND ManagerId = :loggeduserId AND UserRole.Name LIKE :System.label.AccountTeamRole+'%'];
        System.debug('@@subUsers '+subUsers);

        boolean isBudgetYr = chosenFiscalYear.equals(budgetYr);
        System.debug('@@isBudgetYr '+isBudgetYr);

        System.debug('@@loggedInUser.Profile.Name '+loggedInUser.Profile.Name);
        boolean isSuperUser = SuperUserRoles__c.getAll().containsKey(loggedInUser.Profile.Name) ? true : false;
        System.debug('@@isSuperUser '+isSuperUser);

        System.debug('@@loggedInUser.UserRole.Name '+loggedInUser.UserRole.Name);
        String loggedRoleName = null != loggedInUser.UserRole.Name ? loggedInUser.UserRole.Name:'';
        System.debug('@@loggedRoleName '+loggedRoleName);
        // Logic to display Save , Approve and Submit button based on logged in user role and editable budget year custom setting value
        if (isSuperUser || (isBudgetYr && ((subUsers != null && subUsers.size() > 0) || loggedRoleName.startsWith(System.label.AccountTeamRole)))){
            showSave = true;
        }
        
        if (isBudgetYr && loggedRoleName.startsWith(System.label.AccountTeamRole)){
            isSubmitter = true;
        }
        
        if (isBudgetYr && subUsers != null && subUsers.size() > 0){
            isApprover = true;
        }
        //collectionData();
        budgetAllRows = new list<budgetRow>();
        budgetAllRows = getBudgets(chosenFiscalYear,currUsr.ID);
        system.debug('budgetRows ' + budgetAllRows);
        allMonths();
    }
    
    
    /*
        Method to retun a list of years for which Budgets can be entered/viewed. It returns CurrYear -1 - CurrYear+5 as option in dropdown.
    */
    public List<SelectOption> getFiscalYear(){
        List<SelectOption> options = new List<SelectOption>(); 
        Integer startYear = Date.today().year()-1;
        Integer endYear =  startYear + 5;
        for(Integer i = startYear; i < endYear; i++){
            options.add(new SelectOption(String.valueOf(i), String.valueOf(i)));
        }
        return options;
    }
    /*
        Method to retun a list of all the Months
    */
    public List<String> allMonths(){
        monthList = new List<String>(); 
        monthList.add('Jan');
        monthList.add('Feb');
        monthList.add('Mar');
        monthList.add('Apr');
        monthList.add('May');
        monthList.add('June');
        monthList.add('July');
        monthList.add('Aug');
        monthList.add('Sep');
        monthList.add('Oct');
        monthList.add('Nov');
        monthList.add('Dec');
        monthList.add('Totals');
        return monthList;
    }
    
    /*
        Method to retun a list of users for which Budgets can be entered/viewed. It returns based on logged in and selected user.
    */
    public List<SelectOption> getUsersList(){
         List<SelectOption> options = new List<SelectOption>();
        
        // If Sys Admin Profile then show list of all users
        if (loggedInUser.Profile.Name == 'System Administrator'){
            for (User subUser : [SELECT Id, Name FROM User WHERE UserRole.Id != NULL AND UserRole.ParentRoleID != NULL AND isActive = true AND( User.UserRole.Name Like 'AE%'  or User.UserRole.Name Like 'LSM%') 
            //AND Designation__c NOT IN :filteredDesignation 
            order by firstname]){
                options.add(new SelectOption(subUser.Id , subUser.Name));
            }
            if (currUsr != loggedInUser){
                chosenUser = currUsr.Id;
            }else{
                chosenUser = options[0].getValue();
            }
        }else if (loggedInUser.Profile.Name == 'Billing'){
            // If Finance profile then show only those users who report to same Manager
            Set<Id> allRelatedUserIds = getAllSubUserIds(new Set<Id>{loggedInUser.ManagerId});
            allRelatedUserIds.remove(loggedInUser.Id);
            for (User subUser : [SELECT Id, Name FROM User WHERE UserRole.Id != NULL AND UserRole.ParentRoleID != NULL AND isActive = true AND Id IN:allRelatedUserIds 
            //AND Designation__c NOT IN :filteredDesignation 
            order by firstname]){
                options.add(new SelectOption(subUser.Id , subUser.Name));
            }
            if (currUsr != loggedInUser){
                chosenUser = currUsr.Id;
            }else{
                chosenUser = options[0].getValue();
            }
        }
        else{
            // Show only those users which report to this user
            options.add(new SelectOption(loggedInUser.Id , loggedInUser.Name));
            System.debug('@@Test '+ [SELECT Id, Name FROM User WHERE UserRole.ParentRoleID != NULL]);

            for (User subUser : [SELECT Id, Name FROM User WHERE UserRole.ParentRoleID != NULL AND isActive = true AND (ManagerId = :loggedInUser.Id OR ManagerId = :currUsr.Id) 
            //AND Designation__c NOT IN :filteredDesignation 
            order by firstname]){
                options.add(new SelectOption(subUser.Id , subUser.Name));
            }
            // Check to see if the current user is present in the user dropdown list
            boolean currUserFound = false;
            for(SelectOption sel : options){
                if (sel.getValue() == currUsr.Id)
                    currUserFound = true;
            }
            if (!currUserFound)
                options.add(new SelectOption(currUsr.Id , currUsr.Name));
            chosenUser = currUsr.Id;
        }
        System.debug('options ' + options);
        return options;
    }
    
        
    /*
        Method to recursively get the User Hierarchy for the selected user for which Budgets are being requested.
    */
    @TestVisible
    private static Set<Id> getAllSubUserIds(Set<ID> userIds){
        Set<ID> currentUserIds = new Set<ID>();
        Map<String,String> localParentChildUserMap = new Map<String,String>();
        // get all of the user underneath the passed user
        for(User usr :[select Id,ManagerId from User WHERE ManagerId IN :userIds AND UserRole.ParentRoleID != null AND isActive = true 
        //AND Designation__c NOT IN :filteredDesignation
        ]) {
            currentUserIds.add(usr.Id);
            localParentChildUserMap.put(usr.Id,usr.ManagerId);
        }
        //System.debug('localParentChildUserMap---'+localParentChildUserMap);
        // go fetch some more users!
        if(currentUserIds.size() > 0) {
            for (String userId : localParentChildUserMap.keySet()){
                //System.debug('userId---'+userId);
                String managerId = localParentChildUserMap.get(userId);
                // Map the user to the record against which the records will be aggregated for viewing
                if (globalParentChildUserMap.get(managerId) != null){
                    globalParentChildUserMap.put(userId,globalParentChildUserMap.get(managerId));
                }
            }
            currentUserIds.addAll(getAllSubUserIds(currentUserIds));
        }

        return currentUserIds;
        
    }
    
    
     /*
        Method to return label for Top Level Row depending upon selected user role.
    */
    @TestVisible
    private static String getTopRowLabel(String currRoleName){
        String topLineRowLabel = 'undefined';
        //System.debug('currRoleName>>>>>>'+currRoleName);
        try
        {
	        if(String.isNotBlank(currRoleName))
	        { 
		        if (currRoleName.startsWith(System.label.AccountTeamRole)){
		            topLineRowLabel = 'AE Total';
		        }else{
		        	for(String mur: ManagerUserRoles__c.getAll().keySet()){
		        		if(currRoleName.startsWith(mur)){
		        			topLineRowLabel = mur;
		        		}
		        	}
		        }
	        }
        }
        catch(exception ex)
        {
        	System.debug('Exception >>>>>> '+ex.getMessage());
        	//pageMsg = 'User record does not has any role';
        } 
        
        /*if (currRoleName.startsWith('LSM')){
            topLineRowLabel = 'LSM';
        }else if (currRoleName.startsWith('GSM')){
            topLineRowLabel = 'GSM';
        }else if (currRoleName.startsWith('Director')){
            topLineRowLabel = 'Director';
        }else if (currRoleName.startsWith('VP')){
            topLineRowLabel = 'VP';
        }*/
        return topLineRowLabel;
    }
    
    
    /*
        Method called remotely through Java Script to return Budget records for the selected user for selected year.
    */
    
    public  List<BudgetRow> getBudgets(String selYear,String selUser){
    	if(selUser == 'Select One')
    	return new List<Budgetrow>();
        List<BudgetRow> budgets = new List<BudgetRow>();
        Map<String,BudgetRow> rowMap = new Map<String,BudgetRow>();
        system.debug('selUser '+ selUser);
        User currUser = [SELECT Id,ManagerId, UserRole.Name,UserRole.Id,Job_Share_User__c FROM User WHERE Id = :selUser LIMIT 1];

        
        String loggedInUserRoleId = UserInfo.getUserRoleId();
        String loggedRoleName = null != loggedInUserRoleId ?[SELECT Id,Name FROM UserRole WHERE Id = :loggedInUserRoleId].Name:'';
        String loggedProfileName = [SELECT Id,Name FROM Profile WHERE Id = :UserInfo.getProfileId()].Name;
        Set<Id> childUserIds = new Set<Id>();
        Map<String,String> highestUserMap = new Map<String,String>();
        
        
        // Get the Top Row Label
        String topLineRowLabel = getTopRowLabel(null != currUser.UserRole.Name?currUser.UserRole.Name:'' );
        BudgetRow toprow = createBudgetRow(topLineRowLabel,topLineRowLabel);
        //rowMap.put(topLineRowLabel,toprow);
        budgets.add(toprow);
        
        // Validate the role of current logged in user
        boolean isLSM = loggedRoleName.startsWith('LSM') ? true :false;

        boolean isAE = loggedRoleName.startsWith(System.label.AccountTeamRole) ? true:false;
        boolean isSuperUser = SuperUserRoles__c.getAll().containsKey(loggedProfileName) ? true : false;
        boolean isCurrentUserAE = String.isNotBlank(currUser.UserRole.Name) ? currUser.UserRole.Name.startsWith(System.label.AccountTeamRole) ? true:false:false;
        // If selected user is an LSM then show LSM specific rows
        //if (currUser.UserRole.Name.startsWith('LSM')){
            //budgets.addAll(createLSMBudgetRows(rowMap,selYear));
        //}

        
        // Get the first level of reportee's 
        for (User reportee : [SELECT Id,ManagerId,Name,UserRole.ParentRoleId, UserRole.Id FROM User WHERE UserRole.ParentRoleId != NULL AND ManagerId = :currUser.Id 
        //AND Designation__c NOT IN :filteredDesignation 
        ORDER BY Name] ){
            BudgetRow row = createBudgetRow(reportee.Id,reportee.Name);
            row.UserId = reportee.Id;
            //row.allAmounts= new List<budgetAmounts>(0);
            rowMap.put(reportee.Id,row);
            system.debug('row 1 ' + row);
            //budgets.add(row);
            // Map of user Id against which Budget records will be aggregated for viewing
            highestUserMap.put(reportee.Id,reportee.Id);
            globalParentChildUserMap.put(reportee.Id,reportee.Id);
            childUserIds.add(reportee.Id);
        }
        System.debug('budgets size---'+budgets.size());
        //System.debug('highestUserMap:---'+highestUserMap);
        childUserIds.addAll(getAllSubUserIds(childUserIds));
        //System.debug('globalParentChildUserMap---'+globalParentChildUserMap);
        
        System.debug('@rowMap '+ rowMap);  
        Boolean isRowEditable = false;
        Boolean ownerRecordFound = false;
        System.debug('@selYear '+ selYear + selUser);
        // Fetch the budget records for which the selected User is an Owner
        List<budget__c> budgetList = [select Id, Name, Account__c,Amount__c,Broadcast_Month_Date__c ,Broadcast_Month__c,Product_Line__c,Year__c,Budget_Key__c,Status__c,BudgetAE__c     
                                from Budget__c 
                                WHERE Year__c = :selYear AND BudgetAE__c = :selUser 
                                ORDER BY Product_Line__c];
        System.debug('budgetList::'+budgetList.size());
        System.debug('selYear::'+selYear);
        System.debug('selUser::'+selUser);
        System.debug('isAE::'+isAE);
        if(budgetList.size() <= 0 && isAE)
        {
        	List<String> productList = getAllProducts();
        	system.debug('productList' +productList);
        	for(Integer i = 0; i < productList.size();i++)
        	{
        		Budget__c budg = new budget__c();
        		budg.Product_Line__c = productList[i];
        		budg.Amount__c = 0;
        		budg.BudgetAE__c = selUser;
        		budg.Broadcast_Month_Date__c = date.today();
        		budgetList.add(budg);
        	}
        }
        System.debug('@budgetList '+ budgetList);                        
        for (Budget__c budget: budgetList){
                
                ownerRecordFound = true;
                // Validate if the row has to be shown as editable or not
                if (isSuperUser){
                    isRowEditable = false;
                }
                else if ((isAE || isLSM) && !isRowEditable){                
                    if (isLSM && budget.Status__c != 'Approved'){
                        isRowEditable = false;
                    }
                    else if (budget.Status__c == 'Not Submitted'){
                        isRowEditable = false;
                    }
                }
                
                String rowId = '';
                String rowName = '';                
                rowId = budget.Product_Line__c;
                rowName = budget.Product_Line__c;
                system.debug('rowName 1 ' + rowName);
                //Validate if we have already a Budget Row. If present then we will modify the row based on month else create a new one and add it to Map
                BudgetRow row = rowMap.get(rowName);
                system.debug('row 12 ' + row);
                if (row ==  null){
                    row = createBudgetRow(budget.Product_Line__c,rowName);
                    rowMap.put(rowName,row);
                    system.debug('row 1 ' + row);
                    budgets.add(row);                    
                }
                if (isRowEditable)
                    row.rowEditable = true;
                // Set amount based on budget month
                
                system.debug('budget.Amount__c' + budget.Broadcast_Month_Date__c.month());
                row.setAmount((Integer)budget.Amount__c,String.valueOf(budget.Broadcast_Month_Date__c.month()));
                system.debug('row' + row);
        }
        System.debug('childUserIds---'+childUserIds);
        if (childUserIds.size() == 0 && isCurrentUserAE){
            // Since no data has been found we will be allowing entry of data if it is allowed budget year
            for (Integer i = 1; i < budgets.size(); i++){
                setRowEditable(budgets[i],isSuperUser, ownerRecordFound, isRowEditable, selYear);
            }
            // Means that we are now at AE Level
            if (!rowMap.containsKey('Linear')){
                BudgetRow row = createBudgetRow('Linear','Linear');
                // If we have a Budget record then set editable based on that record else based on editable Budget year
                setRowEditable(row,isSuperUser, ownerRecordFound, isRowEditable, selYear);
                budgets.add(row);
            }
            else{
                //budgets.add(rowMap.get('Linear'));
            }
            if (!rowMap.containsKey('Digital')){
                BudgetRow row = createBudgetRow('Digital','Digital');
                // If we have a Budget record then set editable based on that record else based on editable Budget year
                setRowEditable(row,isSuperUser, ownerRecordFound, isRowEditable, selYear);
                budgets.add(row);
            }else{
                //budgets.add(rowMap.get('Digital'));
            }
            if (!rowMap.containsKey('Production')){
                BudgetRow row = createBudgetRow('Production','Production');
                // If we have a Budget record then set editable based on that record else based on editable Budget year
                setRowEditable(row,isSuperUser, ownerRecordFound, isRowEditable, selYear);
                budgets.add(row);
            }
            else{
                //budgets.add(rowMap.get('Prod'));
            }            
            if (!rowMap.containsKey('SRNews')){
                BudgetRow row = createBudgetRow('SRNews','SRNews');
                // If we have a Budget record then set editable based on that record else based on editable Budget year
                setRowEditable(row,isSuperUser, ownerRecordFound, isRowEditable, selYear);
                budgets.add(row);
            }
            else{
                //budgets.add(rowMap.get('SRNews'));
            }            
            if (!rowMap.containsKey('RSN')){
                BudgetRow row = createBudgetRow('RSN','RSN');
                // If we have a Budget record then set editable based on that record else based on editable Budget year
                setRowEditable(row,isSuperUser, ownerRecordFound, isRowEditable, selYear);
                budgets.add(row);
            }
            else{
                //budgets.add(rowMap.get('RSN'));
            }
            
           
        }else if (childUserIds.size() > 0){
            // Now we have reporting users and for all of them data needs to be aggregated for display
            // Aggregate data based on owner and month
            System.debug('budgets---'+budgets.size());
            AggregateResult[] budgetResults = [SELECT SUM(Amount__c) bAmt, BudgetAE__c userId, CALENDAR_MONTH(Broadcast_Month_Date__c) bMonth FROM Budget__c WHERE Year__c = :selYear AND BudgetAE__c IN :childUserIds GROUP BY BudgetAE__c,CALENDAR_MONTH(Broadcast_Month_Date__c)];
            for (AggregateResult br : budgetResults){
            	System.debug('budgetResults---'+budgetResults.size());
                // Get the row against which this data will be aggregated for display
                if(String.valueOf(br.get('bMonth')) != '')
                {
	                String rowId = highestUserMap.get(globalParentChildUserMap.get((String)br.get('userId')));
	                System.debug('rowId---'+rowId);
	                System.debug('row---'+rowMap.get(rowId));
	                BudgetRow row = rowMap.get(rowId);
	                if (null != row){
	                    // Update the row amount for budget month
	                    //row.setAmount(Integer.valueOf(br.get('bAmt')),String.valueOf(br.get('bMonth')));
	                    Integer amnt = Integer.valueOf(row.allAmounts[(Integer)br.get('bMonth')-1].amount);
	                    row.allAmounts[(Integer)br.get('bMonth')-1].amount =String.valueOf(amnt+ (Integer.valueOf(br.get('bAmt'))));
	                }
	                rowMap.put(rowId,row);
	                //
                }
            }
            // Changes for SRSF-958 - Start
            for(BudgetRow row : rowMap.values())
            {
                if(!budgets.contains(row))
                  budgets.add(row);  
            }
            //budgets.addAll(rowMap.values());
            // Changes for SRSF-958 - End
        }
        
        System.debug('budgets---'+budgets.size());
        budgets = calculateTotal(budgets);
        System.debug('budgets---'+budgets.size());
        // Return the budgets row
        return budgets;
    }
    /*
        Method for on change total calculation
    */
    public void onChangeTotal()
    { 
    	try
    	{
	    	System.debug('budgetAllRows ' + budgetAllRows);
	    	if(budgetAllRows.size() > 0)
	    	budgetAllRows = calculateTotal(budgetAllRows);
    	}
    	catch(Exception ex)
    	{
    		system.debug('Exception >>> ' +  ex.getMessage());
    	}
    }
    
    /*
        Method to calcualte AE Total and Row Total
    */    
    public List<BudgetRow> calculateTotal(List<BudgetRow> budgets)
    { 
    	Integer counter = 0;
    	for(BudgetRow bgRow:budgets)
            {
            	System.debug('bgRow ' + bgRow.rowId +bgRow.allAmounts);
            	Boolean flag = true;
            	bgRow.allAmounts[12].amount = '0';
            	List<budgetAmounts> bdgAmnts = new List<budgetAmounts>();
            	for(Integer i = 0; i < bgRow.allAmounts.size(); i++)
            	{
            		budgetAmounts bdg  = new budgetAmounts(0);
            		bdgAmnts.add(bdg);
            		if(flag && counter == 0)
            		{
            			budgets[0].allAmounts = budgets[0].allAmounts == null ? bdgAmnts : budgets[0].allAmounts;
            			budgets[0].allAmounts[i].amount = '0';
            			if(i == bgRow.allAmounts.size()-1)
            			flag = false;
            		}
            		
            		if(counter != 0)
            		budgets[0].allAmounts[i].amount = String.valueOf(Integer.valueOf(budgets[0].allAmounts[i].amount) +  Integer.valueOf(bgRow.allAmounts[i].amount));

            		if(i != bgRow.allAmounts.size()-1)
            			bgRow.allAmounts[12].amount = String.valueOf(Integer.valueOf(bgRow.allAmounts[12].amount)+ Integer.valueOf(bgRow.allAmounts[i].amount)); 
            	} 
            	counter ++;
            }
    	return budgets;
    }
    
    /*
        Method called remotely through Java Script to save Budget records for the selected user for selected year.
    */
    
    global PageReference saveRecords(){
    	System.debug('inside save ' + budgetAllRows);
    	String selYear = ApexPages.currentPage().getParameters().get('selYear');
    	String selUser = ApexPages.currentPage().getParameters().get('userId');
    	List<List<String>> budgetRows = new List<List<String>>(); 
    	System.debug('budgetRows ' + budgetAllRows);
        budgetMap = new Map<String,Budget__c>();
        List<Budget__c> upSertList = new List<Budget__c>();
        // Same Query as used for fetching Budget records. Doing this to only upsert changes instead of blindly updating all budget records
        for (Budget__c budget: [select Id, Name, Account__c,Amount__c,Account__r.Name,Broadcast_Month__c,Product_Line__c,Year__c,Budget_Key__c,BudgetAE__c,BudgetAE__r.Id    
            from Budget__c WHERE Year__c = :selYear AND BudgetAE__c = :selUser ORDER BY Product_Line__c]){
                if (BUDGET_LEVEL_CHECK.contains(budget.Product_Line__c)){
                    budgetMap.put(String.valueOf(budget.Budget_Key__c),budget);
                }else{
                    budgetMap.put(String.valueOf(budget.Budget_Key__c),budget);
                }
        }
        // Remove the toplevel summary row
        //budgetAllRows.remove(0);
        //ibudgetRows = budgetRows;
        //System.debug('budgetRows '+budgetRows); 
        String userId = selUser;
        User currUser = [SELECT Id, UserRole.Name,UserRole.Id FROM User WHERE Id = :selUser LIMIT 1];
        // If curr User is an LSM then only first two rows belong to user. Rest all are users aggregated rows.
        if (currUser.UserRole.Name.startsWith('LSM')){
            List<budgetRow> tempRows = new List<budgetRow>();
            tempRows.add(budgetAllRows.get(0));
            //tempRows.add(budgetAllRows.get(1));
            budgetAllRows.clear();
            budgetAllRows.addAll(tempRows);
            tempRows = null;
        }
        // Iterate over all rows and upsert changes only
        for (budgetRow rowObjs : budgetAllRows){
        	if(budgetAllRows[0] != rowObjs )
        	{
	        	System.debug('rowObjs:---'+rowObjs);
	            String rowId = rowObjs.rowId;
	            String rowLabel = rowObjs.rowLabel;
	            for (Integer i = 1; i < rowObjs.allAmounts.size(); i++){
	                String bRecKey = userId + rowId;
	                String monthStr = String.valueOf(i);
	                if (monthStr.length() < 2){
	                     monthStr =  '0'+monthStr;
	                }
	                // Key for identifying existing against new record
	                bRecKey += monthStr+selYear;
	                System.debug('bRecKey:---'+bRecKey);
	                Budget__c existingRec = budgetMap.get(bRecKey);
	                Integer rowAmt = null != rowObjs.allAmounts[i-1].amount ? Integer.valueOf(rowObjs.allAmounts[i-1].amount):0;
	                if (null == existingRec){
	                    if (rowAmt != 0){
	                        Date budgetDate = Date.newinstance(Integer.valueOf(selYear),i,15);
	                        rowId = rowId == rowLabel? null: rowId;
	                        Budget__c newRec = new Budget__c(Id = rowId,Amount__c=rowAmt,Broadcast_Month_Date__c=budgetDate,BudgetAE__c=userId);
	                        if (BUDGET_LEVEL_CHECK.contains(rowLabel)){
	                            newRec.Product_Line__c = rowLabel;
	                        }
	                        upSertList.add(newRec);
	                    }
	                }else if (rowAmt != existingRec.Amount__c){
	                	System.debug('existingRec ' +existingRec);
	                    existingRec.Amount__c = rowAmt;
	                    upSertList.add(existingRec);
	                }
	            }
        	}
        }
        System.debug('upSertList ' +upSertList);
        boolean isSuccess = true;
        if (null != upSertList && upSertList.size() > 0){
            //System.debug('upSertList:---'+upSertList);
            Database.UpsertResult[] upsertResults = Database.upsert(upSertList,false);
            for (Database.UpsertResult upsertResult : upsertResults){
                if (upsertResult.getErrors().size() > 0){
                    for (Database.Error error: upsertResult.getErrors()){
                        System.debug('Upsert Error--'+error);
                        isSuccess = false;
                    }
                }
            }
        }
        
        if (isSuccess)
            pageMsg= 'Data Saved Successfully';
        else
            pageMsg = 'An error occurred while processing this request.  Please contact your Administrator for more details.';
        onChangeTotal();   
		return null;            
    }
    
    
    /*
        Method called remotely through Java Script to submit Budget records for Approval for selected user for selected year.
    */
    @RemoteAction
    global static String submitForApproval(String selYear,String selUser){
        User usr = [SELECT Id,Name,ManagerId FROM User WHERE Id = :selUser LIMIT 1];
        String userEmail = '';
        if (null != usr.ManagerId){
            userEmail = [SELECT Id,Email FROM User WHERE Id = :usr.ManagerId].Email;
        }
        
        List<Budget__c> budgets = new List<Budget__c>();
        for (Budget__c budget : [SELECT Id FROM Budget__c WHERE Year__c = :selYear AND BudgetAE__c = :selUser AND Status__c = 'Not Submitted' AND Account__r.RecordType.Name != 'Competitor Account']){
            budget.Status__c = 'Submitted For Approval';
            budgets.add(budget);
        }
        boolean isSuccess = true;
        if (null != budgets && budgets.size() > 0){
            Database.SaveResult[] saveResults = Database.update(budgets,false);
            for (Database.SaveResult saveResult : saveResults){
                if (saveResult.getErrors().size() > 0){
                    for (Database.Error error: saveResult.getErrors()){
                        System.debug('Update Error--'+error);
                        isSuccess = false;
                    }
                }
            }
        }else{
            return 'Budget records have already been submitted or approved';
        }
        
        if (isSuccess){
            if (null != userEmail && userEmail != ''){
                sendEmail(new List<String>{userEmail},'Budget Records Submitted For Approval','Budget Records For Year '+selYear+' have been Submitted For Approval by '+usr.Name);
            }
            return 'Budget Records Submitted For Approval';
        }
        else
            return 'An error occurred while processing this request.  Please contact your Administrator for more details.';
    }
    
    
     /*
        Method called remotely through Java Script to Approve Budget records for Approval for selected user/all reporting users for selected year.
    */
    @RemoteAction
    global static String approveBudgets(String selYear,String selUser,Boolean allAE){
        List<Budget__c> budgets = new List<Budget__c>();
        Set<String> aeIds = new Set<String>();
        List<String> userEmailIds = new List<String>();
        if (allAE){
            for (User usr : [SELECT Id,Email FROM User WHERE UserRole.ParentRoleID != NULL AND isActive = true AND ManagerId = :selUser 
            //AND Designation__c NOT IN :filteredDesignation
            ]){
                aeIds.add(usr.Id);
                if (null != usr.Email && usr.Email != ''){
                    userEmailIds.add(usr.Email);
                }
            }
        }else{
            aeIds.add(selUser);
            String emailId = [SELECT Id, Email FROM User WHERE Id IN :aeIds].Email;
            if (null != emailId && emailId != ''){
                userEmailIds.add(emailId);
            }
        }
        for (Budget__c budget : [SELECT Id FROM Budget__c WHERE Year__c = :selYear AND BudgetAE__c IN :aeIds AND Status__c != 'Approved']){
            budget.Status__c = 'Approved';
            budgets.add(budget);
        }
        boolean isSuccess = true;
        if (null != budgets && budgets.size() > 0){
            Database.SaveResult[] saveResults = Database.update(budgets,false);
            for (Database.SaveResult saveResult : saveResults){
                if (saveResult.getErrors().size() > 0){
                    for (Database.Error error: saveResult.getErrors()){
                        System.debug('Update Error--'+error);
                        isSuccess = false;
                    }
                }
            }
        }else{
            return 'Budget records have already been approved';
        }
        
        if (isSuccess){
            if (!userEmailIds.isEmpty()){
                sendEmail(userEmailIds,'Budget Records Approved','Budget Records For Year '+selYear+' have been Approved by Your Manager');
            }
            return 'Budget Records Approved';
        }
        else
            return 'An error occurred while processing this request.  Please contact your Administrator for more details.';
    }
    
    
    /*
        Method called remotely through Java Script to Reject Budget records submitted for Approval for selected user/all reporting users for selected year.
    */
    @RemoteAction
    global static String rejectBudgets(String selYear,String selUser,Boolean allAE){
        List<Budget__c> budgets = new List<Budget__c>();
        Set<String> aeIds = new Set<String>();
        List<String> userEmailIds = new List<String>();
        if (allAE){
            for (User usr : [SELECT Id,Email FROM User WHERE UserRole.ParentRoleID != NULL AND ManagerId = :selUser AND isActive = true 
            //AND Designation__c NOT IN :filteredDesignation
            ]){
                aeIds.add(usr.Id);
                if (null != usr.Email && usr.Email != ''){
                    userEmailIds.add(usr.Email);
                }
            }
        }else{
            aeIds.add(selUser);
            String emailId = [SELECT Id, Email FROM User WHERE Id IN :aeIds].Email;
            if (null != emailId && emailId != ''){
                userEmailIds.add(emailId);
            }
        }
        for (Budget__c budget : [SELECT Id FROM Budget__c WHERE Year__c = :selYear AND BudgetAE__c IN :aeIds AND Status__c = 'Submitted For Approval' AND Account__r.RecordType.Name != 'Competitor Account']){
            budget.Status__c = 'Not Submitted';
            budgets.add(budget);
        }
        boolean isSuccess = true;
        if (null != budgets && budgets.size() > 0){
            Database.SaveResult[] saveResults = Database.update(budgets,false);
            for (Database.SaveResult saveResult : saveResults){
                if (saveResult.getErrors().size() > 0){
                    for (Database.Error error: saveResult.getErrors()){
                        System.debug('Update Error--'+error);
                        isSuccess = false;
                    }
                }
            }
        }else{
            return 'Budget records have already been approved/rejected.';
        }
        
        if (isSuccess){
            if (!userEmailIds.isEmpty()){
                sendEmail(userEmailIds,'Budget Records Rejected','Budget Records For Year '+selYear+' have been Rejected by Your Manager');
            }
            return 'Budget Records Rejected';
        }
        else
            return 'An error occurred while processing this request.  Please contact your Administrator for more details.';
    }
    
    
     /*
        Method to set Row Editability on the page.
    */
        @TestVisible
    private static void setRowEditable(BudgetRow row,Boolean isSuperUser, Boolean ownerRecordFound, Boolean isRowEditable, String selYear){
        if (isSuperUser){
            row.rowEditable = true;
        }else if (ownerRecordFound){
            if (isRowEditable){
                row.rowEditable = true;
            }
        }else if (selYear.equals(budgetYr)){
            row.rowEditable = true;
        }
    }
    
    
    /*
        Method to send Approval emails.
    */
    private static void sendEmail(List<String> emailTo, String mailSubject, String mailText){
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        mail.setToAddresses(emailTo);
        mail.setSubject(mailSubject);
        mail.setPlainTextBody(mailText);
        if (!Test.isRunningTest())
            Messaging.sendEmail(new List<Messaging.SingleEmailMessage> {mail});
    }
    
    
     /*
        Method to create a Budget Row for display.
    */
    private static BudgetRow createBudgetRow(String rowId, String rowLabel){
        BudgetRow row = new BudgetRow();
        row.rowId = rowId;
        row.rowLabel = rowLabel;
        return row;
    }
    
    
     /*
        Method to create a LSM Role Budget Rows for display.
    */
    private static List<BudgetRow> createLSMBudgetRows(Map<String,BudgetRow> rowMap, String selYear){
        List<BudgetRow> newRows = new List<BudgetRow>();
        List<String> LSMRows = new List<String>{'LSM Budget Override'};
        for (String LSMRow : LSMRows){
            BudgetRow row = new BudgetRow();
            row.rowId = LSMRow;
            row.rowLabel = LSMRow;
            if (selYear.equals(budgetYr)){
                row.rowEditable = true;
            }
            newRows.add(row);
            rowMap.put(LSMRow,row);
        }
        return newRows;
    }
    /*
        Method to set fetch all the Products to offer.
    */
    private List<String> getAllProducts()
    {
   	   Schema.DescribeFieldResult fieldResult =	   Budget__c.Product_Line__c.getDescribe();
	   List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
	   List<String> options = new List<String>();     
	   for( Schema.PicklistEntry f : ple)
	   {
	      options.add(f.getValue());
	   } 
    	return options;
    }
        
    
    /*
        Wrapper class to display Budget Data on Grid
    */
    public class BudgetRow {
        /* String to hold Row unique Id */
        public String rowId {get; set;}
        /* String to hold Row Label */
        public String rowLabel {get; set;}
        /* String to hold user Id for aggregated data */
        public String userId{get; set;}
        /* Array to hold amounts for 12 months */
        public List<Integer> amounts {get; set;}
        public List<budgetAmounts> allAmounts {get; set;}
        /*Boolean to define if a row can be edited */
        public Boolean rowEditable {get; set;}
        
        public BudgetRow()
        { 
        	rowEditable = false;
        	amounts = new List<Integer>{0,0,0,0,0,0,0,0,0,0,0,0,0};
        	allAmounts = new List<budgetAmounts>();
        	for(Integer amnt : amounts)
        	{
        		budgetAmounts bamount = new budgetAmounts(amnt);
        		bamount.amount = String.valueOf(amnt);
        		allAmounts.add(bamount);
        	}
        	
        }
        public BudgetRow(String rowId,String rowLabel,String userId,List<Integer> amounts )
        {
        	this.rowId = rowId;
        	this.rowLabel = rowLabel;
        	this.userId = userId;
        	this.amounts = amounts;
        	for(Integer amnt : amounts)
        	{
        		budgetAmounts bamount = new budgetAmounts(amnt);
        		bamount.amount = String.valueOf(amnt);
        		allAmounts.add(bamount);
        	}
        	
        }

        /*
            Method to set Amount for specific month
        */
        public void setAmount(Integer amount, String month){
        	try
        	{
	        	System.debug(this.amounts);
	        	if(month != null)
	            this.amounts[Integer.valueOf(month)-1]=amount;
	            else
	            this.amounts[0]=amount;
	            budgetAmounts bamount = new budgetAmounts(amount);
	            this.allAmounts[Integer.valueOf(month)-1]=bamount;
        	}
        	catch(exception e)
        	{
        		System.debug(e.getMessage());
        	}
        }
    }    
		public class budgetAmounts
        {
        	public String amount {get; set;}
        	
        	public budgetAmounts(Integer Amount)
        	{
        		this.amount = String.valueOf(Amount);
        	}
        	
        }
    
    public PageReference Redirect() {
    PageReference ref= new PageReference('/lightning/n/Budgeting_Tool');
    ref.setredirect(true);
    return ref;
    }
        
}