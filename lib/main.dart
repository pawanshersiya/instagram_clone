// lib/main.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'screens/splash_screen.dart';
import 'services/post_repository.dart';
import 'providers/feed_provider.dart';

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (_) => FeedNotifier(PostRepository()),
      child: const InstagramApp(),
    ),
  );
}

class InstagramApp extends StatelessWidget {
  const InstagramApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Instagram',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: Colors.black,
        colorScheme: const ColorScheme.dark(
          primary: Color(0xFF0095F6),
          background: Colors.black,
        ),
      ),
      builder: (context, child) {
        final mediaQuery = MediaQuery.of(context);
        // Lock text scale so typography and spacing stay pixel-perfect
        return MediaQuery(
          data: mediaQuery.copyWith(
            textScaler: const TextScaler.linear(1.0),
          ),
          child: child ?? const SizedBox.shrink(),
        );
      },
      home: const SplashScreen(),
    );
  }
}
