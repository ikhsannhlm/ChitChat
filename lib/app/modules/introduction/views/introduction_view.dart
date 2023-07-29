import 'package:chitchat/app/routes/app_pages.dart';
import 'package:flutter/material.dart';

import 'package:get/get.dart';
import 'package:introduction_screen/introduction_screen.dart';

import '../controllers/introduction_controller.dart';
import 'package:lottie/lottie.dart';

class IntroductionView extends GetView<IntroductionController> {
  Widget build(BuildContext context) {
    return Scaffold(
      body: IntroductionScreen(
        pages: [
          PageViewModel(
            title: "Welcome To ChitChat",
            body:
                "Merupakan Aplikasi Message Real-Time, dibangun dengan Flutter, GetX, dan Firebase.",
            image: Container(
              width: Get.width * 0.6,
              height: Get.width * 0.6,
              child: Center(
                child: Lottie.asset("assets/lottie/main-laptop-duduk.json"),
              ),
            ),
          ),
          PageViewModel(
            title: "ChitChat",
            body:
                "Merupakan Aplikasi Message Real-Time, dibangun dengan Flutter, GetX, dan Firebase.",
            image: Container(
              width: Get.width * 0.6,
              height: Get.width * 0.6,
              child: Center(
                child: Lottie.asset("assets/lottie/ojek.json"),
              ),
            ),
          ),
          PageViewModel(
            title: "Object Oriented Programming",
            body:
                "Aplikasi ini dibangun untuk memenuhi salah satu tugas praktikum PBO.",
            image: Container(
              width: Get.width * 0.6,
              height: Get.width * 0.6,
              child: Center(
                child: Lottie.asset("assets/lottie/payment.json"),
              ),
            ),
          ),
          PageViewModel(
            title: "About Developer",
            body:
                "Muhammad Ikhsan Nurhalim Mahasiswa Teknik Infomatika UIN SGD.",
            image: Container(
              width: Get.width * 0.6,
              height: Get.width * 0.6,
              child: Center(
                child: Lottie.asset("assets/lottie/pesawat.json"),
              ),
            ),
          ),
          PageViewModel(
            title: "Join Now!",
            body: "Daftarkan diri anda untuk menjadi bagian dari kami.",
            image: Container(
              width: Get.width * 0.6,
              height: Get.width * 0.6,
              child: Center(
                child: Lottie.asset("assets/lottie/register.json"),
              ),
            ),
          ),
        ],
        showSkipButton: true,
        skip: Text("Skip"),
        next: Text(
          "Next",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        done: const Text(
          "Login",
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        onDone: () => Get.toNamed(Routes.LOGIN),
      ),
    );
  }
}
