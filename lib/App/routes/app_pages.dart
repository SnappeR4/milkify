import 'package:get/get.dart';
import 'package:milkify/App/bindings/settings/rate_settings_binding.dart';
import 'package:milkify/App/user_interface/pages/settings/rate_settings_page.dart';
import '../bindings/dashboard_binding.dart';
import '../bindings/register_binding.dart';
import '../bindings/report_binding.dart';
import '../bindings/sale_binding.dart';
import '../bindings/settings/backup_restore_binding.dart';
import '../bindings/settings/collection_settings_binding.dart';
import '../bindings/settings/language_settings_binding.dart';
import '../bindings/settings/member_settings_binding.dart';
import '../bindings/settings/printer_settings_binding.dart';
import '../bindings/settings/profile_settings_binding.dart';
import '../bindings/settings_binding.dart';
import '../bindings/splash_binding.dart';
import '../user_interface/pages/dashboard_page.dart';
import '../user_interface/pages/register_page.dart';
import '../user_interface/pages/report_page.dart';
import '../user_interface/pages/sale_page.dart';
import '../user_interface/pages/settings/backup_restore_page.dart';
import '../user_interface/pages/settings/collection_settings_page.dart';
import '../user_interface/pages/settings/language_settings_page.dart';
import '../user_interface/pages/settings/member_setting/add_member_page.dart';
import '../user_interface/pages/settings/member_setting/edit_member_page.dart';
import '../user_interface/pages/settings/member_settings_page.dart';
import '../user_interface/pages/settings/printer_settings_page.dart';
import '../user_interface/pages/settings/profile_settings_page.dart';
import '../user_interface/pages/settings_page.dart';
import '../user_interface/pages/splash_page.dart';
import 'app_routes.dart';

class AppPages {
  static final pages = [
    GetPage(
      name: AppRoutes.splash,
      page: () => const SplashPage(),
      binding: SplashBinding(),
    ),
    GetPage(
      name: AppRoutes.register,
      page: () => const RegisterPage(),
      binding: RegisterBinding(),
    ),
    GetPage(
      name: AppRoutes.dashboard,
      page: () => DashboardPage(),
      binding: DashboardBinding(),
    ),
    GetPage(
      name: AppRoutes.sale,
      page: () => SalePage(),
      binding: SaleBinding(),
    ),
    GetPage(
      name: AppRoutes.report,
      page: () => ReportPage(),
      binding: ReportBinding(),
    ),
    GetPage(
      name: AppRoutes.settings,
      page: () => const SettingsPage(),
      binding: SettingsBinding(),
    ),

    //settings
    GetPage(
      name: AppRoutes.memberList,
      page: () => MemberListPage(),
      binding: MemberSettingsBinding(),
    ),
    GetPage(
      name: AppRoutes.profileSettings,
      page: () => ProfileSettingsPage(),
      binding: ProfileSettingsBinding(),
    ),
    GetPage(
      name: AppRoutes.backupRestore,
      page: () => BackupRestorePage(),
      binding: BackupRestoreBinding(),
    ),
    GetPage(
      name: AppRoutes.languageSettings,
      page: () => LanguageSettingsPage(),
      binding: LanguageSettingsBinding(),
    ),
    GetPage(
      name: AppRoutes.printerSettings,
      page: () => PrinterSettingsPage(),
      binding: PrinterSettingsBinding(),
    ),
    GetPage(
      name: AppRoutes.collectionSettings,
      page: () => CollectionSettingsPage(),
      binding: CollectionSettingsBinding(),
    ),

    //member setting
    GetPage(
      name: AppRoutes.editMember,
      page: () => EditMemberPage(),
    ),
    GetPage(
      name: AppRoutes.addMember,
      page: () => AddMemberPage(),
    ),
    GetPage(
      name: AppRoutes.rateSettings,
      page: () => RateSettingPage(),
      binding: RateSettingsBinding(),
    )
  ];
}
