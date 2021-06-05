import 'package:auto_size_text/auto_size_text.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';

class AdminScreen extends StatefulWidget {
  const AdminScreen({Key? key}) : super(key: key);

  @override
  _AdminScreenState createState() => _AdminScreenState();
}

class _AdminScreenState extends State<AdminScreen> {
  final fbDB = FirebaseDatabase.instance;
  final fbAuth = FirebaseAuth.instance;
  Map snap = {}, notVerifiedStudents = {}, notVerifiedGovt = {};
  bool _isLoading = false;

  bool showStudents = true;
  @override
  void didChangeDependencies() async {
    super.didChangeDependencies();
    setState(() {
      _isLoading = true;
    });
    final res = await fbDB.reference().child('users').once();
    snap = res.value;
    notVerifiedStudents = getNotVerifiedUsers('Student');
    notVerifiedGovt = getNotVerifiedUsers('Govt Official');
    print(notVerifiedStudents);
    setState(() {
      _isLoading = false;
    });
  }

  Map getNotVerifiedUsers(String userType) {
    Map result = {};
    snap.forEach((key, value) {
      if (value['userType'] == userType && value['status'] == 'created') {
        result[key] = value;
      }
    });

    return result;
  }

  Future updateStatus(String userKey, String status, bool isStudent) async {
    await FirebaseDatabase.instance
        .reference()
        .child('users/$userKey/status')
        .set(status);
    if (isStudent)
      notVerifiedStudents.remove(userKey);
    else
      notVerifiedGovt.remove(userKey);
    setState(() {});
  }

  Future<void> refresh() async {
    final res = await fbDB.reference().child('users').once();
    snap = res.value;
  }

  @override
  Widget build(BuildContext context) {
    final mqs = MediaQuery.of(context).size;
    return Container(
      color: Colors.white,
      child: _isLoading
          ? Center(
              child: CircularProgressIndicator(),
            )
          : SafeArea(
              child: Scaffold(
                body: Column(
                  children: [
                    Container(
                      padding: EdgeInsets.fromLTRB(20, 20, 20, 0),
                      child: Row(
                        children: [
                          Text(
                            "Admin",
                            style: TextStyle(
                              fontSize: 40,
                            ),
                          ),
                          Spacer(),
                          IconButton(
                            onPressed: () {
                              fbAuth.signOut();
                            },
                            icon: Icon(Icons.logout),
                          ),
                        ],
                      ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        TextButton(
                          onPressed: () {
                            setState(() {
                              showStudents = true;
                            });
                          },
                          child: AutoSizeText(
                            "Students",
                            style: TextStyle(
                                fontSize: 20,
                                color: showStudents ? null : Colors.black),
                          ),
                        ),
                        TextButton(
                          onPressed: () {
                            setState(() {
                              showStudents = false;
                            });
                          },
                          child: AutoSizeText(
                            "Govt. Officials",
                            style: TextStyle(
                                fontSize: 20,
                                color: !showStudents ? null : Colors.black),
                          ),
                        ),
                      ],
                    ),
                    if (showStudents)
                      Expanded(
                        child: Container(
                          margin: EdgeInsets.all(mqs.width * 0.04),
                          //color: Colors.red,
                          child: ListView.builder(
                            itemCount: notVerifiedStudents.length,
                            itemBuilder: (context, index) {
                              return UserVerification(
                                userKey:
                                    notVerifiedStudents.keys.toList()[index],
                                users: notVerifiedStudents,
                                isStudent: true,
                                updateStatus: updateStatus,
                              );
                            },
                          ),
                        ),
                      ),
                    if (!showStudents)
                      Expanded(
                        child: Container(
                          margin: EdgeInsets.all(mqs.width * 0.04),
                          //color: Colors.red,
                          child: ListView.builder(
                            itemCount: notVerifiedGovt.length,
                            itemBuilder: (context, index) {
                              return UserVerification(
                                userKey: notVerifiedGovt.keys.toList()[index],
                                users: notVerifiedGovt,
                                isStudent: false,
                                updateStatus: updateStatus,
                              );
                            },
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
    );
  }
}

class UserVerification extends StatelessWidget {
  const UserVerification({
    Key? key,
    required this.userKey,
    required this.users,
    required this.isStudent,
    required this.updateStatus,
  }) : super(key: key);
  final Map users;
  final String userKey;
  final bool isStudent;
  final Function updateStatus;

  @override
  Widget build(BuildContext context) {
    final mqs = MediaQuery.of(context).size;
    return Container(
      padding: EdgeInsets.only(
        top: mqs.width * 0.04,
        left: mqs.width * 0.04,
        right: mqs.width * 0.04,
      ),
      decoration: BoxDecoration(
          color: Colors.grey[200],
          boxShadow: kElevationToShadow[1],
          borderRadius: BorderRadius.circular(mqs.width * 0.04)),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              AutoSizeText(isStudent ? "Student Name" : "Govt. Official Name"),
              AutoSizeText(users[userKey]['name']),
            ],
          ),
          Divider(),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              AutoSizeText(
                  isStudent ? "Student Email" : "Govt. Official Email"),
              AutoSizeText(users[userKey]['email']),
            ],
          ),
          Divider(),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              AutoSizeText(isStudent ? "School" : "Official Id"),
              AutoSizeText(isStudent
                  ? users[userKey]['school']
                  : users[userKey]['officialId']),
            ],
          ),
          if (!isStudent) Divider(),
          if (!isStudent)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                AutoSizeText("Location"),
                AutoSizeText(users[userKey]['location']),
              ],
            ),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton(
                  onPressed: () async {
                    updateStatus(userKey, "verified", isStudent);
                  },
                  child: AutoSizeText(
                    "Accept",
                    style: TextStyle(color: Colors.green),
                  )),
              TextButton(
                  onPressed: () async {
                    updateStatus(userKey, "rejected", isStudent);
                  },
                  child: AutoSizeText("Reject",
                      style: TextStyle(color: Colors.red))),
            ],
          )
        ],
      ),
    );
  }
}
