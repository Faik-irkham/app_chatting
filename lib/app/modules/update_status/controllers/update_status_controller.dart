import 'package:flutter/material.dart';
import 'package:get/get.dart';

class UpdateStatusController extends GetxController {
  //TODO: Implement UpdateStatusController

  late TextEditingController statusC;

  @override
  void onInit() {
    // TODO: implement onInit

    statusC = TextEditingController();
    super.onInit();
  }

  @override
  void onClose() {
    // TODO: implement onClose

    statusC.dispose();
    super.onClose();
  }
}
