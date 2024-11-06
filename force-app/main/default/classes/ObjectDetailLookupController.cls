public with sharing class ObjectDetailLookupController {
	public PageReference findDetailPage() {
		try {
			Id objId = (Id) ApexPages.currentPage().getParameters().get('id');
			system.debug('============>> in ObjectDetailLookupController, id = ' + objId);
            return new ApexPages.StandardController(
                    objId.getSObjectType().newSObject( objId)).view();
        }
        catch (Exception e) { /* ignore exceptions */ }

        return null;
		}
}