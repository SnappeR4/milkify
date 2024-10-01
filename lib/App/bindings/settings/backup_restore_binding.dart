// lib/app/bindings/backup_restore_binding.dart
import 'package:get/get.dart';
import '../../controllers/settings/backup_restore_controller.dart';

class BackupRestoreBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<BackupRestoreController>(() => BackupRestoreController());
  }
}
