public with sharing class SyscodeController {
    @AuraEnabled
    public static Syscode_and_Network__c syscodeDetails(String sysCode){
        Syscode_and_Network__c syscodeDetail= new Syscode_and_Network__c();
        syscodeDetail =[Select ID,Name,Market__c,Network_Code__c,State__c,System_Name__c,System_Type__c,MVPD__c,External_Id__c,Syscode__c,Is_Duplicate__c from Syscode_and_Network__c where Id = :sysCode];
        return sysCodeDetail;
    }
    
    @AuraEnabled
    public static Syscode_and_Network__c updateSyscode(String syscodeId, String syscodeName, String mvpd, String externalId, String systemType, String market, String systemName, String state, String networkCode,String sysCode, Boolean check){
        System.debug('syscodeName->'+syscodeName+'mvpd->'+mvpd+' '+'externalId->'+externalId+' '+'systemType->'+systemType+' '+'market->'+market+' '+'systemName->'+systemName+' '+'state->'+state+' '+'networkCode->'+networkCode+' '+'sysCode->'+sysCode+' '+'check->'+check );
        Syscode_and_Network__c queriedSysCode=[Select Id, Name,MVPD__c,External_Id__c,System_Type__c,Market__c,System_Name__c,State__c,Network_Code__c,Syscode__c,Is_Duplicate__c from Syscode_and_Network__c where Id =: syscodeId];
        System.debug('queriedSysCode :: '+ queriedSysCode);
        if(syscodeName != queriedSysCode.Name){
            UpdateAllSponsorship(syscodeId,syscodeName);
        }
        queriedSysCode.Name=syscodeName;
        queriedSysCode.MVPD__c= mvpd;
        queriedSysCode.External_Id__c=externalId;
        queriedSysCode.System_Type__c=systemType;
        queriedSysCode.Market__c=market;
        queriedSysCode.System_Name__c= systemName;
        queriedSysCode.State__c=state;
        queriedSysCode.Network_Code__c=networkCode;
        queriedSysCode.Syscode__c=syscodeName;
        // queriedSysCode.Is_Duplicate__c=check;
        update queriedSysCode;
        
        return queriedSysCode;
    }
    
    @AuraEnabled
    public static Boolean syscodeValidation(String givenSyscode){
        System.debug('Syscode provioded by user-->'+givenSyscode);
        List<Syscode_and_Network__c> queriedSysCode=[Select Id,Name from Syscode_and_Network__c where Name =: givenSyscode];
        for(Syscode_and_Network__c sys: queriedSysCode){
            if(sys.Name==givenSyscode){
                return true;
            }
        }
        return false;
    }
    
    @AuraEnabled
    public static Syscode_and_Network__c mergeSyscodeProcess(String syscodeId, String mvpd, String externalId, String systemType, String market, String systemName, String state, String networkCode, Boolean check, String childSyscodeId){
        System.debug('mvpd->'+mvpd+' '+'externalId->'+externalId+' '+'systemType->'+systemType+' '+'market->'+market+' '+'systemName->'+systemName+' '+'state->'+state+' '+'networkCode->'+networkCode+' '+' '+'check->'+check+' '+'childSyscodeId-->'+childSyscodeId);
        Syscode_and_Network__c queriedSysCode=[Select Id,MVPD__c,External_Id__c,System_Type__c,Market__c,System_Name__c,State__c,Network_Code__c,Syscode__c,Is_Duplicate__c from Syscode_and_Network__c where Id =: syscodeId];
        System.debug('queriedSysCode :: '+ queriedSysCode);
        queriedSysCode.MVPD__c= mvpd;
        queriedSysCode.External_Id__c=externalId;
        queriedSysCode.System_Type__c=systemType;
        queriedSysCode.Market__c=market;
        queriedSysCode.System_Name__c= systemName;
        queriedSysCode.State__c=state;
        queriedSysCode.Network_Code__c=networkCode;
        // queriedSysCode.Is_Duplicate__c=check;
        update queriedSysCode;
        
        delete[SELECT id FROM Syscode_and_Network__c where id=: childSyscodeId];
        return queriedSysCode;
    }
    
    
    @AuraEnabled
    public static List<Templates__c> SponsorshipDetails(String givenSyscodeId){
        List<Templates__c> templateList = [Select Id, Name, Start_Date__c, End_Date__c from Templates__c where News_Syscode__r.Id =: givenSyscodeId];
        system.debug('Sponsorship Details-->'+templateList);
        return templateList;
    }
    
    //This method is intended for updating Sponsorships and Sponsorship Bookings in case the Syscode name is changed.
    @AuraEnabled
    public static void UpdateAllSponsorship(string syscodeId,string sysCode){
        try {
            system.debug('sysCode'+sysCode);
            system.debug('syscodeId'+syscodeId);
            
            List<Templates__c>  tempList = [Select ID,Name,News_Syscode__r.name, News_Syscode__c from Templates__c where News_Syscode__r.Id =: syscodeId];
            if(tempList.size()>0){
                List<Sponsorship_Booking__c> listSpon=[SELECT Id, Template__r.Name, Name FROM Sponsorship_Booking__c WHERE Template__c in:tempList];  
                system.debug('listSponSize'+listSpon.size());
                string SyscodeName=tempList[0].News_Syscode__r.name;
                system.debug('tempList'+tempList.size());
                system.debug('SysCode'+tempList[0].News_Syscode__r.name);
                List<Templates__c> Templst=new  List<Templates__c>();
                List<Sponsorship_Booking__c> Sponlst=new  List<Sponsorship_Booking__c>();
                
                // if(SyscodeName!=sysCode){
                    
                    for(Templates__c temp:tempList){
                        if(temp.News_Syscode__r.name != sysCode){
                            string SponsorshipName=temp.Name;
                            system.debug('SponsorshipName'+SponsorshipName);
                            string addNewSyscode=sysCode;
                            string NameWithoutSyscode=SponsorshipName.substringAfter('-').trim();
                            string NewSponsorshipName =addNewSyscode +' - '+ NameWithoutSyscode;
                            system.debug('NewSponsorshipName '+NewSponsorshipName);
                            //  Templates__c tempupdate=new Templates__c();
                            temp.Name=NewSponsorshipName;
                            Templst.add(temp);
                        }
                        
                    }
                    if(listSpon.size() > 0){
                        for(Sponsorship_Booking__c spon:listSpon){
                            string BookedSponsorshipName=spon.Name;
                            system.debug('BookedSponsorshipName '+BookedSponsorshipName);
                            
                            string NewSyscode=sysCode;
                            string NameWithSyscode=BookedSponsorshipName.substringAfter('-').trim();
                            string NewBookedSponsorshipName =NewSyscode +' - '+ NameWithSyscode;
                            system.debug('NewBookedSponsorshipName '+NewBookedSponsorshipName);
                            spon.Name=NewBookedSponsorshipName;
                            Sponlst.add(spon);
                        } 
                    }
                    
                    
                    system.debug('Templst'+Sponlst.size());
                    
                    system.debug('Templst'+Templst.size());
                    
                    if(Templst.size() > 0){
                        update Templst;
                    }
                    if(Sponlst.size() > 0){
                        update Sponlst;
                    }
                //     }else{
                //     system.debug('Syscode is same');
                // }
            }
            
                
                
                
                //system.debug('listSpon '+listSpon.size());
            
            
            
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }


    @AuraEnabled //This method is intended for updating Sponsorships and Sponsorship Bookings in case the Syscode merge process.
    public static void UpdateAllSponsorshipDuringMerge(string childSyscodeId, string parentSyscodeName, String parentSyscodeId) {
        try {
            List<Templates__c> tempList = [SELECT ID, Name, News_Syscode__r.name, News_Syscode__c FROM Templates__c WHERE News_Syscode__r.Id =: childSyscodeId];
            
            // Check if tempList is not empty before proceeding
            if (!tempList.isEmpty()) {
                String syscodeName = tempList[0].News_Syscode__r.name;
				  System.debug('syscodeName::'+syscodeName);
                System.debug('parentSyscodeName::'+parentSyscodeName);
                // if (syscodeName != parentSyscodeName) {
                    List<Templates__c> templst = new List<Templates__c>();
                    for (Templates__c temp : tempList) {
                        if(temp.News_Syscode__r.name != parentSyscodeName){
                            temp.Name = parentSyscodeName +' - ' + temp.Name.substringAfter('-').trim();
                            temp.News_Syscode__c = parentSyscodeId;
                            templst.add(temp);
                        }
                    }

                    if(templst.size() > 0){
                        update templst;
                    }

                    List<Sponsorship_Booking__c> listSpon = [SELECT Id, Template__r.Name,News_Syscode__c, Name FROM Sponsorship_Booking__c WHERE Template__c IN :tempList];
                    List<Sponsorship_Booking__c> sponlst = new List<Sponsorship_Booking__c>();
                    if(listSpon.size() > 0){
                        for (Sponsorship_Booking__c spon : listSpon) {
                            spon.Name = parentSyscodeName +' - ' + spon.Name.substringAfter('-').trim();
                            spon.News_Syscode__c = parentSyscodeId;
                            sponlst.add(spon);
                        }
                        if(sponlst.size() > 0){
                            update sponlst;
                        }
                    }
                    
                // } else {
                //     System.debug('Syscode is the same');
                // }
            } else {
                System.debug('No Templates__c records found for the provided childSyscodeId');
            }
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
}