import 'package:beamer/beamer.dart';
import 'package:crypto/crypto.dart';
import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:frontend/tokenmanager.dart';
import 'package:frontend/widgets/menu_area.dart';
import 'package:frontend/widgets/title_text.dart';
import 'package:intl/intl.dart';

class NewTournamentPage extends StatefulWidget {
  const NewTournamentPage({super.key});

  @override
  State<NewTournamentPage> createState() => _NewTournamentPageState();
}

class _NewTournamentPageState extends State<NewTournamentPage> {
  TextEditingController name = TextEditingController();
  TextEditingController slots = TextEditingController();
  TextEditingController datetime = TextEditingController();
  DateTime? datetime_raw;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Center(
      child: MenuArea(
        title: TitleText("New tournament"),
        backButton: true,
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              SizedBox(
                width: 300,
                child:
                    CupertinoTextField(controller: name, placeholder: "Name"),
              ),
              SizedBox(
                width: 300,
                child: CupertinoTextField(
                  controller: slots,
                  placeholder: "Slots",
                  keyboardType: TextInputType.number,
                ),
              ),
              SizedBox(
                width: 300,
                child: CupertinoTextField(
                  controller: datetime,
                  placeholder: "Date & Time",
                  readOnly: true,
                  onTap: () async {
                    DateTime? time = await showDatePicker(
                      context: context,
                      firstDate: DateTime.now(), 
                      lastDate: DateTime.parse("9999-12-31"),
                    );
                    if (time != null) {
                      datetime.text = DateFormat("E MMM d y").format(time);
                      setState(() {
                        datetime_raw = time;
                      });
                    }
                  },

                ),
              ),
              CupertinoButton(
                  child: Text("Create"),
                  onPressed: () async {

                    var response = await TokenManager.dio
                        .post("http://localhost:8000/tournament/new", data: {
                      "name": name.text,
                      "slots": int.parse(slots.text),
                      "start_datetime": datetime_raw?.toIso8601String(),
                    });
                    
                    Beamer.of(context).beamBack();
                  })
            ],
          ),
        ),
      ),
    ));
  }
}
