import 'package:auto_size_text/auto_size_text.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';

class IssuesScreen extends StatefulWidget {
  IssuesScreen({Key? key, required this.issues, required this.school})
      : super(key: key);
  final Map issues;
  final String school;

  @override
  State<IssuesScreen> createState() => _IssuesScreenState();
}

class _IssuesScreenState extends State<IssuesScreen> {
  final fbDB = FirebaseDatabase.instance;

  @override
  Widget build(BuildContext context) {
    Size mqs = MediaQuery.of(context).size;
    final ref = fbDB.reference();

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Column(
          children: [
            AutoSizeText(widget.school),
            AutoSizeText(
              "Issues",
              style: TextStyle(
                fontSize: 10,
              ),
            ),
          ],
        ),
      ),
      body: ListView(
          children: widget.issues.keys
              .map(
                (e) => Container(
                  height: mqs.height * 0.155,
                  width: double.infinity,
                  margin: EdgeInsets.all(8),
                  padding: EdgeInsets.all(8),
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      color: Colors.white,
                      boxShadow: kElevationToShadow[1]),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          FutureBuilder(
                              future: ref
                                  .child('users/${e.split(' ')[0]}/name')
                                  .get(),
                              builder: (fctx, snap) {
                                if (snap.hasData) {
                                  final data = snap.data as DataSnapshot;
                                  return AutoSizeText("Name: " + data.value);
                                }
                                return Container(
                                    width: 100,
                                    child: LinearProgressIndicator());
                              }),
                          AutoSizeText(e.split(' ')[1]),
                        ],
                      ),
                      AutoSizeText("Subject: " + widget.issues[e]['subject']),
                      Divider(
                        height: 10,
                      ),
                      Container(
                        height: mqs.height * 0.051,
                        child: AutoSizeText(
                          widget.issues[e]['issue'],
                          maxLines: 3,
                        ),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          TextButton(
                            onPressed: () async {
                              await ref
                                  .child('schools/${widget.school}/issues/$e')
                                  .update({'status': 'ignore'});
                              setState(() {
                                widget.issues.remove(e);
                              });
                            },
                            child: Text("Ignore"),
                          ),
                          TextButton(
                            onPressed: () async {
                              await ref
                                  .child('schools/${widget.school}/issues/$e')
                                  .update({'status': 'resolved'});
                              setState(() {
                                widget.issues.remove(e);
                              });
                            },
                            child: Text(
                              "Resolved",
                              style: TextStyle(color: Colors.green),
                            ),
                          )
                        ],
                      )
                    ],
                  ),
                ),
              )
              .toList()),
    );
  }
}
