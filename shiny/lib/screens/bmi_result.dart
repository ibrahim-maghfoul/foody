import 'package:flutter/material.dart';

import 'package:shiny/models/dataModel.dart';
import 'package:shiny/models/styles.dart';

class BmiResultScreen extends StatefulWidget {
  final double bmi;

  BmiResultScreen({required this.bmi});

  @override
  _BmiResultScreenState createState() => _BmiResultScreenState();
}

class _BmiResultScreenState extends State<BmiResultScreen> {
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text('تحليل الوزن'),
      ),
      body: SingleChildScrollView(
        child: Stack(
          children: [
            Center(
              child: Container(
                width: width,
                margin: EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: colors[4].withOpacity(0.7),
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: EdgeInsets.all(30),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                        padding:
                            EdgeInsets.symmetric(vertical: 5, horizontal: 20),
                        child: Text(
                          DataModel().bmiNotation(widget.bmi),
                          style: kSmallText,
                        ),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(60),
                          color: colors[4],
                        )),
                    SizedBox(
                      height: 30,
                    ),
                    Text(
                      "Your BMI is",
                      textAlign: TextAlign.center,
                      style: kSmallText,
                    ),
                    Text(
                      "${widget.bmi.toStringAsFixed(1)}",
                      textAlign: TextAlign.center,
                      style: kLargeText,
                    ),
                    SizedBox(
                      height: 30,
                    ),
                    Text(
                      DataModel().bmiAdvice(widget.bmi),
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.white, fontSize: 17),
                    ),
                  ],
                ),
              ),
            ),
            Positioned(
              child: Container(
                height: 20,
                width: 20,
                decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20)),
              ),
              bottom: 30,
              left: 30,
            ),
            Positioned(
              child: Container(
                height: 20,
                width: 20,
                decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20)),
              ),
              bottom: 30,
              right: 30,
            ),
            Positioned(
              child: Container(
                height: 20,
                width: 20,
                decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20)),
              ),
              top: 30,
              left: 30,
            ),
            Positioned(
              child: Container(
                height: 20,
                width: 20,
                decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20)),
              ),
              top: 30,
              right: 30,
            ),
          ],
        ),
      ),
    );
  }
}
