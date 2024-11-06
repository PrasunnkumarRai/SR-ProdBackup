/*
###########################################################################
# File..................: ProposalLightningSwitcherController.cls
# Version...............: 1
# Created by............: Sanchit Singhal   
# Created Date..........: 10-May-2017
# Last Modified by......: 
# Last Modified Date....: 
# Description...........: This class contains redirect methods for Proposal TIM Create
# TAO Ref#..............: NA
# Change Log:               
#
#
############################################################################*/
public with sharing class ProposalLightningSwitcherController {
    
    public pageReference redirect(){
     
        String destination = ApexPages.currentPage().getParameters().get('redirectdestination');
        String oppId = ApexPages.currentPage().getParameters().get('id');

        PageReference newpage=Page.ProposalTIMCreate;
        newpage.getParameters().put('id',oppId);
        return newpage;
    }
    
}