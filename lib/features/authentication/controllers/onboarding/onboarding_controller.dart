import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

import '../../screens/login/login.dart';

class OnBoardingController extends GetxController {
  static OnBoardingController get instance => Get.find();

  /// Variables
  final pageController = PageController();
  Rx<int> currentPageIndex = 0.obs;

  /// Dispose of PageController
  @override
  void onClose() {
    pageController.dispose();
    super.onClose();
  }

  /// Update Current Index when Page Scrolls
  void updatePageIndicator(int index) {
    currentPageIndex.value = index;
  }

  /// Jump to a specific dot-selected page
  void dotNavigationClick(int index) {
    currentPageIndex.value = index;
    pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  /// Update Current Index & jump to the next page
  void nextPage() {
    if (currentPageIndex.value == 2) {

      final storage = GetStorage();

      if (kDebugMode) {
        print('==================== GET STORAGE Next Button ====================');
        print(storage.read('IsFirstTime'));
      }

      storage.write('isFirstTime', false);
      
      // Navigate to the Login Screen
      Get.offAll(const LoginScreen());
    } else {
      int page = currentPageIndex.value + 1;
      pageController.animateToPage(
        page,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
      currentPageIndex.value = page;
    }
  }

  /// Update Current Index & jump to the last page
  void skipPage() {
    const int lastPageIndex = 2; // Update as per your last page index
    currentPageIndex.value = lastPageIndex;
    pageController.animateToPage(
      lastPageIndex,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }
}
