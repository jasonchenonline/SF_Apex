({
	getCurrentRecord : function(component, event, configObjectName) {
		var action = component.get("c.getCSListObject");
		action.setParams({ "settingName" : configObjectName });
		action.setCallback(this, function(response) {
			var state = response.getState();
			if (state === "SUCCESS") {
                var setting = response.getReturnValue();
                console.log(setting)
                component.set("v.configObject", setting[0]);
                component.set("v.originalObject", setting[1]);
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
		var action = component.get("c.saveCSListObject");
        var configObject = component.get("v.configObject");
        var originalObject = component.get("v.originalObject");
        action.setParams({ "configObject" : configObject,
        					"originalObject" : originalObject,
							"settingName" : configObjectName });
		component.find('status').set("v.message", null);
        console.log('saving');
        action.setCallback(this, function(response) {
            var statusComp = component.find('status');
            console.log('found status comp');
            console.log(statusComp);
			var state = response.getState();
			if (state === "SUCCESS") {
				console.log("saved succesfully");
                statusComp.set("v.message","Configuration saved");
                statusComp.set("v.success", true);
            }
            else if (state === "ERROR") {
	            var errors = response.getError();
    	        if (errors) {
        		    if (errors[0] && errors[0].message) {
                        console.log("Error message: " + errors[0].message);
		                statusComp.set("v.message",errors[0].message);
                    	}
                }
            } else {
	            console.log("Unknown error");
               	statusComp.set("v.message","Unknown error");
            }
		});
        $A.enqueueAction(action);
    }    
})