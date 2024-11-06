public without sharing class FileEnhanceController {

    public static List < ContentDistribution > filesToSendExternally {   get;  set;   }
    public static String messageToSendExternally {   get;  set;   }
    public static String emailSubjectforExternalSharing {   get;  set;   }

    //Creating a method to display and search the files related to the current record.
    //This method will be called from the LWC when the record page loads or when the user searches for a file name in the search box.
    @AuraEnabled(cacheable = true)
    public static List < ContentVersion > showData(String id, String searchKey) {
        try {
            if (String.isNotEmpty(id)) {
                List < sObject > lst;
                String str = searchKey + '%';
                List<ContentDocumentLink> cdList = [SELECT ContentDocumentId FROM ContentDocumentLink WHERE LinkedEntityId = : id];
                List<ID> cdIDList = new List<ID>();
                for(ContentDocumentLink cd : cdList)
                {
                  cdIDList.add(cd.ContentDocumentID);
                }
                if(searchKey == '' && cdIDList.size() > 0){
                  lst = [SELECT Id,ContentDocumentId,FirstPublishLocationId,Title,LastModifiedDate,FileExtension,ContentSize FROM ContentVersion WHERE  contentDocumentId in : cdIDList] ;
                } else {
                    lst = [SELECT Id, ContentDocumentId, FirstPublishLocationId, Title, LastModifiedDate, FileExtension, ContentSize FROM ContentVersion WHERE contentDocumentId in : cdIDList AND(Title like: str OR FileExtension like: str)];
                }
                return lst;
            }
        } catch (Exception ex) {
            Log4SF.logMessage('FileEnhanceController', 'showData', ex.getMessage(), ex, UserInfo.getUserId(), null, '');
            System.debug('errror msg in showData::' + ex);
        }
        return null;
    }


    //Creating a method to download the selected files.
    //This method will be called from the LWC when the user clicks on Download Selected button or the user clicks the download button from the drop down of any file.
    @AuraEnabled(cacheable = true)
    public static Map < ID, String > getRelatedFilesByRecordId(String recordId, String id) {
        try {
            List < ID > fIDs = id.split(',');
            List < ContentDocumentLink > files = [SELECT ContentDocumentId FROM ContentDocumentLink WHERE LinkedEntityId =: recordId];
            List < ID > fileIDs = new List < ID > ();
            for (ContentDocumentLink docLink: files) {
                fileIDs.add(docLink.ContentDocumentId);
            }
            List < ContentVersion > docs = [SELECT ContentDocumentId, FileExtension, Title FROM ContentVersion WHERE ContentDocumentId IN: fileIDs AND Id IN: fIDs];
            Map < ID, String > mapIdTitle = new Map < ID, String > ();
            for (ContentVersion docLink: docs) {
                mapIdTitle.put(docLink.ContentDocumentId, docLink.Title);
            }
            return mapIdTitle;
        } catch (Exception ex) {
            Log4SF.logMessage('FileEnhanceController', 'getRelatedFilesByRecordId', ex.getMessage(), ex, UserInfo.getUserId(), null, '');
            System.debug('errror msg in getRelatedFilesByRecordId::' + ex);
        }
        return null;
    }


    //Creating a method to upload the files.
    //This method will be called from the LWC when the user clicks on upload new version button from the drop down.
    @AuraEnabled
    public static String uploadFile(String fileName, String base64Data, Id recordId, String title, Id contentDocumentId) {
        try {
            Blob myBlob = Blob.valueOf(base64Data);
            ContentVersion cv = new ContentVersion();
            cv.ContentDocumentId = contentDocumentId;
            cv.Title = title;
            cv.PathOnClient = '/' + fileName;
            cv.VersionData = myBlob;
            database.insert(cv, false);
            return 'File uploaded successfully.';
        } catch (Exception ex) {
            Log4SF.logMessage('FileEnhanceController', 'uploadFile', ex.getMessage(), ex, UserInfo.getUserId(), null, '');
            System.debug('errror msg in uploadFile::' + ex);
        }
        return null;
    }

    @AuraEnabled(cacheable = true)
    public static User getUserEmail(String userName, String userId) {
        try {
            return [SELECT Id, Email FROM User WHERE Id =: userId and Name like: userName LIMIT 1];
        } catch (Exception ex) {
            Log4SF.logMessage('FileEnhanceController', 'getUserEmail', ex.getMessage(), ex, UserInfo.getUserId(), null, '');
            System.debug('errror msg in getUserEmail::' + ex);
        }
        return null;
    }


    // Creating a method to create ContentDocumentLink records for Internal sharing
    // This method will be called from the LWC when a user clicks on the Share Button.

    @AuraEnabled
    public static void createConDocLink(List<String> userIds, string fileIDs, string shareType) {
         try {
            system.debug('fileIDList' + fileIDs);
            system.debug('User Ids-->'+userIds);
            List < String > fileIDList = new List < String > ();
            if (fileIDs.indexOf(',') > 0)
                fileIDList = fileIDs.split(',');
            else
                fileIDList.add(fileIDs);


            //To share a file create a content document link.
            // First we will have to verify if the files are already shared with the user?

            if (!userIds.isEmpty() && !fileIDList.isEmpty()) {
                List<ContentDocumentLink> cdLinkListInsert = new List<ContentDocumentLink>();
                List<ContentDocumentLink> cdLinkListUpdate = new List<ContentDocumentLink>();
                
                List<ContentDocumentLink> existingCDLinks = [SELECT ID, ContentDocumentID, shareType, LinkedEntityId 
                                                            FROM ContentDocumentLink 
                                                            WHERE ContentDocumentId IN: fileIDList 
                                                            AND LinkedEntityId IN: userIds];

                Map<String, ContentDocumentLink> mapFileToCDL = new Map<String, ContentDocumentLink>();
                for (ContentDocumentLink cdLink : existingCDLinks) {
                    mapFileToCDL.put(cdLink.ContentDocumentId + '-' + cdLink.LinkedEntityId, cdLink);
                }

                for (String fileID : fileIDList) {
                    for (String userId : userIds) {
                        String mapKey = fileID + '-' + userId;

                        if (!mapFileToCDL.containsKey(mapKey)) {
                            system.debug('creating a new link, the file is not shared with the selected user earlier. '+ userId);
                            ContentDocumentLink cdl = new ContentDocumentLink();
                            cdl.LinkedEntityId = userId;
                            cdl.contentDocumentId = fileID;
                            cdl.shareType = shareType;
                            cdLinkListInsert.add(cdl);
                        } else if (mapFileToCDL.get(mapKey).shareType != shareType) {
                            system.debug('updating the shared link, the file already shared with the selected user. '+ userId);
                            ContentDocumentLink cdl = mapFileToCDL.get(mapKey);
                            cdl.shareType = shareType;
                            cdLinkListUpdate.add(cdl);
                        }
                    }
                }

                if (!cdLinkListInsert.isEmpty())
                    database.insert(cdLinkListInsert, false);
                if (!cdLinkListUpdate.isEmpty())
                    database.update(cdLinkListUpdate, false);
            }
        } catch (Exception ex) {
            Log4SF.logMessage('FileEnhanceController', 'createConDocLink', ex.getMessage(), ex, UserInfo.getUserId(), null, '');
            System.debug('error msg in createConDocLink::' + ex);
            throw new AuraHandledException(ex.getMessage());
        }
    }

    //   @AuraEnabled(cacheable=true)
    //   public static void sendDocumentLinkEmail(String ContentDocumentId, String recipientEmail,String senderName,String senderEmail,String access) {

    //     String[] values = ContentDocumentId.split(',');
    //     System.debug('Internal Sharing-->'+values);
    //     Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
    //     Map<Integer, String> resultMap = new Map<Integer, String>();
    //     for (Integer i = 0; i < values.size(); i++) {
    //       String val = values[i];
    //       ContentDocumentLink cdl = [SELECT Id,ContentDocumentId, ShareType,LinkedEntityId FROM ContentDocumentLink WHERE ContentDocumentId = :val LIMIT 1];
    //       cdl.ShareType = 'V';        
    //       String documentURL = 'https://spectrumreach--preproddev.sandbox.my.salesforce.com/'+val+'?fromEmail=1';
    //       email.setToAddresses(new String[]{recipientEmail});
    //       User currentUser = [SELECT Name, Email FROM User WHERE Id = :UserInfo.getUserId() LIMIT 1];
    //       email.setSubject(currentUser.Name+' has shared a file you can edit on Chatter');
    //       String emailBody =  currentUser.Name + ' has shared a file you can edit on Chatter.';
    //       emailBody += 'File details:\n';
    //       emailBody += 'To view the file, go to: ' + documentURL + '\n';
    //       emailBody += 'This email was sent to the user ' + recipientEmail + '.\n\n';
    //       email.setPlainTextBody(emailBody);
    //       Messaging.SendEmailResult[] result = Messaging.sendEmail(new Messaging.SingleEmailMessage[]{email});
    //     }

    //   }



    //Creating a method to generate the Public links for external file sharing.
    //This method will be called from the LWC when the user clicks on the Share button from the External share tab.
   @AuraEnabled
    public static List < ContentDistribution > generatePublicLink(List < String > contenVersionId,String emails, String messageToSend, Integer expirationDate, Boolean isDownloadable, Boolean isPasswordEnabled) {
        try {
            List < ContentVersion > contentVersions = [SELECT Id, ContentDocumentId, Title FROM ContentVersion WHERE Id IN: contenVersionId];
            Set < Id > contentDocumentIds = new Set < Id > ();
            List < ContentDistribution > condisList = new List < ContentDistribution > ();
            for (ContentVersion cv: contentVersions) {
                contentDocumentIds.add(cv.ContentDocumentId);
                ContentDistribution conDis = new ContentDistribution();
                conDis.Name = cv.Title;
                conDis.ContentVersionId = cv.Id;
                conDis.PreferencesAllowViewInBrowser = true;
                conDis.PreferencesPasswordRequired = true;
                conDis.ExpiryDate = Date.today().addDays(expirationDate);
                conDis.PreferencesAllowOriginalDownload = isDownloadable;
                conDis.PreferencesPasswordRequired = isPasswordEnabled;
                conDis.PreferencesExpires = true;

                condisList.add(conDis);
            }
            database.insert(condisList, false);
            Set < Id > conSetId = new Set < Id > ();
            for (ContentDistribution conDB: condisList) {
                conSetId.add(conDB.Id);
            }
            List < ContentDistribution > contentDistributions = [SELECT Id, Name, ContentDocumentId, ContentDownloadUrl, ContentVersionId, CreatedBy.Name, CreatedDate, DistributionPublicUrl, ExpiryDate, FirstViewDate, IsDeleted, LastModifiedDate, LastViewDate, Password, PdfDownloadUrl, RelatedRecordId, PreferencesPasswordRequired, ViewCount, PreferencesAllowOriginalDownload, PreferencesAllowPDFDownload, SystemModstamp FROM ContentDistribution WHERE Id IN: conSetId];
            //List < ContentDistributionView > contentDistributionViews = [SELECT DistributionId, CreatedDate, IsDownload, IsInternal, ParentviewID FROM ContentDistributionView WHERE DistributionId IN: contentDistributions];
            List < FileExternalsharing__c > fileExtSharingList = new List < FileExternalsharing__c > ();
            List < String > emailList = new List < String > (emails.split(','));
            for (ContentDistribution conDis: contentDistributions) {
                for (String email: emailList) {
                    FileExternalsharing__c fileExObj = new FileExternalsharing__c();
                    fileExObj.Email__c = email;
                    fileExObj.Public_Link_Url__c = conDis.DistributionPublicUrl;
                    fileExObj.Password_protected__c = conDis.PreferencesPasswordRequired;
                    fileExObj.Is_Download__c = conDis.PreferencesAllowOriginalDownload;
                    fileExObj.File_Name__c = conDis.Name;
                    fileExObj.Expiration_Date__c = conDis.ExpiryDate;
                    fileExObj.FileId__c = conDis.ContentDocumentId;
                    // fileExObj.CreatedDate__c = conDis.CreatedDate;
                    // fileExObj.FirstViewDate__c = conDis.FirstViewDate;
                    // fileExObj.LastModificationDate__c = conDis.LastModifiedDate;
                    // fileExObj.LastViewDate__c = conDis.LastViewDate;
                    fileExObj.Password__c = conDis.Password;
                    fileExObj.PdfDownloadURL__c = conDis.PdfDownloadUrl;
                    // fileExObj.ViewCount__c = conDis.ViewCount;
                    // fileExObj.isDeleted__c = conDis.IsDeleted;
                    fileExObj.CreatedName__c = conDis.CreatedBy.Name;
                    fileExtSharingList.add(fileExObj);
                }
            }
            database.insert(fileExtSharingList, false);
            sendEmailforExternalFileShare(emailList,messageToSend,contentDistributions);
            // List < Messaging.SingleEmailMessage > emailMessages = new List < Messaging.SingleEmailMessage > ();
            // if(messageToSend=='null'){
            //     messageToSend='';
            // }
            // String emailBody = '<html><body>' + messageToSend + '<br/><br/><table style="border-collapse: collapse; width: 100%;">' + '<tr style="background-color: #351C75;color:white;"><th style="border: 1px solid #dddddd; text-align: left; padding: 8px;">File Name</th>' + '<th style="border: 1px solid #dddddd; text-align: left; padding: 8px;">Public Link</th>' + '<th style="border: 1px solid #dddddd; text-align: left; padding: 8px;">Password</th></tr>';
            // for (ContentDistribution conDisBution: contentDistributions) {
            //     emailBody += '<tr><td style="border: 1px solid #dddddd; text-align: left; padding: 8px;">' + conDisBution.Name + '</td>' + '<td style="border: 1px solid #dddddd; text-align: left; padding: 8px;">' + conDisBution.DistributionPublicUrl + '</td>' + '<td style="border: 1px solid #dddddd; text-align: left; padding: 8px;">' + conDisBution.Password + '</td></tr>';
            // }
            // emailBody += '</table></body></html>';
            // // List < String > salesforceEmailList = new List < String > ();
            // // salesforceEmailList.add(UserInfo.getUserEmail());
            // EmailTemplate et = [Select Id,HtmlValue from EmailTemplate where DeveloperName = 'SRExternal_file_share_email_template'];
            // String htmlBody = et.HtmlValue;
            // htmlBody = htmlBody.replace('{!User.IsActive}', messageToSend);
            // htmlBody = htmlBody.replace('{!User.City}', emailBody);
            // system.debug('HTML Body-->'+htmlBody);
            // Messaging.SingleEmailMessage message = new Messaging.SingleEmailMessage();
            // // message.toAddresses = salesforceEmailList;
            // message.bccaddresses = emailList;
            // message.subject = emailSubject;
            // message.setTemplateID(et.Id); 
            // message.setHtmlBody(htmlBody);
            // emailMessages.add(message);
            // Messaging.SendEmailResult[] emailResults = Messaging.sendEmail(emailMessages);
            return contentDistributions;
        } catch (Exception ex) {
            Log4SF.logMessage('FileEnhanceController', 'generatePublicLink', ex.getMessage(), ex, UserInfo.getUserId(), null, '');
            System.debug('errror msg in generatePublicLink::' + ex);
        }
        return null;
    }

    public static void sendEmailforExternalFileShare(List<String> emailList, String messageToSend, List<ContentDistribution> contentDistributions) {
        Id userId = UserInfo.getUserId();
        User loggedInUser = [Select Id, Name, Title,Department,Phone,MobilePhone FROM USER WHERE ID =: UserId];
        String SubjectFromCustomLable = System.Label.External_file_share_email_subject;
        String senderName = loggedInUser.Name;
        String extEmailSubject = senderName+' '+ SubjectFromCustomLable;
        system.debug('Email subject-->'+extEmailSubject);
        List<Messaging.SingleEmailMessage> emailMessages = new List<Messaging.SingleEmailMessage>();
        if (messageToSend == 'null') {
            messageToSend = '';
        }
        String emailBody = '<html><body>' + messageToSend + '<br/><br/><table style="border-collapse: collapse; width: 100%;">' + '<tr style="background-color: #001B33;color:white;"><th style="border: 1px solid #dddddd; text-align: left; padding: 8px;">File Name</th>' + '<th style="border: 1px solid #dddddd; text-align: left; padding: 8px;">Public Link</th>' + '<th style="border: 1px solid #dddddd; text-align: left; padding: 8px;">Password</th></tr>';
        
        for (ContentDistribution conDisBution : contentDistributions) {
            emailBody += '<tr><td style="border: 1px solid #dddddd; text-align: left; padding: 8px;">' + conDisBution.Name + '</td>' + '<td style="border: 1px solid #dddddd; text-align: left; padding: 8px;">' + conDisBution.DistributionPublicUrl + '</td>' + '<td style="border: 1px solid #dddddd; text-align: left; padding: 8px;">' + conDisBution.Password + '</td></tr>';
        }
        
        emailBody += '</table></body></html>';
        
        EmailTemplate et = [Select Id, HtmlValue from EmailTemplate where DeveloperName = 'SRExternal_file_share_email_template'];
        String htmlBody = et.HtmlValue;
        // htmlBody = htmlBody.replace('{!User.IsActive}', messageToSend);
        htmlBody = htmlBody.replace('{!Customer.CreatedBy}', emailBody);
        // htmlBody = htmlBody.replace('{!User.Name}', loggedInUser.Name);
        // if(loggedInUser.Title!=null){
        //     htmlBody = htmlBody.replace('{!User.Title}', loggedInUser.Title);
        // }
        // else{
        //     htmlBody = htmlBody.replace('{!User.Title}', '');
        // }
        // if(loggedInUser.Department!=null){
        //     htmlBody = htmlBody.replace('{!User.Department}', loggedInUser.Department);
        // }
        // else{
        //     htmlBody = htmlBody.replace('{!User.Department}', '');

        // }   
        // if(loggedInUser.Department!=null){
        //     htmlBody = htmlBody.replace('{!User.Phone}', loggedInUser.Phone);
        // }
        // else{
        //     htmlBody = htmlBody.replace('{!User.Phone}', '');

        // }   
        // if(loggedInUser.Department!=null){
        //     htmlBody = htmlBody.replace('{!User.MobilePhone}', loggedInUser.MobilePhone);
        // }
        // else{
        //     htmlBody = htmlBody.replace('{!User.MobilePhone}', '');

        // }   
        
        System.debug('HTML Body-->' + htmlBody);
        
        Messaging.SingleEmailMessage message = new Messaging.SingleEmailMessage();
        message.bccAddresses = emailList;
        message.subject = extEmailSubject;
        message.setTemplateId(et.Id);
        message.setHtmlBody(htmlBody);
        emailMessages.add(message);
        
        Messaging.SendEmailResult[] emailResults = Messaging.sendEmail(emailMessages);
    }

    


    //Creating a method to track the File viewer information in the file analytics.
    //This method will be called from the LWC when we navigate to the file. 
    @AuraEnabled
    public static List < ExternalFileWrapper > getExternalViewerInfo(String contentDocumentId) {
        try {
            List < ContentDistribution > contentDistList = new List < ContentDistribution > ();
            contentDistList = [SELECT Id, Name, ContentDocumentId, ContentDownloadUrl, ContentVersionId, CreatedBy.Name, CreatedDate, DistributionPublicUrl, ExpiryDate, FirstViewDate, IsDeleted, LastModifiedDate, LastViewDate, Password, PdfDownloadUrl, RelatedRecordId, ViewCount, PreferencesAllowOriginalDownload, PreferencesAllowPDFDownload, SystemModstamp FROM ContentDistribution WHERE ContentDocumentId =: contentDocumentId]; //= '0694C000002g7jtQAA' :contentDocumentId
            system.debug('View Conut->'+contentDistList[0].ViewCount);
            List < ContentDistributionView > contentDisBViewList = new List < ContentDistributionView > ();
            contentDisBViewList = [Select DistributionId, CreatedDate, IsDownload, IsInternal, ParentviewID From ContentDistributionView where DistributionId IN: contentDistList];
            List < FileExternalsharing__c > extFileShareList = new List < FileExternalsharing__c > ();
            extFileShareList = [Select Id, CreatedBy.Name, CreatedDate, Email__c, Public_Link_Url__c, CreatedDate__c, CreatedName__c, Password_protected__c, File_Name__c, Expiration_Date__c, Download_Count__c From FileExternalsharing__c where FileId__c =: contentDocumentId];
            List < ExternalFileWrapper > externalFileWrapperList = new List < ExternalFileWrapper > ();
            ExternalFileWrapper externalFileWrapperObj = new ExternalFileWrapper();
            externalFileWrapperObj.contentDistWrapperList = contentDistList;
            externalFileWrapperObj.contentDisBViewWrapperList = contentDisBViewList;
            externalFileWrapperObj.extFileShareWrapperList = extFileShareList;
            externalFileWrapperList.add(externalFileWrapperObj);
            return externalFileWrapperList;
        } catch (Exception ex) {
            Log4SF.logMessage('FileEnhanceController', 'getExternalViewerInfo', ex.getMessage(), ex, UserInfo.getUserId(), null, '');
            System.debug('errror msg in getExternalViewerInfo::' + ex);
        }
        return null;
    }

    public class ExternalFileWrapper {

        @Auraenabled
        public List < ContentDistribution > contentDistWrapperList {
            get;
            set;
        }
        @Auraenabled
        public List < ContentDistributionView > contentDisBViewWrapperList {
            get;
            set;
        }
        @Auraenabled
        public List < FileExternalsharing__c > extFileShareWrapperList {
            get;
            set;
        }

    }

    //creating a method to populate the serached records, a LWC Lookup.
    //This method will be called from the lwc when the user starts typing anything in the Lookup Search box.
    @AuraEnabled(cacheable = true)
    public static List < sobject > findRecords(String searchKey, String objectName) {
        try {
            string searchText = ('\'' + String.escapeSingleQuotes(searchKey) + '%\'');
            string query;
            query = ('SELECT Id, Name FROM ' + objectName + ' WHERE Name LIKE ' + searchText + 'LIMIT 10000');
            return Database.query(query);
        } catch (Exception ex) {
            Log4SF.logMessage('FileEnhanceController', 'findRecords', ex.getMessage(), ex, UserInfo.getUserId(), null, '');
            System.debug('errror msg in findRecords::' + ex);
        }

        return null;
    }

    //-----------------------------------------------------------------------------------------------------------------------------------------------------------------
    //files admin utility code changes

    //Creating a method to execute the FilesAdminUtilityBatch class.
    //This method will be called from the Files Admin Utility when the user clicks on Save button.
    //  @AuraEnabled(cacheable=true)
    //   public static void executeFilesAdminUtilityBatch(Boolean isDownloadable,Boolean isPasswordRequired, Integer expiryDurationDate, Boolean stopSharing) {
    //       System.debug('Values to execute batch-->'+'    '+'isDownloadable-->'+isDownloadable+' '+' expiryDurationDate-->'+expiryDurationDate);
    //       filesAdminUtilityBatch batch = new filesAdminUtilityBatch(isDownloadable, isPasswordRequired,stopSharing,expiryDurationDate); //
    //       Database.executeBatch(batch, 200); 
    //   }

    // @AuraEnabled(cacheable=true)
    // public static List<ContentDistribution> contentDistributionDetailsForAdmin(){
    //     List<contentDistribution> cd=[Select Id,PreferencesAllowOriginalDownload,PreferencesPasswordRequired FROM ContentDistribution limit 1 ];
    //     return cd;
    // }


    //Creating a method to fetch external file sharing settings, such as downloadability, password protection, and expiry duration, from the custom metadata.
    //This method will be called from the LWC when the user clicks on share button to share any file externally.
    @AuraEnabled(cacheable = true)
    public static External_File_Share__mdt getExternalFileShareSettings() {
        try {
            External_File_Share__mdt settings = [SELECT Is_Downloadable__c, Password_enabled__c, Expiry_Duration__c FROM External_File_Share__mdt WHERE DeveloperName = 'External_File_Share_Settings'
                LIMIT 1
            ];
            return settings;
        } catch (Exception ex) {
            Log4SF.logMessage('FileEnhanceController', 'getExternalFileShareSettings', ex.getMessage(), ex, UserInfo.getUserId(), null, '');
            System.debug('errror msg in getExternalFileShareSettings::' + ex);
        }
        return null;
    }


    //Creating a method to update the custom metadata record related to Sharing settings.
    //This method will be called from the Files Admin Utility when the user clicks on save button.
    // @AuraEnabled
    // public static void updateExternalFileShareSettings(Boolean isDownloadable, Boolean passwordEnabled, Integer expiryDuration) {

    //     try {
    //         // Create Metadata instance
    //         Metadata.CustomMetadata customMetadataRecord = new Metadata.CustomMetadata();
    //         customMetadataRecord.fullName = 'External_File_Share__mdt.External_File_Share_Settings';
    //         customMetadataRecord.label = 'External File Share Settings';

    //         Metadata.CustomMetadataValue isDownloadableValue = new Metadata.CustomMetadataValue();
    //         isDownloadableValue.field = 'Is_Downloadable__c';
    //         isDownloadableValue.value = isDownloadable;
    //         customMetadataRecord.values.add(isDownloadableValue);

    //         Metadata.CustomMetadataValue passwordEnabledValue = new Metadata.CustomMetadataValue();
    //         passwordEnabledValue.field = 'Password_enabled__c';
    //         passwordEnabledValue.value = passwordEnabled;
    //         customMetadataRecord.values.add(passwordEnabledValue);

    //         Metadata.CustomMetadataValue expiryDurationValue = new Metadata.CustomMetadataValue();
    //         expiryDurationValue.field = 'Expiry_Duration__c';
    //         expiryDurationValue.value = expiryDuration;
    //         customMetadataRecord.values.add(expiryDurationValue);

    //         // Create a deploy container
    //         Metadata.DeployContainer mdContainer = new Metadata.DeployContainer();
    //         mdContainer.addMetadata(customMetadataRecord);

    //         // Deploy
    //         Id jobId = Metadata.Operations.enqueueDeployment(mdContainer, new MetadataCallbackHandler());
    //     } catch (Exception ex) {
    //         Log4SF.logMessage('FileEnhanceController', 'updateExternalFileShareSettings', ex.getMessage(), ex, UserInfo.getUserId(), null, '');
    //         System.debug('errror msg in updateExternalFileShareSettings::' + ex);
    //     }

    // }

    // public class MetadataCallbackHandler implements Metadata.DeployCallback {

    //     public void handleResult(Metadata.DeployResult result, Metadata.DeployCallbackContext context) {
    //         if (result.status == Metadata.DeployStatus.Succeeded) {
    //             System.debug('Metadata Deploy Successful.');
    //         } else {
    //             System.debug('Metadata Deploy Failed: ' + result.errorMessage);
    //         }
    //     }
    // }


    //creating a method to delete the file from the org.
    //This method will be called from the LWC when the user clicks on the Delete button from the drop down of any file.
    @AuraEnabled
    public static void handleDelete(string idOfCon) {
        System.debug('what Id ::: ' + idOfCon);

        try {
            if (idOfCon != null) {
                List < FileExternalsharing__c > fileExtSharingListToDelete = new List < FileExternalsharing__c > ();
                fileExtSharingListToDelete = [Select Id from FileExternalsharing__c Where FileId__c =: idOfCon];
                System.debug('fileExtSharingListToDelete-->' + fileExtSharingListToDelete);
                delete fileExtSharingListToDelete;
                System.debug('inside apex class');
                ContentDocument conData = [Select Id From ContentDocument Where Id =: idOfCon];
                delete conData;

            } else {
                System.debug('id is null thats why coming in the else part');
            }
        } catch (Exception ex) {
            Log4SF.logMessage('FileEnhanceController', 'handleDelete', ex.getMessage(), ex, UserInfo.getUserId(), null, '');
            System.debug('errror msg ::' + ex);
        }
    }


}