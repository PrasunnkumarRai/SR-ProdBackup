public with sharing class BudgetingToolModelDOS {

    public List<List<Body>> Body;

    // Body --> Acc --> Pro

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

        public List<Items_Acc> Items;

        public Body() {
            Def ='t';
        }
    }  //end Body classdef

    public class Items_Acc {
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
            Def = 'prod';
        }
    }  //end Items_Acc classdef

    public class Items_Pro {
        public String Account;
        public String id;
        public String Def;
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

        public Items_Pro() {
            Spanned = '1';
        }        

        public void format(String f) {
            String defTmp = 'lplain';
            if     (Account == '2019 Unknown Churn')                                { defTmp = 'lneg'; }
            else if(Account == '2019 Budget' || Account == '2019 New Business')     { defTmp = 'ldollar'; }
            else if(f == 'p')                                                       { defTmp = 'lpct'; }
            Def = defTmp;
        }
    }  //end Items_Pro classdef

    public static BudgetingToolModelDOS parse(String json) {
        return (BudgetingToolModelDOS) System.JSON.deserialize(json, BudgetingToolModelDOS.class);
    }    
}