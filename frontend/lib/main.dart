import 'dart:convert';

import 'package:beamer/beamer.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:frontend/models/bracket.dart';
import 'package:frontend/models/participant.dart';
import 'package:frontend/models/tournament.dart';
import 'package:frontend/pages/homescreen.dart';
import 'package:frontend/pages/login_signin.dart';
import 'package:frontend/pages/newtournament.dart';
import 'package:frontend/pages/profile.dart';
import 'package:frontend/pages/tournament.dart';
import 'package:frontend/pages/tournaments.dart';
import 'package:frontend/pages/tournamentsignup.dart';
import 'package:frontend/tokenmanager.dart';

void main() async {
  await dotenv.load();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  MyApp({super.key});

  final routerDelegate = BeamerDelegate(
    guards: [
      // Valid token guard; Locks users without a token out of the app.
      BeamGuard(
        pathPatterns: [
          '/profile',
          '/new-tournament',
          "/tournaments",
          RegExp("/tournament/.*/signup")
        ],
        // guardNonMatching: true, // This essentially just mean any route not in pathPatters will be matched here.
        check: (context, location) => TokenManager.tokenIsValid,

        beamToNamed: (origin, target) {
          final converted =
              target.state.routeInformation.uri.path.replaceAll("/", "-");

          return '/login?origin=$converted';
        },
      )
    ],
    // ignore: implicit_call_tearoffs
    locationBuilder: RoutesLocationBuilder(
      routes: {
        // Return either Widgets or BeamPages if more customization is needed
        '/': (context, state, data) => const HomeScreen(),
        '/tournaments': (context, state, data) => TournamentsPage(),
        '/new-tournament': (context, state, data) => const NewTournamentPage(),
        '/login': (context, state, data) {
          final origin = state.queryParameters['origin']!;
          return LoginSignupPage(origin: origin);
        },
        '/tournament/:id': (context, state, data) {
          final id = int.parse(state.pathParameters['id']!);

          return BeamPage(
            key: ValueKey("tournament_page_$id\_" + DateTime.now().microsecondsSinceEpoch.toString()),
            child: FutureBuilder(
              key: ValueKey(DateTime.now().microsecondsSinceEpoch.toString() + "SWAG"),
                future: Future.wait([
                  formatTournamentFromResponse(TokenManager.dio.get("/tournament/get/$id")),
                  formatBracketsFromResponse(TokenManager.dio.get("/tournament/get/$id/brackets")),
                  formatParticipantsFromResponse(TokenManager.dio.get("/tournament/get/$id/players")),
                ]),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) return SizedBox();
                  return TournamentPage(
                      tournament: snapshot.data![0] as Tournament,
                      brackets: snapshot.data![1] as List<List<Bracket>>,
                      players: snapshot.data![2] as List<Participant>);
                }),
          );
        },
        '/tournament/:id/signup': (context, state, data) {
          final id = int.parse(state.pathParameters['id']!);

          return BeamPage(key: ValueKey("tournament-signup-page"),child: TournamentSignupPage(tournamentId: id));
        },
        '/profile': (context, state, data) => ProfilePage(),
      },
    ),
  );

  @override
  Widget build(BuildContext context) {
    // return MaterialApp(
    //   title: 'The Fighting Pit',
    //   theme: ThemeData(
    //     colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
    //     useMaterial3: true,
    //   ),
    //   routes: {
    //     "/login": (context) => const MyHomePage(title: 'The Fighting Pit'),
    //   }
    // );
    WidgetsFlutterBinding.ensureInitialized();
    TokenManager.initialize();
    dotenv.load();

    return MaterialApp.router(
      routeInformationParser: BeamerParser(),
      routerDelegate: routerDelegate,
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(
                  seedColor: const Color.fromARGB(255, 15, 42, 28))
              .copyWith(
            background: const Color.fromARGB(255, 238, 229, 211),
          ),
          useMaterial3: true),
    );
  }
}

Future<Tournament> formatTournamentFromResponse(Future<Response> response) async {
  var data = (await response).data;

  return Tournament.fromRocket(data);
}

Future<List<Participant>> formatParticipantsFromResponse(Future<Response<dynamic>> response) async {
  var data = (await response).data;

  List<Participant> participants = [];

  for (dynamic participant in data) {
    participants.add(Participant.fromRocket(participant));
  }
  return participants;
}

Future<List<List<Bracket>>> formatBracketsFromResponse(Future<Response<dynamic>> response) async {
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

  return brackets;
}

