

import 'package:taskify/config/app_images.dart';

class OnboardingContents {
  final String title;
  final String image;
  final String desc;
  final bool? isLastPage;

  OnboardingContents({
    required this.title,
    required this.image,
    required this.desc,
    this.isLastPage
  });
}

List<OnboardingContents> contents = [
  OnboardingContents(
    title: 'Research',
    desc: 'The app provide a platform where you no need to remember your everyday task.',
    image: AppImages.onBoardingImage1,
  ),
  OnboardingContents(
    title: 'Collaborate',
    desc: 'You can easily track your daily progress and perform your task efficiently.',
    image: AppImages.onBoardingImage2,
  ),
  OnboardingContents(
    title: 'Implement',
    desc: 'You get notifications of your task and track your daily work on this platform.',
    image: AppImages.onBoardingImage3,
    isLastPage: true, // Mark the last page
  ),
];