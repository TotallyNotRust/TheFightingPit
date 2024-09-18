import 'dart:convert';

import 'package:beamer/beamer.dart';
import 'package:crypto/crypto.dart';
import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:frontend/tokenmanager.dart';

class SignupPage extends StatefulWidget {
  const SignupPage({super.key, required this.origin});

  final String? origin;

  @override
  State<SignupPage> createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {

  TextEditingController email = TextEditingController();
  TextEditingController username = TextEditingController();
  TextEditingController password = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Column(
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
                  controller: username,
                  placeholder: "Username"
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
            CupertinoButton(child: Text("Signup"), onPressed: () async {
                var passdigest = sha256.convert(utf8.encode(password.text));
                var passhash = passdigest.toString();
                var response = await TokenManager.dio.post("http://localhost:8000/account/new", data: {
                  "email": email.text,
                  "username": username.text,
                  "password": passhash
                });
                TokenManager.token = response.data;
                print(TokenManager.token);
                
                Beamer.of(context).beamBack();
            })
          ],
        );
  }
}
