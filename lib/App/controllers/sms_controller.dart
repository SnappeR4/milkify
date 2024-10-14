import 'package:get/get.dart';
import 'package:background_sms/background_sms.dart';
import 'package:milkify/App/data/services/sms_service.dart';

class SmsController extends GetxController {
  final SmsService _smsService = SmsService();

  var isPermissionGranted = false.obs;
  var isCustomSimSupported = false.obs;
  var sendingStatus = ''.obs;

  @override
  void onInit() {
    super.onInit();
    _checkPermission();
  }

  Future<void> _checkPermission() async {
    isPermissionGranted.value = await _smsService.isPermissionGranted();
  }

  Future<void> requestPermission() async {
    isPermissionGranted.value = await _smsService.getPermission();
  }

  Future<void> checkCustomSimSupport() async {
    isCustomSimSupported.value = (await _smsService.supportCustomSim) ?? false;
  }

  Future<void> sendSms(String phoneNumber, String message) async {
    if (!isPermissionGranted.value) {
      await requestPermission();
    }

    if (isPermissionGranted.value) {
      await checkCustomSimSupport();

      SmsStatus result;
      if (isCustomSimSupported.value) {
        result =
            await _smsService.sendMessage(phoneNumber, message, simSlot: 1);
      } else {
        result = await _smsService.sendMessage(phoneNumber, message);
      }

      if (result == SmsStatus.sent) {
        sendingStatus.value = "SMS Sent Successfully!";
      } else {
        sendingStatus.value = "SMS Sending Failed!";
      }
    } else {
      sendingStatus.value = "SMS Permission Denied!";
    }
  }
}
