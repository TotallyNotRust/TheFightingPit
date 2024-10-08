import 'package:beamer/beamer.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:frontend/models/tournament.dart';
import 'package:frontend/tokenmanager.dart';
import 'package:intl/intl.dart';

class TournamentListElement extends StatelessWidget {
  const TournamentListElement({super.key, required this.tournament});

  final Tournament tournament;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 8.0),
      child: Container(
        height: 50,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8.0),
          color: Colors.grey.shade100,
        ),
        child: Row(
          children: [
            const SizedBox(width: 8),
            const Icon(Icons.sports),
            const SizedBox(width: 8),
            Text(tournament.name, style: TextStyle(fontWeight: FontWeight.bold),),
            const Expanded(child: SizedBox()),
            Text(DateFormat("dd-MM-yyyy hh:mm:ss").format(tournament.date)),
            const SizedBox(width: 8.0,),
            IconButton(onPressed: () {
              Clipboard.setData(ClipboardData(text: "${TokenManager.dio.options.baseUrl}/tournament/${tournament.id}"));
            }, icon: const Icon(Icons.share)),
            IconButton(onPressed: () {
              Beamer.of(context).beamToNamed("/tournament/${tournament.id}");
            }, icon: const Icon(Icons.edit)),
            const SizedBox(width: 8.0)
          ],
        ),
      ),
    );
  }
}
