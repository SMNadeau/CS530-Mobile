import 'dart:async';

import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:avatar_glow/avatar_glow.dart';
import 'package:cs530_mobile/views/get_started.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lottie/lottie.dart';

/// Class defines a view for Splash Screen
class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

/// Private Class for Splash Screen State
class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    // Make app it portrait only
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    Timer(
        const Duration(seconds: 4),
        () => Navigator.of(context).pushReplacement(
                MaterialPageRoute(builder: (BuildContext context) {
              return const GetStarted();
            })));
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
          image: DecorationImage(
              image: AssetImage("assets/bg.jpg"), fit: BoxFit.fill)),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              AvatarGlow(
                endRadius: 130,
                duration: const Duration(seconds: 2),
                glowColor: Colors.white24,
                repeat: true,
                repeatPauseDuration: const Duration(seconds: 2),
                startDelay: const Duration(seconds: 1),
                child: Material(
                  elevation: 8.0,
                  shape: const CircleBorder(),
                  child: CircleAvatar(
                    backgroundColor: Colors.grey[100],
                    radius: 90.0,
                    child: Lottie.asset(
                      'assets/subscriber.json',
                      repeat: true,
                      reverse: true,
                      animate: true,
                    ),
                  ),
                ),
              ),
              const SizedBox(
                height: 45,
              ),
              FittedBox(
                fit: BoxFit.contain,
                child: Padding(
                  padding: const EdgeInsets.only(left: 60.0),
                  child: AnimatedTextKit(
                    animatedTexts: [
                      TypewriterAnimatedText(
                        'VOLUNTARY SPAM APP',
                        textStyle: GoogleFonts.roboto(
                          color: Colors.white,
                          fontSize: 44,
                          fontWeight: FontWeight.w600,
                        ),
                        textAlign: TextAlign.center,
                        speed: const Duration(milliseconds: 50),
                      ),
                    ],
                    totalRepeatCount: 1,
                    displayFullTextOnTap: true,
                    stopPauseOnTap: true,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
