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
@istest
public with sharing class TestTriggersExample {
	
    @istest
    public static void testFrameworks()
    {
    	List<Opportunity> ops = initOpportunities(5);
        List<OpportunityStage> opStages = [Select ID, DefaultProbability, MasterLabel from OpportunityStage Order By SortOrder Asc];
        
        Test.startTest();
        insert ops;
        ops = [Select ID, StageName, Amount from Opportunity where id in :ops];
        for(Opportunity op: ops)
        {
            system.assertEquals(opStages[2].MasterLabel, op.stageName);
            system.assertEquals(20, op.Amount);
        }
        // Do a random update
        for(Opportunity op:ops) op.Description = 'updating';
        update ops;
        ops = [Select ID, StageName, Amount from Opportunity where id in :ops];
        for(Opportunity op: ops)
        {
            system.assertEquals(opStages[3].MasterLabel, op.stageName);
            system.assertEquals(30, op.Amount);
        } 
        test.stopTest();
    }

    public static List<Opportunity> initOpportunities(Integer numberOfOpportunities)
    {
	    List<Opportunity> ops = new List<Opportunity>();
        List<OpportunityStage> opStages = [Select ID, DefaultProbability, MasterLabel from OpportunityStage Order By SortOrder Asc];
    	
        for(Integer x=0; x<numberOfOpportunities; x++)
		{
			ops.add(
				new Opportunity(CloseDate = Date.Today().addDays(5), 
				Name = 'optest_' + String.valueOf(x), 
				StageName = opStages[0].MasterLabel ));	
		}
        return ops;        
    }


}
