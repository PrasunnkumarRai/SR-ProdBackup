trigger TopicAssignmentTrigger on TopicAssignment (after insert, after delete) {

    List<Opportunity> oppList= new List<Opportunity>();
    List<ID> topicIDList= new List<ID>();
    List<ID> OpportunityIDList= new List<ID>();
    //Map<ID,ID> mapOfOppTopic = new Map<ID,ID>();
    //Map<ID,Opportunity> mapOfOpps = new Map<ID,Opportunity>();
    if(trigger.isAfter && trigger.isInsert)
    {
        for(TopicAssignment topicAssigned : trigger.newMap.values())
        {
            
            if(topicAssigned.EntityType == 'Opportunity')
            {
                topicIDList.add(topicAssigned.topicID);
                OpportunityIDList.add(topicAssigned.EntityID);
                //mapOfOppTopic.put(topicAssigned.topicID,topicAssigned.EntityID);
                //oppList.add(opp);
            }
        }
    }
    else if(trigger.isAfter && trigger.isDelete)
    {
        for(TopicAssignment topicAssigned : trigger.oldMap.values())
        {
            
            if(topicAssigned.EntityType == 'Opportunity')
            {
                topicIDList.add(topicAssigned.topicID);
                OpportunityIDList.add(topicAssigned.EntityID);
                //mapOfOppTopic.put(topicAssigned.topicID,topicAssigned.EntityID);
                //oppList.add(opp);
            }
        }
    }
        
    if(topicIDList.size() > 0)
    {
        MAP<ID,Topic> topicMap = new Map<ID,Topic>([Select ID,Name from Topic where ID in : topicIDList]);
   		MAP<ID,Opportunity> opportunityMap = new Map<ID,Opportunity>([Select ID,Topics__c from Opportunity where ID in : OpportunityIDList]);
        
        for(TopicAssignment topicAssigned : trigger.isInsert ? trigger.newMap.values(): trigger.oldMap.values() )
        {
            
            Opportunity opp = opportunityMap.get(topicAssigned.EntityID);
            //opp.Id = topicAssigned.EntityId;
            system.debug(opp.Topics__c);
            if(trigger.isAfter && trigger.isInsert)
            	opp.Topics__c = String.isBlank(opportunityMap.get(opp.ID).Topics__c) ? topicMap.get(topicAssigned.topicID).Name : opp.Topics__c + ' , ' + topicMap.get(topicAssigned.topicID).Name ;
            if(trigger.isAfter && trigger.isDelete)
            {
                if(String.isNotBlank(opportunityMap.get(opp.ID).Topics__c))
                {
                    if(opportunityMap.get(opp.ID).Topics__c.indexOf(',') > 0)
                    {
                		List<String> topicList = opportunityMap.get(opp.ID).Topics__c.split(',');
                        system.debug(topicList.indexOf(topicMap.get(topicAssigned.topicID).Name));
                        system.debug(topicMap.get(topicAssigned.topicID).Name);
                        system.debug(topicList);
                        //topicList.remove(topicList.indexOf(topicMap.get(topicAssigned.topicID).Name));
                        for(Integer i = 0; i< topicList.size(); i++)
                        {	
                            if(topicList[i].trim() != topicMap.get(topicAssigned.topicID).Name.trim())
                            	opp.Topics__c = i == 0 ? topicList[i] : opp.Topics__c + ' , ' + topicList[i]; 
                        }
                    }
                }
            } 
            if(opp.topics__c.length() > 255)
                opp.topics__c = opp.topics__c.subString(0,255);
            system.debug(opp.Id);
            system.debug(topicAssigned);
            system.debug(topicAssigned.topic.Name);
            //mapOfOpps.put(topicAssigned.EntityId,opp);
            oppList.add(opp);
        }
    }
    if(oppList.size() > 0)
    {
        update oppList;
        //database.update(oppList,false);
    }
}