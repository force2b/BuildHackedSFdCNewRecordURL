/* ****************************************************************************************************
* Controller Class: GenerateNewChildRecordURLController
* - Written by Michael Smith, Force2b, LLC. 2015-01-05
*
* Purpose:
* - Generates a target redirection URL using values passed by the VF page
*
* URL Parameters to use for setting actions:
* -- &uploadFile=1 				Redirect the user to the upload new file page
* -- &returnToNewRecord=1 		Don't redirect the user back to the parent record after saving
* -- &redirectHere=/apex/...	Redirect the user to this page after saving
*
* Modifications:  
*
******************************************************************************************************* */
public without sharing class GenerateNewChildRecordURLController {

	// Constructor
	public GenerateNewChildRecordURLController() { }

	// Public class vars
	public String customFieldIdsJSON	{ get; set; }

	public Map<String, String> customFieldIds;
	public String targetObjectName;

	// Method called by an ActionFunction on the VF page to generate the URL and redirect the user
	public pageReference generateTargetURLApex() {
		if (this.customFieldIdsJSON != null) {
			this.customFieldIds = (Map<String, String>)JSON.deserialize(customFieldIdsJSON, Map<String, String>.class);
		} else {
			apexPages.AddMessage(new ApexPages.Message(ApexPages.Severity.Fatal, 
				'Unable to generate a target URL to continue due to an unknown error'
			));	
			return null;
		}

		try {
			Map<String,String> urlParms = ApexPages.CurrentPage().getParameters();

			this.targetObjectName = urlParms.get('targetObjectName');
			String parentRecordId = urlParms.get('Id');
			String parentRecordName = urlParms.get('Name');
			String redirectHere = urlParms.get('redirectHere');
			Boolean returnToNewRecord = (urlParms.get('returnToNewRecord') == '1');
			Boolean redirectToUploadFile = (urlParms.get('uploadFile') == '1');
			
			// process each field parameter
			List<defaultField> fields = new List<defaultField>();
			for (String p : urlParms.keySet()) {
				if (p.startsWith('parmField')) {
					fields.add(new defaultField(this, urlParms.get(p)));
				}
			}

			Schema.SObjectType objectType;
			if (this.targetObjectName != null) {
				objectType = Schema.getGlobalDescribe().get(this.targetObjectName);
				if (objectType == null) {
					apexPages.AddMessage(new ApexPages.Message(ApexPages.Severity.Fatal, 
						'Unable to find a target object for ' + this.targetObjectName
					));	
					return null;
				}
			} else {
				apexPages.AddMessage(new ApexPages.Message(ApexPages.Severity.Fatal, 
					'Missing targetObjectName Parameter'
				));	
				return null;
			}

			pageReference pg = new PageReference('/' + objectType.getDescribe().getKeyPrefix() + '/e');
			pg.getParameters().put('retURL', '/' + parentRecordId);
			if (redirectToUploadFile == false && !returnToNewRecord && redirectHere == null) {
				pg.getParameters().put('saveURL', '/' + parentRecordId);
			} else if (redirectToUploadFile == false && redirectHere != null) {
				pg.getParameters().put('saveURL', redirectHere);
			} else if (redirectToUploadFile == true) {
				pageReference attachFileURL = Page.redirectSaveToUploadAttachment;
				attachFileURL.getParameters().put('objName', ' - ' + parentRecordName);
				if (!returnToNewRecord && redirectHere == null) {
					attachFileURL.getParameters().put('retURL', '/' + parentRecordId);
				} else if (redirectHere != null) {
					attachFileURL.getParameters().put('retURL', redirectHere);
				}
				pg.getParameters().put('saveURL', attachFileURL.getURL());
			}
			// build additional parameters for other custom field default values
			for (defaultField df : fields) {
				if (df.fieldId != null) {
					pg.getParameters().put(df.fieldId, df.value);
				}
			}
			
			return pg;
		} catch (exception ex) {
			apexPages.AddMessage(new ApexPages.Message(ApexPages.Severity.Fatal, 
				'Error building the target URL: ' + ex.getMessage()
			));
			return null;
		}

	}

	public class defaultField {
		String fieldName	{ get; private set; }
		String fieldId 		{ get; private set; }
		String value		{ get; private set; }
		Boolean isLookupId	{ get; private set; }

		public defaultField(GenerateNewChildRecordURLController myParent, String v) {
			List<String> vals = v.split('\\^');
			this.fieldName = vals[0];
			this.value = vals[1];

			// If this is a custom field, find the FieldId in the Map of FieldNames to Field Id's
			if (this.fieldName.endsWith('__c')) {
				this.fieldId = myParent.customFieldIds.get(myParent.targetObjectName.toLowerCase() + '.' + vals[0].toLowerCase());
			} else {
				// Use the actual field name for standard fields
				this.fieldId = this.fieldName;
			}

			// Handle Lookups a little differently
			if (vals.size() > 2 && vals[2] == 'lkid') {
				this.isLookupId = true;
				this.fieldId = 'CF' + this.fieldId + '_lkid';
			}
			if (vals.size() > 2 && vals[2] == 'lkName') {
				this.fieldId = 'CF' + this.fieldId;
			}
		}
	}

}