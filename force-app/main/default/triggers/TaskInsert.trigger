trigger TaskInsert on Task (after insert) {
	
	for (Task task: Trigger.new) {
	system.debug(task.WhatId.getSObjectType());
	system.debug('aaaa');
	}
}