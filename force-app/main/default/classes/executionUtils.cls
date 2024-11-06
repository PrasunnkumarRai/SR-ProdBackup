public with sharing class executionUtils {
    public static boolean allowBox = true;

    public static boolean isBoxAllowed() {
        allowBox = (System.Label.Box_Allow_Auto_Folder_Creation == 'true') ? true : false;
        return  !system.isBatch() &&
                !system.isFuture() &&
                Limits.getFutureCalls() < Limits.getLimitFutureCalls() &&
                allowBox;
    }

    public static boolean isFutureAllowed() {
        return  !system.isBatch() &&
                !system.isFuture() &&
                Limits.getFutureCalls() < Limits.getLimitFutureCalls();
    }

    public static void disableBox() {
        allowBox = false;
    }

    public static void enableBox() {
        allowBox = true;
    }
}