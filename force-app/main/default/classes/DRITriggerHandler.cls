public class DRITriggerHandler {
	private boolean triggerIsExecuting;
    private integer triggerSize;
    public DRITriggerHelper helper;
    public DRITriggerHandler(boolean triggerIsExecuting, integer triggerSize) {
        this.triggerIsExecuting = triggerIsExecuting;
        this.triggerSize = triggerSize;
        this.helper = new DRITriggerHelper();
    }
    public void beforeUpdate(List<DuplicateRecordItem> newDRIs) {
        helper.updateRecordTypeofDRI(newDRIs);
    }
    public void beforeInsert(List<DuplicateRecordItem> newDRIs) {
        helper.updateRecordTypeofDRI(newDRIs);
    }
}