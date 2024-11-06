/* 
 * Date:        - Project: UserStory#       - Developer/Company           - Description
 * -----------------------------------------------------------------------------------------------------------------------------------------
 * 05/07/2017 - Spectrum Reach: 178      - J King, M&S              - Creation
 *
 */

public class AccountRequestUtils {
  public static Map<String, Schema.RecordTypeInfo> recordTypeInfoMap{
        get{
            if (recordTypeInfoMap == null){
                recordTypeInfoMap = new map<String,Schema.RecordTypeInfo>();
                recordTypeInfoMap = Account_Request__c.sObjectType.getDescribe().getRecordTypeInfosByName();
            }
            return recordTypeInfoMap;
        }
        set;
    }
    
    public static Id accountIdCreditRequestRtId             = recordTypeInfoMap.get('Account Id/Credit Request').getRecordTypeId();
    public static Id accountMergeRequestRtId                = recordTypeInfoMap.get('Account Merge Request').getRecordTypeId();
    public static Id accountSwitchRequestRtId               = recordTypeInfoMap.get('Account Switch Request').getRecordTypeId();
    public static Id badDebtWriteOffRequestRtId             = recordTypeInfoMap.get('Bad Debt write off Request').getRecordTypeId();
    public static Id billingRequestRtId                     = recordTypeInfoMap.get('Billing Request').getRecordTypeId();
    public static Id contactNoContactRequestRtId            = recordTypeInfoMap.get('Contact/No contact request').getRecordTypeId();
    public static Id creditCollectionExceptionRtId          = recordTypeInfoMap.get('Credit/Collection Exception').getRecordTypeId();
    public static Id integrataionUserOnlyRtId               = recordTypeInfoMap.get('Integration User Only').getRecordTypeId();
    public static Id paymentResearchRtId                    = recordTypeInfoMap.get('Payment Research').getRecordTypeId();
    public static Id refundRtId                             = recordTypeInfoMap.get('Refund').getRecordTypeId();
    public static Id revenueAdjustmentRtId                  = recordTypeInfoMap.get('Revenue Adjustment').getRecordTypeId();
    public static Id teamMemberRequestRtId                  = recordTypeInfoMap.get('Team Member Request').getRecordTypeId();
    public static Id termsAndConditionsExceptionsRtId       = recordTypeInfoMap.get('Terms and Conditions Exceptions').getRecordTypeId();
    public static Id tradeAccountAuthorizationRequestRtId   = recordTypeInfoMap.get('Trade Account Authorization Request').getRecordTypeId();
    public static Id accApprovalRtId                        = recordTypeInfoMap.get('Account Approval Request').getRecordTypeId();


}