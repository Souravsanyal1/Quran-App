import 'package:get/get.dart';
import '../settings/n8n_config_controller.dart';
import 'admin_dashboard_controller.dart';

class AdminDashboardBinding extends Bindings {
  AdminDashboardBinding();

  @override
  void dependencies() {
    Get.lazyPut<AdminDashboardController>(() => AdminDashboardController(Get.find(), Get.find()));
    Get.lazyPut<N8nConfigController>(() => N8nConfigController());
  }
}
