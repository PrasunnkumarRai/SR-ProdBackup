@IsTest
public class LeadSearchControllerTest {
      @IsTest
     static void testGetDMAList(){
      User newUser = TestDataHelper.createUser(true);
      System.runAs(newUser) {
         String str = 'los';
         LeadSearchController.getDMAList(str);
      }
     }
    @IsTest
     static void testGetLeadDMAList(){
          User newUser = TestDataHelper.createUser(true);
          System.runAs(newUser) {
            String selectedDMA = 'LAREDO - TX';
            LeadSearchController.getLeadDMAList(selectedDMA);
          }
     }
     @IsTest
     static void testGetFilterList(){
          User newUser = TestDataHelper.createUser(true);
          System.runAs(newUser) {
              String filerStr = 'Suzette Barrera';
            String selectedDMA = 'LAREDO - TX';
            LeadSearchController.getFilterList(filerStr,selectedDMA);
          }
     }
    @IsTest
     static void testGetMetaData(){  
         LeadSearchController.getMetaData();
     }
}