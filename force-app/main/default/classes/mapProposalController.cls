public class mapProposalController {
    // @AuraEnabled(cacheable=false)
  //   public PageReference mapProposalController() {

  //       string url = 'https://dev.map.spectrumreach.io/';

  //       PageReference page = new PageReference(url);
  //       page.setRedirect(true);
  //       return page;
  // }
  public String currentRecordId {get;set;}
  public String  aeEmail {get;set;}
  public Opportunity opp{get;set;}
  public mapProposalController(ApexPages.StandardController controller){
  
      currentRecordId  = ApexPages.CurrentPage().getparameters().get('id');
      if(currentRecordId != null){ opp = [SELECT Owner.Email FROM Opportunity WHERE Id = :currentRecordId ];
      aeEmail=opp.Owner.Email;
      System.debug('Entire Opportunity '+opp);
      System.debug('@@Opp Owner '+opp.Owner.Email);}
  
  }

  
}