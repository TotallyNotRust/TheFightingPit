import 'dart:convert';

import 'package:beamer/beamer.dart';
import 'package:crypto/crypto.dart';
import 'package:custom_sliding_segmented_control/custom_sliding_segmented_control.dart';
import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:frontend/pages/login.dart';
import 'package:frontend/pages/signup.dart';
import 'package:frontend/tokenmanager.dart';
import 'package:frontend/widgets/menu_area.dart';
import 'package:frontend/widgets/title_text.dart';

class LoginSignupPage extends StatefulWidget {
  LoginSignupPage({super.key, required this.origin});

  final String? origin;

  @override
  State<LoginSignupPage> createState() => _LoginSignupPageState();
}

class _LoginSignupPageState extends State<LoginSignupPage> {
  int page = 1;

  @override
  Widget build(BuildContext context) {
    
    return Scaffold(
      body: Center(
        child: MenuArea(
          homeButton: true,
          middle: CustomSlidingSegmentedControl(
            children: const {1: Text("Login"), 2: Text("Signup")},
            decoration: BoxDecoration(
              color: CupertinoColors.lightBackgroundGray,
              borderRadius: BorderRadius.circular(8),
            ),
            thumbDecoration: BoxDecoration(
              borderRadius: BorderRadius.all(Radius.circular(8)),
              color: Colors.white,
            ),
            onValueChanged: (page) {
              setState(() {
                this.page = page;
              });
            },
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 8),
              if (page == 1) SizedBox(height: 200, child: LoginPage(origin: widget.origin)),
              if (page == 2) SizedBox(height: 200, child: SignupPage(origin: widget.origin)),
            ],
          ),
        ),
      ),
    );
  }
}
