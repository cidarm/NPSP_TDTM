/*Set WhatId from the result of query the Contact record primary affiliation*/

public with sharing class TGFI_Tasks_TDTM extends npsp.TDTM_runnable {
   
    public override npsp.TDTM_Runnable.DmlWrapper run(List<SObject> newlist, List<SObject> oldlist,
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
          
            for (Task ts : (list<Task>)newlist) {
                if (String.IsBlank(ts.WhatId)) {
                    updatedTasks.add(ts.Id);

                }
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
    private void priAff(){
                //Map used to retrieve Task Relation's Contact Id for Primary Affiliation map below.
                Map<String,Id> tRelId = new Map<String,Id>();
                for(TaskWhoRelation xt : [Select Id, RelationId, TaskId
                                            FROM TaskWhoRelation
                                            WHERE Type = 'Contact'
                                            AND TaskId =''
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
    }

 }