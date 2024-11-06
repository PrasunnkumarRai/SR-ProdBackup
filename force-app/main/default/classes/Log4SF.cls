public with sharing class Log4SF{
    
    //Info message log
	public static void logMessage(String className, String methodName, String message, Id usr, String recordId){		
		Exception ex;
		createLog(className, methodName, message, ex, 'INFO',usr, recordId,'');
	}
	
	//Data message log
	public static void logMessage(String className, String methodName, String message, Id usr, String dataLog, String recordId){		
		Exception ex;
		createLog(className, methodName, message, ex, dataLog, usr, recordId,'');
	}
	
	//Error message log
	public static void logMessage(String className, String methodName, String message, Exception ex, Id usr, String recordId){
		createLog(className, methodName, message, ex, 'ERROR',usr, recordId,'');
	}
	
	//Boomi message log
	public static void logMessage(String className, String methodName, String message, Exception ex, Id usr, String recordId, String boomiLog){
		createLog(className, methodName, message, ex, 'ERROR',usr, recordId, boomiLog);
	}
	
	//Create Log
	private static void createLog(String className, String methodName, String message, Exception ex, String logType, Id usr, String recordId, String boomiLog){
        /*
            This if block ensures that INSERT that we are doing shouldn't disturb the GOVERNOR LIMITS
            and hence prevent the other Business Logic from execution.
        */
        if (  
            (Limits.getDMLRows() < Limits.getLimitDMLRows()) &&
            (Limits.getDMLStatements() < Limits.getLimitDMLStatements())
        ){              
            try{
            	Logger__c newDebugMsg = populateLog(className, methodName, message, ex, logType, usr, recordId, boomiLog);
	            INSERT newDebugMsg;
            }
            catch (Exception lex){
                System.debug(
                    'Failed to INSERT the [Apex Debug Log] ADL record. ' +
                    'Error: ' + lex.getMessage() + lex.getLineNumber()
                );
            }
        }
        else {
            System.debug(
                'Failed to INSERT the [Apex Debug Log] ADL record. ' +
                'Error: The APEX RUNTIME GOVERNOR LIMITS has been exhausted.'
            );
        }
    }
    
    public static Logger__c populateLog(String className, String methodName, String message, Exception ex, String logType, Id usr, String recordId, String boomiLog) {

    	Logger__c logger = new Logger__c(
	                    Class__c = className,
	                    Method__c = methodName,
	                    Message__c = message,	                    
	                    User__c = usr,
	                    Type__c = logType,
	                    Record_Id__c = recordId,
	                    Boomi_Log__c = boomiLog );
        
        if(ex != null){
        	logger.Exception__c = ex.getMessage();
            logger.Exception_Trace__c = ex.getStackTraceString();
            logger.Line__c = ex.getLineNumber();
        }
        return logger;
    }

    public static SObject assignFields(Map<String, Object> fieldNameValueMapping, SObject obj, Boolean isInsert) {
        if(fieldNameValueMapping != null && !fieldNameValueMapping.IsEmpty()) {
            for (String key : fieldNameValueMapping.keyset()) {
                obj.put(key, fieldNameValueMapping.get(key));
            }
        }
        if (isInsert) {
            insert obj;
        }
        return obj;
    }

    public static Third_Party_Logger__c createThirdPartyLogger(Map<String, Object> fieldNameValueMapping, Boolean ins ,Third_Party_Logger__c newThirdPartyLogger){        
        return (Third_Party_Logger__c) assignFields(fieldNameValueMapping, newThirdPartyLogger, ins);
    }

}