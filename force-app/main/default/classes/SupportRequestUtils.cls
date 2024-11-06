/* 
 * Date:        - Project: UserStory#       - Developer/Company           - Description
 * -----------------------------------------------------------------------------------------------------------------------------------------
 * 05/25/2017 - Spectrum Reach: 97      - J King, M&S              - Creation
 *
 */

public class SupportRequestUtils {
  public static Map<String, Schema.RecordTypeInfo> recordTypeInfoMap{
        get{
            if (recordTypeInfoMap == null){
                recordTypeInfoMap = new map<String,Schema.RecordTypeInfo>();
                recordTypeInfoMap = Support_Request__c.sObjectType.getDescribe().getRecordTypeInfosByName();
            }
            return recordTypeInfoMap;
        }
        set;
    }
   //Commented out due to 'Pre Production' value no longer being used. 
  //  public static Id preProductionRtId = recordTypeInfoMap.get('Pre Production').getRecordTypeId();
    public static Id productionRtId = recordTypeInfoMap.get('Production').getRecordTypeId();
    public static Id researchRequestRtId = recordTypeInfoMap.get('Research Request').getRecordTypeId();
    
    
}