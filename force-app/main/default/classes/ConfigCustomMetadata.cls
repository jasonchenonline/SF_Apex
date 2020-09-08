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
public without sharing class ConfigCustomMetadata {

    public class MDSettingClass
    {
        public Boolean BooleanSetting;
        public String TextSetting;
        public String Name;

        public MDSettingClass(MDSetting__mdt source)
        {
            BooleanSetting = source.BooleanSetting__c == true;
            TextSetting = source.TextSetting__c;
            Name = source.DeveloperName;
        }

        // Constructor that sets default values
        public MDSettingClass(String MDName) {
            Name = MDName;
            BooleanSetting = false;
        }
        
        public MDSettingClass() {}

        public void setMetadataFields(List<Metadata.CustomMetadataValue> values)
        {
            setFieldValue(values, 'BooleanSetting__c', BooleanSetting);
            setFieldValue(values, 'TextSetting__c', TextSetting);
            Metadata.CustomMetadataValue customField = new Metadata.CustomMetadataValue();
        }

        private void setFieldValue(List<Metadata.CustomMetadataValue> values, String fieldName, Object fieldValue)
        {
            // Check for existing field
            for(Metadata.CustomMetadataValue cmvalue: values)
            {
                if(cmvalue.field == fieldName)
                {
                    cmvalue.value = fieldValue;
                    return;
                }
            }
            Metadata.CustomMetadataValue customField = new Metadata.CustomMetadataValue();
            customField.field = fieldName;
            customField.value = fieldValue;
            values.add(customField);
        }
    }

    @testvisible
    private static MDSettingClass cachedConfig = null;
	
	public static MDSettingClass getConfig()
	{
		if(cachedConfig!=null) return cachedConfig;
		
        List<MDSetting__mdt> settings = [Select DeveloperName, MasterLabel, BooleanSetting__c, TextSetting__c from MDSetting__mdt where DeveloperName = 'Default'];

		if(settings.size()==0 || Test.isRunningTest()) 
		{
            cachedConfig = new MDSettingClass('Default');
            return cachedConfig;
		}
        cachedConfig = new MDSettingClass(settings[0]);
		return cachedConfig;    // If configuration data is large, don't cache it outside of test mode
	}

	public static Boolean BooleanSetting
	{ 
		get
		{
			return getConfig().BooleanSetting;
		}
	}
	
	public static String TextSetting
	{
		get
		{
			return getConfig().TextSetting;
		}
	}
}
