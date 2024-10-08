import 'dart:async';

import 'package:beamer/beamer.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:frontend/models/bracket.dart';
import 'package:frontend/models/participant.dart';
import 'package:frontend/models/tournament_permissions.dart';
import 'package:frontend/models/user.dart';
import 'package:frontend/tokenmanager.dart';

class BracketsDisplay extends StatefulWidget {
  const BracketsDisplay(
      {super.key,
      required this.tournamentId,
      required this.brackets,
      required this.players,
      required this.permissions});

  final List<List<Bracket>> brackets;
  final List<Participant> players;
  final int tournamentId;
  final TournamentPermissions permissions;

  @override
  State<BracketsDisplay> createState() => _BracketsDisplayState();
}

class _BracketsDisplayState extends State<BracketsDisplay> {
  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        for (List<Bracket> brackets in widget.brackets.reversed)
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              for (Bracket bracket in brackets)
                BracketDisplay(
                  bracket: bracket,
                  players: widget.players,
                  permissions: widget.permissions,
                )
            ],
          )
      ],
    );
  }
}

class BracketDisplay extends StatelessWidget {
  const BracketDisplay(
      {super.key,
      required this.bracket,
      required this.players,
      required this.permissions});

  final Bracket bracket;
  final List<Participant> players;
  final TournamentPermissions permissions;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: GestureDetector(
        onTap: () {
          if (permissions.isReferee) {
            Beamer.of(context).beamToNamed(
              "/tournament/${bracket.tournament_id}/matches/${bracket.id}",
            );
          }
        },
        child: Container(
          decoration: BoxDecoration(
              color: Colors.grey.shade200,
              borderRadius: const BorderRadius.all(Radius.circular(8.0))),
          height: 80,
          width: 150,
          child: Row(
            children: [
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      bracket.player1_id != null
                          ? Text(players
                              .firstWhere(
                                  (element) => element.id == bracket.player1_id)
                              .user
                              .username)
                          : const Text("TBD"),
                      const Divider(),
                      bracket.player2_id != null
                          ? Text(players
                              .firstWhere(
                                  (element) => element.id == bracket.player2_id)
                              .user
                              .username)
                          : const Text("TBD"),
                    ],
                  ),
                ),
              ),
              Container(
                width: 30,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: const BorderRadius.only(
                      topRight: Radius.circular(8.0),
                      bottomRight: Radius.circular(8.0)),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Text(bracket.score_1.toString()),
                      const Divider(color: Colors.transparent),
                      Text(bracket.score_2.toString()),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
