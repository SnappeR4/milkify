import 'package:background_sms/background_sms.dart';
import 'package:permission_handler/permission_handler.dart';

class SmsService {
  Future<bool> getPermission() async {
    var status = await Permission.sms.request();
    return status.isGranted;
  }

  Future<bool> isPermissionGranted() async {
    return await Permission.sms.status.isGranted;
  }

  Future<bool?> get supportCustomSim async {
    return await BackgroundSms.isSupportCustomSim;
  }

  Future<SmsStatus> sendMessage(String phoneNumber, String message, {int? simSlot}) async {
    var result = await BackgroundSms.sendMessage(
      phoneNumber: phoneNumber,
      message: message,
      simSlot: simSlot,
    );
    return result;
  }
}
