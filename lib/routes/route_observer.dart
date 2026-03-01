import 'package:flutter/material.dart';


class PathObserver extends NavigatorObserver {
  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    // Access the route's name (usually set in GoRoute or CupertinoPageRoute)
    print('Pushed route: ${route.settings.name}');
    if (route.settings.name != null && route.settings.name!.contains('/clientdetails/')) {
    }
    // If the route has extra data (e.g., parameters from GoRoute), you can print that too
    if (route.settings.arguments != null) {
      print('Route arguments: ${route.settings.arguments}');
    }
  }

  @override
  void didPop(Route<dynamic> route, Route<dynamic>? previousRoute) {
    // Access the route's name when it's popped
    print('Popped route: ${route.settings.name}');
    if (route.settings.arguments != null) {
    }
    // Check if the route's settings contain parameters from GoRouter
    if (route.settings.name != null && route.settings.name!.contains('/clientdetails/')) {
    }
  }
}


