({
	successSet : function(component, event, helper) {
		if(event.getParam("value") == true)
        {
            window.setTimeout(
			    $A.getCallback(function() {
			        component.set("v.message", null);
			        component.set("v.success", false);
			    }), 2000
			);
        }
	}
})