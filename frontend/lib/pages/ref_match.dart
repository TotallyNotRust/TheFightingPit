import 'package:beamer/beamer.dart';
import 'package:flutter/material.dart';
import 'package:frontend/models/bracket.dart';
import 'package:frontend/models/participant.dart';
import 'package:frontend/models/user.dart';
import 'package:frontend/tokenmanager.dart';
import 'package:frontend/widgets/menu_area.dart';
import 'package:frontend/widgets/title_text.dart';

class RefMatchPage extends StatefulWidget {
  const RefMatchPage({super.key, required this.bracket, required this.players, required this.tournamentId});

  final Bracket bracket;
  final List<Participant> players;
  final int tournamentId;

  @override
  State<RefMatchPage> createState() => _RefMatchPageState();
}

class _RefMatchPageState extends State<RefMatchPage> {
  late int score_1;
  late int score_2;

  String player1_name = "TBD";
  String player2_name = "TBD";

  @override
  void initState() {
    super.initState();

    score_1 = widget.bracket.score_1;
    score_2 = widget.bracket.score_2;

    for (Participant participant in widget.players) {
      if (participant.id == widget.bracket.player1_id) {
        player1_name = participant.user.username;
      }
      if (participant.id == widget.bracket.player2_id) {
        player2_name = participant.user.username;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: MenuArea(
          title: TitleText("$player1_name VS $player2_name"),
          backButton: true,
          child: Container(
            height: 200,
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                children: [
                  Row(
                    children: [
                      SizedBox( width: 200, child: Text("$player1_name: ", style: TextStyle(fontSize: 32))),
                      Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.all(Radius.circular(8.0)),
                          color: Colors.grey.shade100,
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(
                            score_1.toString(),
                            style: TextStyle(fontSize: 32),
                          ),
                        ),
                      ),
                      IconButton(
                        onPressed: () {
                          setState(() {
                            score_1 += 1;
                          });
                        },
                        icon: Icon(Icons.add),
                      ),
                      IconButton(
                        onPressed: () {
                          setState(() {
                            if (score_1 > 0) {
                              score_1 -= 1;
                            }
                          });
                        },
                        icon: Icon(Icons.remove),
                      )
                    ],
                  ),
                  Divider(),
                  Row(
                    children: [
                      SizedBox(width: 200, child: Text("$player2_name: ", style: TextStyle(fontSize: 32))),
                      Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.all(Radius.circular(8.0)),
                          color: Colors.grey.shade100,
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(
                            score_2.toString(),
                            style: TextStyle(fontSize: 32),
                          ),
                        ),
                      ),
                      IconButton(
                        onPressed: () {
                          setState(() {
                            score_2 += 1;
                          });
                        },
                        icon: Icon(Icons.add),
                      ),
                      IconButton(
                        onPressed: () {
                          setState(() {
                            if (score_1 > 0) {
                              score_2 -= 1;
                            }
                          });
                        },
                        icon: Icon(Icons.remove),
                      )
                    ],
                  ),
                  ElevatedButton(onPressed: () async {
                    await TokenManager.dio.post("/tournament/${widget.tournamentId}/brackets/${widget.bracket.id}/updatescore", data: {
                      "score_1": score_1,
                      "score_2": score_2,
                      "final_score": true,
                    });
                    Beamer.of(context).beamBack();
                  }, child: Text("Submit score"))
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
