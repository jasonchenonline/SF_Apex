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
/*
    This class watches for the opportunity probability to go over 20%. If so, it creates a task
*/
public with sharing class WatchForStageUpdates {
  
    public static void processStageUpdate(TriggerOperation triggerType, List<Opportunity> newlist, 
			Map<ID, Opportunity> newMap, List<Opportunity> oldList, 
			Map<ID,Opportunity> oldMap)
	{
        
        switch on triggerType {
            When AFTER_INSERT, AFTER_UPDATE
            {
                List<Task> newTasks = new List<Task>();
                List<Opportunity> opsToUpdate = new List<Opportunity>();

                for(Opportunity op:newlist)
                {
                    if((triggerType== TriggerOperation.AFTER_INSERT || oldMap.get(op.id).Probability <=20) && op.Probability>50)
                    {
				        newTasks.add(
                            new Task(ownerId = op.OwnerID, 
                                WhatID = op.id, 
                                ActivityDate = Date.Today().addDays(2), 
                                Subject='Opportunity stage update', 
                                Type='Other'));
                        Opportunity updatingOp = new Opportunity(Id = op.id);
                        updatingOp.Description = ((op.Description==null)? '': op.Description) + ' Stage update task on ' + Date.Today().format();
                        opsToUpdate.add(updatingOp);
                    }
                }  
            if(newTasks.size()>0) insert newtasks;
            if(opsToUpdate.size()>0) update opsToUpdate;
            }
        }

	}

}
