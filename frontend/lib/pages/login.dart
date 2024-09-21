import 'dart:convert';

import 'package:beamer/beamer.dart';
import 'package:crypto/crypto.dart';
import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:frontend/tokenmanager.dart';
import 'package:frontend/widgets/menu_area.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key, required this.origin});

  final String? origin;

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {

  TextEditingController email = TextEditingController();
  TextEditingController password = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return  Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        SizedBox(
          width: 300,
          child: CupertinoTextField(
              controller: email,
              placeholder: "Email"
          ),
        ),
        SizedBox(
          width: 300,
          child: CupertinoTextField(
              controller: password,
              placeholder: "Password",
              obscureText: true,
          ),
        ),
        CupertinoButton(child: Text("Login"), onPressed: () async {
            var passdigest = sha256.convert(utf8.encode(password.text));
            var passhash = passdigest.toString();
            var response = await TokenManager.dio.post("/account/login", data: {
              "email": email.text,
              "password": passhash
            });
            TokenManager.token = response.data;
            print(response.data);
            if (widget.origin != null) {
              Beamer.of(context).beamToNamed((widget.origin ?? "/").replaceAll("-", "/"));
            } else {  
              Beamer.of(context).beamBack();
            }
        })
      ],
    );
  }
}
