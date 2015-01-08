[Details on the related VF Component that uses the Tooling API to retrieve all Custom FieldId's for any object] (README-FIELDSBYOBJECTCOMPONENT.md)

# BuildHackedSFdCNewRecordURL
VF and Apex to build a custom New Record URL from a custom button while easily passing in default field values on the target object.

To create a custom button on a child object to automatically fill in fields on the new record, create a custom button of type URL and set the syntax as follows:

## Button URL for an that is linked to a Contact:
The button URL below can create a new record for SomeObjectName__c, setting default values on the Contact__c, OtherLookup__c, and Date_Field__c fields. After saving the record, the user will be returned to the parent Contact record.

    /apex/GenerateNewChildRecordURL?Id={!Contact.Id}
    &Name={!Contact.name}
    &targetObjectName=SomeObjectName__c
    &parmField1=Contact__c^{!Contact.Name}^lkName
    &parmField2=Contact__c^{!Contact.Id}^lkid
    &parmField3=OtherLookup__c^{!Contact.AccountId}^lkid
    &parmField4=OtherLookup__c^{!Contact.Account.Name}^lkName
    &parmField5=Date_Field__c^{! TEXT(MONTH(TODAY()))+&quot;/&quot; +TEXT(DAY(TODAY()))+&quot;/&quot; +TEXT(YEAR(TODAY())) }
    
## Additional URL Options:

* &uploadFile=1 -- When passed to the GenerateNewChildRecordURL page, this will redirect the user to the "Attach a File" page for the newly created record
* &returnToNewRecord=1 -- The GenerateNewChildRecordURL page returns to the parent record by default. This parameter tells the page to stay on the new record.
* &redirectHere= -- When passed with a valid URL, and if returnToNewRecord is not set to 1, this will redirect the user to this page after saving the new record.
* &recordTypeName= -- When passed with a valid RecordType.DeveloperName value this will skip the record type propmt and create a record of the passed record type
