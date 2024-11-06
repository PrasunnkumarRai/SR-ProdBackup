global without sharing class SponsorshipAdminUtilityController {

  @AuraEnabled
  public static list < bulk_sponsorship__c > csvFileRead(Id contentDocumentId, String scriptSelected) {
      list < bulk_sponsorship__c > bulkSponsorshipList = new list < bulk_sponsorship__c > ();
      if (contentDocumentId != null) {
          ContentVersion contentVersionObj = [SELECT Id, VersionData FROM ContentVersion WHERE ContentDocumentId =: contentDocumentId];
          list < String > csvRecordsList = contentVersionObj.VersionData.toString().split('\n');

          Id nationalTotal = Schema.SObjectType.Bulk_Sponsorship__c.getRecordTypeInfosByName().get('National total').getRecordTypeId();
          Id nationalSold = Schema.SObjectType.Bulk_Sponsorship__c.getRecordTypeInfosByName().get('National sold').getRecordTypeId();
          Id localTotal = Schema.SObjectType.Bulk_Sponsorship__c.getRecordTypeInfosByName().get('Total').getRecordTypeId();
          Id localSold = Schema.SObjectType.Bulk_Sponsorship__c.getRecordTypeInfosByName().get('Sold').getRecordTypeId();

          for (Integer i = 1; i < csvRecordsList.size(); i++) {
              bulk_sponsorship__c objBulkSP = new bulk_sponsorship__c();
              list < String > csvRowData = csvRecordsList[i].split(',');
              System.debug('csvRowData====> ' + csvRowData);
              if (scriptSelected == 'SoldLocalSponsorship') {
                  objBulkSP.Name = csvRowData[0];
                  objBulkSP.End_Date__c = Datetime.now().date(); //Date.valueOf(csvRowData[1]);
                  objBulkSP.Inventory_Type__c = csvRowData[2];
                  objBulkSP.MVPD__c = csvRowData[3];
                  objBulkSP.DMA__c = csvRowData[4];
                  objBulkSP.Network__c = csvRowData[5];
                  objBulkSP.Start_Date__c = Datetime.now().date(); //Date.valueOf(csvRowData[6]);
                  objBulkSP.State__c = csvRowData[7];
                  objBulkSP.System_Type__c = csvRowData[8];
                  objBulkSP.Selling_area__c = csvRowData[9];
                  objBulkSP.SysCode__c = csvRowData[10];
                  objBulkSP.TIM_System__c = csvRowData[11];
                  objBulkSP.Client_Name__c = csvRowData[12];
                  objBulkSP.TIMID__c = csvRowData[13];
                  objBulkSP.RecordTypeId = localSold;
                  System.debug(csvRowData[10]);
                  objBulkSP.Quantity__c = 15.00;
              } else if (scriptSelected == 'TotalLocalSponsorship') {
                  objBulkSP.Name = csvRowData[0];
                  objBulkSP.End_Date__c = Datetime.now().date(); //Date.valueOf(csvRowData[1]);
                  objBulkSP.Inventory_Type__c = csvRowData[2];
                  objBulkSP.MVPD__c = csvRowData[3];
                  objBulkSP.DMA__c = csvRowData[4];
                  objBulkSP.Network__c = csvRowData[5];
                  objBulkSP.Start_Date__c = Datetime.now().date(); //Date.valueOf(csvRowData[6]);
                  objBulkSP.State__c = csvRowData[7];
                  objBulkSP.Syscode__c = csvRowData[8];
                  objBulkSP.Selling_area__c = csvRowData[9];
                  objBulkSP.System_Type__c = csvRowData[10];
                  objBulkSP.Quantity__c = 48.00;
                  objBulkSP.RecordTypeId = localTotal;

              } else if (scriptSelected == 'TotalNationalSponsorship') {
                  objBulkSP.Name = csvRowData[0];
                  objBulkSP.End_Date__c = Datetime.now().date(); //Date.valueOf(csvRowData[1]);
                  objBulkSP.Inventory_Type__c = csvRowData[2];
                  objBulkSP.MVPD__c = csvRowData[3];
                  objBulkSP.DMA__c = csvRowData[4];
                  objBulkSP.Syscode__c = csvRowData[5];
                  objBulkSP.Network__c = csvRowData[6];
                  objBulkSP.Start_Date__c = Datetime.now().date(); //Date.valueOf(csvRowData[6]);
                  objBulkSP.State__c = csvRowData[8];
                  objBulkSP.Selling_area__c = csvRowData[9];
                  objBulkSP.System_Type__c = csvRowData[10];
                  objBulkSP.Quantity__c = 48.00;
                  objBulkSP.RecordTypeId = nationalTotal;

              } else if (scriptSelected == 'SoldNationalSponsorship') {
                  objBulkSP.Name = csvRowData[0];
                  objBulkSP.DMA__c = csvRowData[1];
                  objBulkSP.Selling_area__c = csvRowData[2];
                  objBulkSP.SysCode__c = csvRowData[3];
                  objBulkSP.Network__c = csvRowData[4];
                  objBulkSP.TIM_System__c = csvRowData[5];
                  objBulkSP.Client_Name__c = csvRowData[6];
                  objBulkSP.AE_Name__c = csvRowData[7];
                  objBulkSP.Quantity__c = 48.00;
                  objBulkSP.Start_Date__c = Datetime.now().date(); //Date.valueOf(csvRowData[9]);
                  objBulkSP.End_Date__c = Datetime.now().date(); //Date.valueOf(csvRowData[10]);
                  objBulkSP.TIMID__c = csvRowData[11];
                  objBulkSP.RecordTypeId = nationalSold;
              }
              bulkSponsorshipList.add(objBulkSP);
          }

          try {
              if (!bulkSponsorshipList.isEmpty()) {
                  insert bulkSponsorshipList;
              }
          } catch (Exception ex) {
              throw new AuraHandledException(ex.getMessage());
          }
      }
      return bulkSponsorshipList;
  }

  @AuraEnabled
  public static list < bulk_sponsorship__c > createBulkSposorships(List < bulk_sponsorship__c > bulkSponsorships, String scriptSelected) {
      try {
          Id nationalTotal = Schema.SObjectType.Bulk_Sponsorship__c.getRecordTypeInfosByName().get('National total').getRecordTypeId();
          Id nationalSold = Schema.SObjectType.Bulk_Sponsorship__c.getRecordTypeInfosByName().get('National sold').getRecordTypeId();
          Id localTotal = Schema.SObjectType.Bulk_Sponsorship__c.getRecordTypeInfosByName().get('Total').getRecordTypeId();
          Id localSold = Schema.SObjectType.Bulk_Sponsorship__c.getRecordTypeInfosByName().get('Sold').getRecordTypeId();
          for (bulk_sponsorship__c objBulkSP: bulkSponsorships) {
              if (scriptSelected == 'SoldLocalSponsorship') {
                  objBulkSP.RecordTypeId = localSold;
              } else if (scriptSelected == 'TotalLocalSponsorship') {
                  objBulkSP.RecordTypeId = localTotal;
              } else if (scriptSelected == 'TotalNationalSponsorship') {
                  objBulkSP.RecordTypeId = nationalTotal;
              } else if (scriptSelected == 'SoldNationalSponsorship') {
                  objBulkSP.RecordTypeId = nationalSold;
              }
          }
          insert bulkSponsorships;
      } catch (Exception ex) {
          throw new AuraHandledException(ex.getMessage());
      }

      return bulkSponsorships;
  }

  public void createTotalLocalSponsorships(Date createdDate) {
      List < bulk_sponsorship__c > bSprList = new List < bulk_sponsorship__c > ();
      bSprList = [Select ID, DMA__c, Selling_area__c, SysCode__c, Start_Date__c, End_Date__c, Network__c, System_Type__c,
          Quantity__c, Inventory_Type__c, TimID__c, is_Errored__c, Error_Message__c, isSuccess__c, tim_System__c, recordType.Name, Name from bulk_sponsorship__c where RecordType.Name = 'Total'
          AND CreatedDate >=: createdDate AND(isSuccess__c = False OR isSuccess__c = NULL)
      ];
      List < String > sysCodeExtIDList = new List < String > ();
      List < Templates__c > sprList = new List < Templates__c > ();
      List < String > sprSysCodeList = new List < String > ();
      List < Syscode_and_Network__c > upsertSysCodeList = new List < Syscode_and_Network__c > ();

      System.debug('bSprList ' + bSprList);
      System.debug('bSprList.size() ' + bSprList.size());

      for (bulk_sponsorship__c bSpr: bSprList) {
          sysCodeExtIDList.add(bSpr.DMA__c + bSpr.SysCode__c);
          sprSysCodeList.add(bSpr.syscode__c);
      }

      List < Syscode_and_Network__c > sysCodeList = [Select ID, Externa_Id_System_Name__c, external_ID__c from Syscode_and_Network__c where external_ID__c in: sysCodeExtIDList];
      System.debug('sysCodeList ' + sysCodeList);
      System.debug('sysCodeList.size() ' + sysCodeList.size());
      Map < String, Syscode_and_Network__c > sysCodeMap = new Map < String, Syscode_and_Network__c > ();
      for (Syscode_and_Network__c sysCode: sysCodeList) {
          string key = sysCode.external_ID__c;
          if (!sysCodeMap.containsKey(key))
              sysCodeMap.put(key, sysCode);
          else {
              System.debug('Key violation1' + sysCodeMap.get(key));
              System.debug('Key violation2' + sysCode);
          }
      }
      Map < String, String > syscodeSPRMap = new Map < String, String > ();
      Map < Integer, bulk_sponsorship__c > bulkSprMap = new Map < Integer, bulk_sponsorship__c > ();

      Integer i = 0;
      for (bulk_sponsorship__c bSpr: bSprList) {
          bulkSprMap.put(i, bSpr);
          try {
              string key = bSpr.DMA__c + bSpr.SysCode__c;

              if (bSpr.recordType.Name == 'Total') {
                  Templates__c spr = new Templates__c();
                  if (sysCodeMap.containsKey(key))
                      spr.News_Syscode__c = sysCodeMap.get(key).ID;
                  else {
                      Syscode_and_Network__c sysCode = new Syscode_and_Network__c();
                      sysCode.Market__c = bSpr.DMA__c;
                      sysCode.Network_Code__c = bSpr.Network__c;
                      sysCode.External_Id__c = bSpr.DMA__c + bSpr.SysCode__c;
                      sysCode.Syscode__c = bSpr.SysCode__c;
                      sysCode.Name = bSpr.SysCode__c;
                      sysCode.System_Name__c = bSpr.Selling_area__c;
                      System.debug('location 1');
                      upsertSysCodeList.add(sysCode);
                      System.debug('sysCode.External_Id__c ' + sysCode.External_Id__c);
                      syscodeSPRMap.put(bSpr.Name, sysCode.External_Id__c);
                      System.debug('location 2');
                  }

                  System.debug('location 3');
                  spr.Start_Date__c = bSpr.Start_Date__c;
                  spr.End_Date__c = bSpr.End_Date__c;
                  spr.Total_Quantity__c = bSpr.Quantity__c;
                  spr.Inventory_Type__c = bSpr.Inventory_Type__c;
                  spr.RecordTypeId = Schema.SObjectType.Templates__c.getRecordTypeInfosByName().get('Local').getRecordTypeId();
                  System.debug('location 4');
                  spr.SysCode_Details__c = String.valueOf(bSpr.DMA__c) + ',' + String.valueOf(bSpr.Selling_area__c) + ',' + String.valueOf(bSpr.Network__c) + ',' + String.valueOf(bSpr.SysCode__c) + ',' + String.valueOf(bSpr.System_Type__c);
                  System.debug('location 5');
                  spr.Name = bSpr.Name;
                  System.debug('spr ' + spr);
                  sprList.add(spr);
                  System.debug('i ' + i);
              }
              i++;
          } catch (Exception ex) {
              System.debug('in catch' + ex.getMessage());
              bulkSprMap.get(i).is_Errored__c = true;
              bulkSprMap.get(i).Error_Message__c = ex.getMessage();
              i++;
          }
      }

      List < bulk_sponsorship__c > errorUpdate = new List < bulk_sponsorship__c > ();
      List < bulk_sponsorship__c > successUpdate = new List < bulk_sponsorship__c > ();
      System.debug('location 6');
      Map < String, String > saveResultIDMap = new Map < String, String > ();
      List < Database.SaveResult > saveResultIDList = Database.insert(upsertSysCodeList, true);
      for (Integer j = 0; j < saveResultIDList.size(); j++) {
          saveResultIDMap.put(upsertSysCodeList.get(j).External_Id__c, saveResultIDList.get(j).getId());
      }

      System.debug('sprList.size() ' + sprList.size());
      System.debug('sprList ' + sprList);

      if (sprList.size() > 0) {
          for (Templates__c temp: sprList) {
              if (temp.News_Syscode__c == null) temp.News_Syscode__c = saveResultIDMap.get(syscodeSPRMap.get(temp.Name));
          }

          List < Database.SaveResult > saveResultList = Database.insert(sprList, true);
          System.debug('saveResultList  ' + saveResultList);
          for (Integer j = 0; j < saveResultList.size(); j++) {
              if (saveResultList.get(j).isSuccess()) {
                  saveResultList.get(j).getId();
                  bulkSprMap.get(j).Error_Message__c = 'Success';
                  bulkSprMap.get(j).isSuccess__c = true;
                  system.debug('Inserted data' + saveResultList.get(j));
                  successUpdate.add(bulkSprMap.get(j));
              } else if (!saveResultList.get(j).isSuccess()) {
                  Database.Error error = saveResultList.get(j).getErrors().get(0);
                  String failedDML = error.getMessage();
                  bulkSprMap.get(j).is_Errored__c = true;
                  bulkSprMap.get(j).Error_Message__c = failedDML;
                  system.debug('Failed ID' + saveResultList.get(j) + failedDML);
                  errorUpdate.add(bulkSprMap.values());
                  Log4SF.logMessage('SponsorshipDataLoad', 'TotalSponsorship Insert', failedDML, UserInfo.getUserId(), bulkSprMap.get(j).Name);
              }
          }
      }

      if (bulkSprMap.values().size() > 0) {
          Database.update(bulkSprMap.values(), true);
      }
      SponsorshipDateInventoryBatch objBatch = new SponsorshipDateInventoryBatch(sprList);
      ID batchprocessid = Database.executeBatch(objBatch);
  }

  public void createSoldLocalSponsorships(Date createdDate) {
      List < bulk_sponsorship__c > bSprList = new List < bulk_sponsorship__c > ();
      bSprList = [Select ID, DMA__c, Selling_area__c, SysCode__c, Start_Date__c, End_Date__c, Network__c, System_Type__c, Quantity__c, Inventory_Type__c, TimID__c, is_Errored__c, Error_Message__c, isSuccess__c, tim_System__c, recordType.Name, Name from bulk_sponsorship__c where RecordType.Name = 'Sold'
          AND CreatedDate >=: createdDate
      ];
      List < Tim_Eclipse_Map__mdt > timEclipseList = [Select TIM_System__c, Label from Tim_Eclipse_Map__mdt];
      List < String > sysCodeExtIDList = new List < String > ();
      List < Templates__c > sprList = new List < Templates__c > ();
      List < String > timIDList = new List < String > ();
      List < String > sprSysCodeList = new List < String > ();
      Map < String, string > timEclipseMap = new Map < String, string > ();
      for (Tim_Eclipse_Map__mdt timMap: timEclipseList) {
          timEclipseMap.put(timMap.Label, timMap.TIM_System__c);
      }

      for (bulk_sponsorship__c bSpr: bSprList) {
          sysCodeExtIDList.add(bSpr.DMA__c + bSpr.SysCode__c);
          if (bSpr.recordType.Name == 'Sold') {
              timIDList.add(bSpr.TimID__c);
          }
          sprSysCodeList.add(bSpr.syscode__c);
      }

      List < Templates__c > sponsorshipList = new List < Templates__c > ();
      Map < String, templates__c > sprMap = new Map < String, templates__c > ();
      Map < String, Proposal__c > prMap = new Map < String, Proposal__c > ();
      if (timIDList.size() > 0) {
          List < Proposal__c > proposalList = [Select ID, TIM_Id__c, Tim_System__c, Opportunity__c from Proposal__c where Tim_id__c in: timIDList and RecordType.Name = 'Linear'];
          for (Proposal__c pr: proposalList) {
              prMap.put(pr.TIM_Id__c + pr.TIM_System__c, pr);
              System.debug('proposal deata ' + prMap + pr);
          }
          sponsorshipList = [Select ID, Name from templates__c];
      }

      if (sponsorshipList.size() > 0) {
          for (templates__c spr: sponsorshipList) {
              sprMap.put(spr.Name, spr);
          }
      }
      List < Syscode_and_Network__c > sysCodeList = [Select ID, Externa_Id_System_Name__c, external_ID__c from Syscode_and_Network__c where external_ID__c in: sysCodeExtIDList];
      Map < String, Syscode_and_Network__c > sysCodeMap = new Map < String, Syscode_and_Network__c > ();

      for (Syscode_and_Network__c sysCode: sysCodeList) {
          string key = sysCode.external_ID__c;
          if (!sysCodeMap.containsKey(key))
              sysCodeMap.put(key, sysCode);
          else {
              System.debug('Key violation1' + sysCodeMap.get(key));
              System.debug('Key violation2' + sysCode);
          }
      }
      Map < Integer, Booked_Sponsorship__c > bookSprMap = new Map < Integer, Booked_Sponsorship__c > ();
      Map < Integer, Sponsorship_Booking__c > sprBookingMap = new Map < Integer, Sponsorship_Booking__c > ();
      Map < Integer, Sponsorship_Proposals__c > sprProposalMap = new Map < Integer, Sponsorship_Proposals__c > ();
      Map < Integer, bulk_sponsorship__c > bulkSprMap = new Map < Integer, bulk_sponsorship__c > ();
      Integer j = 0;
      for (bulk_sponsorship__c bSpr: bSprList) {
          bulkSprMap.put(j, bSpr);
          try {
              string key = bSpr.DMA__c + bSpr.SysCode__c;
              if (bSpr.recordType.Name == 'Sold') {
                  System.debug('in Sold ' + bSpr);
                  System.debug('in Sold sprMap ' + sprMap.get(bSpr.Name));
                  Booked_Sponsorship__c bookMaster = new Booked_Sponsorship__c();
                  Sponsorship_Booking__c sprBooking = new Sponsorship_Booking__c();
                  Sponsorship_Proposals__c sprProposal = new Sponsorship_Proposals__c();
                  bookMaster.Is_Editable__c = false;
                  bookMaster.legacyID__c = j;
                  bookMaster.Source__c = 'Data Load';
                  bookMaster.Status__c = 'Approved';
                  if (String.isNotBlank(bSpr.timID__c) && prMap.containsKey(bSpr.timID__c + timEclipseMap.get(bSpr.tim_System__c))) {
                      bookMaster.Opportunity__c = prMap.get(bSpr.timID__c + timEclipseMap.get(bSpr.tim_System__c)).Opportunity__c;
                      sprProposal.Proposal__c = prMap.get(bSpr.timID__c + timEclipseMap.get(bSpr.tim_System__c)).Id;
                      sprProposalMap.put(j, sprProposal);
                  }
                  bookSprMap.put(j, bookMaster);
                  sprBooking.End_Date__c = bSpr.End_Date__c;
                  sprBooking.Start_Date__c = bSpr.Start_Date__c;
                  sprBooking.Syscode__c = bSpr.Syscode__c;
                  sprBooking.Template__c = sprMap.get(bSpr.Name).Id;
                  if (sysCodeMap.containsKey(key))
                      sprBooking.News_Syscode__c = sysCodeMap.get(key).ID;
                  sprBooking.Name = bSpr.Name;
                  sprBookingMap.put(j, sprBooking);
              }
              j++;
          } catch (Exception ex) {
              bulkSprMap.get(j).is_Errored__c = true;
              bulkSprMap.get(j).Error_Message__c = ex.getMessage();
              j++;
          }
      }
      List < bulk_sponsorship__c > errorUpdate = new List < bulk_sponsorship__c > ();
      List < bulk_sponsorship__c > successUpdate = new List < bulk_sponsorship__c > ();

      if (bookSprMap.values().size() > 0) {

          List < Database.SaveResult > saveResultList = Database.insert(bookSprMap.values(), true);

          for (Integer i = 0; i < saveResultList.size(); i++) {
              try {
                  if (saveResultList.get(i).isSuccess()) {
                      saveResultList.get(i).getId();
                      bulkSprMap.get(i).Error_Message__c = 'Success';
                      bulkSprMap.get(i).isSuccess__c = true;
                      System.debug('Inserted Master : ' + bookSprMap.get(i));
                      if (sprBookingMap.containsKey(i))
                          sprBookingMap.get(i).Booked_Sponsorship__c = saveResultList.get(i).getId();
                      if (sprProposalMap.containsKey(i))
                          sprProposalMap.get(i).Bookied_Sponsorship__c = saveResultList.get(i).getId();
                      successUpdate.add(bulkSprMap.get(i));
                  } else if (!saveResultList.get(i).isSuccess()) {
                      Database.Error error = saveResultList.get(i).getErrors().get(0);
                      String failedDML = error.getMessage();
                      bulkSprMap.get(i).is_Errored__c = true;
                      bulkSprMap.get(i).Error_Message__c = failedDML;
                      system.debug('Failed ID' + bookSprMap.get(i) + failedDML);
                      errorUpdate.add(bulkSprMap.values());
                      Log4SF.logMessage('SponsorshipDataLoad', 'booked sponsorship Insert', failedDML, UserInfo.getUserId(), bulkSprMap.get(i).Name);
                  }

              } catch (Exception ex) {
                  system.debug('ex ID' + ex.getStackTraceString() + ex.getMessage());
                  Log4SF.logMessage('SponsorshipDataLoad', 'booked sponsorship  Insert', ex.getMessage(), UserInfo.getUserId(), bulkSprMap.get(i).Name);
              }
          }
      }
      if (sprBookingMap.values().size() > 0)
          Database.insert(sprBookingMap.values(), true);
      if (sprProposalMap.values().size() > 0)
          Database.insert(sprProposalMap.values(), true);
      if (bulkSprMap.values().size() > 0)
          Database.update(bulkSprMap.values(), true);

      DateInventoryHandleUpdateBatch objBatch = new DateInventoryHandleUpdateBatch('Select Id,Name,Start_Date__c,End_date__c,Template__c,RecordType.Name from Sponsorship_Booking__c where Id IN:SponsorshipBookingList', sprBookingMap.values(), 'AdminUtility');
      ID batchprocessid = Database.executeBatch(objBatch, 10);
  }

  public void createTotalNationalSponsorships(Date createdDate) {
      List < bulk_sponsorship__c > bSprList = new List < bulk_sponsorship__c > ();
      bSprList = [Select ID, DMA__c, Selling_area__c, SysCode__c, Start_Date__c, End_Date__c, Network__c, System_Type__c, Quantity__c, Inventory_Type__c, TimID__c, is_Errored__c, Error_Message__c, isSuccess__c, tim_System__c, recordType.Name, Name from bulk_sponsorship__c where RecordType.Name = 'National total'
          and CreatedDate >=: createdDate
      ];

      List < String > sysCodeExtIDList = new List < String > ();
      List < Templates__c > sprList = new List < Templates__c > ();
      List < String > sprSysCodeList = new List < String > ();
      List < Syscode_and_Network__c > upsertSysCodeList = new List < Syscode_and_Network__c > ();

      System.debug('bSprList ' + bSprList);
      System.debug('bSprList.size() ' + bSprList.size());

      for (bulk_sponsorship__c bSpr: bSprList) {
          sysCodeExtIDList.add(bSpr.DMA__c + bSpr.SysCode__c);
          sprSysCodeList.add(bSpr.syscode__c);
      }

      List < Syscode_and_Network__c > sysCodeList = [Select ID, Externa_Id_System_Name__c, external_ID__c from Syscode_and_Network__c where external_ID__c in: sysCodeExtIDList];
      System.debug('sysCodeList ' + sysCodeList);
      System.debug('sysCodeList.size() ' + sysCodeList.size());

      Map < String, Syscode_and_Network__c > sysCodeMap = new Map < String, Syscode_and_Network__c > ();

      for (Syscode_and_Network__c sysCode: sysCodeList) {
          string key = sysCode.external_ID__c;
          if (!sysCodeMap.containsKey(key))
              sysCodeMap.put(key, sysCode);
          else {
              System.debug('Key violation1' + sysCodeMap.get(key));
              System.debug('Key violation2' + sysCode);
          }
      }

      Map < String, String > syscodeSPRMap = new Map < String, String > ();
      Map < Integer, bulk_sponsorship__c > bulkSprMap = new Map < Integer, bulk_sponsorship__c > ();
      Map < Integer, Template_Inventory__c > tiMap = new Map < Integer, Template_Inventory__c > ();

      Integer i = 0;
      for (bulk_sponsorship__c bSpr: bSprList) {
          bulkSprMap.put(i, bSpr);
          try {
              string key = bSpr.DMA__c + bSpr.SysCode__c;

              if (bSpr.recordType.Name == 'National total') {
                  Templates__c spr = new Templates__c();
                  Template_Inventory__c ti = new Template_Inventory__c();
                  if (sysCodeMap.containsKey(key))
                      spr.News_Syscode__c = sysCodeMap.get(key).ID;
                  else {
                      System.debug('creating syscode');
                      Syscode_and_Network__c sysCode = new Syscode_and_Network__c();
                      sysCode.Market__c = bSpr.DMA__c;
                      sysCode.Network_Code__c = bSpr.Network__c;
                      sysCode.External_Id__c = bSpr.DMA__c + bSpr.SysCode__c;
                      sysCode.Syscode__c = bSpr.SysCode__c;
                      sysCode.Name = bSpr.SysCode__c;
                      sysCode.System_Name__c = bSpr.Selling_area__c;
                      upsertSysCodeList.add(sysCode);
                      System.debug('sysCode.External_Id__c ' + sysCode.External_Id__c);
                      syscodeSPRMap.put(bSpr.Name, sysCode.External_Id__c);
                  }
                  spr.Start_Date__c = bSpr.Start_Date__c;
                  spr.End_Date__c = bSpr.End_Date__c;
                  spr.RecordTypeId = Schema.SObjectType.Templates__c.getRecordTypeInfosByName().get('National').getRecordTypeId();
                  spr.SysCode_Details__c = String.valueOf(bSpr.DMA__c) + ',' + String.valueOf(bSpr.Selling_area__c) + ',' + String.valueOf(bSpr.Network__c) + ',' + String.valueOf(bSpr.SysCode__c) + ',' + String.valueOf(bSpr.System_Type__c);
                  spr.Name = bSpr.Name;
                  System.debug('spr ' + spr);
                  ti.Template__c = spr.Id;
                  ti.Total_quantity__c = bSpr.Quantity__c;
                  ti.Quantity__c = bSpr.Quantity__c;
                  ti.Inventory_Type__c = bSpr.Inventory_Type__c;
                  tiMap.put(i, ti);
                  sprList.add(spr);
                  System.debug('i ' + i);
              }
              i++;
          } catch (Exception ex) {
              System.debug('in catch' + ex.getMessage());
              bulkSprMap.get(i).is_Errored__c = true;
              bulkSprMap.get(i).Error_Message__c = ex.getMessage();
              i++;
          }
      }

      List < bulk_sponsorship__c > errorUpdate = new List < bulk_sponsorship__c > ();
      List < bulk_sponsorship__c > successUpdate = new List < bulk_sponsorship__c > ();
      System.debug('location 6');

      Map < String, String > saveResultIDMap = new Map < String, String > ();

      List < Database.SaveResult > saveResultIDList = Database.insert(upsertSysCodeList, true);
      for (Integer j = 0; j < saveResultIDList.size(); j++) {
          saveResultIDMap.put(upsertSysCodeList.get(j).External_Id__c, saveResultIDList.get(j).getId());
      }

      System.debug('sprList.size() ' + sprList.size());
      System.debug('sprList ' + sprList);

      if (sprList.size() > 0) {

          for (Templates__c temp: sprList) {
              if (temp.News_Syscode__c == null) temp.News_Syscode__c = saveResultIDMap.get(syscodeSPRMap.get(temp.Name));
          }
          List < Database.SaveResult > saveResultList = Database.insert(sprList, true);
          System.debug('saveResultList  ' + saveResultList);
          for (Integer j = 0; j < saveResultList.size(); j++) {
              if (saveResultList.get(j).isSuccess()) {
                  bulkSprMap.get(j).Error_Message__c = 'Success';
                  bulkSprMap.get(j).isSuccess__c = true;
                  if (tiMap.containsKey(j)) tiMap.get(j).Template__c = saveResultList.get(j).getId();
                  system.debug('Inserted data' + saveResultList.get(j));
                  successUpdate.add(bulkSprMap.get(j));
              } else if (!saveResultList.get(j).isSuccess()) {
                  Database.Error error = saveResultList.get(j).getErrors().get(0);
                  String failedDML = error.getMessage();
                  bulkSprMap.get(j).is_Errored__c = true;
                  bulkSprMap.get(j).Error_Message__c = failedDML;
                  system.debug('Failed ID' + saveResultList.get(j) + failedDML);
                  errorUpdate.add(bulkSprMap.values());
                  Log4SF.logMessage('SponsorshipDataLoad', 'Total Sponsorship National Insert', failedDML, UserInfo.getUserId(), bulkSprMap.get(j).Name);
              }
          }
      }

      if (tiMap.values().size() > 0) Database.insert(tiMap.values(), true);

      if (bulkSprMap.values().size() > 0) Database.update(bulkSprMap.values(), true);
  }

  public void createSoldNationalSponsorships(Date createdDate) {
      List < bulk_sponsorship__c > bSprList = new List < bulk_sponsorship__c > ();

      bSprList = [Select ID, DMA__c, Selling_area__c, SysCode__c, Start_Date__c, Booked_Quantity__c,
          End_Date__c, Network__c, System_Type__c, Quantity__c, Inventory_Type__c, TimID__c, is_Errored__c,
          Error_Message__c, isSuccess__c, TIM_System__c, recordType.Name, Name
          from bulk_sponsorship__c where RecordType.Name = 'National sold'
          and CreatedDate >=: createdDate
      ];

      List < Tim_Eclipse_Map__mdt > timEclipseList = [Select TIM_System__c, Label from Tim_Eclipse_Map__mdt];
      List < String > sysCodeExtIDList = new List < String > ();
      List < Templates__c > sprList = new List < Templates__c > ();
      List < String > timIDList = new List < String > ();
      List < String > sprSysCodeList = new List < String > ();
      Map < String, string > timEclipseMap = new Map < String, string > ();
      for (Tim_Eclipse_Map__mdt timMap: timEclipseList) {
          timEclipseMap.put(timMap.Label, timMap.TIM_System__c);
      }

      for (bulk_sponsorship__c bSpr: bSprList) {
          sysCodeExtIDList.add(bSpr.DMA__c + bSpr.SysCode__c);
          if (bSpr.recordType.Name == 'National sold') timIDList.add(bSpr.TimID__c);
          sprSysCodeList.add(bSpr.syscode__c);
      }

      List < Templates__c > sponsorshipList = new List < Templates__c > ();
      String recordTypeNationalSold = Schema.SObjectType.Templates__C.getRecordTypeInfosByName().get('National').getRecordTypeId();
      sponsorshipList = [SELECT Id, name from Templates__c WHERE RecordTypeId =: recordTypeNationalSold];
      Map < String, templates__c > sprMap = new Map < String, templates__c > ();
      Map < String, Proposal__c > prMap = new Map < String, Proposal__c > ();

      if (timIDList.size() > 0) {
          // Add Tim System association
          List < Proposal__c > proposalList = [Select ID, TIM_Id__c, Tim_System__c, Opportunity__c from Proposal__c where Tim_id__c in: timIDList and RecordType.Name = 'Linear'];

          for (Proposal__c pr: proposalList) {
              prMap.put(pr.TIM_Id__c + pr.TIM_System__c, pr);
              System.debug('proposal data ' + prMap + pr);
          }
      }

      System.debug('sponsorshipList   ' + sponsorshipList);
      if (sponsorshipList.size() > 0) {
          for (templates__c spr: sponsorshipList) {
              sprMap.put(spr.Name, spr);
          }
      }

      List < Syscode_and_Network__c > sysCodeList = [Select ID, Externa_Id_System_Name__c, external_ID__c from Syscode_and_Network__c where external_ID__c in: sysCodeExtIDList];
      Map < String, Syscode_and_Network__c > sysCodeMap = new Map < String, Syscode_and_Network__c > ();

      for (Syscode_and_Network__c sysCode: sysCodeList) {
          string key = sysCode.external_ID__c;
          if (!sysCodeMap.containsKey(key)) sysCodeMap.put(key, sysCode);
          else {
              System.debug('Key violation1' + sysCodeMap.get(key));
              System.debug('Key violation2' + sysCode);
          }
      }

      Map < Integer, Booked_Sponsorship__c > bookSprMap = new Map < Integer, Booked_Sponsorship__c > ();
      Map < Integer, Sponsorship_Booking__c > sprBookingMap = new Map < Integer, Sponsorship_Booking__c > ();
      Map < Integer, Sponsorship_Proposals__c > sprProposalMap = new Map < Integer, Sponsorship_Proposals__c > ();
      Map < Integer, Booked_Sponsorship_Inventory__c > sprInventoryMap = new Map < Integer, Booked_Sponsorship_Inventory__c > ();
      Map < Integer, bulk_sponsorship__c > bulkSprMap = new Map < Integer, bulk_sponsorship__c > ();
      Map < Integer, Map < String, Decimal >> inventoryUpdateMap = new Map < Integer, Map < String, Decimal >> ();

      System.debug('in Sold size' + bSprList.size());
      System.debug('in Sold sprMap size' + sprMap.size());
      Integer i = 0;
      for (bulk_sponsorship__c bSpr: bSprList) {
          bulkSprMap.put(i, bSpr);
          try {
              string key = bSpr.DMA__c + bSpr.SysCode__c;
              if (bSpr.recordType.Name == 'National sold') {
                  System.debug('in Sold ' + bSpr);
                  System.debug('in Sold sprMap ' + sprMap.get(bSpr.Name));
                  Booked_Sponsorship__c bookMaster = new Booked_Sponsorship__c();
                  Sponsorship_Booking__c sprBooking = new Sponsorship_Booking__c();
                  Sponsorship_Proposals__c sprProposal = new Sponsorship_Proposals__c();
                  Booked_Sponsorship_Inventory__c sprInventory = new Booked_Sponsorship_Inventory__c();
                  bookMaster.Is_Editable__c = false;
                  bookMaster.legacyID__c = i;
                  bookMaster.Source__c = 'Data Load';
                  bookMaster.Status__c = 'Approved';
                  bookMaster.Bulk_Sponsorship__c = bSpr.ID;
                  if (String.isNotBlank(bSpr.timID__c) && prMap.containsKey(bSpr.timID__c + timEclipseMap.get(bSpr.tim_System__c))) {
                      bookMaster.Opportunity__c = prMap.get(bSpr.timID__c + timEclipseMap.get(bSpr.tim_System__c)).Opportunity__c;
                      sprProposal.Proposal__c = prMap.get(bSpr.timID__c + timEclipseMap.get(bSpr.tim_System__c)).Id;
                      sprProposalMap.put(i, sprProposal);
                  }
                  bookSprMap.put(i, bookMaster);
                  sprBooking.End_Date__c = bSpr.End_Date__c;
                  sprBooking.Start_Date__c = bSpr.Start_Date__c;
                  sprBooking.Syscode__c = bSpr.Syscode__c;
                  sprBooking.Template__c = sprMap.get(bSpr.Name).Id;
                  if (sysCodeMap.containsKey(key)) {
                      sprBooking.News_Syscode__c = sysCodeMap.get(key).ID;
                      inventoryUpdateMap.put(i, new Map < String, Decimal > {
                          sprMap.get(bSpr.Name).Id => bSpr.Booked_Quantity__c
                      });
                  }
                  sprBooking.Name = bSpr.Name;
                  sprBookingMap.put(i, sprBooking);
                  sprInventory.Quantity__c = bSpr.Booked_Quantity__c;
                  sprInventory.Inventory_Type__c = bSpr.Inventory_Type__c;
                  sprInventoryMap.put(i, sprInventory);
              }
              i++;
          } catch (Exception ex) {
              Log4SF.logMessage('SponsorshipDataLoad', 'booked sponsorship Sold Insert', ex.getMessage(), UserInfo.getUserId(), bulkSprMap.get(i).Id);
              bulkSprMap.get(i).is_Errored__c = true; //failed record from the list
              bulkSprMap.get(i).Error_Message__c = ex.getMessage();
              bulkSprMap.get(i).isSuccess__c = false;
              i++;
          }
      }

      //Booked Inventory to be updated 
      List < String > inventoryIds = new List < String > ();
      for (Integer k: inventoryUpdateMap.keySet()) {
          for (String str: inventoryUpdateMap.get(k).keySet()) {
              inventoryIds.add(str);
          }
      }

      List < Template_Inventory__c > inventoryList = [SELECT Id, Name, Booked_Inventory__c, Total_quantity__c, Template__c, Available_Quantity__c FROM Template_Inventory__c WHERE Template__c IN: inventoryIds];
      for (Integer j: inventoryUpdateMap.keySet()) {
          for (String str: inventoryUpdateMap.get(j).keySet()) {
              for (Template_Inventory__c tInv: inventoryList) {
                  Decimal bookingQty = inventoryUpdateMap.get(j).get(str);
                  if (str == tInv.Template__c && tInv.Available_Quantity__c >= bookingQty) {
                      System.debug('Booking allowed ');
                      tInv.Booked_Inventory__c = tInv.Booked_Inventory__c + bookingQty;
                  } else {
                      System.debug('Booking not allowed due to Available Qty Shortage');
                  }
              }
          }
      }

      update inventoryList;

      List < bulk_sponsorship__c > errorUpdate = new List < bulk_sponsorship__c > ();
      List < bulk_sponsorship__c > successUpdate = new List < bulk_sponsorship__c > ();

      if (bookSprMap.values().size() > 0) {
          List < Database.SaveResult > saveResultList = Database.insert(bookSprMap.values(), true);
          for (Integer l = 0; l < saveResultList.size(); l++) {
              try {
                  if (saveResultList.get(l).isSuccess()) {
                      saveResultList.get(l).getId();

                      //bulkSprMap.get(l).Error_Message__c = 'Success';
                      if (!bulkSprMap.get(l).is_Errored__c)
                          bulkSprMap.get(l).isSuccess__c = true;
                      if (sprBookingMap.containsKey(l))
                          sprBookingMap.get(l).Booked_Sponsorship__c = saveResultList.get(l).getId();
                      if (sprProposalMap.containsKey(l))
                          sprProposalMap.get(l).Bookied_Sponsorship__c = saveResultList.get(l).getId();
                      successUpdate.add(bulkSprMap.get(l));
                  } else if (!saveResultList.get(l).isSuccess()) {
                      // DML operation failed
                      Database.Error error = saveResultList.get(l).getErrors().get(0);
                      String failedDML = error.getMessage();
                      bulkSprMap.get(l).is_Errored__c = true; //failed record from the list
                      bulkSprMap.get(l).Error_Message__c = failedDML;
                      system.debug('Failed ID' + bookSprMap.get(l) + failedDML);
                      errorUpdate.add(bulkSprMap.values());
                      Log4SF.logMessage('SponsorshipDataLoad', 'booked sponsorship Insert', failedDML, UserInfo.getUserId(), bulkSprMap.get(l).Name);
                  }
              } catch (Exception ex) {
                  system.debug('ex ID' + ex.getStackTraceString() + ex.getMessage());
                  Log4SF.logMessage('SponsorshipDataLoad', 'booked sponsorship  Insert', ex.getMessage(), UserInfo.getUserId(), bulkSprMap.get(l).Name);
              }
          }
      }

      if (sprProposalMap.values().size() > 0) Database.insert(sprProposalMap.values(), true);
      System.debug('Booking list size: ' + sprBookingMap.values().size());
      if (sprBookingMap.values().size() > 0) {
          List < Database.SaveResult > detailInsertList = Database.insert(sprBookingMap.values(), true);
          for (Integer g = 0; g < detailInsertList.size(); g++) {
              try {
                  if (detailInsertList.get(g).isSuccess()) {
                      if (sprInventoryMap.containsKey(g)) sprInventoryMap.get(g).Booking_Details__c = detailInsertList.get(g).getId();
                  } else {
                      Database.Error error = detailInsertList.get(g).getErrors().get(0);
                      String failedDML = error.getMessage();
                      System.debug('Failed ID' + sprBookingMap.get(g) + failedDML);
                      Log4SF.logMessage('SponsorshipDataLoad', 'Booking Details Insert', failedDML, UserInfo.getUserId(), bulkSprMap.get(g).Name);
                  }
              } catch (Exception ex) {
                  System.debug('ex ID' + ex.getStackTraceString() + ex.getMessage());
                  Log4SF.logMessage('SponsorshipDataLoad', 'Booking Details Insert', ex.getMessage(), UserInfo.getUserId(), bulkSprMap.get(g).Name);
              }
          }
      }

      if (sprInventoryMap.values().size() > 0) Database.insert(sprInventoryMap.values(), true);
      if (bulkSprMap.values().size() > 0) Database.update(bulkSprMap.values(), true);
  }

  @AuraEnabled(cacheable=true)
  public static Map < ID, String > getRelatedFilesByRecordId(String scriptSelected) {
      // Get record file IDs        
      //List<ContentDocumentLink> files = [SELECT ContentDocumentId FROM ContentDocumentLink WHERE ContentDocumentId = :recordId];
      //List<ID> fileIDs = new List<ID>();
      // for (ContentDocumentLink docLink : files) {
      //     fileIDs.add(docLink.ContentDocumentId);
      // }
      System.debug('scriptSelected: '+scriptSelected);
      ContentDocument objContentDocument;
      if (scriptSelected == 'TotalLocalSponsorship') {
          objContentDocument = [SELECT ID, Title FROM ContentDocument WHERE Title = 'TotalLocalSponsorshipCSVFormat'
              LIMIT 1
          ];
      } else if (scriptSelected == 'SoldLocalSponsorship') {
          objContentDocument = [SELECT ID, Title FROM ContentDocument WHERE Title = 'SoldLocalSponsorshipCSVFormat'
              LIMIT 1
          ];
      } else if (scriptSelected == 'TotalNationalSponsorship') {
          objContentDocument = [SELECT ID, Title FROM ContentDocument WHERE Title = 'TotalNationalSponsorshipCSVFormat'
              LIMIT 1
          ];
      } else if (scriptSelected == 'SoldNationalSponsorship') {
          objContentDocument = [SELECT ID, Title FROM ContentDocument WHERE Title = 'SoldNationalSponsorshipCSVFormat'
              LIMIT 1
          ];
      }
      System.debug('objContentDocument: '+objContentDocument);
      Map < ID, String > mapIdTitle = new Map < ID, String > ();
      if (objContentDocument != null) {
          List < ContentVersion > docs = [SELECT ContentDocumentId, FileExtension, Title
              FROM ContentVersion WHERE ContentDocumentId =: objContentDocument.ID
          ];
          System.debug('docs: '+docs);
          for (ContentVersion docLink: docs) {
              mapIdTitle.put(docLink.ContentDocumentId, docLink.Title);
          }
      }
      return mapIdTitle;
  }
}