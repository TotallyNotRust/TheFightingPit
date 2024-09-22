import 'package:beamer/beamer.dart';
import 'package:flutter/material.dart';
import 'package:frontend/tokenmanager.dart';
import 'package:frontend/widgets/menu_area.dart';

class TournamentSignupPage extends StatefulWidget {
  const TournamentSignupPage({super.key, required this.tournamentId});

  final int tournamentId;

  @override
  State<TournamentSignupPage> createState() => _TournamentSignupPageState();
}

class _TournamentSignupPageState extends State<TournamentSignupPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: MenuArea(
          child: SizedBox(
            height: 150,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Text(
                  "Are you sure you want to sign up?",
                  style: TextStyle(fontSize: 25),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ElevatedButton(
                      onPressed: () async {
                        // Sign up user.
                        await TokenManager.dio.post("/tournament/${widget.tournamentId}/signup");

                        Beamer.of(context)
                            .beamToNamed("/tournament/${widget.tournamentId}");
                      },
                      child: const Text("Confirm"),
                    ),
                    ElevatedButton(
                      style: ButtonStyle(
                        foregroundColor: MaterialStateProperty.all(Colors.red),
                      ),
                      onPressed: () {
                        Beamer.of(context)
                            .beamToNamed("/tournament/${widget.tournamentId}");
                      },
                      child: const Text(
                        "Cancel",
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
