@isTest
private class TEST_TGFI_Tasks_TDTM {
    static taskTestMethod TEST_TGFI_Tasks_TDTM() {

		// Retrieve default NPSP Trigger Handlers
		List<npsp__Trigger_Handler__c> triggerHandlers = npsp.TDTM_Config_API.getCachedRecords();

		// Add our Trigger Handler to cached Trigger Handlers
		npsp__Trigger_Handler__c th = new npsp__Trigger_Handler__c();
		th.Name = 'TGFITaskTH';
		th.npsp__Class__c = 'TGFI_Tasks_TDTM';
		th.npsp__Object__c = 'Task';
		th.npsp__Trigger_Action__c = 'AfterInsert;AfterUpdate;';
		th.npsp__Active__c = true;
		th.npsp__Load_Order__c = 2;
		th.npsp__Asynchronous__c = false;

		triggerHandlers.add(th);

        //Set up data

        Contact con1 = new Contact(FirstName='John', LastName='Doe');
        Insert con1;

        Contact con2 = new Contact(FirstName='Jane', LastName='Awesome');
        Insert con2;
        
        Account tOrg1 = new Account(Name='Test Org');
        Insert tOrg1;


        Task tsk1 = new Task();
		tsk1.Subject = 'Task 3 test';
		tsk1.Status = 'Not Started';
		insert tsk1;

		TaskRelation tskr1 = new TaskRelation();
		tskr1.TaskId = tsk1.Id;
		tskr1.IsWhat = false;
		tskr1.RelationId = con1.Id;

		TaskRelation tskr2 = new TaskRelation();
		tskr2.TaskId = tsk1.Id;
		tskr2.IsWhat = false;
		tskr2.RelationId = con2.Id;


    }
}
