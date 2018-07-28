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
public with sharing class DiagnosticsTriggers2  implements DiagnosticsMain.ITriggerEntry {
    
    public void mainEntry(TriggerOperation triggerType, Schema.SObjectType objectType,
             List<SObject> newObjlist, Map<ID, SObject> newObjMap, 
             List<SObject> oldObjList, Map<ID,SObject> oldObjMap)
	{
        if(objectType!= Opportunity.SObjectType) return;
        // Only process after update and after insert triggers
        if(triggertype != TriggerOperation.AFTER_UPDATE && triggerType != TriggerOperation.AFTER_INSERT) return;    

        List<Opportunity> newList = (List<Opportunity>)newObjList;
        List<Opportunity> oldList = (List<Opportunity>)oldObjList;
        Map<ID, Opportunity> newMap = DiagnosticsMain.castMapToOpportunities(newObjMap);
        Map<ID, Opportunity> oldMap = DiagnosticsMain.castMapToOpportunities(oldObjMap);
        processStageUpdate(triggerType, newList, newMap, oldMap);
    }

   	private static Map<ID, Double> probabilityOverrides = null;

    // This code implements the task creation features of processStageUpdate implementation from chapter 6
    private void processStageUpdate(TriggerOperation triggerType,
             List<Opportunity> newlist, Map<ID, Opportunity> newMap, Map<ID,Opportunity> oldMap)
	{
		if(probabilityOverrides==null) probabilityOverrides = new Map<ID, Double>();

        List<Task> newTasks = new List<Task>();

        for(Opportunity op:newlist)
        {
            Double oldProbability = (probabilityOverrides.containskey(op.id))? 
                                    probabilityOverrides.get(op.id) : 
                                    ((oldMap==null)? 0: oldMap.get(op.id).Probability);
            system.debug('old probability ' + 
                        ((oldMap!=null)? String.valueOf(oldMap.get(op.id).Probability): 'n/a') + 
                        ' new probability ' + op.Probability);
            if((triggerType== TriggerOperation.AFTER_INSERT || oldProbability <=20) && op.Probability>50)
            {
                newTasks.add(
                    new Task(ownerId = op.OwnerID, 
                        WhatID = op.id, 
                        ActivityDate = Date.Today().addDays(2), 
                        Subject='Opportunity stage update', 
                        Type='Other'));
                if(oldProbability != op.Probability) 
                    probabilityOverrides.put(op.id, op.Probability);
            }
        }  
        if(newTasks.size()>0) insert newtasks;

	}

    public void inProgressEntry(TriggerOperation triggerType, Schema.SObjectType objectType,
             List<SObject> newObjlist, Map<ID, SObject> newObjMap, 
             List<SObject> oldObjList, Map<ID,SObject> oldObjMap)
	{
    }

    public void inDmlEntry(TriggerOperation triggerType, Schema.SObjectType objectType,
             List<SObject> newObjlist, Map<ID, SObject> newObjMap, 
             List<SObject> oldObjList, Map<ID,SObject> oldObjMap)
	{
    }
}
