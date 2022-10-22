/*Set WhatId from the result of query the Contact record primary affiliation*/

global class TGFI_Tasks_TDTM extends npsp.TDTM_runnable {
    
    private static Map<Id, Task> mapNewOldTask = new Map<Id, Task>();

    global override npsp.TDTM_Runnable.DmlWrapper run(List<SObject> newlist, List<SObject> oldlist,
    npsp.TDTM_Runnable.Action triggerAction, Schema.DescribeSObjectResult objResult) {
       npsp.TDTM_Runnable.dmlWrapper dmlWrapper = new npsp.TDTM_Runnable.DmlWrapper();

       System.debug('NPSP Runnable Action is ' +triggerAction );
       try {
        //Task ID used 
        Set<Id> taskToUpdate = new Set<Id>();

        //Logic used to determine if the Task WhatID needs to be updated during trigger execution.
        if ((triggerAction == npsp.TDTM_Runnable.Action.AfterInsert ||
             triggerAction == npsp.TDTM_Runnable.Action.AfterUpdate
               && 
                (!TGFI_checkrecursive.firstcall))  ) {
        
        //Recursive variable.
       TGFI_checkrecursive.firstcall = true;

        System.debug('Determined TriggerAction is ' + triggerAction);
        System.debug('Recursive Check is inside '+ TGFI_checkrecursive.firstcall);


                List<SObject> listToCheck = newlist != null ? newlist : oldlist;

                for (SObject newSO : listToCheck) {
                    Task newTask = (Task)newSo;
                    if ( String.isBlank(newTask.WhatId) ){
                        taskToUpdate.add(newTask.Id);
                        mapNewOldTask.put(newTask.Id, newTask);
                    }
                }

                System.debug('tasktoupdate' + taskToUpdate);

                if (taskToUpdate.size() > 0){
                    updateTaskRelId(taskToUpdate, dmlWrapper);
                }
        }
    return dmlWrapper;
    }
    catch (Exception e){
            throw new DmlException(e.getMessage());
    }
        }

    private static void updateTaskRelId(Set<Id> taskToUpdate, DmlWrapper dmlWrapper){

        //Create List of Task for update purposes.
       list<Task> updatedTasks = new list<Task>();
 
        //Map used to retrieve Contact record's Primary Affiliation.
        Map<String,Id> cPriAff = new Map<String, Id>();
        //Map used to retrieve Task Relation's Contact Id for Primary Affiliation map below.
        Map<String,Id> tRelId = new Map<String,Id>();
                    
        for(Contact tRC : [Select id, npsp__Primary_Affiliation__c
                            FROM Contact
                            WHERE npsp__Primary_Affiliation__c != null 
                            and RecordType.name != 'Staff'
                            //and Id in :tRelId.keySet(RelationId)
                            and Id in (Select RelationId
                            FROM TaskWhoRelation
                            WHERE Type = 'Contact'
                            AND TaskId in :taskToUpdate)
                            WITH SECURITY_ENFORCED]){
                cPriAff.put(tRC.Id, tRC.npsp__Primary_Affiliation__c);
        System.debug('Primary Affiliation is' + cPriAff);
                                                }

        for(TaskWhoRelation xt : [Select Id, RelationId, TaskId
                                    FROM TaskWhoRelation
                                    WHERE Type = 'Contact'
                                    AND TaskId in :taskToUpdate
                                    Order by Id
                                    Limit 1]){
                            tRelId.put(xt.TaskId, xt.RelationId);
        System.debug('Relation ID' + tRelId);
                                                        }

        //Put list of task ids from the ts for loop into a new loop to set the WhatId equal to Primary Affiliation
        for (Task uTSK : [Select Id, WhatId FROM Task WHERE Id in :taskToUpdate WITH SECURITY_ENFORCED]){
            uTSK.WhatId = cPriAff.get(tRelId.get(uTSK.Id));
            updatedTasks.add(uTSK);

            System.debug('Updated Tasks' + updatedTasks);
        }

        dmlWrapper.objectsToUpdate.addAll((list<SObject>)updatedTasks);
    }

 }