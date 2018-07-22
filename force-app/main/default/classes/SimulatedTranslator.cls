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
global class SimulatedTranslator {

	global class MockTranslator implements HttpCalloutMock
	{
		global HTTPResponse respond(HTTPRequest req)
		{
			String requestBody = req.getBody();
			HttpResponse res = new HttpResponse();
			res.setHeader('Content-Type', 'text');
			res.setBody(requestBody + ' in Spanish');
			res.setStatusCode(200);
			return res;
		}
	}

	private static HTTPResponse translate(HTTPRequest req)
	{
		// Just simulate the call for now - remove this code if you've implemented
		// real translation
		if(!Test.isRunningTest())
		{
			// Call the mock translator
			MockTranslator mock = new MockTranslator();
			return mock.respond(req);
		}
		// Replace following with call to actual translation service
		req.setEndpoint('http://api.salesforce.com/foo/bar');
		req.setMethod('GET');
		Http h = new Http();
		HttpResponse res = h.send(req);
		return res;
	}

	public static String translate(String sourcetext)
	{
		if(sourcetext==null) return null;
		HttpRequest req = new HttpRequest();
		req.setBody(sourcetext);
		req.setHeader('Content-Type','text');
		HttpResponse result = translate(req);
		return result.getBody();
	}

}
