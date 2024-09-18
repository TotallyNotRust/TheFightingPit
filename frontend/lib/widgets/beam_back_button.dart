import 'package:beamer/beamer.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class BeamBackButton extends StatelessWidget {
  const BeamBackButton({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        IconButton(onPressed: () {Beamer.of(context).beamBack();}, icon: Icon(Icons.chevron_left))
      ],
    );
  }
}