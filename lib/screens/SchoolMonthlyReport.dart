import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';

class SchoolMonthlyReport extends StatefulWidget {
  const SchoolMonthlyReport({
    Key? key,
    required this.reportedData,
    required this.schoolName,
    required this.month,
  }) : super(key: key);
  final String month;
  final String schoolName;
  final Map reportedData;

  @override
  _SchoolMonthlyReportState createState() => _SchoolMonthlyReportState();
}

class _SchoolMonthlyReportState extends State<SchoolMonthlyReport> {
  Map days = {
    "Jan": 31,
    "Feb": 28,
    "Mar": 31,
    "Apr": 30,
    "May": 31,
    "Jun": 30,
    "Jul": 31,
    "Aug": 31,
    "Sep": 30,
    "Oct": 31,
    "Nov": 30,
    "Dec": 31,
  };

  @override
  Widget build(BuildContext context) {
    int studentCount =
        int.parse(widget.reportedData['studentCount'].toString());
    Map reportedData = widget.reportedData['reportedData'] ?? {};
    Size mqs = MediaQuery.of(context).size;

    return Container(
      color: Colors.white,
      child: SafeArea(
        child: Scaffold(
          appBar: AppBar(
            leading: IconButton(
                padding: const EdgeInsets.only(left: 8),
                onPressed: () {
                  Navigator.of(context).pop();
                },
                icon: Icon(Icons.arrow_back_ios, color: Colors.black)),
            backgroundColor: Colors.white,
            centerTitle: true,
            title: Column(
              children: [
                AutoSizeText(
                  widget.schoolName,
                  style: TextStyle(
                    fontSize: 20,
                    color: Colors.black,
                  ),
                ),
                AutoSizeText(
                  widget.month,
                  style: TextStyle(
                    fontSize: 15,
                    color: Colors.black54,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ],
            ),
          ),
          body: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: AutoSizeText("Total Student Count: $studentCount"),
                ),
                Container(
                  height: mqs.height * 0.35,
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        for (int i = 1; i <= days[widget.month]; i++)
                          Padding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 8.0),
                            child: Builder(
                              builder: (context) {
                                String k = i.toString();
                                if (k.length == 1) k = "0" + k;
                                Map dayReport = reportedData.length == 0
                                    ? {}
                                    : reportedData[widget.month][k] ?? {};
                                int dayCount = dayReport.length;

                                var recievedAllItemsCount = 0,
                                    notRecievedAllItemsCount = 0;

                                dayReport.keys.forEach((key) {
                                  bool recievedAllItems = true;
                                  dayReport[key].forEach((ke, v) {
                                    if (ke != 'imageUrl' && !v)
                                      recievedAllItems = false;
                                  });
                                  if (recievedAllItems)
                                    recievedAllItemsCount += 1;
                                  else
                                    notRecievedAllItemsCount += 1;
                                });
                                double percent = dayCount / studentCount,
                                    recievedPercent =
                                        recievedAllItemsCount / studentCount,
                                    notRecievedPercent =
                                        notRecievedAllItemsCount / studentCount;
                                return Column(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.end,
                                      children: [
                                        buildBar(mqs, percent, dayCount,
                                            Theme.of(context).primaryColor),
                                        buildBar(
                                            mqs,
                                            recievedPercent,
                                            recievedAllItemsCount,
                                            Colors.green),
                                        buildBar(
                                            mqs,
                                            notRecievedPercent,
                                            notRecievedAllItemsCount,
                                            Colors.red),
                                      ],
                                    ),
                                    SizedBox(
                                      height: 10,
                                    ),
                                    AutoSizeText(
                                      k,
                                      style: TextStyle(
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                );
                              },
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
                SizedBox(
                  height: 10,
                ),
                Row(
                  children: [
                    buildLabel(
                      "Reported",
                      Theme.of(context).primaryColor,
                    ),
                    buildLabel(
                      "Recieved",
                      Colors.green,
                    ),
                    buildLabel(
                      "Not Recieved",
                      Colors.red,
                    ),
                  ],
                ),
                SizedBox(
                  height: 20,
                ),
                for (int i = 1; i <= days[widget.month]; i++)
                  Column(
                    children: [
                      Container(
                        margin: EdgeInsets.fromLTRB(10, 0, 10, 5),
                        child: Row(
                          children: [
                            AutoSizeText(
                              widget.month + " " + i.toString(),
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Theme.of(context).primaryColorDark),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          color:
                              Theme.of(context).primaryColor.withOpacity(0.1),
                        ),
                        margin: EdgeInsets.fromLTRB(10, 0, 10, 10),
                        alignment: Alignment.centerLeft,
                        child: Builder(builder: (ctx) {
                          String k = i.toString();
                          if (k.length == 1) k = "0" + k;
                          Map dayReport = reportedData.length == 0
                              ? {}
                              : reportedData[widget.month][k] ?? {};
                          List<String> imageUrls = [];
                          dayReport.keys.forEach((element) {
                            if (dayReport[element]['imageUrl'] != null)
                              imageUrls.add(dayReport[element]['imageUrl']);
                          });
                          return SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: imageUrls.length == 0
                                ? Container(
                                    alignment: Alignment.center,
                                    width: mqs.width - 20,
                                    child: Text("No Images Uploaded"))
                                : Row(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: imageUrls.map((e) {
                                      return Container(
                                        margin: EdgeInsets.only(right: 10),
                                        decoration: BoxDecoration(
                                          image: DecorationImage(
                                              image: NetworkImage(e),
                                              fit: BoxFit.cover),
                                          borderRadius:
                                              BorderRadius.circular(10),
                                        ),
                                        width: mqs.height * 0.1,
                                      );
                                    }).toList()),
                          );
                        }),
                        width: double.infinity,
                        height: mqs.height * 0.1,
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

  Expanded buildLabel(String label, Color color) {
    return Expanded(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(2),
              color: color,
            ),
            width: 20,
            height: 15,
          ),
          AutoSizeText(label),
        ],
      ),
    );
  }

  Container buildBar(Size mqs, double percent, int dayCount, Color color) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(2),
        color: color,
      ),
      alignment: Alignment.topCenter,
      padding: EdgeInsets.only(top: 5),
      width: 15,
      height: mqs.height * 0.3 * percent,
      child: AutoSizeText(
        dayCount.toString(),
        style: TextStyle(color: Colors.white),
      ),
    );
  }
}
