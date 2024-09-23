import 'package:dio/dio.dart';
import 'package:frontend/models/bracket.dart';
import 'package:frontend/models/participant.dart';
import 'package:frontend/models/referee.dart';
import 'package:frontend/models/tournament.dart';
import 'package:frontend/models/tournament_permissions.dart';

class Formatter {
  static Future<Tournament> formatTournamentFromResponse(
      Future<Response> response) async {
    var data = (await response).data;

    print("FINISHING TOURNAMENT");
    return Tournament.fromRocket(data);
  }

  static Future<List<Participant>> formatParticipantsFromResponse(
      Future<Response<dynamic>> response) async {
    var data = (await response).data;

    List<Participant> participants = [];

    for (dynamic participant in data) {
      participants.add(Participant.fromRocket(participant));
    }
    print("FINISHING PARTICIPANTS");
    return participants;
  }

  static Future<List<Referee>> formatRefereesFromResponse(
      Future<Response<dynamic>> response) async {
    var data = (await response).data;

    List<Referee> referees = [];

    for (dynamic referee in data) {
      referees.add(Referee.fromRocket(referee));
    }
    print("FINISHING REFEREES");

    return referees;
  }

  static Future<List<List<Bracket>>> formatBracketsFromResponse(
      Future<Response<dynamic>> response) async {
    List<List<Bracket>> brackets = [];

    var data = (await response).data;

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
    print("FINISHING BRACKETS");
    return brackets;
  }

  static Future<TournamentPermissions> formatTournamentPermissionsFromResponse(Future<Response> response) async {
    var resp = (await response).data;
    print("GOT RESPONSE FOR PERMS");
    TournamentPermissions perms = TournamentPermissions.fromMap(resp);
    print("FINISHING PERMS");
    return perms;
  }
}
