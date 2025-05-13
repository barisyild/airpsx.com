sceKernelSendNotificationRequest("Heartbeat test started");

while(checkHeartbeat()) {

}

sceKernelSendNotificationRequest("Heartbeat test finished");