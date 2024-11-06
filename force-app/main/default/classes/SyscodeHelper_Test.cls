@IsTest
public class SyscodeHelper_Test {
    static Testmethod void validate_SyscodeHelper(){
        SyscodeHelper sh = new SyscodeHelper();
        String json = '{\"menu\": {\"id\": \"file\",\"value\": \"File\"}}';
        SyscodeHelper.parse(json);
        
    } 

}