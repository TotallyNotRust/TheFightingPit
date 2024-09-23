// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

import 'package:beamer/beamer.dart';
import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:frontend/formatting.dart';

import 'package:frontend/models/referee.dart';
import 'package:frontend/tokenmanager.dart';
import 'package:frontend/widgets/menu_area.dart';
import 'package:frontend/widgets/title_text.dart';

class TournamentSettingsPage extends StatefulWidget {
  const TournamentSettingsPage(
      {super.key, required this.tournamentId, required this.referees});
  final int tournamentId;
  final List<Referee> referees;
  @override
  State<TournamentSettingsPage> createState() => _TournamentSettingsPageState();
}

class _TournamentSettingsPageState extends State<TournamentSettingsPage> {
  late List<Referee> referees;

  @override
  void initState() {
    super.initState();

    referees = widget.referees;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: MenuArea(
          title: const TitleText("Settings"),
          backButton: true,
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    children: [
                      Text("Referees"),
                      const Expanded(child: SizedBox()),
                      ElevatedButton(
                          onPressed: () async {
                            List<String>? refereeEmails =
                                await showAddRefereesPopup(context);
                            if (refereeEmails != null) {
                              await TokenManager.dio.post(
                                "/tournament/${widget.tournamentId}/referee",
                                options:
                                    Options(contentType: "application/json"),
                                data: refereeEmails,
                              );
                              referees = await Formatter
                                  .formatRefereesFromResponse(TokenManager.dio.get(
                                      "/tournament/${widget.tournamentId}/referee"));
                              setState(() {});
                            }
                          },
                          child: Text("Add")),
                    ],
                  ),
                ),
                SizedBox(
                  height: 200,
                  child: ListView.builder(
                      itemCount: referees.length,
                      itemBuilder: (context, index) {
                        return Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Container(
                            height: 60,
                            width: 200,
                            decoration: BoxDecoration(
                                color: Colors.grey.shade100,
                                borderRadius:
                                    BorderRadius.all(Radius.circular(8.0))),
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Row(
                                children: [
                                  Text(referees[index].user.username),
                                  Expanded(child: SizedBox()),
                                  IconButton(
                                    onPressed: () async {
                                      await TokenManager.dio.delete(
                                          "/tournament/${widget.tournamentId}/referee/${referees[index].id}");
                                      referees = await Formatter
                                          .formatRefereesFromResponse(
                                              TokenManager.dio.get(
                                                  "/tournament/${widget.tournamentId}/referee"));
                                      setState(() {});
                                    },
                                    icon: const Icon(
                                      Icons.delete,
                                      color: Colors.red,
                                    ),
                                  )
                                ],
                              ),
                            ),
                          ),
                        );
                      }),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<List<String>?> showAddRefereesPopup(BuildContext context) async {
    return showDialog<List<String>>(
        context: context,
        builder: (context) {
          TextEditingController controller = TextEditingController();
          return SimpleDialog(
            title: Text("Add referees"),
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: SizedBox(
                  width: 200,
                  child: CupertinoTextField(
                    controller: controller,
                    placeholder:
                        "Enter emails seperated by commas: 'email@domain.com,email2@domain.com'",
                  ),
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  ElevatedButton(
                      onPressed: () {
                        if (!RegExp(
                                r"^([\w\-\.]+@([\w-]+\.)+[\w\-]{2,4},)*([\w\-\.]+@([\w-]+\.)+[\w\-]{2,4})$")
                            .hasMatch(controller.text)) {
                          showAlertPopup("Invalid input", context);
                        }
                        Navigator.pop(context, controller.text.split(","));
                      },
                      child: Text("Submit")),
                  ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      child: Text("Cancel"))
                ],
              ),
            ],
          );
        });
  }

  void showAlertPopup(String s, BuildContext context) async {
    await showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: const Text("Alert"),
            content: Text(s),
            actions: [
              ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: const Text("OK"))
            ],
          );
        });
  }
}
