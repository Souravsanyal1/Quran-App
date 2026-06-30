import 'package:get/get.dart';
import 'namaz_guide_2_controller.dart';

class NamazGuide2Binding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<NamazGuide2Controller>(() => NamazGuide2Controller());
  }
}
