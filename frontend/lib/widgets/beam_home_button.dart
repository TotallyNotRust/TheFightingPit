import 'package:beamer/beamer.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class BeamHomeButton extends StatelessWidget {
  const BeamHomeButton({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        IconButton(
          onPressed: () {
            Beamer.of(context).beamToNamed("/");
          }, 
          icon: const Icon(Icons.home)
        )
      ],
    );
  }
}