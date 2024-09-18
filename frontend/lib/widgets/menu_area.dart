import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:frontend/widgets/beam_back_button.dart';
import 'package:frontend/widgets/beam_home_button.dart';

class MenuArea extends StatelessWidget {
  MenuArea({super.key, required this.child, this.homeButton = false, this.middle, this.actions, this.title, this.backButton = false});

  final Widget child;
  final bool homeButton;
  final bool backButton;
  final Widget? title;
  final Widget? middle; 
  final List<Widget>? actions;


  @override
  Widget build(BuildContext context) {
    var width = MediaQuery.of(context).size.width * 0.7;

    return Padding(
      padding: EdgeInsets.all(8.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (title != null) title!,
          Container(
            decoration: BoxDecoration(boxShadow: [
              BoxShadow(
                offset: Offset(0, 3),
                color: Colors.black.withOpacity(0.2),
                spreadRadius: 6,
                blurRadius: 10,
              ),
            ]),
            child: ClipRRect(
              borderRadius: BorderRadius.all(Radius.circular(8.0)),
              child: Container(
                width: width > 200 ? width : 200,
                color: Colors.white,
                child: Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Stack(
                        alignment: Alignment.center,
                        children: [
                          if (homeButton) const Positioned(child: BeamHomeButton()),
                          if (backButton) const Positioned(child: BeamBackButton()),
                          if (middle != null) Positioned(child: middle!),
                          if (actions != null) Positioned(child: Row(children: actions!,), right: 0,)
                        ],
                      ),
                      child
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
