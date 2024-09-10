import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class MenuArea extends StatelessWidget {
  MenuArea({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    var width = MediaQuery.of(context).size.width * 0.7;

    return Padding(
      padding: EdgeInsets.all(8.0),
      child: ClipRRect(
        borderRadius: BorderRadius.all(Radius.circular(8.0)),
        child: Container(
          width: width > 200 ? width : 200,
          color: Colors.white,
          child: Padding(
              padding: EdgeInsets.all(8.0),
              child: child
            )
        ),
      ),
    );
  }
}