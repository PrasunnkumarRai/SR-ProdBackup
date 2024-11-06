global class StratagTimService_Mock implements WebServiceMock {
          global void doInvoke(
           Object stub,
           Object request,
           Map<String, object> response,
           String endpoint,
           String soapAction,
           String requestName,
           String responseNS,
           String responseName,
           String responseType) 
           {
           	   System.debug('Mock.soapAction: ' + soapAction);
           	    
               if(soapAction=='http://www.stratag.com/TIMService/SAuthenticate')
               {
	               StratagTimservice.SAuthenticateResponse_element respElement = new StratagTimservice.SAuthenticateResponse_element();
	               respElement.SAuthenticateResult= 'Mock Test';
	               response.put('response_x', respElement);
               }
               else if(soapAction=='http://www.stratag.com/TIMService/DeleteOrder')
               {
	               request='deleteorder';
	               requestName='deleteorder';
	               soapAction='http://www.stratag.com/TIMService/DeleteOrder';
	               responseName='DeleteOrderResponse';
	               responseType='StratagTimservice.DeleteOrderResponse_element';
	               StratagTimservice.DeleteOrderResponse_element respElement = new StratagTimservice.DeleteOrderResponse_element();
	               respElement.DeleteOrderResult= True;
	               response.put('response_x', respElement);
               } 
               else if(soapAction=='http://www.stratag.com/TIMService/UndeleteOrder')
               {
	               request='UndeleteOrder';
	               requestName='UndeleteOrder';
	               soapAction='http://www.stratag.com/TIMService/UndeleteOrder';
	               responseName='UndeleteOrderResponse';
	               responseType='StratagTimservice.UndeleteOrderResponse_element';
	               StratagTimservice.UndeleteOrderResponse_element respElement = new StratagTimservice.UndeleteOrderResponse_element();
	               respElement.UndeleteOrderResult= True;
	               response.put('response_x', respElement);
               }
              
               else if(soapAction=='http://www.stratag.com/TIMService/GetEstimateHeaders_4_6')
               {
	               request='GetEstimateHeaders_4_6';
	               requestName='GetEstimateHeaders_4_6';
	               soapAction='http://www.stratag.com/TIMService/GetEstimateHeaders_4_6';
	               responseName='GetEstimateHeaders_4_6Response';
	               responseType='StratagTimservice.UndeleteOrderResponse_element';
	               
	               StratagTimService.BroadcastValue bv = new StratagTimService.BroadcastValue();
			       bv.YearMonth = '2014.05';
			       bv.TotalCost = 123;		        
			        		        
			       StratagTimService.BroadcastValue[] broadcastArray = new StratagTimService.BroadcastValue[]{};
			       broadcastArray.add(bv);
			        
			       StratagTimService.ArrayOfBroadcastValue broadcastValuesArray = new StratagTimService.ArrayOfBroadcastValue();
			       broadcastValuesArray.BroadcastValue = broadcastArray;
			       
			       StratagTimService.ScheduleItem_4_6 scheduleItem = new StratagTimService.ScheduleItem_4_6();                    
	                
	               scheduleItem.SysCodes = '8155';                    
	               scheduleItem.Markets = 'Charter/La Crosse Interconnect, WI, 8155';
	               scheduleItem.Zones = 'La Crosse';                
	             
	               scheduleItem.BroadcastValues = broadcastValuesArray; 
	               
	               StratagTimService.ScheduleItem_4_6[] scheduleItems = new StratagTimService.ScheduleItem_4_6[]{};
	               scheduleItems.add(scheduleItem);
	               
	               StratagTimservice.ArrayOfScheduleItem_4_6 scheduleItemsArray = new StratagTimservice.ArrayOfScheduleItem_4_6();
	               scheduleItemsArray.ScheduleItem_4_6 = scheduleItems;
	               
	               StratagTimservice.EstimateHeader_4_6 estimate = new StratagTimservice.EstimateHeader_4_6();
			       estimate.FlightStart = '01/01/2015'; 
			       estimate.FlightEnd = '01/01/2015';        
			       estimate.AdvertiserID = 2472;
			       estimate.AgencyID = 122;
			       estimate.EstimateID = 1234;
			       estimate.ProductID = 0;
			       estimate.AeID = 149;
			       
			       estimate.ScheduleItems = scheduleItemsArray;
	               
	               StratagTimservice.EstimateHeader_4_6[] estList = new StratagTimservice.EstimateHeader_4_6[]{};
	               estList.add(estimate);
	                
	               StratagTimservice.ArrayOfEstimateHeader_4_6 aeh = new StratagTimservice.ArrayOfEstimateHeader_4_6();
	               aeh.EstimateHeader_4_6 = estList;
	               
	               StratagTimservice.GetEstimateHeaders_4_6Response_element respElement = new StratagTimservice.GetEstimateHeaders_4_6Response_element();
	               respElement.GetEstimateHeaders_4_6Result = aeh;
	               
	               response.put('response_x', respElement);
               }
               else if(soapAction=='http://www.stratag.com/TIMService/GetEntities_4_2')
               {
	               request='GetEntities_4_2';
	               requestName='GetEntities_4_2';
	               soapAction='http://www.stratag.com/TIMService/GetEntities_4_2';
	               responseName='Entities';
	               responseType='StratagTimservice.GetEntities_4_2Response_element';
	               
	               StratagTimservice.AE_3_5 ae = new StratagTimservice.AE_3_5();
	               ae.AeName = 'Test AE';
	               ae.AeId = 123;
	               
	               StratagTimservice.AE_3_5[] ae35_arr = new StratagTimservice.AE_3_5[]{};
	               ae35_arr.add(ae);
	               
	               StratagTimservice.ArrayOfAE_3_5 aeArray = new StratagTimservice.ArrayOfAE_3_5();
	               aeArray.AE_3_5 = ae35_arr;
	               
	               StratagTimservice.Entities ent = new StratagTimservice.Entities();
	               ent.AEList = aeArray;
	               
	               StratagTimservice.GetEntities_4_2Response_element respElement = new StratagTimservice.GetEntities_4_2Response_element();
	               respElement.GetEntities_4_2Result = ent;
	               System.debug('respElement: ' + respElement);
	               response.put('response_x', respElement);
               }
               else if(soapAction=='http://www.stratag.com/TIMService/GetEntities_4_2')
               {
	               request='GetEntities_4_2';
	               requestName='GetEntities_4_2';
	               soapAction='http://www.stratag.com/TIMService/GetEntities_4_2';
	               responseName='GetEntities_4_2Response_element';
	               responseType='StratagTimservice.GetEntities_4_2Response_element';
	               StratagTimservice.GetEntities_4_2Response_element respElement = new StratagTimservice.GetEntities_4_2Response_element();
	               response.put('response_x', respElement);
               }
               else if(soapAction=='http://www.stratag.com/TIMService/GetEstimateHeaders_3_2')
               {
	               request='GetEstimateHeaders_3_2';
	               requestName='GetEstimateHeaders_3_2';
	               soapAction='http://www.stratag.com/TIMService/GetEstimateHeaders_3_2';
	               responseName='GetEstimateHeaders_3_2Response_element';
	               responseType='StratagTimservice.GetEstimateHeaders_3_2Response_element';
	               StratagTimservice.GetEstimateHeaders_3_2Response_element respElement = new StratagTimservice.GetEstimateHeaders_3_2Response_element();
	               response.put('response_x', respElement);
               }
               else if(soapAction=='http://www.stratag.com/TIMService/SaveEstimate_4_6')
               {
	               request='SaveEstimate_4_6';
	               requestName='SaveEstimate_4_6';
	               soapAction='http://www.stratag.com/TIMService/SaveEstimate_4_6';
	               responseName='SaveEstimate_4_6Response_element';
	               responseType='StratagTimservice.SaveEstimate_4_6Response_element';
	               StratagTimservice.SaveEstimate_4_6Response_element respElement = new StratagTimservice.SaveEstimate_4_6Response_element();
	               response.put('response_x', respElement);
               }
               else if(soapAction=='http://www.stratag.com/TIMService/GetEntities')
               {
	               request='GetEntities';
	               requestName='GetEntities';
	               soapAction='http://www.stratag.com/TIMService/GetEntities';
	               responseName='GetEntitiesResponse_element';
	               responseType='StratagTimservice.GetEntitiesResponse_element';
	               StratagTimservice.GetEntitiesResponse_element respElement = new StratagTimservice.GetEntitiesResponse_element();
	               response.put('response_x', respElement);
               }
               else if(soapAction=='http://www.stratag.com/TIMService/SaveEntities')
               {
	               request='SaveEntities';
	               requestName='SaveEntities';
	               soapAction='http://www.stratag.com/TIMService/SaveEntities';
	               responseName='SaveEntitiesResponse_element';
	               responseType='StratagTimservice.SaveEntitiesResponse_element';
	               StratagTimservice.SaveEntitiesResponse_element respElement = new StratagTimservice.SaveEntitiesResponse_element();
	               response.put('response_x', respElement);
               }
               else if(soapAction=='http://www.stratag.com/TIMService/SaveAgency')
               {
	               request='SaveAgency';
	               requestName='SaveAgency';
	               soapAction='http://www.stratag.com/TIMService/SaveAgency';
	               responseName='SaveAgencyResponse_element';
	               responseType='StratagTimservice.SaveAgencyResponse_element';
	               StratagTimservice.SaveAgencyResponse_element respElement = new StratagTimservice.SaveAgencyResponse_element();
	               response.put('response_x', respElement);
               }
               else if(soapAction=='http://www.stratag.com/TIMService/GetAgency_3_2')
               {
	               request='GetAgency_3_2';
	               requestName='GetAgency_3_2';
	               soapAction='http://www.stratag.com/TIMService/GetAgency_3_2';
	               responseName='GetAgency_3_2Response_element';
	               responseType='StratagTimservice.GetAgency_3_2Response_element';
	               StratagTimservice.GetAgency_3_2Response_element respElement = new StratagTimservice.GetAgency_3_2Response_element();
	               response.put('response_x', respElement);
               }
               else if(soapAction=='http://www.stratag.com/TIMService/SetEstimateStatus_4_4')
               {
	               request='SetEstimateStatus_4_4';
	               requestName='SetEstimateStatus_4_4';
	               soapAction='http://www.stratag.com/TIMService/SetEstimateStatus_4_4';
	               responseName='SetEstimateStatus_4_4Response_element';
	               responseType='StratagTimservice.SetEstimateStatus_4_4Response_element';
	               StratagTimservice.SetEstimateStatus_4_4Response_element respElement = new StratagTimservice.SetEstimateStatus_4_4Response_element();
	               StratagTimservice.Result result = new StratagTimservice.Result();
	               respElement.SetEstimateStatus_4_4Result = result;
	               response.put('response_x', respElement);
               }
               else if(soapAction=='http://www.stratag.com/TIMService/ImportSCX_4_2')
               {
	               request='ImportSCX_4_2_element';
	               requestName='ImportSCX_4_2_element';
	               soapAction='http://www.stratag.com/TIMService/ImportSCX_4_2';
	               responseName='ImportSCX_4_2Response_element';
	               responseType='StratagTimservice.ImportSCX_4_2Response_element';
	               StratagTimservice.ImportSCX_4_2Response_element respElement = new StratagTimservice.ImportSCX_4_2Response_element();
	               StratagTimservice.Result result = new StratagTimservice.Result();
	               respElement.ImportSCX_4_2Result = result;
	               response.put('response_x', respElement);
               }
               else if(soapAction=='http://www.stratag.com/TIMService/GetEstimateHeaderChanges_4_6')
               {
	               request='GetEstimateHeaderChanges_4_6_element';
	               requestName='GetEstimateHeaderChanges_4_6_element';
	               soapAction='http://www.stratag.com/TIMService/GetEstimateHeaderChanges_4_6';
	               responseName='GetEstimateHeaderChanges_4_6Response_element';
	               responseType='StratagTimservice.GetEstimateHeaderChanges_4_6Response_element';
	               StratagTimservice.GetEstimateHeaderChanges_4_6Response_element respElement = new StratagTimservice.GetEstimateHeaderChanges_4_6Response_element();
	               StratagTimservice.Result result = new StratagTimservice.Result();
	               response.put('response_x', respElement);
               }
           }
}