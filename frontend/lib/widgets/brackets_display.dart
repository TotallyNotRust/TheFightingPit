import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:frontend/models/bracket.dart';
import 'package:frontend/models/participant.dart';
import 'package:frontend/models/user.dart';
import 'package:frontend/tokenmanager.dart';

class BracketsDisplay extends StatefulWidget {
  const BracketsDisplay(
      {super.key,
      required this.tournamentId,
      required this.brackets,
      required this.players});

  final Completer<List<List<Bracket>>> brackets;
  final Completer<List<Participant>> players;
  final int tournamentId;

  @override
  State<BracketsDisplay> createState() => _BracketsDisplayState();
}

class _BracketsDisplayState extends State<BracketsDisplay> {
  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: Future.wait([
        widget.brackets.future,
        widget.players.future,
      ]),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const SpinKitCubeGrid(
            size: 20,
            color: Colors.black,
          );
        }
        List<List<Bracket>> brackets = snapshot.data![0] as List<List<Bracket>>;
        List<Participant> players = snapshot.data![1] as List<Participant>;
        return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            for (List<Bracket> brackets in brackets.reversed)
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  for (Bracket bracket in brackets)
                    BracketDisplay(bracket: bracket)
                ],
              )
          ],
        );
      },
    );
  }
}

class BracketDisplay extends StatelessWidget {
  const BracketDisplay({super.key, required this.bracket});

  final Bracket bracket;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
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
                        ? Text(bracket.player1_id.toString())
                        : const Text("TBD"),
                    const Divider(),
                    bracket.player2_id != null
                        ? Text(bracket.player2_id.toString())
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
    );
  }
}
