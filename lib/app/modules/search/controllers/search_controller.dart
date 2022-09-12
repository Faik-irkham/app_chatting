import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';

class SearchController extends GetxController {
  //TODO: Implement SearchController

  late TextEditingController searchC;

  @override
  void onInit() {
    // TODO: implement onInit
    searchC = TextEditingController();
    super.onInit();
  }

  @override
  void onClose() {
    // TODO: implement onClose
    searchC.dispose();
    super.onClose();
  }
}
