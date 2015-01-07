@isTest
private class GenerateNewChildRecordURLControllerTest {
	
	@isTest static void test_URLBuilder() {

		Test.setCurrentPage(Page.GenerateNewChildRecordURL);
		GenerateNewChildRecordURLController ctrlr = new GenerateNewChildRecordURLController();

		system.assertEquals(null, ctrlr.generateTargetURLApex(), 'Should generate an error');

		ApexPages.CurrentPage().getParameters().put('Id', UserInfo.getUserId());
		ApexPages.CurrentPage().getParameters().put('Name', 'xyz');
		ApexPages.CurrentPage().getParameters().put('uploadFile', '1');
		ApexPages.CurrentPage().getParameters().put('targetObjectName', 'SomeNonExistingObject__c');
		ApexPages.CurrentPage().getParameters().put('parmField1', 'Field1__c^Value^lkid');
		ApexPages.CurrentPage().getParameters().put('parmField2', 'Field1__c^Value^lkname');
		ApexPages.CurrentPage().getParameters().put('parmField3', 'Field2__c^Value');
		ApexPages.CurrentPage().getParameters().put('parmField4', 'Name^Value');

		ctrlr.customFieldIdsJSON = '{"Field1__c":"0000001","Field2__c":"0000002"}';
		system.assertEquals(null, ctrlr.generateTargetURLApex(), 'Should generate an error');

		ApexPages.CurrentPage().getParameters().put('targetObjectName', 'Contact');
		system.assertNotEquals(null, ctrlr.generateTargetURLApex(), 'Should NOT generate an error');

		ApexPages.CurrentPage().getParameters().put('uploadFile', '0');
		ApexPages.CurrentPage().getParameters().put('returnToNewRecord', '1');
		system.assertNotEquals(null, ctrlr.generateTargetURLApex(), 'Should NOT generate an error');

		ApexPages.CurrentPage().getParameters().put('redirectHere', '/home/home.jsp');
		system.assertNotEquals(null, ctrlr.generateTargetURLApex(), 'Should NOT generate an error');

	}
	
}