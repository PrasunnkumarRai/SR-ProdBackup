global with sharing class BookedSponsorshipEmailController {

    global static String bsId {get; set; }
    global static List < FirstRightToRefusalWrapper > wrapperList {   get;  set;   }

    global BookedSponsorshipEmailController() {
        System.debug('bsId' + bsId);
        if (String.isNotBlank(bsId) && string.isNotEmpty(bsId)) {
            List < String > templateList = new List < String > ();
            List < Sponsorship_Booking__c > sprBookingList = [Select Id, name, Network_Code__c, Template__r.News_Syscode__r.Name, Recordtype.Name, Inventory_Type__c, Quantity__c, Start_Date__c, End_Date__c, Is_Sponsorship_Cancelled__c, Linear_Revenue__c, Streaming_Revenue__c, First_Right_to_Refusal__c, Confirm_Right_to_Refusal__c from Sponsorship_Booking__c where Booked_Sponsorship__c =: bsId];
            System.debug('sprBookingList' +sprBookingList);
            List < SponsorshipController.allSelectedTemplatesWrapper > allSelectedTemplatesWrapperList = new List < SponsorshipController.allSelectedTemplatesWrapper > ();
            for (Sponsorship_Booking__c sb: sprBookingList) {
                System.debug('sb' +sb);
                SponsorshipController.allSelectedTemplatesWrapper astw = new SponsorshipController.allSelectedTemplatesWrapper();
                astw.sd = String.valueOf(sb.Start_Date__c);
                astw.ed = String.valueOf(sb.End_Date__c);
                astw.recordID = sb.Id;
                astw.tempID = sb.Template__c;
                allSelectedTemplatesWrapperList.add(astw);

            }
            wrapperList = new List < FirstRightToRefusalWrapper > ();
            Map < String, SponsorshipController.allSelectedTemplatesWrapper > mapAllSelectedWrapper = new Map < String, SponsorshipController.allSelectedTemplatesWrapper > ();
            list < String > sprIDList = new List < String > ();

            for (SponsorshipController.allSelectedTemplatesWrapper ats: allSelectedTemplatesWrapperList) {
                sprIDList.add(ats.recordID);
                mapAllSelectedWrapper.put(ats.tempID, ats);
            }
            List < Sponsorship_Booking__c > sprList = [Select ID, Booked_Sponsorship__r.Account__c, End_Date__c, Start_Date__c, Template__c, Linear_Revenue__c, Streaming_Revenue__c from Sponsorship_Booking__c where Template__c in: sprIDList AND First_Right_to_Refusal__c = true];
            if (sprList.size() > 0) {
                for (Sponsorship_Booking__c sprBook: sprList) {
                    //if(accID == sprBook.Booked_Sponsorship__r.Account__c)
                    //{
                    if (mapAllSelectedWrapper.containsKey(sprBook.Template__c)) {
                        if (SponsorshipController.dateOverlappingChecker(Date.parse(mapAllSelectedWrapper.get(sprBook.Template__c).sd), Date.parse(mapAllSelectedWrapper.get(sprBook.Template__c).ed), sprBook.Start_Date__c, sprBook.End_Date__c)) {
                            FirstRightToRefusalWrapper wrapperObj = new FirstRightToRefusalWrapper();
                            wrapperObj.Account = sprBook.Booked_Sponsorship__r.Account__c;
                            wrapperObj.bookingID = sprBook.ID;
                            wrapperObj.accountID = sprBook.Booked_Sponsorship__r.Account__c;
                            wrapperObj.startDate = sprBook.Start_Date__c;
                            wrapperObj.endDate = sprBook.End_Date__c;
                            wrapperObj.recordID = sprBook.Template__c;
                            wrapperObj.LinearRevenue = sprBook.Linear_Revenue__c;
                            wrapperObj.StreamingRevenue = sprBook.Streaming_Revenue__c;
                            wrapperList.add(wrapperObj);
                        }
                    }

                    //}
                }
            }
        }
    }

    global List < Sponsorship_Booking__c > sbs {
        get {
             if (string.isNotBlank(bsId) && string.isNotEmpty(bsId)) {
                return [Select Id, name, Network_Code__c, Template__r.News_Syscode__r.Name, Recordtype.Name, Opportunity__r.Owner.Name, Inventory_Type__c, Quantity__c, Start_Date__c, End_Date__c, Is_Sponsorship_Cancelled__c, Linear_Revenue__c, Streaming_Revenue__c from Sponsorship_Booking__c where Booked_Sponsorship__c =: bsId AND Recordtype.Name = 'Original'];  } else {return new List < Sponsorship_Booking__c >(); }
        }
        set;
    }

    global List < Sponsorship_Booking__c > sbsupdated {
        get { if (string.isNotBlank(bsId) && string.isNotEmpty(bsId)) {
                return [Select Id, name, Network_Code__c, Template__r.News_Syscode__r.Name, Recordtype.Name, Opportunity__r.Owner.Name, Inventory_Type__c, Quantity__c, Start_Date__c, End_Date__c, Is_Sponsorship_Cancelled__c, Linear_Revenue__c, Streaming_Revenue__c from Sponsorship_Booking__c where Booked_Sponsorship__c =: bsId AND Recordtype.Name = 'Updated']; } else {return new List < Sponsorship_Booking__c >();  }
        }
        set;
    }

    global Booked_Sponsorship__c bs {

        get { if (string.isNotBlank(bsId) && string.isNotEmpty(bsId)) {  return [Select Id, Opportunity__r.name, Opportunity__r.AccountID, Opportunity__r.Account.Name, Opportunity__r.Owner.Name, Opportunity__r.Id, Region__c, Status__c, Record_Type__c, (Select ID, Name, Template__r.News_Syscode__r.Name, Network_Code__c, Template__r.RecordType.Name, Linear_Revenue__c, Streaming_Revenue__c from Sponsorship_Bookings__r) from Booked_Sponsorship__c where Id =: bsId];  } else { return new Booked_Sponsorship__c();  }
      
    }
        set;
    }

    global String bsLink {
        get {
            return ApexPages.currentPage().getHeaders().get('Host') + '/' + bs.Id;
        }
        set;
    }

    global String oppLink {
        get {
            return ApexPages.currentPage().getHeaders().get('Host') + '/' + bs.Opportunity__r.Id;
        }
        set;
    }
    global String accLink {
        get {
            return ApexPages.currentPage().getHeaders().get('Host') + '/' + bs.Opportunity__r.AccountID;
        }
        set;
    }

    global String NewLine {
        get {
            return '\r\n';
        }
        set;
    }
    public class FirstRightToRefusalWrapper {

        public String name {  get; set; }
        public String bookingID {  get;  set; }
        public String Account {  get; set;  }
        public String accountID {  get;  set;   }
        public Date startDate { get; set; }
        public Date endDate {  get;  set;   }
        public String recordID {  get; set; }
        public Decimal LinearRevenue { get; set;   }
        public Decimal StreamingRevenue { get;set;  }
    }
}