import 'dart:convert';

import 'package:beamer/beamer.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:frontend/formatting.dart';
import 'package:frontend/models/bracket.dart';
import 'package:frontend/models/participant.dart';
import 'package:frontend/models/referee.dart';
import 'package:frontend/models/tournament.dart';
import 'package:frontend/models/tournament_permissions.dart';
import 'package:frontend/pages/homescreen.dart';
import 'package:frontend/pages/login_signin.dart';
import 'package:frontend/pages/newtournament.dart';
import 'package:frontend/pages/profile.dart';
import 'package:frontend/pages/ref_match.dart';
import 'package:frontend/pages/tournament.dart';
import 'package:frontend/pages/tournament_settings.dart';
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
          RegExp("/tournament/.*/signup"),
          RegExp("/tournament/.*/settings")
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
            key: ValueKey(
                "tournament_page_${id}_${DateTime.now().microsecondsSinceEpoch}"),
            child: FutureBuilder(
                future: Future.wait([
                  Formatter.formatTournamentFromResponse(
                    TokenManager.dio.get("/tournament/$id"),
                  ),
                  Formatter.formatBracketsFromResponse(
                    TokenManager.dio.get("/tournament/$id/brackets"),
                  ),
                  Formatter.formatParticipantsFromResponse(
                    TokenManager.dio.get("/tournament/$id/players"),
                  ),
                  TokenManager.tokenIsValid
                      ? Formatter.formatTournamentPermissionsFromResponse(
                          TokenManager.dio.get("/tournament/$id/permissions"),
                        )
                      : Future(() => TournamentPermissions.none())
                ]),
                builder: (context, snapshot) {
                  if (!snapshot.hasData)
                    return Scaffold(
                      body: Text("SWAG"),
                    );
                  return TournamentPage(
                      tournament: snapshot.data![0] as Tournament,
                      brackets: snapshot.data![1] as List<List<Bracket>>,
                      players: snapshot.data![2] as List<Participant>,
                      permissions: snapshot.data![3] as TournamentPermissions);
                }),
          );
        },
        '/tournament/:id/signup': (context, state, data) {
          final id = int.parse(state.pathParameters['id']!);

          return BeamPage(
              key: ValueKey("tournament-signup-page"),
              child: TournamentSignupPage(tournamentId: id));
        },
        '/tournament/:id/settings': (context, state, data) {
          final id = int.parse(state.pathParameters['id']!);

          return BeamPage(
            key: ValueKey(
                "tournament_settings_page_${id}_${DateTime.now().microsecondsSinceEpoch}"),
            child: FutureBuilder(
                future: Future.wait([
                  Formatter.formatRefereesFromResponse(
                      TokenManager.dio.get("/tournament/$id/referee")),
                ]),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) return SizedBox();
                  return TournamentSettingsPage(
                    referees: snapshot.data![0],
                    tournamentId: id,
                  );
                }),
          );
        },
        '/tournament/:id/matches/:bracket_id': (context, state, data) {
          final id = int.parse(state.pathParameters['id']!);
          final bracket_id = int.parse(state.pathParameters['bracket_id']!);

          return BeamPage(
            key: ValueKey(
                "tournament_settings_page_${id}_${DateTime.now().microsecondsSinceEpoch}"),
            child: FutureBuilder(
                future: Future.wait([
                  Formatter.formatBracketFromResponse(
                    TokenManager.dio.get("/tournament/$id/bracket/$bracket_id"),
                  ),
                  Formatter.formatParticipantsFromResponse(
                    TokenManager.dio.get("/tournament/$id/players"),
                  ),
                ]),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) return SizedBox();
                  return RefMatchPage(
                    bracket: snapshot.data![0] as Bracket,
                    players: snapshot.data![1] as List<Participant>,
                    tournamentId: id,
                  );
                }),
          );
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
