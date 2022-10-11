Map<String, String> tTask = new Map<String,String>();
tTask.put('test', 'id');
System.debug('Data set is: '+ tTask);

Map<String,Object> tObj = new Map<String,Object>();
tObj.put('test','id' );
tObj.put('Next', '34');
Object code = tObj.get('test');
System.debug('Test Object is: '+ tObj);
System.debug('code :' + code);


Map<Id,Task> tCS = new Map<Id,Task>();
List<Contact> ts = [SELECT Id, npsp__Primary_Affiliation__c
            from contact
            where Id in (SELECT RelationId
            from TaskWhoRelation
            WHERE Type = 'Contact')];

System.debug('Id ' + iTS);
System.debug('Contact list '+ ts);
System.debug('TCS is '+ tCS);

List<Task> tskList = [Select Id, WhatId, WhoId from Task where Id = '00T3F00000NdSULUA3'];
Set<Id> tWhatIdSet = new Set<Id>();
Map<Task, Id> taskByContactIdMap = new Map<Task, Id>();

for(Task tSK : tskList){
    if(String.isBlank(tSK.WhatId)){
        tWhatIdSet.add(tsk.WhatId);
        taskByContactIdMap.put(tsk, tsk.WhatId);
    }
}

Map<Id, Contact> priAff = new Map<Id, Contact>();

for(Contact tRC : [SELECT Id, npsp__Primary_Affiliation__c
            from contact
            where Id in (SELECT RelationId
            from TaskWhoRelation
            WHERE Type = 'Contact')] ){
        
        priAff.put(tRC.Id, tRC);


    }
System.debug('trc is '+ priAff);

Map<Task, Contact> taskByContactMap = new Map<Task, Contact>();
for (task tsk : tskList) {
    taskByContactMap.put(tsk, priAff.get(taskByContactIdMap.get(tsk)));
}
System.debug('task by contactmap' + taskByContactMap);
System.debug('Task List is ' + tskList);
System.debug('WhatID is ' + tWhatIdSet);