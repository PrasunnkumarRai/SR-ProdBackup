@isTest
public class ObjectPrefixControllerTest {
    static testmethod void getObjectPrefix(){
        ObjectPrefixController.getAllObjectPrefix();
        ObjectPrefixController.getObjectPrefix('800');
    }
}