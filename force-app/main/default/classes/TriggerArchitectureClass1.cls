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

public with sharing class TriggerArchitectureClass1 {
	
    public static void entry1(TriggerOperation triggerType, List<Opportunity> newlist, 
			Map<ID, Opportunity> newMap, List<Opportunity> oldList, 
			Map<ID,Opportunity> oldMap, Map<ID, Opportunity> updateableMap)
	{
        List<OpportunityStage> opStages = [Select ID, DefaultProbability, MasterLabel from OpportunityStage Order By SortOrder Asc];

        for(Opportunity op:newlist)
        {
            Opportunity updateableOp = (updateableMap== null)? null: updateableMap.get(op.id);
            system.debug('Existing opportunity stage: ' + op.stagename);
            switch on triggerType {
                when BEFORE_INSERT
                {
                    // Do some processing here
                    // No need to add entries to the objectstoupdate map in before triggers
                    op.stageName = opStages[1].MasterLabel;
                }
                when AFTER_INSERT
                {
                    // Do some processing here
                    // Add entries to the dispatcher static variable if they need to be updated
                    String targetStage = opStages[2].MasterLabel;
                    if(op.stageName!= targetStage)
                    {
                        updateableOp.stageName = targetStage;
                        // Mark for update if changed
                        TriggerDMLSupport.opsToUpdate.put(updateableOp.id, updateableOp);
                    }
                }
                when AFTER_UPDATE
                {
                    // Do some processing here
                    // Add entries to the dispatcher static variable if they need to be updated
                    String targetStage = opStages[3].MasterLabel;
                    if(op.stageName != targetStage)
                    {
                        updateableOp.stageName = targetStage;
                        // Mark for update if changed
                        TriggerDMLSupport.opsToUpdate.put(updateableOp.id, updateableOp);
                    }
                }
            }
        }


	}


}
