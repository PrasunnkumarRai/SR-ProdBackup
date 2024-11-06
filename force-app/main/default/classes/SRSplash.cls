public with sharing class SRSplash{ 
public  List<Splash_Page__c> Records {get; set;} 
public  List<Splash_Ack__c> Acks {get; set;} 
public  List<Splash_Page__c> FinalSplashes {get; set;}
public  Id CurrUser;
public Boolean showAck  {get; set;}

    public SRSplash()
    { 
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
            Records = [select Id, Name, Message__c from Splash_Page__c where Platform__c in ('Mobile','Both') and Start_Date__c <= TODAY and End_Date__c >= TODAY AND recordtype.Name != 'Commission Calendar' order by End_Date__c desc];
        }
        else
        {
            Records = [select Id, Name, Message__c from Splash_Page__c where Platform__c in ('Desktop','Both') and Start_Date__c <= TODAY and End_Date__c >= TODAY AND recordtype.Name != 'Commission Calendar' order by End_Date__c desc];
        }
 
        
        System.Debug(Records);

        Acks = 
        [select Splash_Page__c from Splash_Ack__c where User__c = :CurrUser];
        System.Debug(Acks);        
        
        FinalSplashes = Records.clone();
        System.debug('in needToAck, FinalSplashes = ' + FinalSplashes);
        
     ////   Integer i = 0;
        for (Splash_Page__c sp : Records)
        {
            Integer i = FinalSplashes.size() - 1;
            for (Splash_Ack__c sa : Acks)
            {
                if (sa.Splash_Page__c == sp.Id)
                {
                    System.Debug(i);
                    if (FinalSplashes.size() == 0) break;
                    FinalSplashes.remove(i);
                    i--;
                    System.Debug(i);        
                }                        
            }
            i++;
        }
        system.debug('========>> Records =       ' + Records);
        system.debug('========>> finalsplashes = ' + finalsplashes);
        showAck = (finalsplashes.size() > 0 ? true : false);
        system.debug('========>> showAck = ' + showAck);
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

    @RemoteAction public static Boolean showAckElements() {
        SRSplash mySplash = new SRSplash();
        return mySplash.needToAck(); 
    }

    @RemoteAction public static String mobileRedirect() {
        SRSplash mySplash = new SRSplash();
        String retVal = System.Label.Splash_Page_Redirect;
        if (mySplash.getNumSecondsSinceLogin() > Integer.valueOf(System.Label.Splash_Page_Redirect_Seconds_Mobile))
            return '';
        if (!mySplash.needToAck() && UserInfo.getUiThemeDisplayed() == 'Theme4t')
            return retVal;
        return '';
    } 

    @RemoteAction public static List<Splash_Page__c> getAnnouncements() {
        SRSplash mySplash = new SRSplash();
        mySplash.needToAck();
        return mySplash.Records;
    }

    @RemoteAction public static String SplashAckMobile()
    {   
        system.debug('===========>> in SplashAckMobile!!!!'); 
        SRSplash mySplash = new SRSplash();
        mySplash.needToAck();
        //insert into acks (finalsplashes.id, curr user)
        List<Splash_Ack__c> FinalAcks = new List<Splash_Ack__c>();
        system.debug('===========>> in SplashAckMobile, mySplash.FinalSplashes = ' + mySplash.FinalSplashes); 
        for (Splash_Page__c fs : mySplash.FinalSplashes )
        {
            Splash_Ack__c sa = new Splash_Ack__c();
            sa.Splash_Page__c = fs.Id;
            sa.User__c = mySplash.CurrUser;
            FinalAcks.add(sa);
        }

        if (FinalAcks.size() > 0)
        {
            insert FinalAcks;
        }
        String retVal = System.Label.Splash_Page_Redirect;
            return retVal;
    }
    

    public  PageReference SplashAck()
    {    
        //insert into acks (finalsplashes.id, curr user)
        List<Splash_Ack__c> FinalAcks = new List<Splash_Ack__c>();
        system.debug('------------->> FinalSplashes = ' + FinalSplashes);
        for (Splash_Page__c fs : FinalSplashes )
        {
            Splash_Ack__c sa = new Splash_Ack__c();
            sa.Splash_Page__c = fs.Id;
            sa.User__c = CurrUser;
            FinalAcks.add(sa);
        }

        if (FinalAcks.size() > 0)
        {
            insert FinalAcks;
        }
        
        return SplashRedirect();
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
}