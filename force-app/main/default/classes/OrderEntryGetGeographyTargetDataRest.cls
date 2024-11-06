@RestResource(urlMapping='/OrderEntry/GetGeographyTargetData/*')
global with sharing class OrderEntryGetGeographyTargetDataRest {
    @HttpGet
    global static OrderEntryGeoTargetRestHelper GetGeographyTargetData() {
        return new OrderEntryGeoTargetRestHelper();
    }
}