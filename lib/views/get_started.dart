import 'package:avatar_glow/avatar_glow.dart';
import 'package:cs530_mobile/controllers/fbm.dart';
import 'package:cs530_mobile/anims/animation.dart';
import 'package:cs530_mobile/views/home.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

/// Class defines a view for users without a firebase id to create one
class GetStarted extends StatefulWidget {
  const GetStarted({Key? key}) : super(key: key);

  @override
  _GetStartedState createState() => _GetStartedState();
}

/// Private class for GetStarted state
class _GetStartedState extends State<GetStarted> with TickerProviderStateMixin {

  // initState
  @override
  void initState() {
    // Set anim controller
    _bc = AnimationController(
      duration: const Duration(seconds: 7),
      vsync: this,
    )..repeat();
    ba = CurvedAnimation(parent: _bc, curve: Curves.easeIn);
    super.initState();
  }

  // Animation vars
  late Animation<double> ba;
  late AnimationController _bc;
  // Firebase Auth instance
  final FirebaseAuth _auth = FirebaseAuth.instance;
  // Get current User
  var _user = FirebaseAuth.instance.currentUser;

  // build method for GetStarted
  @override
  Widget build(BuildContext context) {
    double _w = MediaQuery.of(context).size.width;
    double _h = MediaQuery.of(context).size.height;
    const color = Colors.white;
    return 
    // Condition to check if user is null then return Get Started Else route to home
    _user == null
        ? Scaffold(
            body: Container(
            width: _w,
            height: _h,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: aT.evaluate(ba),
                end: aB.evaluate(ba),
                colors: [
                  darkBackground.evaluate(ba)!,
                  normalBackground.evaluate(ba)!,
                  lightBackground.evaluate(ba)!,
                ],
              ),
            ),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
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
                          child: Lottie.asset('assets/subscriber.json',
                              repeat: true,
                              reverse: true,
                              animate: true,
                              height: 150,
                              width: 150),
                          radius: 50.0,
                        )),
                  ),
                  const Center(
                    child: Text(
                      "Hello!",
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 35.0,
                          color: color),
                    ),
                  ),
                  const Center(
                    child: Text(
                      "Welcome to Voluntary Spam",
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 25.0,
                          color: color),
                    ),
                  ),
                  const SizedBox(
                    height: 30.0,
                  ),
                  const Center(
                    child: Text(
                      "We noticed",
                      style: TextStyle(fontSize: 20.0, color: color),
                    ),
                  ),
                  const Center(
                    child: Text(
                      "It is your first time here",
                      style: TextStyle(fontSize: 20.0, color: color),
                    ),
                  ),
                  const SizedBox(
                    height: 100.0,
                  ),
                  const SizedBox(
                    height: 50.0,
                  ),
                  Center(
                      child: TextButton(
                    onPressed: () {
                      // call method to create a firebase account
                      _signInAnonymously();
                    },
                    child: Text(
                      "Get Started".toUpperCase(),
                      style: const TextStyle(
                          fontSize: 20.0,
                          fontWeight: FontWeight.bold,
                          decoration: TextDecoration.underline,
                          color: color),
                    ),
                  )),
                ],
              ),
            ),
          ))
        :
        // route to home screen if logged in user is not null 
        const HomeScreen();
  }

  // overriding dispose to dispose anim controller
  @override
  void dispose() {
    _bc.dispose();
    super.dispose();
  }

  // private method to create anonymous firebase account
  void _signInAnonymously() {
    _auth.signInAnonymously().then((result) {
      // Update user state to route to homeScreen
      setState(() {
        _user = result.user;
      });
      // subscribe to "Uncat" always which is the topic used by web app to send notifications
      FCM fbm = FCM();
      fbm.subscribeTopic("Uncat");
    });
  }
}
