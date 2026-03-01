import 'package:avatar_glow/avatar_glow.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:url_launcher/url_launcher.dart'; // Import url_launcher
import '../../config/strings.dart';

class BuyNowPage extends StatelessWidget {
  final Widget child;
  final AnimationController animationController;

  const BuyNowPage({
    Key? key,
    required this.child,
    required this.animationController,
  }) : super(key: key);

  // Function to launch URL
  Future<void> _launchURL(String url) async {
    final Uri uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      throw 'Could not launch $url';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        child, // Your actual page content
     isDemo ?   Positioned(
          top: 400.h,
          right: 30.w,
          child: AvatarGlow(
            glowRadiusFactor: 0.5,

            glowCount: 2,
            duration: Duration(milliseconds: 1500),
            repeat: true,
            glowColor: Colors.white.withValues(alpha: 0.4),
            child: Material(
              elevation: 10.0,
              shape: CircleBorder(),
              child: GestureDetector(
                onTap: () {
                  _launchURL('https://codecanyon.net/item/taskify-flutter-app-project-management-task-manager-and-productivity-tool/57033235'); // Replace with your URL
                },
                child: Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      colors: [Colors.blue, Colors.purple],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                  child: CircleAvatar(
                    backgroundColor: Colors.transparent,
                    child: const Icon(
                      Icons.shopping_cart,
                      size: 20,
                      color: Colors.white,
                    ),
                    radius: 20.0,
                  ),
                ),
              ),
            ),
          ),
        ):SizedBox.shrink(),
      ],
    );
  }
}
