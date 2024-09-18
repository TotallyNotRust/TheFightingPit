import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class MyAppBar extends StatelessWidget implements PreferredSizeWidget {
  const MyAppBar({super.key, required this.title, required this.actions});

  final Widget title;
  final List<Widget> actions;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            offset: Offset(3, 3),
            color: Colors.black.withOpacity(0.2),
            spreadRadius: 6,
            blurRadius: 10,
          ),
        ]
      ),
      child: AppBar(
        backgroundColor: Theme.of(context).colorScheme.primary,
        title: title as Text,
        actions: actions,
        centerTitle: true,
      ),
    );
  }
  
  @override
  Size get preferredSize => AppBar().preferredSize;
}