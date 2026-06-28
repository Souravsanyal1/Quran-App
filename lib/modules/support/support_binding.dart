import 'package:get/get.dart';
import 'support_controller.dart';
import '../../data/repositories/support_repository.dart';

class SupportBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<SupportController>(() => SupportController(Get.find<SupportRepository>()));
  }
}
