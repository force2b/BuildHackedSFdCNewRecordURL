# FieldIdByObjectFromMetadata VF Component

## Purpose 
VisualForce Component that uses the metadata toolip API to retrieve all Custom Field ID's for the specified object. Results are stored in 3 global vars:
* mdapi_customFieldIds[] -- key is object.fieldname__c
* * 

## Usage Example 1:
Simple example using JS only to retrieve field ID's only in JS and using jQuery to apply to a link

    <c:FieldIdByObjectFromMetadata />
    <script>
    mdapi_retrieveCustomFieldIdsForAnObject('Contact', function() { 
        // Do something with the fields if needed
        // Note that the object key is case sensitive by default
        var fieldID = mdapi_customFieldIds["Contact.My_Custom_Field__c"];
        // Example using jQuery to change the URL of a custom link to include
        // a custom field Id with a custom default value of "some default value"
        $(".someCustomLink").attr("href", $(".someCustomLink").attr("href") +
            "&" + fieldID + "=some+default+value");
      });
    </script>

## Usage Example 2:

To retrieve custom Ids for multiple objects, and then pass the results back to  an Apex controller via an Action Function:

### Visualforce/JavaScript:
	<c:FieldIdByObjectFromMetadata useLowerCaseKeys="true" />
	<apex:form>
	<apex:actionFunction name="handleCustomFieldIDs" immediate="true" 
			action="{!handleCustomFieldIDs}" rerender="msgs">
		<apex:param name="fieldIds" assignTo="{!customFieldIdsJSON}" value="" />
	</apex:actionFunction>
	</apex:form>

    <script>	
	mdapi_retrieveCustomFieldIdsForAnObject('Contact', function() { 
		// Chaining the calls together using the callback method
		mdapi_retrieveCustomFieldIdsForAnObject('My_Custom_Object__c', function() { 
			handleCustomFieldIDs(JSON.stringify(mdapi_customFieldIds));
		});
	});
    </script>

### Apex Controller:
	public String customFieldIdsJSON	{ get; set; }
	private Map<String, String> customFieldIds;
	public pageReference handleCustomFieldIDs() {
		// Convert the JSON Map into a Map of Object.Field__c ==> FieldId
		if (this.customFieldIdsJSON != null) {
			this.customFieldIds = (Map<String, String>)JSON.deserialize(customFieldIdsJSON, Map<String, String>.class);
		}
		return null;
	}
