public class AOSDealIdSender {

    public void sendAOSDealIds(List<String> aosDealIds) {
        // Endpoint URL
         String endpoint = System.Label.BoomiEndPointAOSCreativeLine;

        // Username and password for basic authentication
        String username = 	System.Label.BoomiUserNameCreativeAOSLine;
        String password = 	System.Label.BoomiUserPasswordAOSLine;

        // Encode the credentials
        String credentials = username + ':' + password;
        String encodedCredentials = EncodingUtil.base64Encode(Blob.valueOf(credentials));
        System.debug('encodedCredentials: ' + encodedCredentials);
        Integer Settimeoutval=Integer.valueOf(system.Label.SettimeoutforAOS);
        // Create a new HTTP request
        HttpRequest req = new HttpRequest();
        req.setEndpoint(endpoint);
        req.setMethod('POST');
        req.setHeader('Content-Type', 'application/json');
        req.setHeader('Authorization', 'Basic ' + encodedCredentials);
        req.setTimeout(Settimeoutval); // Set the timeout to 20 seconds (20000 milliseconds)


        // Construct the JSON payload
        Map<String, List<String>> payloadMap = new Map<String, List<String>>();
        payloadMap.put('planId', aosDealIds);
        String jsonPayload = JSON.serialize(payloadMap);
        System.debug('jsonPayload: ' + jsonPayload);
        req.setBody(jsonPayload);

        // Send the request
        Http http = new Http();
        HttpResponse res = http.send(req);

        // Handle the response
        if (res.getStatusCode() == 200 && res.getBody() != null && res.getBody().trim().length() > 0) {
            System.debug('Response received successfully: ' + res.getBody());

            // Parse the response
            String responseBody = res.getBody();
            Object parsedResponse = JSON.deserializeUntyped(responseBody);
            
            List<Object> responseList;
            // Check if the response is a Map or a List
            if (parsedResponse instanceof List<Object>) {
                responseList = (List<Object>) parsedResponse;
            } else if (parsedResponse instanceof Map<String, Object>) {
                responseList = (List<Object>) ((Map<String, Object>) parsedResponse).get('data'); // Adjust this key if necessary
                if (responseList == null) {
                    System.debug('No data found in response map.');
                    return;
                }
            } else {
                System.debug('Unexpected response format: ' + parsedResponse);
                return; // Exit if response format is not as expected
            }

            System.debug('Parsed response list: ' + responseList);

            // Prepare a list of records to upsert and a set to track unique plan IDs
            List<PLAN_DIGITAL_LINES__c> recordsToUpsert = new List<PLAN_DIGITAL_LINES__c>();
            Set<String> planIdSet = new Set<String>();

            for (Object obj : responseList) {
                Map<String, Object> creativeLine = (Map<String, Object>) obj;
                String planLineId = String.valueOf(creativeLine.get('planLineId'));

                // Skip duplicate plan IDs
                if (planIdSet.contains(planLineId)) {
                    continue;
                }
                planIdSet.add(planLineId);

                PLAN_DIGITAL_LINES__c record = new PLAN_DIGITAL_LINES__c();

                // Map the response fields to Salesforce fields
                record.Line_Name__c = (String) creativeLine.get('lineName');
                record.Plan_Name__c = (String) creativeLine.get('planName');
                record.Sequence_Id__c = String.valueOf(creativeLine.get('planLineId'));
                record.Plan_Id__c =  String.valueOf(creativeLine.get('planId'));
                // Handle date fields with null checks
                record.Package_Line_End_Date__c = parseDate((String) creativeLine.get('packageLineEndDate'));
                record.Package_Line_Start_Date__c = parseDate((String) creativeLine.get('packageLineStartDate'));
                record.Max_Pending_Creative_End_Date__c = parseDate((String) creativeLine.get('creativeLineEndDate'));
                record.Max_Pending_Creative_Start_Date__c = parseDate((String) creativeLine.get('creativeLineStartDate'));

                recordsToUpsert.add(record);
            }

            System.debug('Records to upsert: ' + recordsToUpsert.size());
            System.debug('Records details: ' + recordsToUpsert);

            // Upsert the records
            try {
               upsert recordsToUpsert PLAN_DIGITAL_LINES__c.Sequence_Id__c;
                System.debug('Records upserted successfully: ' + recordsToUpsert.size());
                updateAdvanceProposalonPlanDigitalLine(aosDealIds);
            } catch (DmlException e) {
                System.debug('Error upserting records: ' + e.getMessage());
            }
        } else {
            System.debug('Failed to retrieve AOS Deal Ids. Status code: ' + res.getStatusCode() + ', Response: ' + res.getBody());
        }
    }

    private Date parseDate(String dateString) {
        Date dateValue = null;
        try {
            if (dateString != null && dateString.trim().length() > 0) { // Use length() to check if the string is not empty
                dateValue = Date.valueOf(dateString.split(' ')[0]); // Extract just the date part
            }
        } catch (Exception e) {
            System.debug('Error parsing date: ' + e.getMessage());
        }
        return dateValue;
    }
  private void updateAdvanceProposalonPlanDigitalLine(List<String> aosDealId) {
    List<Proposal__c> proposals = [
            SELECT Id, AOS_Deal_Id__c
            FROM Proposal__c where RecordType.Name='Advanced Proposal' and AOS_Deal_Id__c IN:aosDealId
        ];
        
        // Create a map to store the Proposal__c records by AOS_Deal_Id__c
        Map<String, Proposal__c> proposalMap = new Map<String, Proposal__c>();
        for (Proposal__c proposal : proposals) {
            proposalMap.put(proposal.AOS_Deal_Id__c, proposal);
        }
        
        // Query all PLAN_DIGITAL_LINES__c records
        List<PLAN_DIGITAL_LINES__c> planDigitalLines = [
            SELECT Id, Plan_Id__c, Proposal__c
            FROM PLAN_DIGITAL_LINES__c where Plan_Id__c IN:aosDealId
        ];
        
        // Create a list to store the updated PLAN_DIGITAL_LINES__c records
        List<PLAN_DIGITAL_LINES__c> updatedPlanDigitalLines = new List<PLAN_DIGITAL_LINES__c>();
        
        // Iterate through the PLAN_DIGITAL_LINES__c records
        for (PLAN_DIGITAL_LINES__c planDigitalLine : planDigitalLines) {
            // Get the Proposal__c record that matches the Plan_Id__c of the PLAN_DIGITAL_LINES__c record
            Proposal__c matchedProposal = proposalMap.get(planDigitalLine.Plan_Id__c);
            if (matchedProposal != null) {
                // Update the Proposal__c field of the PLAN_DIGITAL_LINES__c record
                planDigitalLine.Proposal__c = matchedProposal.Id;
                updatedPlanDigitalLines.add(planDigitalLine);
            }
        }
       system.debug('updatedPlanDigitalLines'+updatedPlanDigitalLines) ;
        // Update the PLAN_DIGITAL_LINES__c records in the database
        if (!updatedPlanDigitalLines.isEmpty()) {
           update updatedPlanDigitalLines;
            system.debug('updatedPlanDigitalLines'+updatedPlanDigitalLines.size());
        }}
    
}