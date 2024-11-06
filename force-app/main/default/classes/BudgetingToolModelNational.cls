public with sharing class BudgetingToolModelNational {

// Body --> DMA --> Commodity --> Acc --> Led

    public List<List<Body>> Body;

    public class Body {
        public String Def;
        public String Account;

        public Decimal Jan;
        public Decimal Feb;
        public Decimal Mar;
        public Decimal Apr;
        public Decimal May;
        public Decimal Jun;
        public Decimal Jul;
        public Decimal Aug;
        public Decimal Sep;
        public Decimal Oct;
        public Decimal Nov;
        public Decimal Dec;

        public List<Items_DMA> Items;

        public Body() {
            Def ='t';
        }       
    }  //end Body classdef

    public class Items_DMA {
        public String Account;
        public Integer Selected;

        public Decimal Jan;
        public Decimal Feb;
        public Decimal Mar;
        public Decimal Apr;
        public Decimal May;
        public Decimal Jun;
        public Decimal Jul;
        public Decimal Aug;
        public Decimal Sep;
        public Decimal Oct;
        public Decimal Nov;
        public Decimal Dec;

        public String Def;

        //public List<Items_Commodity> Items;
        public List<Items_Acc> Items;
        public Items_DMA() {
            Def = 't';
        }
    }  //end Items_DMA classdef

/*
    public class Items_Commodity {
        public String Account;
        public Integer Selected;

        public Decimal Jan;
        public Decimal Feb;
        public Decimal Mar;
        public Decimal Apr;
        public Decimal May;
        public Decimal Jun;
        public Decimal Jul;
        public Decimal Aug;
        public Decimal Sep;
        public Decimal Oct;
        public Decimal Nov;
        public Decimal Dec;

        public String Def;

        public List<Items_Acc> Items;
        
        public Items_Commodity() {
            Def = 't';
        }
    }  //end Items_Commodity classdef
*/
	public class Items_Acc {
		public String Account;
		public Integer Selected;
		public String Def;
		
		public Decimal Jan;
		public Decimal Feb;
        public Decimal Mar;
        public Decimal Apr;
        public Decimal May;
        public Decimal Jun;
        public Decimal Jul;
        public Decimal Aug;
        public Decimal Sep;
        public Decimal Oct;
        public Decimal Nov;
        public Decimal Dec;

		public List<Items_Led> Items;
		
		public Items_Acc() {
            Def = 'prod';
        }   
    }  //end Items_Acc classdef

	public class Items_Led {
		public String Account;
		public String id;
		public Integer Selected;
		public String ChurnIndicator;
        public String Spanned;
        public String Def;
		
        public Decimal Jan;
        public Decimal Feb;
        public Decimal Mar;
        public Decimal Apr;
        public Decimal May;
        public Decimal Jun;
        public Decimal Jul;
        public Decimal Aug;
        public Decimal Sep;
        public Decimal Oct;
        public Decimal Nov;
        public Decimal Dec;

        public Items_Led(){
            Spanned = '1';
        }

        public void format(String f) {
            String defTmp = 'lplain';
            if     (Account == '2019 Unknown Churn')                                { defTmp = 'lneg'; }
            else if(Account == '2019 Budget' || Account == '2019 New Business')     { defTmp = 'ldollar'; }
            else if(f == 'p')                                                       { defTmp = 'lpct'; }
            Def = defTmp;
        }
	}  //end Items_Led classdef
	
	public static BudgetingToolModelNational parse(String json) {
		return (BudgetingToolModelNational) System.JSON.deserialize(json, BudgetingToolModelNational.class);
	}
}