import 'package:flutter/material.dart';

class MealChart extends StatelessWidget {
  const MealChart({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Size mqs = MediaQuery.of(context).size;
    return Scaffold(
      appBar: AppBar(
        title: Text("Meal Chart"),
        elevation: 0.0,
        centerTitle: true,
      ),
      body: ListView(
        children: [
          Container(
            height: mqs.height * 0.3,
            width: mqs.width,
            margin: EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: kElevationToShadow[1],
              borderRadius: BorderRadius.circular(10),
              image: DecorationImage(
                image: AssetImage("assets/mealChart.JPG"),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
