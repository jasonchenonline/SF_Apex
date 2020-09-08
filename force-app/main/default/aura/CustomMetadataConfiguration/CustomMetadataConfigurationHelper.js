({
	getCurrentRecord : function(component, event, configObjectName) {
		var action = component.get("c.getCustomMetadataObject");
		action.setParams({ "MDName" : configObjectName });
		action.setCallback(this, function(response) {
			var state = response.getState();
			if (state === "SUCCESS") {
                var setting = response.getReturnValue();
                console.log(setting)
                component.set("v.configObject", JSON.parse(setting));
                component.set("v.originalObject", JSON.parse(setting));
            }
            else if (state === "ERROR") {
	            var errors = response.getError();
    	        if (errors) {
        		    if (errors[0] && errors[0].message) {
            			console.log("Error message: " +
            			errors[0].message);
                    	}
                }
            } else {
	            console.log("Unknown error");
            }
		});
        $A.enqueueAction(action);
    },
	saveRecord : function(component, event, configObjectName) {
		var action = component.get("c.saveCustomMetadataObject");
        var configObject = component.get("v.configObject");
        var originalObject = component.get("v.originalObject");
        action.setParams({ "configObjectJSON" : JSON.stringify(configObject),
        					"originalObjectJSON" : JSON.stringify(originalObject),
							"MDName" : configObjectName });
		component.find('status').set("v.message", null);
        console.log('saving');
        action.setCallback(this, function(response) {
			var state = response.getState();
            var statusComp = component.find('status');
			if (state === "SUCCESS") {
				console.log("save in progress");
                var jobID = response.getReturnValue();
                console.log("job ID " + jobID);
                component.set("v.metadataJobId", jobID);
            }
            else if (state === "ERROR") {
	            var errors = response.getError();
    	        if (errors) {
        		    if (errors[0] && errors[0].message) {
                        console.log("Error message: " + errors[0].message);
                        statusComp.set("v.message",errors[0].message);
                        this.getCurrentRecord(component, event, configObjectName);   // Reload
                        this.showSpinner(component, false, null);
                    	}
                }
            } else {
	            console.log("Unknown error");
            }
		});
        $A.enqueueAction(action);
    },
    metadataComplete: function(component, event) {
    	var success = event.getParam("success");
        var status = event.getParam("status");
        var statusComp = component.find('status');
        if(success)
        {
            console.log("Metadata deployed succesfully");
			statusComp.set("v.message", "Metadata saved succesfully");
			statusComp.set("v.success", true);
            
        } else
        {
            statusComp.set("v.message", event.getParam("errorMessage"));
        }	
    },
    showSpinner: function(component, show, spinnerId)
    {
        if(spinnerId==null) spinnerId = 'spinner';
        var spinner = component.find(spinnerId);
        var evt = spinner.get("e.toggle");
        evt.setParams({ isVisible: show });
        evt.fire();
    }
})