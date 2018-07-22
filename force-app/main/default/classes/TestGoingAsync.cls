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
@isTest
public class TestGoingAsync {

	private static Integer bulkTestSize = 10;

    @isTest
    private static void testWorkOrdersInsert() {
 		
 		List<WorkOrder> wos = new List<WorkOrder>();
 		
 		for(Integer x = 0; x<bulkTestSize; x++)
    	{
    		wos.add(
    			new WorkOrder(
    				Subject='work order ' + String.valueOf(x), 
    				Description = 'This is work order # ' + String.ValueOf(x) ));
    	}
    	Test.StartTest();

 		Test.setMock(HttpCalloutMock.class, 
 			new SimulatedTranslator.MockTranslator());

		insert wos;
		Test.StopTest();
 
 		Map<ID, WorkOrder> wosmap = new Map<ID, WorkOrder>(wos);
 		
 		List<WorkOrder> results = 
 			[Select ID, Description, DescriptionSpanish__c 
 			from WorkOrder where ID in :wosmap.keyset()];
 		for(WorkOrder wo: results) 
 			System.AssertEquals(wo.Description + ' in Spanish', 
 				wo.DescriptionSpanish__c);
 
    }

	// Note: testScheduler is intended to test the scheduler code in ScheduledDispatcher and GoingAsync5
 @isTest
    private static void testScheduler() {
 		
		// Start with application off
		AppCustomSetting.testConfig = new AppConfig__c(name='default', appEnabled__c = false, enableDiagnostics__c = true);

 		List<WorkOrder> wos = new List<WorkOrder>();
 		
 		for(Integer x = 0; x<bulkTestSize; x++)
    	{
    		wos.add(
    			new WorkOrder(
    				Subject='work order ' + String.valueOf(x), 
    				Description = 'This is work order # ' + String.ValueOf(x) ));
    	}

 		Test.setMock(HttpCalloutMock.class, 
 			new SimulatedTranslator.MockTranslator());

		// Application is off, so while the async records will be created, they won't run
		insert wos;

    	Test.StartTest();
		// Turn the app back on
		AppCustomSetting.testconfig.appEnabled__c = true;
		// And run the scheduler (it will run on StopTest)
		GoingAsync5.startScheduler(DateTime.now(), 'testjob');

		Test.StopTest();
 
 		Map<ID, WorkOrder> wosmap = new Map<ID, WorkOrder>(wos);
 		
 		List<WorkOrder> results = 
 			[Select ID, Description, DescriptionSpanish__c 
 			from WorkOrder where ID in :wosmap.keyset()];
 		for(WorkOrder wo: results) 
 			System.AssertEquals(wo.Description + ' in Spanish', 
 				wo.DescriptionSpanish__c);
 
    }	

}
