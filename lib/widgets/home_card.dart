import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lottie/lottie.dart';

/// Class defines Home Screen Menu Card Widget 
class HomeCardWidget extends StatelessWidget {
  final String assetName, name;
  const HomeCardWidget({
    Key? key,
    required this.assetName,
    required this.name,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: const BorderRadius.vertical(top: Radius.circular(40), bottom: Radius.circular(40)),  
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
        child: Card(
          margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(40),),
          color: Colors.white.withOpacity(0.4),
          elevation: 10,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Lottie.asset(
                'assets/' + assetName + '.json',
                repeat: true,
                reverse: true,
                animate: true,
                height: 120,
                width: 120,
              ),
              Text(
                name,
                style: GoogleFonts.robotoCondensed(
                  color: Colors.white,
                  fontSize: 15,
                  fontWeight: FontWeight.w400,                  
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
