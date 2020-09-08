({
  connectCometd : function(component) {
    var helper = this;
    // Configure CometD
    var cometdUrl = window.location.protocol+'//'+window.location.hostname+'/cometd/40.0/';
    var cometd = component.get('v.cometd');
    cometd.configure({
      url: cometdUrl,
      requestHeaders: { Authorization: 'OAuth '+ component.get('v.sessionId')},
      appendMessageTypeToURL : false
    });
    cometd.websocketEnabled = false;
    // Establish CometD connection
    console.log('Connecting to CometD: '+ cometdUrl);
    cometd.handshake($A.getCallback(function(handshakeReply) {
      if (handshakeReply.successful) {
        console.log('Connected to CometD.');
        // Subscribe to platform event
        var newSubscription = cometd.subscribe('/event/MetadataDeployComplete__e',
          $A.getCallback(function(platformEvent) {
            console.log('Platform event received: '+ JSON.stringify(platformEvent));
            helper.onReceiveNotification(component, platformEvent);
          })
        );
        // Save subscription for later
        var subscriptions = component.get('v.cometdSubscriptions');
        subscriptions.push(newSubscription);
        component.set('v.cometdSubscriptions', subscriptions);
      }
      else
        console.error('Failed to connected to CometD.');
    }));
      },
  disconnectCometd : function(component) {
    var cometd = component.get('v.cometd');
    // Unsuscribe all CometD subscriptions
    cometd.batch(function() {
      var subscriptions = component.get('v.cometdSubscriptions');
      subscriptions.forEach(function (subscription) {
        cometd.unsubscribe(subscription);
      });
    });
    component.set('v.cometdSubscriptions', []);
    // Disconnect CometD
    cometd.disconnect();
    console.log('CometD disconnected.');
  },
  onReceiveNotification : function(component, platformEvent) {
    // Extract notification from platform event
   	var mdEvent = $A.get("e.c:MetadataDeployEvent");
    console.log("mdevent is " + mdEvent);
    mdEvent.setParams({"jobId": platformEvent.data.payload.JobID__c,
                               "success": platformEvent.data.payload.Success__c,
                               "status": platformEvent.data.payload.Status__c,
                               "errorMessage": platformEvent.data.payload.ErrorMessage__c});
	mdEvent.fire();
  }
})