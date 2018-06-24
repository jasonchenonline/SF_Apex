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
public with sharing class TriggerDMLSupport {
    
    public static Boolean updatingPendingObjects = false;
    public static Map<ID, Opportunity> opsToUpdate = new Map<ID, Opportunity>();

    // Return a map of updatable opportunity records to use in after triggers
    public static Map<ID, Opportunity> getUpdatableOpportunities(Set<ID> opIds)
    {
        Map<ID, Opportunity> ops = new Map<ID, Opportunity>();
        for(ID opid: opIDs) ops.put(opid, new Opportunity(ID = opid));
        return ops;
    }

    public static void updatePendingOpportunties()
    {
        if(!updatingPendingObjects) 
        {
            while(opsToUpdate.size()>0)
            {
                List<Opportunity> updatingList = opsToUpdate.values();
                opsToUpdate = new Map<ID, Opportunity>(); // Clear this to prevent multiple attempts to update
                updatingPendingObjects = true;
                update updatingList;
                updatingPendingObjects = false;
            }
        }
    }

}
