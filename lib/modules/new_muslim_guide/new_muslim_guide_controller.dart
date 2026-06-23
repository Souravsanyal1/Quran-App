import 'package:get/get.dart';

class WuduStep {
  final int stepNumber;
  final String titleEn;
  final String titleBn;
  final String descEn;
  final String descBn;

  const WuduStep({
    required this.stepNumber,
    required this.titleEn,
    required this.titleBn,
    required this.descEn,
    required this.descBn,
  });
}

class NewMuslimGuideController extends GetxController {
  final List<WuduStep> wuduSteps = const [
    WuduStep(
      stepNumber: 1,
      titleEn: 'Intention (Niyyah)',
      titleBn: 'নিয়ত করা',
      descEn: 'Make a silent intention to perform Wudu for purification, and say "Bismillah" (In the name of Allah).',
      descBn: 'ওযু করার জন্য মনে মনে নিয়ত করুন এবং বলুন "বিসমিল্লাহ"।',
    ),
    WuduStep(
      stepNumber: 2,
      titleEn: 'Washing Hands',
      titleBn: 'হাত ধোয়া',
      descEn: 'Wash both hands up to the wrists three times, ensuring water reaches between the fingers.',
      descBn: 'দুই হাতের কবজি পর্যন্ত ভালো করে ৩ বার ধৌত করুন। আঙুলের ফাঁকে ভালো করে পানি পৌঁছান।',
    ),
    WuduStep(
      stepNumber: 3,
      titleEn: 'Rinsing the Mouth',
      titleBn: 'কুলি করা',
      descEn: 'Take water in your right hand, put it into your mouth, rinse thoroughly, and spit it out. Repeat three times.',
      descBn: 'ডান হাতে পানি নিয়ে মুখের ভেতর দিন এবং ভালো করে গড়গড়া করে কুলি করুন। এভাবে ৩ বার করুন।',
    ),
    WuduStep(
      stepNumber: 4,
      titleEn: 'Inhaling Water in Nose',
      titleBn: 'নাকে পানি দেওয়া',
      descEn: 'Take water in your right hand, sniff it into your nose, and expel it with your left hand. Repeat three times.',
      descBn: 'ডান হাত দিয়ে নাকে হালকা পানি টেনে দিন এবং বাম হাত দিয়ে নাক পরিষ্কার করুন। এভাবে ৩ বার করুন।',
    ),
    WuduStep(
      stepNumber: 5,
      titleEn: 'Washing the Face',
      titleBn: 'মুখমণ্ডল ধোয়া',
      descEn: 'Wash the entire face three times, from the hairline to the chin, and from ear to ear.',
      descBn: 'কপাল থেকে থুতনি এবং দুই কানের লতি পর্যন্ত পুরো মুখমণ্ডল ৩ বার ভালো করে ধৌত করুন।',
    ),
    WuduStep(
      stepNumber: 6,
      titleEn: 'Washing Arms',
      titleBn: 'হাত কনুই পর্যন্ত ধোয়া',
      descEn: 'Wash both arms up to the elbows three times, starting with the right arm first and then the left.',
      descBn: 'প্রথমে ডান হাত এবং পরে বাম হাত কনুই পর্যন্ত ভালো করে ৩ বার ধৌত করুন।',
    ),
    WuduStep(
      stepNumber: 7,
      titleEn: 'Wiping the Head (Masah)',
      titleBn: 'মাথা মাসেহ করা',
      descEn: 'Wet your hands, run them from the front of the head to the back, then wipe the inside of your ears with your index fingers and the back of your ears with your thumbs. Perform once.',
      descBn: 'দুই হাত ভিজিয়ে কপাল থেকে পেছনের দিক পর্যন্ত পুরো মাথা এবং তর্জনী ও বুড়ো আঙুল দিয়ে কানের ভেতর ও বাইরে ১ বার মাসেহ করুন।',
    ),
    WuduStep(
      stepNumber: 8,
      titleEn: 'Washing Feet',
      titleBn: 'পা টাখনু পর্যন্ত ধোয়া',
      descEn: 'Wash both feet up to the ankles three times, starting with the right foot and ensuring water flows between the toes.',
      descBn: 'প্রথমে ডান পা এবং পরে বাম পা টাখনু (গিরা) পর্যন্ত ভালো করে ৩ বার ধৌত করুন। পায়ের আঙুলের ফাঁকে ভালো করে পানি পৌঁছান।',
    ),
  ];
}
