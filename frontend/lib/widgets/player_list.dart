import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:frontend/models/participant.dart';
import 'package:frontend/models/user.dart';

class PlayerList extends StatelessWidget {
  const PlayerList({super.key, required this.players});

  final Completer<List<Participant>> players;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: players.future,
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const SpinKitCubeGrid(
              size: 20,
              color: Colors.black,
            );
          }
          return ListView.builder(
              itemCount: snapshot.data!.length,
              itemBuilder: (context, index) {
                return Container(
                  child: Row(
                    children: [
                      Text(snapshot.data![index].user.username),
                    ],
                  ),
                );
              });
        });
  }
}
