Map<String, String> tTask = new Map<String,String>();
tTask.put('test', 'id');
System.debug('Data set is: '+ tTask);

Map<String,Object> tObj = new Map<String,Object>();
tObj.put('test','id' );
tObj.put('Next', '34');
Object code = tObj.get('test');
System.debug('Test Object is: '+ tObj);
System.debug('code :' + code);