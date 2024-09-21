import 'dart:convert';

import 'package:beamer/beamer.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:frontend/pages/homescreen.dart';
import 'package:frontend/pages/login_signin.dart';
import 'package:frontend/pages/newtournament.dart';
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
        pathPatterns: ['/profile', '/new-tournament', "/tournaments", RegExp("/tournament/.*/signup")],
        // guardNonMatching: true, // This essentially just mean any route not in pathPatters will be matched here.
        check: (context, location) => TokenManager.tokenIsValid,
    
        beamToNamed: (origin, target) {
          final converted = target.state.routeInformation.uri.path.replaceAll("/", "-");
          
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

          return TournamentPage(tournamentId: id);
        },
        '/tournament/:id/signup': (context, state, data) {
          final id = int.parse(state.pathParameters['id']!);

          return TournamentSignupPage(tournamentId: id);
        },
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
        useMaterial3: true
      ),
    );
  }
}

