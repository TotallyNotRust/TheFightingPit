import 'package:beamer/beamer.dart';
import 'package:flutter/material.dart';
import 'package:frontend/widgets/menu_area.dart';
import 'package:frontend/widgets/menu_button.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  TextEditingController email = TextEditingController();
  TextEditingController password = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Center(
          child: MenuArea(
            title: Image.asset("tfp_logo.png", height: 300,),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                const SizedBox(height: 8),
                MenuButton(child: const Text("Tournaments"), onPressed: () {
                  Beamer.of(context).beamToNamed("/tournaments");
                }),
                const SizedBox(height: 8),
                MenuButton(child: const Text("Profile"), onPressed: () {
                  Beamer.of(context).beamToNamed("/profile");
                }),
                const SizedBox(height: 8),
              ],
            ),
          ),
        ));
  }
}
