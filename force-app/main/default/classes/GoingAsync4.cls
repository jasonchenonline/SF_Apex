/*Copyright (c) 2018, Daniel Appleman

Redistribution and use in source and binary forms, with or without modification,
are permitted provided that the following conditions are met:

1. Redistributions of source code must retain the above copyright notice, 
this list of conditions and the following disclaimer.

2. Redistributions in binary form must reproduce the above copyright notice, 
this list of conditions and the following disclaimer in the documentation 
and/or other materials provided with the distribution.

3. Neither the name of the copyright holder nor the names of its contributors 
may be used to endorse or promote products derived from this software without 
specific prior written permission.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND 
ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED 
WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. 
IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, 
INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES 
(INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; 
LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND 
ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT 
(INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF 
THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
*/
public without sharing class GoingAsync4 
	implements queueable, Database.AllowsCallouts {

 	public void execute(QueueableContext context)
    {
    	if(!AppCustomSetting.appEnabled) return; // On/off switch
    	List<AsyncRequest__c> requests;
    	try
    	{
	    	requests = [Select ID, AsyncType__c, Params__c 
	    		from AsyncRequest__c 
	    		where Error__c = false And
	    		CreatedById = :UserInfo.getUserId() 
	    		Limit 1 for update];
    	}
    	catch(Exception ex) { return; }
    	if(requests.size()==0 ) return;
    	
    	AsyncRequest__c currentRequest = requests[0];
    	
    	try
    	{
    		if(currentRequest.AsyncType__c=='Translate Work Order') 
    			translate(currentRequest);
    		
    		// Add more here
    		
    		delete currentRequest;
    		// Optional
    		database.emptyRecycleBin(new List<ID>{currentRequest.id}); 
    		
    	}
    	catch(Exception ex)
    	{
    		currentRequest.Error__c = true;
    		currentRequest.Error_Message__c = ex.getMessage();
    		update currentRequest;
    	}

    	List<AsyncRequest__c> moreRequests = [Select ID, AsyncType__c, Params__c 
    		from AsyncRequest__c 
    		where Error__c = false 
    		and ID <> :currentRequest.id 
    		and	CreatedById = :UserInfo.getUserId() 
    		Limit 1 ];
    	
    	if(moreRequests.size()==0) return;
    	
		try
		{
			enqueueGoingAsync4(context.getJobId());
		}
		catch(Exception ex)
		{
			tryToQueue();
		}
		
    }

	public static void enqueueGoingAsync4(ID currentJobId)
	{
		List<AsyncApexJob> jobs = [Select ID, Status, ExtendedStatus from AsyncApexJob 
					where JobType = 'Queueable' And (status='Queued'  Or Status='Holding') 
					and CreatedById = :userinfo.getUserID() and 
					ApexClass.Name='GoingAsync4' and ID!= :currentJobId Limit 1 ];
		if(jobs.size()==1) return;	// Already have one queued that isn't this one.
		
		system.enqueueJob(new GoingAsync4());
	}

    
    @future
    private static void tryToQueue()
    {
    	if(!AppCustomSetting.appEnabled) return; // On/off switch
    	try
    	{
			if(Limits.getLimitQueueableJobs() - Limits.getQueueableJobs() > 0)
				enqueueGoingAsync4(null);
    	}
    	catch(Exception ex)
    	{
    		// Wait for someone else to make a request...
    		// Or maybe use scheduled Apex?
    	}
    }

    public void translate(AsyncRequest__c request)
    {
    	Integer allowedCallouts = 
    	Limits.getLimitCallouts() - Limits.getCallouts();
		if(allowedCallouts<=0) return;
		
		List<ID> idsAfterSplit = request.Params__c.split(',');
		
		List<WorkOrder> workOrdersToUpdate = 
			[SELECT ID, Description, DescriptionSpanish__c 
			from WorkOrder 
			where ID in :idsAfterSplit 
			LIMIT :allowedCallouts];
		for(WorkOrder wo: workOrdersToUpdate)
		{
			wo.DescriptionSpanish__c = 
				SimulatedTranslator.translate(wo.Description);
			wo.TranslationPending__c = false;
		}
		database.update(workOrdersToUpdate, false);
    }
}
