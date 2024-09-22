import 'dart:async';

import 'package:beamer/beamer.dart';
import 'package:custom_sliding_segmented_control/custom_sliding_segmented_control.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:frontend/models/bracket.dart';
import 'package:frontend/models/participant.dart';
import 'package:frontend/models/tournament.dart';
import 'package:frontend/tokenmanager.dart';
import 'package:frontend/widgets/brackets_display.dart';
import 'package:frontend/widgets/menu_area.dart';
import 'package:frontend/widgets/player_list.dart';
import 'package:frontend/widgets/title_text.dart';

enum Pages { Players, Brackets }

class TournamentPage extends StatelessWidget {
  const TournamentPage({super.key, required this.tournament, required this.brackets, required this.players});

  final Tournament tournament;
  final List<List<Bracket>> brackets;
  final List<Participant> players;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: MenuArea(
          title: TitleText(tournament.name),
          actions: [
            ElevatedButton(
                onPressed: () {
                  Beamer.of(context).beamToNamed(
                      "/tournament/${tournament.id}/signup",
                      replaceRouteInformation: true);
                },
                child: Text("Sign up"))
          ],
          homeButton: true,
          child: Container(
            height: 400,
            child: Builder(
              builder: (context) {
                return Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Center(
                    child: BracketsDisplay(
                      tournamentId: tournament.id,
                      brackets: brackets,
                      players: players,
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}
