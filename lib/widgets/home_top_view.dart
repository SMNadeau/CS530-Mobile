import 'package:avatar_glow/avatar_glow.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

/// Class defines Home Screen Top View Widget 
class HomeTopViewWidget extends StatelessWidget {
  const HomeTopViewWidget({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      // color: Colors.transparent,
      decoration: const BoxDecoration(        
          image: DecorationImage(
              image: AssetImage("assets/bg.jpg"), fit: BoxFit.fill)),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          AvatarGlow(
            endRadius: 90,
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
                radius: 50.0,
                child: Lottie.asset('assets/subscriber.json',
                    repeat: true,
                    reverse: true,
                    animate: true,
                    height: 120,
                    width: 120),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
