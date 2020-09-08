({
	doInit : function(component, event, helper) {
        var configObjectName = component.get("v.configObjectName");
        if(configObjectName!=null)
        {
			helper.getCurrentRecord(component, event, configObjectName);
        }
	},
    saveSettings : function(component, event, helper) {
        var configObjectName = component.get("v.configObjectName");
        if(configObjectName!=null)
        {
			helper.saveRecord(component, event, configObjectName);
	        var configObjectName = component.get("v.configObjectName");
			// Reinitialize
            helper.getCurrentRecord(component, event, configObjectName);
        }
    }
})