public with sharing class SRCommissionCalendarController{ 
public  List<Splash_Page__c> Records {get; set;} 
public  Id CurrUser;
public Boolean showAck  {get; set;}

    public SRCommissionCalendarController()
    { 
    showAck = false;
    }

    public  PageReference SplashInit()
    {
        String numSecondsSinceLogin = System.Label.Splash_Page_Redirect_Seconds_Desktop;
        if (!needToAck() && UserInfo.getUiThemeDisplayed() != 'Theme4t')  // mobile can't handle PageRefrences
        {
            if (getNumSecondsSinceLogin() > Integer.valueOf(numSecondsSinceLogin)) {
                return null;
            } else {
                return SplashRedirect();
            }
            
        }
        return null;
    }

    private  Boolean needToAck() {
        CurrUser = Userinfo.getUserId();

        if (UserInfo.getUiThemeDisplayed() == 'Theme4t')
        {        
            Records = [select Id, Name,recordType.Name, Message__c from Splash_Page__c where Platform__c in ('Mobile','Both') and Start_Date__c <= TODAY and End_Date__c >= TODAY AND recordtype.Name = 'Commission Calendar' order by End_Date__c desc];
        }
        else
        {
            Records = [select Id, Name, Message__c from Splash_Page__c where Platform__c in ('Desktop','Both') and Start_Date__c <= TODAY and End_Date__c >= TODAY AND recordtype.Name = 'Commission Calendar' order by End_Date__c desc];
        }
 
        
        System.Debug(Records);   
        
        return showAck;
    }

    private Integer getNumSecondsSinceLogin() {
        Datetime loginTime;
        Datetime rightNow = Datetime.now();
        try {
            LoginHistory myLogin = [SELECT Application,Browser,Id,LoginTime,LoginType,LoginUrl,Platform,Status,UserId 
                                    FROM LoginHistory 
                                    WHERE UserId = :Userinfo.getUserId() ORDER BY LoginTime DESC limit 1];
            loginTime = myLogin.LoginTime;        
        } catch (Exception ex) {
            loginTime = rightNow;
        }
        Integer secondsSinceLogin = ((rightNow.getTime() - loginTime.getTime()) / 1000.0).intValue();
        system.debug('--------->> secondsSinceLogin = ' + secondsSinceLogin);
        return secondsSinceLogin;
    }
    
    @RemoteAction public static String mobileRedirect() {
        SRCommissionCalendarController SR = new SRCommissionCalendarController();
        String retVal = System.Label.Splash_Page_Redirect;
        if (SR.getNumSecondsSinceLogin() > Integer.valueOf(System.Label.Splash_Page_Redirect_Seconds_Mobile))
            return '';
        if (!SR.needToAck() && UserInfo.getUiThemeDisplayed() == 'Theme4t')
            return retVal;
        return '';
    }
    
    public  PageReference SplashRedirect()
    { 
        String userAgent = ApexPages.currentPage().getHeaders().get('User-Agent');
        if (userAgent != null && userAgent.contains('iPhone')) {
            PageReference pr = new PageReference('/');
            pr.setRedirect(true);
            return pr;
        }   
        PageReference homePage = new PageReference(System.Label.LEX_BASE_URL + 'home');
        homePage.setRedirect(true);
        return homePage;
    }
    @RemoteAction public static List<Splash_Page__c> getAnnouncements() {
        SRCommissionCalendarController mySplash = new SRCommissionCalendarController();
        mySplash.needToAck();
        return mySplash.Records;
    }
}