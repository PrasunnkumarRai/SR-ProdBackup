@IsTest
public class WebServiceTestMockBudgetAggregateTest {
    static testmethod void test() {
        WebServiceTestMockBudgetAggregate obj = new WebServiceTestMockBudgetAggregate();
        HttpRequest httpRequest = new HttpRequest();
        obj.respond(httpRequest);
    }
}