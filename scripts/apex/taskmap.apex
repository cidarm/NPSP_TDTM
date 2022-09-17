//Primary Affiliation

List<Task> tskList = [Select Id, WhatId, WhoId from Task where Id = '00T3F00000NdSULUA3'];

Map<String, Id> cPriAff = new Map<String,Id>();
for(Contact tRC : [SELECT Id, npsp__Primary_Affiliation__c
            from contact
            where npsp__Primary_Affiliation__c != null 
            and Id in (SELECT RelationId
            from TaskWhoRelation
            WHERE Type = 'Contact')] ){
        
        cPriAff.put(tRC.Id, tRC.npsp__Primary_Affiliation__c);


    }
System.debug('trc is '+ cPriAff);

Map<String,Id> tRelId = new Map<String,Id>();

for(TaskWhoRelation xt : [SELECT Id, RelationId, taskId
            from TaskWhoRelation
            WHERE Type = 'Contact']){
                tRelId.put(xt.taskId, xt.RelationId);
            }
System.debug('x is '+ tRelId);



Task[] taskToUpdate = [SELECT Id, WhatId, WhoId FROM Task where Id = '00T3F00000NdSULUA3'];

for(Task t : taskToUpdate){
   // t.WhatId = cPriAff.get('0033F00000doYn3QAE');
    t.WhatId = cPriAff.get(tRelId.get(t.Id));
System.debug('What id is ' +  t.WhatID);
    
}

update taskToUpdate;