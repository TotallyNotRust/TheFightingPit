import 'package:beamer/beamer.dart';
import 'package:flutter/material.dart';
import 'package:frontend/pages/homescreen.dart';
import 'package:frontend/pages/login.dart';
import 'package:frontend/tokenmanager.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  MyApp({super.key});

  final routerDelegate = BeamerDelegate(
    guards: [
      // Valid token guard; Locks users without a token out of the app.
      BeamGuard(
        pathPatterns: ['/profile'],
        // guardNonMatching: true, // This essentially just mean any route not in pathPatters will be matched here.
        check: (context, location) => TokenManager.tokenIsValid,
        beamToNamed: (origin, target) => '/login',
      )
    ],
    // ignore: implicit_call_tearoffs
    locationBuilder: RoutesLocationBuilder(
      routes: {
        // Return either Widgets or BeamPages if more customization is needed
        '/': (context, state, data) => const HomeScreen(),
        '/login': (context, state, data) => const LoginPage(),
        // '/books/:bookId': (context, state, data) {
        //   // Take the path parameter of interest from BeamState
        //   final bookId = state.pathParameters['bookId']!;
        //   // Collect arbitrary data that persists throughout navigation
        //   final info = (data as MyObject).info;
        //   // Use BeamPage to define custom behavior
        //   return BeamPage(
        //     key: ValueKey('book-$bookId'),
        //     title: 'A Book #$bookId',
        //     popToNamed: '/',
        //     type: BeamPageType.scaleTransition,
        //     child: BookDetailsScreen(bookId, info),
        //   );
        // }
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
    return MaterialApp.router(
      routeInformationParser: BeamerParser(),
      routerDelegate: routerDelegate,
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.white).copyWith(
          background: const Color.fromARGB(255, 238, 229, 211)
        )
      ),
    );
  }
}

