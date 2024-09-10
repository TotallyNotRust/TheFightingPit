import 'dart:convert';

import 'package:beamer/beamer.dart';
import 'package:crypto/crypto.dart';
import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:frontend/tokenmanager.dart';

class SignupPage extends StatefulWidget {
  const SignupPage({super.key});

  @override
  State<SignupPage> createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {

  TextEditingController email = TextEditingController();
  TextEditingController username = TextEditingController();
  TextEditingController password = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          backgroundColor: Theme.of(context).colorScheme.inversePrimary,
          title: Text("Signup"),
          centerTitle: true,
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              CupertinoTextField(
                  controller: email,
                  placeholder: "Email"
              ),
              CupertinoTextField(
                  controller: email,
                  placeholder: "Username"
              ),
              CupertinoTextField(
                  controller: password,
                  placeholder: "Password",
                  obscureText: true,
              ),
              CupertinoButton(child: Text("Signup"), onPressed: () async {
                  var passdigest = sha256.convert(utf8.encode(password.text));
                  var passhash = passdigest.toString();
                  var response = await Dio().post("http://localhost:8000/account/login", data: {
                    "email": email.text,
                    "username": username.text,
                    "password": passhash
                  });
                  TokenManager.token = response.data;
                  print(TokenManager.token);
                  Beamer.of(context).beamToNamed('/home');
              })
            ],
          ),
        ));
  }
}
