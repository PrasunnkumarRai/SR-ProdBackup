@IsTest(SeeAllData = true)
public class GetDependencyPickList_Test {

    @isTest
    public static void getPickList_PrimaryOECommodityDependency_getDependentOptionsImpl_MethodIsCalled(){

        Test.startTest();
        // Arragne
         Map<String, List<String>> pickList = GetDependencyPickList.getPickList();

         // Assert
         System.assertEquals(pickList.size() > 0, true);

         Test.stopTest();
    }
}