/* 
 * Date:        - Project: UserStory#       - Developer/Company           - Description
 * -----------------------------------------------------------------------------------------------------------------------------------------
 * 06/28/2017 - UAT3 - Agency Opportuniy      - J King, M&S              - Creation
 *
 */

public class OpportunityUtils {
  public static Map<String, Schema.RecordTypeInfo> recordTypeInfoMap{
        get{
            if (recordTypeInfoMap == null){
                recordTypeInfoMap = new map<String,Schema.RecordTypeInfo>();
              //  recordTypeInfoMap = Opportunity.sObjectType.getDescribe().getRecordTypeInfosByName();
                recordTypeInfoMap = Opportunity.sObjectType.getDescribe().getRecordTypeInfosByDeveloperName();
            }
            return recordTypeInfoMap;
        }
        set;
    }
    
    public static Id nationalLockedOpportunityRtId  = recordTypeInfoMap.get('National_Locked_Opportunity').getRecordTypeId();
    public static Id nationalOpportunityRtId        = recordTypeInfoMap.get('National_Opportunity').getRecordTypeId();
    public static Id opportunityRtId                = recordTypeInfoMap.get('Opportunity').getRecordTypeId();
    public static Id opportunityLockedAccountRtId   = recordTypeInfoMap.get('Opportunity_Locked').getRecordTypeId();
    public static Id agencyOpportunityRtId          = recordTypeInfoMap.get('Agency_Opportunity').getRecordTypeId();
    public static Id holdingAcctOpportunityRtId     = recordTypeInfoMap.get('Holding_Account_Opportunity').getRecordTypeId(); // SRSF-4392    
}