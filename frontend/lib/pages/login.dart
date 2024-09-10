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
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {

  TextEditingController email = TextEditingController();
  TextEditingController password = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          backgroundColor: Theme.of(context).colorScheme.inversePrimary,
          title: Text("Login"),
          centerTitle: true,
        ),
        body: Center(
          child: MenuArea(
            child: Column(
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
                    var response = await Dio().post("http://localhost:8000/account/login", data: {
                      "email": email.text,
                      "password": passhash
                    });
                    TokenManager.token = response.data;
                    print(TokenManager.token);
                    Beamer.of(context).beamToNamed('/');
                })
              ],
            ),
          ),
        ));
  }
}
