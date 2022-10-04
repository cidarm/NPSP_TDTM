/*Set WhatId from the result of query the Contact record primary affiliation*/

global class TGFI_Tasks_TDTM extends npsp.TDTM_runnable {
   
    global override npsp.TDTM_Runnable.DmlWrapper run(List<SObject> newlist, List<SObject> oldlist,
    npsp.TDTM_Runnable.Action triggerAction, Schema.DescribeSObjectResult objResult) {
       npsp.TDTM_Runnable.dmlWrapper dmlWrapper = new npsp.TDTM_Runnable.DmlWrapper();
       try {
        //List of Old version of Task records.
       List<SObject> ots = oldlist;
        //Recursive variable.
       TGFI_checkrecursive.firstcall = true;

        //Logic used to determine if the Task WhatID needs to be updated during trigger execution.
        if ((triggerAction == npsp.TDTM_Runnable.Action.AfterInsert ||
             triggerAction == npsp.TDTM_Runnable.Action.AfterUpdate 
               && 
                !TGFI_checkrecursive.firstcall)  ) {

            //Create List of Task for update purposes.
            list<Task> updatedTasks = new list<Task>();

            list<ID> listTaskId = new list<ID>();
        //Map used to retrieve Task Relation's Contact Id for Primary Affiliation map below.
        Map<String,Id> tRelId = new Map<String,Id>();
        for(TaskWhoRelation xt : [Select Id, RelationId, TaskId
                                    FROM TaskWhoRelation
                                    WHERE Type = 'Contact'
                                    AND TaskId in :listTaskId
                                    WITH SECURITY_ENFORCED]){
                            tRelId.put(xt.TaskId, xt.RelationId);
                                                        }
        //Map used to retrieve Contact record's Primary Affiliation.
         Map<String,Id> cPriAff = new Map<String, Id>();
                    
        for(Contact tRC : [Select id, npsp__Primary_Affiliation__c
                            FROM Contact
                                                WHERE npsp__Primary_Affiliation__c != null 
                                                and Id in :tRelId.keySet()
                                                WITH SECURITY_ENFORCED]){
                                                    
                                            cPriAff.put(tRC.Id, tRC.npsp__Primary_Affiliation__c);
                    
                                                }
        //Evaluate newlist and add Task.Id to list 
        for (Task ts : (list<Task>)newlist) {
                if (String.IsBlank(ts.WhatId)) {
                    listTaskId.add(ts.Id);

                }
            }
        system.debug('List TaskId' + listTaskId);
        //Put list of task ids from the ts for loop into a new loop to set the WhatId equal to Primary Affiliation
        for (Task uTSK : [Select Id, WhatId FROM Task WHERE Id in :listTaskId WITH SECURITY_ENFORCED]){
            uTSK.WhatId = cPriAff.get(tRelId.get(uTSK.Id));
            updatedTasks.add(uTSK);
        }
            //Invoke NPSP dmlwrapper class to apply update to Task records.
            dmlWrapper.objectsToUpdate.addAll((list<SObject>)updatedTasks);
        }
    return dmlWrapper;
    }
    catch (Exception e){
            throw new DmlException(e.getMessage());
    }
        }

 }