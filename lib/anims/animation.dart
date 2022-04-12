import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

// Animation definitions for GetStarted background

AlignmentTween aT =
    AlignmentTween(begin: Alignment.topRight, end: Alignment.topLeft);
AlignmentTween aB =
    AlignmentTween(begin: Alignment.bottomRight, end: Alignment.bottomLeft);

Animatable<Color?> darkBackground = TweenSequence<Color?>(
  [
    TweenSequenceItem(
      weight: .5,
      tween: ColorTween(
        begin: Colors.deepPurple.withOpacity(.8),
        end: Colors.deepPurple.withOpacity(.8),
      ),
    ),
    TweenSequenceItem(
      weight: .5,
      tween: ColorTween(
        begin: Colors.deepPurple.withOpacity(.8),
        end: Colors.deepPurple.withOpacity(.8),
      ),
    ),
  ],
);

Animatable<Color?> normalBackground = TweenSequence<Color?>(
  [
    TweenSequenceItem(
      weight: .5,
      tween: ColorTween(
        begin: Colors.deepPurple.withOpacity(.6),
        end: Colors.deepPurple.withOpacity(.6),
      ),
    ),
    TweenSequenceItem(
      weight: .5,
      tween: ColorTween(
        begin: Colors.deepPurple.withOpacity(.6),
        end: Colors.deepPurple.withOpacity(.6),
      ),
    ),
  ],
);

Animatable<Color?> lightBackground = TweenSequence<Color?>(
  [
    TweenSequenceItem(
      weight: .5,
      tween: ColorTween(
        begin: Colors.deepPurple.withOpacity(.4),
        end: Colors.indigo.withOpacity(.4),
      ),
    ),
    TweenSequenceItem(
      weight: .5,
      tween: ColorTween(
        begin: Colors.indigo.withOpacity(.4),
        end: Colors.deepPurple.withOpacity(.4),
      ),
    ),
  ],
);
