import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'firebase_options.dart';
import 'screens/page_demarrage.dart';
import 'theme/theme_app.dart';
import 'widgets/curseur_suiveur.dart';

/// Future global qu'on initialise dès le démarrage de l'app, mais sans
/// bloquer `runApp`. Le splash l'attend pendant qu'il joue son animation
/// — ça masque tout le délai d'init Firebase derrière le splash.
final Future<FirebaseApp> firebaseReady = Firebase.initializeApp(
  options: DefaultFirebaseOptions.currentPlatform,
);

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
