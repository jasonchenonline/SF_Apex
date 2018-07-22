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
public with sharing class Concurrency1 {
    public static void delay(Integer seconds)
    {
        List<Integer> largeArray = new List<Integer>();
        for(Integer x =0; x<10000; x++) largeArray.add(x);
        for(Integer counter = 0; counter<seconds * 4; counter++)
        {
            String s = json.serialize(largeArray);
        }
    }

    // Create this opportunity by hand
	private static String opportunityName = 'Concurrency1';
    
    @future
    public static void incrementOptimistic(
    	double amount, Integer delayBefore, 
    	Integer delayFromQuery, Integer delayAfter)
    {
        if(delayBefore>0) delay(delayBefore);
        List<Opportunity> ops = 
        	[Select ID, Amount From Opportunity 
        	where Name = :opportunityName];
        for(Opportunity op: ops)
        	op.Amount = (op.Amount==null)? 
        		amount: op.Amount + Amount;
        if(delayFromQuery>0) delay(delayFromQuery);
        update ops;
        if(delayAfter>0) delay(delayAfter);
    }

    @future
    public static void incrementPessimistic(
    	double amount, Integer delayBefore, 
    	Integer delayFromQuery, Integer delayAfter)
    {
        if(DelayBefore>0) delay(delayBefore);
        List<Opportunity> ops = 
        	[Select ID, Amount From Opportunity 
        	where Name = :opportunityName For Update];
        for(Opportunity op: ops)
        	op.Amount = (op.Amount==null)? 
        		amount: op.Amount + Amount;
        if(delayFromQuery>0) delay(delayFromQuery);
        update ops;
        if(delayAfter>0) delay(delayAfter);
    }

    @future
    public static void incrementOptimisticWithCapture(
    	double amount, Integer delayBefore, 
    	Integer delayFromQuery, Integer delayAfter)
    {
        if(delayBefore>0) delay(delayBefore);
        List<Opportunity> ops = 
        	[Select ID, Amount From Opportunity 
        	where Name = :opportunityName];
        for(Opportunity op: ops)
        	op.Amount = (op.Amount==null)? 
        		amount: op.Amount + Amount;
        if(delayFromQuery>0) delay(delayFromQuery);
        List<Database.SaveResult> 
        	dmlResults = Database.Update(ops, false);
		List<Opportunity> failedUpdates = new List<Opportunity>(); 
		for(Integer x = 0; x< ops.size(); x++)
		{
			Database.SaveResult sr = dmlResults[x];
			if(!sr.isSuccess())
			{
				for(Database.Error err: sr.getErrors())
				{
					if(err.getStatusCode() == StatusCode.UNABLE_TO_LOCK_ROW)
					{
						failedUpdates.add(ops[x]);
						break;
					}
				}
			}
			
		}
		
		if(failedUpdates.size()>0)
		{
			// Do a logging or recovery operation here
			recordRecoveryInformation(failedUpdates, amount);
		}
        
        if(delayAfter>0) delay(delayAfter);
    }
    
    @testvisible 
    private static void recordRecoveryInformation(
    	List<Opportunity> failedOps, double amount)
    {
    	List<AsyncRequest__c> requests = new List<AsyncRequest__c>();
    	for(Opportunity op: failedOps)
    	{
    		requests.add(new AsyncRequest__c(AsyncType__c = 'Amount Update', 
    			NewAmount__c = op.Amount, 
    			OriginalAmount__c = op.Amount - amount, 
    			TargetOpportunity__c = op.id ));
    	}
    	insert requests;
    }

}
