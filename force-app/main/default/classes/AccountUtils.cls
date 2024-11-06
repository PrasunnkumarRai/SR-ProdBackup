/* 
 * Date:        - Project: UserStory#       - Developer/Company           - Description
 * -----------------------------------------------------------------------------------------------------------------------------------------
 * 04/20/2017 - Spectrum Reach: 178      - J King, M&S       - Creation
 * 06/07/2021 - SRSF-2632                - Sridhar           - Updated to use Recordtype Developername
 *
 */

public class AccountUtils {
  public static Map<String, Schema.RecordTypeInfo> recordTypeInfoMap{
        get{
            if (recordTypeInfoMap == null){
                recordTypeInfoMap = new map<String,Schema.RecordTypeInfo>();
                //recordTypeInfoMap = Account.sObjectType.getDescribe().getRecordTypeInfosByName();
                recordTypeInfoMap = Account.sObjectType.getDescribe().getRecordTypeInfosByDeveloperName();
            }
            return recordTypeInfoMap;
        }
        set;
    }
    
    /*public static Id accountRequestRtId             = recordTypeInfoMap.get('Account Request').getRecordTypeId();
    public static Id agencyAccountRtId              = recordTypeInfoMap.get('Agency Account').getRecordTypeId();
    public static Id competitorAccountRtId          = recordTypeInfoMap.get('Competitor Account').getRecordTypeId();
    public static Id localAdvertiserAccountRtId     = recordTypeInfoMap.get('Advertiser Account').getRecordTypeId();
    public static Id nationalAdvertiserAccountRtId  = recordTypeInfoMap.get('National Advertiser Account').getRecordTypeId();
    public static Id repFirmRtId                    = recordTypeInfoMap.get('Rep Firm').getRecordTypeId();*/
    public static Id accountRequestRtId             = recordTypeInfoMap.get('Account_Request').getRecordTypeId();
    public static Id agencyAccountRtId              = recordTypeInfoMap.get('Agency_Account').getRecordTypeId();
    public static Id competitorAccountRtId          = recordTypeInfoMap.get('Competitor_Account').getRecordTypeId();
    public static Id localAdvertiserAccountRtId     = recordTypeInfoMap.get('Advertiser_Account').getRecordTypeId();
    public static Id nationalAdvertiserAccountRtId  = recordTypeInfoMap.get('National_Account').getRecordTypeId();
    public static Id repFirmRtId                    = recordTypeInfoMap.get('Rep_Firm').getRecordTypeId();
    public static Id affiliateRtId                  = recordTypeInfoMap.get('Affiliate').getRecordTypeId();
    public static Id inHouseAgencyAccountRtId       = recordTypeInfoMap.get('In_House_Agency_Account').getRecordTypeId();
    public static Id holdingAccountRtId             = recordTypeInfoMap.get('Holding_Account').getRecordTypeId(); // SRSF-4392
    //**** SRSF-945 : IB : START *****
    public static final String ACC_REC_TYPE_CHANGED = 'ACCOUNT_RECORD_TYPE_CHANGED';
    public static final String ACC_REC_TYPE_AGENCY_TO_REP_FIRM = 'AGENCY_TO_REP_FIRM';
    public static final String ACC_REC_TYPE_REP_FIRM_TO_AGENCY = 'REP_FIRM_TO_AGENCY';
    public static final String ACC_REC_TYPE_UPDATE_DONE = 'ACCOUNT_RECORD_TYPE_CHANGES_PROPOGATED';
    //**** SRSF-945 : IB : END *****
}