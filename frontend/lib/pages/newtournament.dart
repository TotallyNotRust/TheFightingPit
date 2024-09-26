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
  int? slots;
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
              // SizedBox(
              //   width: 300,
              //   child: CupertinoTextField(
              //     controller: slots,
              //     placeholder: "Slots",
              //     keyboardType: TextInputType.number,
              //   ),
              // ),
              SizedBox(
                width: 300,
                child: DropdownButton<int>(
                  value: slots,
                  items: const [
                    DropdownMenuItem(
                      value: 32,
                      child: Text("32 Player"),
                    ),
                    DropdownMenuItem(
                      value: 4,
                      child: Text("4 Player"),
                    )
                  ],
                  onChanged: (int? value) {
                    setState(() {slots = value;});
                  },
                ),
              ),
              SizedBox(
                width: 300,
                child: CupertinoTextField(
                  controller: datetime,
                  placeholder: "Date & Time",
                  readOnly: true,
                  onTap: () async {
                    DateTime? date = await showDatePicker(
                      context: context,
                      firstDate: DateTime.now(),
                      lastDate: DateTime.parse("9999-12-31"),
                    );

                    if (date != null) {
                      TimeOfDay? time = await showTimePicker(
                        context: context,
                        initialTime: TimeOfDay(hour: 12, minute: 0),
                          builder: (BuildContext context, Widget? child) {
                          return MediaQuery(
                            data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: true),
                            child: child ?? const SizedBox(),
                          );
                        },
                      );

                      if (time == null) return;

                      date = DateTime(date.year, date.month, date.day, time.hour, time.minute);

                      datetime.text = DateFormat("E MMM d y HH:mm").format(date);
                      setState(() {
                        datetime_raw = date;
                      });
                    }
                  },
                ),
              ),
              CupertinoButton(
                  child: Text("Create"),
                  onPressed: () async {
                    await TokenManager.dio
                        .post("/tournament/new", data: {
                      "name": name.text,
                      "slots": slots,
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
