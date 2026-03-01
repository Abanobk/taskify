import 'package:flutter/material.dart';

import 'package:taskify/screens/widgets/onboarding__widget.dart';
import 'package:taskify/screens/widgets/onboarding_contacts.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../../config/colors.dart';
import '../../config/strings.dart';
import '../../routes/routes.dart';
import 'package:liquid_swipe/liquid_swipe.dart';




class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final _currentPage = ValueNotifier<int>(0);
 // Adjust based on your number of onboarding screens
  late PageController _controller;
  late LiquidController _liquidController;

  _setFirst() async {
    var box = await Hive.openBox(authBox);
    box.put(firstTimeUserKey, false);
  }

  @override
  void initState() {
    super.initState();
    _controller = PageController();
    _liquidController = LiquidController();
    _setFirst();
    // getRoute();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.pureWhiteColor,
      body: _mainBody(),

    );
  }



  Widget _mainBody() {
    return LiquidSwipe.builder(
      enableLoop: false,
      waveType: WaveType.liquidReveal,
      liquidController: _liquidController,
      onPageChangeCallback: (value) {
        setState(() => _currentPage.value = value);

        if (value == contents.length - 1) {
          Future.delayed(const Duration(seconds: 1), () {
            _setFirst();
            router.go('/login');
          });
        }
      },
      itemCount: contents.length,
      itemBuilder: (context, i) {
        return OnboardingPage(
          color: AppColors.backgroundColors[i],
          title: contents[i].title,
          description: contents[i].desc,
          imageUrl: contents[i].image,
          currentPage: _currentPage,
          controller: _controller,
        );
      },
    );
  }

}