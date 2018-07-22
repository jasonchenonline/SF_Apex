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
global without sharing class GoingAsync2 implements 
	Database.Batchable<SObject>, 
	Database.AllowsCallouts {

	global Database.Querylocator start(Database.BatchableContext bc)
	{
		return Database.getQueryLocator('SELECT ID, Description, DescriptionSpanish__c From WorkOrder Where TranslationPending__c = true');
	}

	global void execute(Database.BatchableContext BC, List<WorkOrder> scope)
	{

		for(WorkOrder wo: scope)
		{
			wo.DescriptionSpanish__c = SimulatedTranslator.translate(wo.Description);
			wo.TranslationPending__c = false;
		}
		Database.update(scope, false);
		
	}

	global void finish(Database.BatchableContext BC)
	{
        AsyncApexJob thisJob = [Select Id, CreatedDate from AsyncApexJob where id = :BC.getJobId()];
		List<WorkOrder> stillPending = 
			[SELECT ID From WorkOrder 
			Where TranslationPending__c = true And LastModifiedDate> :thisJob.CreatedDate Limit 1];
		if(stillPending.size()>0) StartBatch(true);
	}

	private static Boolean batchRequested = false;

	public static void startBatch(Boolean forceStart)
	{
		if(!forceStart && 
			(batchRequested || isBatchActive('GoingAsync2'))) return;
		
		GoingAsync2 ga = new GoingAsync2();
		Integer batchSize = Limits.getLimitCallouts();
		if(batchSize>200) batchSize = 200;
		try
		{
			Database.executeBatch(ga, batchSize);
		} catch(Exception ex)
		{
			return;
		}
		
		batchRequested = true;
	}

	public static Boolean isBatchActive(String classname)
	{
		List<String> inactiveStatuses = 
			new List<String>{'Completed','Aborted','Failed'};
		AsyncApexJob[] activeJobs = 
			[select id, CompletedDate, Status, ExtendedStatus, ApexClassID 
			from AsyncApexJob where ApexClass.Name = :classname 
			and JobType='BatchApex' 
			And Status Not in :inactiveStatuses 
			Order By CreatedDate Desc Limit 1];
		return activeJobs.size() >0;
	}
}
