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
        helper.showSpinner(component, true, null);
        if(configObjectName!=null)
        {
			helper.saveRecord(component, event, configObjectName);
        }
    },
    metadataCompleteEvent: function(component, event, helper) {
    	console.log("Metadata complete event");
        console.log(component.get("v.metadataJobId"));
        console.log(event.getParam("jobId"));
        if(component.get("v.metadataJobId") == event.getParam("jobId"))
        {
            helper.metadataComplete(component, event);
            event.stopPropagation();
	        var configObjectName = component.get("v.configObjectName");
			// Reinitialize
            helper.getCurrentRecord(component, event, configObjectName);
            helper.showSpinner(component, false, null);
        }
	}
})