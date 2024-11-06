public with sharing class ProposalContactCreateController {
	public String accountID;
    public String oppID;
    public ProposalContactCreateController() {
        
    }
    public PageReference accountRecordDetails(){       
        accountID = ApexPages.currentPage().getParameters().get('accId'); 
        System.debug('accountID::'+accountID);
        PageReference accRecordDetails = new PageReference('/' + accountID);
        return accRecordDetails;
    }
    public PageReference lightningComponentdetails(){    	
    	accountID = ApexPages.currentPage().getParameters().get('accId'); 
        PageReference nextPage = new PageReference('/apex/Contact?accid='+accountID);
        return nextPage;
    }
     public PageReference oppRecordDetails(){              
        oppID = ApexPages.currentPage().getParameters().get('oppId');         
        System.debug('oppID::'+oppID);
        PageReference oppRecordDetails = new PageReference('/' + oppID);
        return oppRecordDetails;
    }
    //ProposalLightningComponentContactCreate
}