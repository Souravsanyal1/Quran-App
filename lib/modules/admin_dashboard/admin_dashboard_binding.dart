import 'package:get/get.dart';
import 'admin_dashboard_controller.dart';

class AdminDashboardBinding extends Bindings {
  AdminDashboardBinding();

  @override
  void dependencies() {
    Get.lazyPut<AdminDashboardController>(() => AdminDashboardController(Get.find(), Get.find()));
  }
}
