@RestResource(urlMapping='/DepPickList/*')
global class GetDependencyPickList {
    
    @HttpGet
    global static Map<String, List<String>> getPickList() {

        return PrimaryOECommodityDependency.getDependentOptionsImpl();
    }

}