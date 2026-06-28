import 'package:get/get.dart';
import 'namaz_guide_controller.dart';

class NamazGuideBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<NamazGuideController>(() => NamazGuideController());
  }
}
