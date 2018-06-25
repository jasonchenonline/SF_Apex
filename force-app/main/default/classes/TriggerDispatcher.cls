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
public with sharing class TriggerDispatcher {

  public static void handleTriggers(TriggerOperation triggerType, List<SObject> newList, 
			Map<ID, SObject> newMap, List<SObject> oldList, 
			Map<ID,SObject> oldMap)
    {
        if(TriggerDMLSupport.updatingPendingObjects) return;

        SObject firstObject = (triggerType == TriggerOperation.AFTER_DELETE || triggerType== TriggerOperation.BEFORE_DELETE)? 
            oldList[0]: newList[0];
        
        switch on firstObject
        {
            when Opportunity obj
            {
                // You can dispatch to different handlers by trigger type as well
                TriggerArchitectureClass1.entry1(triggerType, 
                    (List<Opportunity>)newList, castMapToOpportunities(newMap), 
                    (List<Opportunity>)oldList, castMapToOpportunities(oldMap));
                TriggerArchitectureClass2.entry1(triggerType,
                    (List<Opportunity>)newList, castMapToOpportunities(newMap),
                    (List<Opportunity>)oldList, castMapToOpportunities(oldMap));
            }
        }

        TriggerDMLSupport.updatePendingObjects();

    }

    // Helper function, since we can't cast directly from a map of ID,SObject to a specific type
    public static Map<ID, Opportunity> castMapToOpportunities(Map<ID, SObject> sourceMap)
    {
        if(sourceMap==null) return null;
        return new Map<ID, Opportunity>((List<Opportunity>)sourceMap.values());
    }

}
