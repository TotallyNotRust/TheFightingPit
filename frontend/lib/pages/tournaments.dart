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
  TournamentsPage({super.key});

  final ScrollController scrollController = ScrollController();

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
                      future: TokenManager.dio.get("/tournament/list"),
                      builder: (context, snapshot) {
                        if (!snapshot.hasData) {
                          return const SpinKitCubeGrid(
                            size: 20,
                            color: Colors.black,
                          );
                        }
                        final List<dynamic> body = snapshot.data!.data;
                        return SizedBox(
                          height: 200,
                          child: Scrollbar(
                            controller: widget.scrollController,
                            thumbVisibility: true,
                            child: ListView.builder(
                              controller: widget.scrollController,
                              itemCount: body.length,
                              itemBuilder: (context, i) {
                                return Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: TournamentListElement(
                                      tournament:
                                          Tournament.fromRocket(body[i])),
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

class MyWidget extends StatefulWidget {
  const MyWidget({super.key});

  @override
  State<MyWidget> createState() => _MyWidgetState();
}

class _MyWidgetState extends State<MyWidget> {
  int count = 0;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Text("$count"),
          IconButton(
            onPressed: () {
              setState(() {
                count++;
              });
            },
            icon: Icon(Icons.plus_one),
          )
        ],
      ),
    );
  }
}
