public class ObjectPrefixController {



	@AuraEnabled(cacheable = true)
	public static List<SObject> getObjectPrefix(string searchString) {
		searchString = '%' + searchString + '%';
		List<SObject> lstKeyPrefix = [SELECT QualifiedApiName, KeyPrefix, Label FROM EntityDefinition WHERE KeyPrefix LIKE :searchString ORDER BY Label];
		List<SObject> lstLabel = [SELECT QualifiedApiName, KeyPrefix, Label FROM EntityDefinition WHERE Label LIKE :searchString ORDER BY Label ];
		lstLabel.addAll(lstKeyPrefix);
		return lstLabel;
	}

	public class ObjectDetails {
		@AuraEnabled
		public sObject rec { get; set; }
		@AuraEnabled
		public string ObjectType { get; set; }
	}

	@AuraEnabled(cacheable = true)
	public static List<ObjectDetails> getAllObjectPrefix() {
		Map<String, SObject> mapSobject = new Map<String, SObject> ();
		List<ObjectDetails> lstObjDetails = new List<ObjectDetails> ();

		List<SObject> lstSobject = [SELECT QualifiedApiName, KeyPrefix, Label
		                            FROM EntityDefinition WHERE KeyPrefix != NUll
		                            ORDER BY Label];
		//for(SObject sobj: lstSobject){
		//mapSobject.put((string)sobj.get('QualifiedApiName'),sobj);
		//}
		Map<String,string> MapPrefixMetadata = new Map<String,string>();
		for (object_Prefix_meta_data__mdt key :[select key__c,Value__c from object_Prefix_meta_data__mdt ORDER BY Value__c])
		{
			MapPrefixMetadata.put(key.value__c,key.key__c);
		
		}
		System.debug('MapPrefixMetadata@@'+MapPrefixMetadata);
		System.debug('@@lstSobject :'+lstSobject.size());
		
		for (SObject sobj : lstSobject) {
			string apiName = String.valueOf(sobj.get('QualifiedApiName'));
			List<string> apiNameSplit = apiName.split('__');
			apiName =  '__' + (String)apiNameSplit[apiNameSplit.size()-1];
			System.debug('@@apiName.toLowerCase() :'+apiName);
			
			if(apiNameSplit.size()==1)
			{
				ObjectDetails obj = new ObjectDetails();
				obj.ObjectType = 'Standard Object';
				obj.rec = sobj;
				lstObjDetails.add(obj);
			}
			
			else if(MapPrefixMetadata.containsKey(apiName))
			{   System.debug('@@@MapPrefixMetadata.get(apiName) : '+MapPrefixMetadata.get(apiName));
				ObjectDetails obj = new ObjectDetails();
				obj.ObjectType = MapPrefixMetadata.get(apiName);
				obj.rec = sobj;
				lstObjDetails.add(obj);
				
			}
		}
		
		System.debug('lstObjDetails size: '+lstObjDetails.size());
		return lstObjDetails;
		
	}
	//public static List<ObjectPrefixController.HierarchyData> getAllObjectPrefix(){
	//List<ObjectPrefixController.HierarchyData> lstToReturn = new List<ObjectPrefixController.HierarchyData>();
	//Map<String,string> mapMetadata = new Map<String,string>();
	//for(object_Prefix_meta_data__mdt met:[select key__c,value__c from object_Prefix_meta_data__mdt]){
	//	mapMetadata.put(met.key__c,met.value__c);
	//}

	/*for(SObject Rec : [SELECT Label ,QualifiedApiName, KeyPrefix 
	  FROM EntityDefinition WHERE KeyPrefix != NULL
	  ORDER BY Label]){
	  HierarchyData ss = new HierarchyData();
	  ss.rec = Rec;
	  EntityDefinition Rec11 = (EntityDefinition)Rec;
	  String strQualifiedApiName = Rec11.QualifiedApiName;
	  string key= strQualifiedApiName.split('__')[1];
	  string strVal = mapMetadata.get(key);
	  ss.Type = strVal;
	  lstToReturn.add(ss);	
	  }
	  System.debug('@@@lstToReturn :'+lstToReturn);
	  return lstToReturn;
	  }*/
}