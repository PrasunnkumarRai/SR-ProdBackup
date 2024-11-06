/*
  ###########################################################################
  # File..................: BudgetAutomationModel.cls
  # Version...............: 1
  # Created by............: Matthew Kidman
  # Created Date..........: 10-Dec-2019
  # Last Modified by......:
  # Last Modified Date....:
  # Description...........: This class is contains the Budget Automation Object Model
  # TAO Ref#..............: NA
  # Test Class............: 
  # Change Log............:
  #
  #
  ############################################################################
*/
public class BudgetAutomationModel  
{
	public BudgetAutomationModel()
	{

	}
	public string key = '';
	public string OppName = '';
	public string OppBudgetName = '';
	public String DMA = '';
	public string AgencyId='';
	public string OppOwner = '';
	public string oppID = '';
	public string stage = 'Identification';
	public Date presentationDate = System.Date.Today();
	public Decimal probability = 50;
	public string oppSource = 'Forecast Automation';
	public Boolean isOppCreated = false;
	public string oppBudgetID = '';
	public Boolean isOppbudgetCreated = false;
	public string advertiserID = '';
	public string repfirmID = '';
	public string errorMessage = '';
	public Date broadcastDate ;
	//Counter variables
	public Decimal totalOppCount = 0;
	public Decimal pzCount = 0;
	public Decimal pzSuccessCount = 0;
	public Decimal pzmvCount = 0;
	public Decimal pzmvSuccessCount = 0;

	//public List<ProposalZoneModel> proposalZoneList = new List<ProposalZoneModel>();
	public Map<String,ProposalZoneModel> proposalZoneMap = new Map<String,ProposalZoneModel>();

	public class ProposalZoneModel
	{
		//public string oppBudgetID;
		public string productLine;
		public string pzName = '';
		public string pzID = '';
		public string sysCode = '';
		//public string etc;
		public Map<Decimal,ProposalZoneMonthlyValueModel> pzmvMap = new Map<Decimal,ProposalZoneMonthlyValueModel>();
		public Boolean isCreated = false;
		public string errorMessage = '';
	}

	public class ProposalZoneMonthlyValueModel
	{
		public string errorMessage = '';
		public string pzmvID  = '';
		public Decimal broadcastMonth = 00;
		public Decimal broadcastYear = 2019;
		public Decimal amount = 0;
		public Boolean isCreated = false;
	}

}