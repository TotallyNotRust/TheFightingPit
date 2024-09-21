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

class TournamentPage extends StatefulWidget {
  TournamentPage({super.key, required this.tournamentId});

  final Completer<Tournament> tournament = Completer();
  final Completer<List<List<Bracket>>> brackets = Completer();
  final Completer<List<Participant>> players = Completer();
  final int tournamentId;

  Pages page = Pages.Brackets;

  @override
  State<TournamentPage> createState() => _TournamentPageState();
}

class _TournamentPageState extends State<TournamentPage> {
  void formatBracketsFromMap(List<Map<String, dynamic>> data) async {
    List<List<Bracket>> brackets = [];

    Map<String, dynamic> initial_raw =
        data.firstWhere((element) => element["next_match_id"] == null);
    data.remove(initial_raw);

    Bracket initial = Bracket.fromMap(initial_raw);

    brackets.add([initial]);

    List<int> idsForNextRound = [initial.id];
    List lastRound = [];
    while (data.isNotEmpty) {
      print("LOOP");
      if (lastRound == data) {
        throw Exception("Loop detected during bracket creation");
      }
      lastRound = data;
      List<Bracket> currentRound = [];
      List<int> idsForThisRound = idsForNextRound;
      idsForNextRound = [];
      for (Map<String, dynamic> curr in data) {
        if (idsForThisRound.contains(curr["next_match_id"])) {
          currentRound.add(Bracket.fromMap(curr));
          idsForNextRound.add(curr["id"]);
        }
      }
      brackets.add(currentRound);
      for (Bracket bracket in currentRound) {
        data.removeWhere((val) => val["id"] == bracket.id);
      }
    }

    widget.brackets.complete(brackets);
  }

  @override
  void initState() {
    super.initState();

    TokenManager.dio
        .get("/tournament/get/${widget.tournamentId}")
        .then((value) {
      if (value.data == null) return;
      return widget.tournament.complete(Tournament.fromRocket(value.data));
    });

    TokenManager.dio
        .get("/tournament/get/${widget.tournamentId}/brackets")
        .then((value) {
      if (value.data == null) return;
      print("🐻‍❄️ ${value.realUri.toString()} \r\n ${value.data}");

      formatBracketsFromMap(List<Map<String, dynamic>>.from(value.data));
    });
    TokenManager.dio
        .get("/tournament/get/${widget.tournamentId}/players")
        .then((value) {
      if (value.data == null) return;
      if (value.data!.isEmpty) return widget.players.complete([]);

      print("🐻‍❄️ ${value.data}");

      List<Participant> playersList = [];
      for (List<dynamic> player in value.data!) {
        playersList.add(Participant.fromRocket(player));
      }
      widget.players.complete(playersList);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: MenuArea(
          middle: CustomSlidingSegmentedControl(
            children: const {
              Pages.Brackets: Text("Brackets"),
              Pages.Players: Text("Players"),
            },
            onValueChanged: (value) {
              setState(() {
                widget.page = value;
              });
            },
          ),
          title: FutureBuilder(
            future: widget.tournament.future,
            builder: (context, snapshot) {
              if (snapshot.hasData) return TitleText(snapshot.data!.name);
              return const SizedBox();
            },
          ),
          actions: [
            ElevatedButton(
                onPressed: () {
                  Beamer.of(context)
                      .beamToNamed("/tournament/${widget.tournamentId}/signup");
                },
                child: Text("Sign up"))
          ],
          homeButton: true,
          child: Container(
            height: 400,
            child: FutureBuilder(
              future: widget.tournament.future,
              builder: (context, state) {
                if (!state.hasData)
                  return SpinKitCubeGrid(
                    color: Colors.black,
                  );
                if (widget.page == Pages.Brackets) {
                  return Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Center(
                      child: BracketsDisplay(
                        tournamentId: widget.tournamentId,
                        brackets: widget.brackets,
                        players: widget.players,
                      ),
                    ),
                  );
                } else if (widget.page == Pages.Players) {
                  return Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Center(
                      child: PlayerList(
                        players: widget.players,
                      ),
                    ),
                  );
                }
                return SizedBox();
              },
            ),
          ),
        ),
      ),
    );
  }
}
