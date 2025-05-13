import haxe.Exception;

function getAccountId() {
	var numb = 0;
	var user_id = sceUserServiceGetForegroundUser();

	for(i in 1...17) {
		// https://github.com/ps5-payload-dev/linkdev/blob/af529eae5348e4670cbaa4e331b3702e439e97d6/regmgr.h#L3301
		var uidRegKey = customRegMgrGenerateNum(i, 16, 65536, 125829376, 127140096);
		var uid = sceRegMgrGetInt(uidRegKey);

		if(uid == -1) {
			throw 'SCE_REGMGR: unable to get USER_01_16_user_id(${i})';
		} else if(uid == user_id) {
			numb = i;
			break;
		}
	}

	if(numb == 0) {
		throw "Unable to find the account id of the currently logged in user";
	}

	// https://github.com/ps5-payload-dev/linkdev/blob/af529eae5348e4670cbaa4e331b3702e439e97d6/regmgr.h#L3305
	var aiRegKey = customRegMgrGenerateNum(numb, 16, 65536, 125830400, 127141120);

	var account_id = sceRegMgrGetInt64(aiRegKey);
	if(account_id == 0) {
		throw "account id not found, probably PSN is not activated, please use offact payload for activation.";
	}

	return sceRegMgrGetBinBase64(aiRegKey, 8);
}

function main() {
	// https://github.com/ps5-payload-dev/linkdev/blob/af529eae5348e4670cbaa4e331b3702e439e97d6/regmgr.h#L2196C1-L2196C59
	var remotePlayEnableRegKey = 1098973184;

	// Enable Remote Play
	sceRegMgrSetInt(remotePlayEnableRegKey, 1);

	// Get Account ID
	var accountId = -1;

	try {
		accountId = getAccountId();
	} catch(e:Exception) {
		return 'Error: ${e}';
	}

	writeln('Account ID: ${accountId}');

	sceRemoteplayInitialize();
	sceRemoteplayNotifyPinCodeError(1);

	var pin = sceRemoteplayGeneratePinCode();
	if(pin == -1)
	{
		return "Pin Generation Failed!";
	}
	writeln('Pin Code: ${pin}');


	var timeout = 300;
	var timestamp = Math.floor(Sys.time());
	writeln('Remaining time: ${timeout} seconds');

	while(true) {
		Sys.sleep(1);

		var currentTimestamp = Math.floor(Sys.time());
		if(currentTimestamp - timestamp > 300) {
			return "Timeout";
		}

		// Prevent infinite loop
		if(!checkHeartbeat())
			return "Script was stopped because there was no heartbeat";

		var registerData = sceRemoteplayConfirmDeviceRegist();
		var pair_stat = registerData.pair_stat;
		var pair_err = registerData.pair_err;

		if(pair_stat == 2) {
			return "Pairing complete!";
		} else if(pair_stat == 3) {
			if(pair_err == 0x80FC1047) {
				return "Error: incorrect PIN code";
			} else if(pair_err == 0x80FC1040) {
				return "Error: incorrect Account ID";
			} else {
				return 'Error: ${pair_err}';
			}
		}
	}
}();