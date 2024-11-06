<aura:application access="GLOBAL" extends="ltng:outApp">
  <!-- Create attribute to store lookup value as a sObject   force:slds--> 
    <aura:attribute name="selectedLookUpRecord" type="sObject" default="{}"/>
    <aura:dependency resource="c:AETransferTool"/>     
</aura:application>