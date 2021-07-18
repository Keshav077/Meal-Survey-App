import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';

class BillViewer extends StatelessWidget {
  BillViewer({Key? key}) : super(key: key);

  final fbDB = FirebaseDatabase.instance;

  final fbAuth = FirebaseAuth.instance;

  @override
  Widget build(BuildContext context) {
    Size mqs = MediaQuery.of(context).size;
    final ref = fbDB.reference();
    return Scaffold(
      appBar: AppBar(
        title: Text("Bills"),
        elevation: 0.0,
      ),
      body: FutureBuilder(
        future: ref.child("users/${fbAuth.currentUser!.uid}/bills").get(),
        builder: (ctx, snap) {
          if (snap.connectionState == ConnectionState.waiting)
            return Center(
              child: CircularProgressIndicator(),
            );
          if (snap.hasData) {
            final data = snap.data as DataSnapshot;
            final bills = data.value as Map;
            final sortedBills = bills.keys.toList();
            sortedBills.sort((a, b) => b.compareTo(a));
            return GridView(
              padding: EdgeInsets.all(10),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  childAspectRatio: 3 / 4,
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 20),
              children: sortedBills
                  .map(
                    (e) => InkWell(
                      onTap: () {
                        showDialog(
                            context: context,
                            builder: (ctx) {
                              return Dialog(
                                child: Container(
                                  width: mqs.width * 0.8,
                                  height: mqs.height * 0.6,
                                  decoration: BoxDecoration(
                                      image: DecorationImage(
                                          image: NetworkImage(bills[e]),
                                          fit: BoxFit.cover)),
                                ),
                              );
                            });
                      },
                      child: GridTile(
                          footer: Container(
                            height: 30,
                            alignment: Alignment.center,
                            width: double.infinity,
                            decoration: BoxDecoration(
                                color: Colors.black45,
                                borderRadius: BorderRadius.circular(10)),
                            child: Text(
                              e.split(' ')[0],
                              style: TextStyle(color: Colors.white),
                            ),
                          ),
                          child: Container(
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10),
                                image: DecorationImage(
                                    image: NetworkImage(bills[e]),
                                    fit: BoxFit.cover)),
                          )),
                    ),
                  )
                  .toList(),
            );
          }
          return Center(
            child: CircularProgressIndicator(),
          );
        },
      ),
    );
  }
}
