global class FileDashboardController{

  


    
    @AuraEnabled
   global static List<ContentVersion> getContentDocumentData(String startDate,String endDate){
    try{
        System.debug(Limits.getLimitQueryRows());
        System.debug('@@startdate:: '+startdate);
        System.debug('@@enddate:: '+enddate);

        Date sDate=Date.valueof(startDate);
        Date eDate=Date.valueof(endDate);
        // List<ContentDocumentLink> contentList= new List<ContentDocumentLink>();
        // contentList=[SELECT ContentDocumentId, ContentDocument.CreatedDate, LinkedEntity.Type, ContentDocument.ContentSize,ContentDocument.CreatedBy.Profile.Name,ContentDocument.fileType,ContentDocument.fileExtension 
        //        FROM ContentDocumentLink
        //         WHERE ContentDocument.CreatedDate >= :sDate 
        //         AND ContentDocument.CreatedDate <=:eDate  
        //         AND ContentDocument.CreatedBy.Profile.Name != 'Integration User'];


        List<ContentVersion> contentList= new List<ContentVersion>();
        contentList= [SELECT FirstPublishLocation.Type,ContentSize,CreatedBy.Profile.Name,fileType,fileExtension 
               FROM ContentVersion
                WHERE CreatedDate >= :sDate AND CreatedDate<=:eDate
                AND CreatedBy.Profile.Name != 'Integration User' //AND FirstPublishLocationId != Null
                ];
                System.debug('Data Size For uploade files =>'+contentList.size());
        
        return ContentList;

    }catch(Exception ex){
        Log4SF.logMessage('FileDashboardController','getContentDocumentData',ex.getMessage(),ex,UserInfo.getUserId(),'');
        return null;
    }
       
      
    }

    @AuraEnabled(cacheable=true)
    public static Map<String,Integer> getOrgLimit(){
        try {
            Map<String,System.OrgLimit> limitsMap = OrgLimits.getMap();
            System.OrgLimit fileStorage = limitsMap.get('FileStorageMB');
             System.debug('Limit Name: ' + fileStorage.getName());
             System.debug('Usage Value: ' + fileStorage.getValue());
             System.debug('Maximum Limit: ' + fileStorage.getLimit());
             Map<String,Integer> limitData = new  Map<String,Integer>();
             limitData.put('Usage Value',fileStorage.getValue());
             limitData.put('Maximum Limit',fileStorage.getLimit());

             return limitData;

            
        } catch (Exception ex) {
            Log4SF.logMessage('FileDashboardController','getOrgLimit',ex.getMessage(),ex,UserInfo.getUserId(),'');
            return null;
        }
    }


   
    @AuraEnabled
    public static Decimal getContentSize(String startDate,String endDate) {
        try{   
            Date sDate=Date.valueof(startDate);
            Date eDate=Date.valueof(endDate);
    
        
        
            Decimal sumContentSize90Days = 0;
            
            List<AggregateResult> contentVersions90Days = [SELECT SUM(ContentSize) 
                                                          FROM ContentVersion 
                                                          WHERE CreatedDate >= :sDate 
                                                              AND CreatedDate <= :eDate
                                                              AND CreatedBy.Profile.Name != 'Integration User'];
            
            if (!contentVersions90Days.isEmpty() && contentVersions90Days[0].get('expr0') != null) {
                sumContentSize90Days = (Decimal)contentVersions90Days[0].get('expr0');
            }
            
            return sumContentSize90Days;
        }catch(Exception ex){
            Log4SF.logMessage('FileDashboardController','getContentSize',ex.getMessage(),ex,UserInfo.getUserId(),'');
            return null;
        }
     
    }
}