/*
###########################################################################
# Created by............: Sai Anuja
# Created Date..........: 18-June-2018
# Last Modified by......: Puneet Khosla
# Last Modified Date....: 10-Jul-2018
# Description...........: This class is scheduler for BatchToDeleteLoggers
# Change Log:               
# 1. Puneet Khosla - Changes done under SRSF-1144
############################################################################*/

global class ScheduleToDeleteLoggers implements Schedulable {
    global void execute(SchedulableContext sc) {
        BatchToDeleteLoggers loggerBatch = new BatchToDeleteLoggers();
		ID batchprocessid = Database.executeBatch(loggerBatch,2000);
    }
}