import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'screens/splash_page.dart';
import 'theme/app_theme.dart';
import 'widgets/cursor_follower.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
    ),
  );
  runApp(const DiapalerApp());
}

class DiapalerApp extends StatelessWidget {
  const DiapalerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'DIAPALER AFRICA',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light().copyWith(
        pageTransitionsTheme: const PageTransitionsTheme(
          builders: {
            TargetPlatform.android: _FadeThroughBuilder(),
            TargetPlatform.iOS: _FadeThroughBuilder(),
            TargetPlatform.windows: _FadeThroughBuilder(),
            TargetPlatform.macOS: _FadeThroughBuilder(),
            TargetPlatform.linux: _FadeThroughBuilder(),
          },
        ),
      ),
      builder: (context, child) =>
          CursorFollower(child: child ?? const SizedBox()),
      home: const SplashPage(),
    );
  }
}

class _FadeThroughBuilder extends PageTransitionsBuilder {
  const _FadeThroughBuilder();

  @override
  Widget buildTransitions<T>(
    PageRoute<T> route,
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    return FadeTransition(
      opacity: animation,
      child: SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(0, 0.025),
          end: Offset.zero,
        ).animate(CurvedAnimation(
            parent: animation, curve: Curves.easeOutCubic)),
        child: child,
      ),
    );
  }
}
