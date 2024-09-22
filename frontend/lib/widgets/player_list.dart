import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:frontend/models/participant.dart';
import 'package:frontend/models/user.dart';

class PlayerList extends StatelessWidget {
  const PlayerList({super.key, required this.players});

  final List<Participant> players;

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: players.length,
      itemBuilder: (context, index) {
        return Container(
          child: Row(
            children: [
              Text(players[index].user.username),
            ],
          ),
        );
      },
    );
  }
}
