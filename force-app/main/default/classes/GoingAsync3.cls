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
public without sharing class GoingAsync3 implements queueable, Database.AllowsCallouts {

 	public void execute(QueueableContext context)
    {
    	if(!AppCustomSetting.appEnabled) return; // On/off switch
    	
    	Integer allowedCallouts = 
    		Limits.getLimitCallouts() - Limits.getCallouts();
   		
		if(allowedCallouts<=0) return;
		List<WorkOrder> workOrdersToUpdate = 
			[SELECT ID, Description, DescriptionSpanish__c 
			from WorkOrder 
			where LastModifiedDate > :DateTime.Now().addHours(-24) 
			And TranslationPending__c = true LIMIT :allowedCallouts];
		for(WorkOrder wo: workOrdersToUpdate)
		{
			wo.DescriptionSpanish__c = SimulatedTranslator.translate(wo.Description);
			wo.TranslationPending__c = false;
		}
		Database.Update(workOrdersToUpdate, false);
				
		if(workOrdersToUpdate.size()== allowedCallouts &&
			Limits.getLimitQueueableJobs() - Limits.getQueueableJobs() > 0)
			try
			{
				system.enqueueJob(new GoingAsync3());
			} catch(Exception ex)
			{
				// Alternate chaining mechanism
			}
		
    }
}
