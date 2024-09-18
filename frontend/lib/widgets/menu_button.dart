import 'package:flutter/cupertino.dart';

class MenuButton extends StatelessWidget {
  const MenuButton({super.key, required this.child, required this.onPressed});

  final Widget child;
  final void Function() onPressed;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width * 0.4,
      child: CupertinoButton.filled(
        child: child, 
        onPressed: onPressed
      ),
    );
  }
}