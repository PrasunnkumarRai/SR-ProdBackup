public with sharing class BudgetingToolModel {

    public List<List<Body>> Body;

    // Body --> Acc --> Pro --> Led

    public class Body {
        public String Account;
        public String Category;     
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

        public List<Items_Pro> Items;

        public Body() {
            Def ='t';
        }
    }  //end Body classdef

   /* public class Items_Acc {
        public String Account;
        public String Category;
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

        public List<Items_Pro> Items;

        public Items_Acc() {
            Def = 't';
        }
    }  //end Items_Acc classdef
*/
    public class Items_Pro {
        public String Account;
        public String id;
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

        public Items_Pro() {
            Def = 'prod';
        }        
    }  //end Items_Pro classdef

	public class Items_Led {
        public String Account;
        public String Def;
        public String id;
        public String Spanned;
        public String ChurnIndicator;

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

    public static BudgetingToolModel parse(String json) {
        return (BudgetingToolModel) System.JSON.deserialize(json, BudgetingToolModel.class);
    }    
}