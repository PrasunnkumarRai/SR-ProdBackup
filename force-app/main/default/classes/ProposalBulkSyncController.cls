public without sharing class ProposalBulkSyncController {

    public ProposalBulkSyncController(ApexPages.StandardController std){        
    }
    
    public pageReference syncProposals(){
        
        String boomiAtomId = '';
        try{
            Map<String,TIMIntegration__c> custSettMap = new Map<String,TIMIntegration__c>();
            custSettMap = TIMIntegration__c.getAll();
            System.debug('@@custSettMap '+custSettMap);
            
            for(TIMIntegration__c ti: custSettMap.values()){
                  if(String.isNotBlank(ti.boomiAtomId__c)){
                        boomiAtomId = ti.boomiAtomId__c;                
                                    
                        // Instantiate a new http object
                        Http h = new Http();
                        // Instantiate a new HTTP request, specify the method (POST) as well as the endpoint
                        HttpRequest req = new HttpRequest();
                        HttpResponse res ;
                        req.setEndpoint('callout:Boomi/executeProcess');
                        req.setMethod('POST');
                        req.setHeader('Content-type','application/xml; charset=UTF-8');
                        req.setTimeout(120000);
                        //Set request format
                        String reqBody = '<ProcessExecutionRequest processId="'+ System.label.BoomiBulkProposalId +'" atomId="'+ boomiAtomId +'" xmlns="http://api.platform.boomi.com/"></ProcessExecutionRequest>';
                        req.setBody(reqBody);
                        try {
                            res = h.send(req);
                            System.debug('syncProposals Callout response: '+ res);
                        }
                        catch(System.CalloutException e) {
                            System.debug('syncProposals Callout error: '+ e + e.getLineNumber());
                        }
                  }
            }
        }   
        catch(Exception e) {
            System.debug('syncProposals error: '+ e + e.getLineNumber());
        }
        return new pageReference(Label.LEX_sObject_URL + 'ProposalBulkSync__c/list?filterName=All'); 
       // return new pageReference('/one/one.app#/sObject/ProposalBulkSync__c/list?filterName=All');
    }    
}