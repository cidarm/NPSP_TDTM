/*Set WhatId from the result of query the Contact record primary affiliation*/

global class TGFI_Tasks_TDTM extends npsp.TDTM_runnable {
   
    global override npsp.TDTM_Runnable.DmlWrapper run(List<SObject> newlist, List<SObject> oldlist,
    npsp.TDTM_Runnable.Action triggerAction, Schema.DescribeSObjectResult objResult) {
       npsp.TDTM_Runnable.dmlWrapper dmlWrapper = new npsp.TDTM_Runnable.DmlWrapper();
       
       List<SObject> ots = oldlist;

       TGFI_checkrecursive.firstcall = true;

       system.debug('OldWhatID is '+ ots);

        if ((triggerAction == npsp.TDTM_Runnable.Action.AfterInsert ||
             triggerAction == npsp.TDTM_Runnable.Action.AfterUpdate 
               && 
                !TGFI_checkrecursive.firstcall)  ) {
            list<ID> listTaskId = new list<ID>();
          
            for (Task ts : (list<Task>)newlist) {
                if (String.IsBlank(ts.WhatId)) {
                    listTaskId.add(ts.Id);
                }
            }
            
            list<Task> updateTask = [select Id, WhatId from Task where Id in :listTaskId with SECURITY_ENFORCED];
            
            /* Pull npsp__Primary_Affiliation__c from result of querying the contact object*/

            
            Id cPAOId = [SELECT Id, npsp__Primary_Affiliation__r.Id
            from contact
            where npsp__Primary_Affiliation__c != ''
            and RecordType.name != 'Staff'
            and Id in (SELECT RelationId
            from TaskWhoRelation
            WHERE TaskId = :listTaskId
             and Type = 'Contact')
            with SECURITY_ENFORCED
            limit 1].npsp__Primary_Affiliation__r.Id;
            
            system.debug('**cPAOID is **' + cPAOId );
           
            for (Task utsk : updateTask) {
                utsk.WhatId = cPAOId;
                }
            dmlWrapper.objectsToUpdate.addAll((list<SObject>)updateTask);
        }
        return dmlWrapper;
    }
 }