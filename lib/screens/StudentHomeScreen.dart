import 'dart:io';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:date_time_format/date_time_format.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:meal_survey/screens/MealChart.dart';
import 'package:meal_survey/screens/ReportScreen.dart';
import '../widgets/MenuButton.dart';
import 'package:timer_builder/timer_builder.dart';
import 'package:image_picker/image_picker.dart';

import 'package:flutter/material.dart';
import '../Services/studentService.dart';

class StudentHomeScreen extends StatefulWidget {
  const StudentHomeScreen({Key? key}) : super(key: key);

  @override
  _StudentHomeScreenState createState() => _StudentHomeScreenState();
}

class _StudentHomeScreenState extends State<StudentHomeScreen> {
  String name = '';
  final fbDB = FirebaseDatabase.instance;
  final fbAuth = FirebaseAuth.instance;
  bool _isLoading = false;
  String status = 'created';
  bool imagePicked = false;
  String school = '';

  String downloadUrl = '';

  bool uploadingImage = false;
  List<String> todayMenu = [];
  DateTime today = DateTime.now();
  Map<String, bool> selected = {};

  @override
  void didChangeDependencies() async {
    super.didChangeDependencies();
    setState(() {
      _isLoading = true;
    });
    final snap =
        await fbDB.reference().child("users/${fbAuth.currentUser!.uid}").once();
    name = snap.value['name'];
    school = snap.value['school'];
    status = snap.value['status'];
    today = DateTime.now();
    todayMenu = StudentServices.weekScheduleList[today.weekday - 1].split(", ");

    for (int i = 0; i < todayMenu.length; i++) {
      selected[todayMenu[i]] = false;
    }
    setState(() {
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final ref = fbDB.reference();

    final month = DateTimeFormat.format(today, format: "M"),
        date = DateTimeFormat.format(today, format: "d");
    final mqs = MediaQuery.of(context).size;

    return _isLoading
        ? Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          )
        : Container(
            color: Theme.of(context).primaryColor,
            child: SafeArea(
              child: Scaffold(
                drawer: Drawer(
                  child: ListView(
                    children: [
                      DrawerHeader(
                        child: Container(
                          alignment: Alignment.center,
                          child: Text(
                            "Mid Day Meal",
                            style: TextStyle(color: Colors.white, fontSize: 28),
                          ),
                        ),
                        decoration: BoxDecoration(
                            color: Theme.of(context).primaryColor),
                      ),
                      ListTile(
                        onTap: () {
                          Navigator.of(context).push(
                              MaterialPageRoute(builder: (ctx) => MealChart()));
                        },
                        leading: Icon(Icons.fastfood),
                        title: Text("Menu"),
                      ),
                      ListTile(
                        onTap: () {
                          Navigator.of(context).push(MaterialPageRoute(
                              builder: (ctx) => ReportScreen(school: school)));
                        },
                        leading: Icon(Icons.error_outline),
                        title: Text("Report"),
                      ),
                    ],
                  ),
                ),
                appBar: AppBar(
                  elevation: 0.0,
                  centerTitle: true,
                  brightness: Brightness.light,
                  //backgroundColor: Colors.white,
                  title: AutoSizeText(
                    "Home",
                    style: TextStyle(
                      fontSize: 30,
                    ),
                  ),
                  actions: [
                    Container(
                      margin: EdgeInsets.only(bottom: 5),
                      child: IconButton(
                        alignment: Alignment.bottomRight,
                        onPressed: () {
                          fbAuth.signOut();
                        },
                        icon: Icon(
                          Icons.logout,
                          //color: Colors.black,
                        ),
                      ),
                    ),
                  ],
                ),
                body: status == 'created'
                    ? NotVerified(
                        fbAuth: fbAuth,
                        name: name,
                      )
                    : status == 'rejected'
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                AutoSizeText(
                                    "Your request has been rejected by the Admin"),
                                TextButton(
                                  onPressed: () {
                                    fbAuth.signOut();
                                  },
                                  child: Text("Go back"),
                                )
                              ],
                            ),
                          )
                        : ListView(
                            children: [
                              Container(
                                padding: EdgeInsets.only(top: 10),
                                child: Column(
                                  children: [
                                    Container(
                                      width: 100,
                                      height: 100,
                                      decoration: BoxDecoration(
                                        image: DecorationImage(
                                            image: NetworkImage(
                                              "https://image.shutterstock.com/image-vector/social-member-vector-icon-person-260nw-1139787308.jpg",
                                            ),
                                            fit: BoxFit.cover,
                                            alignment: Alignment(1, -1)),
                                        shape: BoxShape.circle,
                                        color: Theme.of(context).primaryColor,
                                      ),
                                    ),
                                    SizedBox(
                                      height: 10,
                                    ),
                                    Text("Hello"),
                                    Text(
                                      name,
                                      style: TextStyle(fontSize: 30),
                                    ),
                                    TimerBuilder.periodic(Duration(days: 1),
                                        builder: (ctx) {
                                      return Container(
                                        decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(20),
                                          color: Theme.of(context)
                                              .primaryColorLight,
                                        ),
                                        padding: EdgeInsets.all(10),
                                        margin: EdgeInsets.all(20),
                                        height: mqs.height * 0.2,
                                        width: double.infinity,
                                        child: Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceEvenly,
                                          children: [
                                            TimerBuilder.periodic(
                                                Duration(seconds: 1),
                                                builder: (ctx2) {
                                              return AutoSizeText(
                                                DateTimeFormat.format(
                                                    DateTime.now(),
                                                    format: "H:i:s A"),
                                                textAlign: TextAlign.center,
                                                presetFontSizes: [60, 45, 30],
                                                style: TextStyle(
                                                  color: Theme.of(context)
                                                      .primaryColorDark,
                                                ),
                                              );
                                            }),
                                            Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: [
                                                AutoSizeText(
                                                  DateTimeFormat.format(
                                                      DateTime.now(),
                                                      format: "l, d F Y"),
                                                  textAlign: TextAlign.center,
                                                  presetFontSizes: [30, 24, 20],
                                                  style: TextStyle(
                                                    color: Theme.of(context)
                                                        .primaryColorDark,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      );
                                    }),
                                    AutoSizeText(
                                      "Today's Menu",
                                      style: TextStyle(
                                          color: Theme.of(context).primaryColor,
                                          fontSize: 25),
                                    ),
                                    TimerBuilder.periodic(
                                      Duration(days: 1),
                                      builder: (ctx) {
                                        return Column(
                                          children: todayMenu
                                              .map(
                                                (e) => Container(
                                                  margin: EdgeInsets.all(15),
                                                  alignment: Alignment.center,
                                                  child: MenuButton(
                                                    menuItem: e,
                                                    mqs: mqs,
                                                    selected: selected,
                                                  ),
                                                ),
                                              )
                                              .toList(),
                                        );
                                      },
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.all(15),
                                      child: ElevatedButton(
                                        style: ButtonStyle(
                                          foregroundColor:
                                              MaterialStateProperty.resolveWith(
                                            (states) {
                                              if (!imagePicked)
                                                return Colors.black;

                                              return Colors.white;
                                            },
                                          ),
                                          backgroundColor:
                                              MaterialStateProperty.resolveWith(
                                            (states) {
                                              if (!imagePicked)
                                                return Theme.of(context)
                                                    .primaryColorLight;

                                              return Theme.of(context)
                                                  .primaryColorDark;
                                            },
                                          ),
                                        ),
                                        onPressed: () async {
                                          final pickedFile = await ImagePicker()
                                              .getImage(
                                                  source: ImageSource.camera,
                                                  maxWidth: 500);
                                          setState(() {
                                            uploadingImage = true;
                                          });
                                          if (pickedFile != null) {
                                            TaskSnapshot snapshot =
                                                await FirebaseStorage.instance
                                                    .ref()
                                                    .child(
                                                        "$school/$month/$date/${fbAuth.currentUser!.uid}")
                                                    .putFile(
                                                        File(pickedFile.path));
                                            if (snapshot.state ==
                                                TaskState.success) {
                                              downloadUrl = await snapshot.ref
                                                  .getDownloadURL();

                                              setState(() {
                                                imagePicked = true;
                                              });
                                            }
                                          }
                                          setState(() {
                                            uploadingImage = false;
                                          });
                                        },
                                        child: uploadingImage
                                            ? CircularProgressIndicator()
                                            : Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                children: [
                                                  Icon(Icons
                                                      .add_a_photo_rounded),
                                                  SizedBox(
                                                    width: 10,
                                                  ),
                                                  AutoSizeText(
                                                    "Add Photo",
                                                    style:
                                                        TextStyle(fontSize: 20),
                                                  ),
                                                ],
                                              ),
                                      ),
                                    ),
                                    Padding(
                                      padding: EdgeInsets.all(20),
                                      child: ElevatedButton(
                                        onPressed: () async {
                                          setState(() {
                                            _isLoading = true;
                                          });

                                          await ref
                                              .child(
                                                  "schools/$school/reportedData/$month/$date/${FirebaseAuth.instance.currentUser!.uid}")
                                              .set(selected);
                                          if (downloadUrl.length != 0) {
                                            await ref
                                                .child(
                                                    "schools/$school/reportedData/$month/$date/${FirebaseAuth.instance.currentUser!.uid}")
                                                .update(
                                                    {'imageUrl': downloadUrl});
                                            ScaffoldMessenger.of(context)
                                                .showSnackBar(
                                              SnackBar(
                                                content: Text(
                                                    "Successfully submitted"),
                                              ),
                                            );
                                          } else {
                                            ScaffoldMessenger.of(context)
                                                .showSnackBar(
                                              SnackBar(
                                                content: Text(
                                                    "Couldn't Upload Image"),
                                              ),
                                            );
                                          }
                                          setState(() {
                                            selected.keys.forEach((element) {
                                              selected[element] = false;
                                            });
                                            imagePicked = false;
                                            _isLoading = false;
                                          });
                                        },
                                        child: AutoSizeText("Submit",
                                            style: TextStyle(fontSize: 20)),
                                      ),
                                    ),
                                  ],
                                ),
                              )
                            ],
                          ),
              ),
            ),
          );
  }
}

class NotVerified extends StatelessWidget {
  const NotVerified({
    Key? key,
    required this.name,
    required this.fbAuth,
  }) : super(key: key);

  final String name;
  final FirebaseAuth fbAuth;

  @override
  Widget build(BuildContext context) {
    return Center(
        child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        AutoSizeText(
          "Hello,",
          minFontSize: 17,
          maxLines: 2,
        ),
        SizedBox(
          height: 10,
        ),
        AutoSizeText(
          name,
          minFontSize: 25,
          maxLines: 2,
        ),
        SizedBox(
          height: 10,
        ),
        AutoSizeText(
          "Your acount is being verified by the admin",
          minFontSize: 20,
          maxLines: 2,
        ),
        TextButton(
          onPressed: () {
            fbAuth.signOut();
          },
          child: Text("Logout"),
        )
      ],
    ));
  }
}
