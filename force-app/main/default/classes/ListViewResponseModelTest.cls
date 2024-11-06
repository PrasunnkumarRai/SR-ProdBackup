@isTest
public class ListViewResponseModelTest {
    
    @isTest static void testData() {
        String json = '{"size": 2, "records": [{"columns": [{"value": "Value 1", "fieldNameOrPath": "Name"}]}], "label": "Label", "id": "123", "done": true, "developerName": "DevName", "columns": [{"type": "Type", "sortable": true, "sortIndex": 1, "sortDirection": "ASC", "selectListItem": "Select", "searchable": true, "label": "ColumnLabel", "hidden": false, "fieldNameOrPath": "Field", "descendingLabel": "Desc", "ascendingLabel": "Asc"}]}';   
        ListViewResponseModel.parse(json);
        String json1 = '{"size": 2, "records": [{"columns": [{"value": "Value 1", "fieldNameOrPath": "Username"}]}], "label": "Label", "id": "123", "done": true, "developerName": "DevName", "columns": [{"type": "Type", "sortable": true, "sortIndex": 1, "sortDirection": "ASC", "selectListItem": "Select", "searchable": true, "label": "ColumnLabel", "hidden": false, "fieldNameOrPath": "Field", "descendingLabel": "Desc", "ascendingLabel": "Asc"}]}';   
        ListViewResponseModel.parse(json1);
        String json2 = '{"size": 2, "records": [{"columns": [{"value": "Value 1", "fieldNameOrPath": "Profile.Name"}]}], "label": "Label", "id": "123", "done": true, "developerName": "DevName", "columns": [{"type": "Type", "sortable": true, "sortIndex": 1, "sortDirection": "ASC", "selectListItem": "Select", "searchable": true, "label": "ColumnLabel", "hidden": false, "fieldNameOrPath": "Field", "descendingLabel": "Desc", "ascendingLabel": "Asc"}]}';   
        ListViewResponseModel.parse(json2);
        String json3 = '{"size": 2, "records": [{"columns": [{"value": "Value 1", "fieldNameOrPath": "Division__c"}]}], "label": "Label", "id": "123", "done": true, "developerName": "DevName", "columns": [{"type": "Type", "sortable": true, "sortIndex": 1, "sortDirection": "ASC", "selectListItem": "Select", "searchable": true, "label": "ColumnLabel", "hidden": false, "fieldNameOrPath": "Field", "descendingLabel": "Desc", "ascendingLabel": "Asc"}]}';   
        ListViewResponseModel.parse(json3);
        String json4 = '{"size": 2, "records": [{"columns": [{"value": "Value 1", "fieldNameOrPath": "Id"}]}], "label": "Label", "id": "123", "done": true, "developerName": "DevName", "columns": [{"type": "Type", "sortable": true, "sortIndex": 1, "sortDirection": "ASC", "selectListItem": "Select", "searchable": true, "label": "ColumnLabel", "hidden": false, "fieldNameOrPath": "Field", "descendingLabel": "Desc", "ascendingLabel": "Asc"}]}';   
        ListViewResponseModel.parse(json4);
        String json5 = '{"size": 2, "records": [{"columns": [{"value": "Value 1", "fieldNameOrPath": "Team_Role__c"}]}], "label": "Label", "id": "123", "done": true, "developerName": "DevName", "columns": [{"type": "Type", "sortable": true, "sortIndex": 1, "sortDirection": "ASC", "selectListItem": "Select", "searchable": true, "label": "ColumnLabel", "hidden": false, "fieldNameOrPath": "Field", "descendingLabel": "Desc", "ascendingLabel": "Asc"}]}';   
        ListViewResponseModel.parse(json5);
    }
}