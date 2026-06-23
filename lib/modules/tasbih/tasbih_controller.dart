import 'package:get/get.dart';
import 'package:vibration/vibration.dart';

class TasbihController extends GetxController {
  final RxInt count = 0.obs;
  final RxInt target = 33.obs;
  final RxInt totalSaves = 0.obs;

  void increment() {
    count.value++;
    _triggerVibration(50); // short tap vibration

    if (count.value == target.value) {
      _triggerVibration(400); // long completion vibration
      totalSaves.value++;
    }
  }

  void reset() {
    count.value = 0;
    _triggerVibration(100);
  }

  void setTarget(int value) {
    target.value = value;
    count.value = 0;
    _triggerVibration(100);
  }

  Future<void> _triggerVibration(int durationMs) async {
    try {
      if (await Vibration.hasVibrator()) {
        Vibration.vibrate(duration: durationMs);
      }
    } catch (e) {
      Get.log('Vibration error: $e');
    }
  }
}
