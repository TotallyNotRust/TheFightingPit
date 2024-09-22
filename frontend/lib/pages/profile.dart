import 'dart:async';

import 'package:beamer/beamer.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:frontend/models/user.dart';
import 'package:frontend/tokenmanager.dart';
import 'package:frontend/widgets/menu_area.dart';

class ProfilePage extends StatefulWidget {
  ProfilePage({super.key});

  final Completer<User> user = Completer();

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {

  @override
  void initState() {
    super.initState();

    TokenManager.dio.get("/account/user").then((value) {
      widget.user.complete(User.fromMap(value.data));
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: MenuArea(
          homeButton: true,
          child: FutureBuilder(
            future: widget.user.future,
            builder: (context, player) {
              if (!player.hasData) {
                return const SpinKitCubeGrid(
                  size: 20,
                  color: Colors.black,
                );
              }

              return Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  children: [
                    const Text("Username"),
                    const SizedBox(height: 10),
                    CupertinoTextField(
                      controller: TextEditingController()
                        ..text = player.data!.username,
                        readOnly: true,
                    ),
                    const SizedBox(height: 10),
                    const Text("Email"),
                    const SizedBox(height: 10),
                    CupertinoTextField(
                      controller: TextEditingController()
                        ..text = player.data!.email!,
                      readOnly: true,
                    ),
                    const SizedBox(height: 30),
                    ElevatedButton(
                      onPressed: () {
                        TokenManager.token = null;
                        Beamer.of(context).beamToNamed("/");
                      },
                      child: const Text("Sign out"),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
