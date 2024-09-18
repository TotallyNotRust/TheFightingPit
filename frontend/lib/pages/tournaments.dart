import 'dart:async';
import 'dart:convert';

import 'package:beamer/beamer.dart';
import 'package:crypto/crypto.dart';
import 'package:custom_sliding_segmented_control/custom_sliding_segmented_control.dart';
import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:frontend/models/tournament.dart';
import 'package:frontend/pages/login.dart';
import 'package:frontend/pages/signup.dart';
import 'package:frontend/tokenmanager.dart';
import 'package:frontend/widgets/menu_area.dart';
import 'package:frontend/widgets/title_text.dart';
import 'package:frontend/widgets/tournament_list_element.dart';

class TournamentsPage extends StatefulWidget {
  const TournamentsPage({super.key});

  @override
  State<TournamentsPage> createState() => _TournamentsPageState();
}

class _TournamentsPageState extends State<TournamentsPage> {
  int page = 1;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: MenuArea(
            title: TitleText("Tournaments"),
            homeButton: true,
            actions: [
              ElevatedButton(
                child: Text("New"),
                onPressed: () {
                  Beamer.of(context).beamToNamed("/new-tournament");
                },
              )
            ],
            child: Column(
              children: [
                Padding(
                  padding: EdgeInsets.all(8.0),
                  child: FutureBuilder(
                      future: TokenManager.dio
                          .get("http://localhost:8000/tournament/list"),
                      builder: (context, data) {
                        if (!data.hasData)
                          return SpinKitWanderingCubes(
                            color: Colors.white,
                          );
                        final List<dynamic> body = data.data!.data;
                        return SizedBox(
                          height: 200,
                          child: Scrollbar(
                            thumbVisibility: true,
                            child: ListView.builder(
                              itemCount: body.length,
                              itemBuilder: (context, i) {
                                return Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: TournamentListElement(tournament: Tournament.fromRocket(body[i])),
                                );
                              },
                            ),
                          ),
                        );
                      }),
                )
              ],
            )),
      ),
    );
  }
}
