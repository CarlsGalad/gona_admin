import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class DailyChart extends StatefulWidget {
  const DailyChart({super.key});

  @override
  State<DailyChart> createState() => _DailyChartState();
}

class _DailyChartState extends State<DailyChart> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(10),
      // implement the bar chart
      child: Column(
        children: [
          Container(
            alignment: Alignment.centerLeft,
            decoration: const BoxDecoration(
                gradient: LinearGradient(colors: [
                  Colors.teal,
                  Colors.white24,
                  Colors.white30,
                ]),
                borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(10),
                    topRight: Radius.circular(10))),
            child: const Padding(
              padding: EdgeInsets.all(8.0),
              child: Text(
                'Performance Chart',
                style:
                    TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
              ),
            ),
          ),
          Container(
            decoration: BoxDecoration(
                gradient: const LinearGradient(colors: [
                  Colors.indigo,
                  Colors.blueGrey,
                  Colors.teal,
                  Colors.white24,
                  Colors.white30,
                  Colors.white54,
                  Colors.white,
                ]),
                borderRadius: BorderRadius.circular(15)),
            width: 500,
            height: 350,
            child: Padding(
              padding: const EdgeInsets.only(
                  top: 20.0, right: 10, bottom: 10, left: 10),
              child: BarChart(
                BarChartData(
                  titlesData: FlTitlesData(
                      show: true,
                      topTitles: const AxisTitles(
                        sideTitles: SideTitles(showTitles: false),
                      ),
                      rightTitles: const AxisTitles(
                        sideTitles: SideTitles(showTitles: false),
                      ),
                      leftTitles: AxisTitles(
                          sideTitles: const SideTitles(
                              showTitles: true, reservedSize: 30),
                          axisNameWidget: Text(
                            'Sales',
                            style: TextStyle(color: Colors.grey[300]),
                          )),
                      bottomTitles: AxisTitles(
                          sideTitles: const SideTitles(
                              showTitles: true, reservedSize: 30),
                          axisNameWidget: Text(
                            'Last Seven Days',
                            style: TextStyle(color: Colors.grey[300]),
                          ))),
                  borderData: FlBorderData(
                      border: const Border(
                    top: BorderSide.none,
                    right: BorderSide.none,
                    left: BorderSide(width: 1, color: Colors.grey),
                    bottom: BorderSide(width: 1, color: Colors.grey),
                  )),
                  groupsSpace: 10,

                  // add bars
                  barGroups: [
                    BarChartGroupData(x: 1, barsSpace: 10, barRods: [
                      BarChartRodData(
                        toY: 10,
                        width: 25,
                        gradient: const LinearGradient(
                            begin: Alignment.topCenter,
                            colors: [
                              Colors.amber,
                              Colors.green,
                              Colors.lightGreen,
                              Colors.lightBlue,
                              Colors.blue
                            ]),
                      ),
                    ]),
                    BarChartGroupData(x: 2, barRods: [
                      BarChartRodData(
                        toY: 9,
                        width: 25,
                        gradient: const LinearGradient(
                            begin: Alignment.topCenter,
                            colors: [
                              Colors.amber,
                              Colors.green,
                              Colors.lightGreen,
                              Colors.lightBlue,
                              Colors.blue
                            ]),
                      ),
                    ]),
                    BarChartGroupData(x: 3, barRods: [
                      BarChartRodData(
                        toY: 4,
                        width: 25,
                        gradient: const LinearGradient(
                            begin: Alignment.topCenter,
                            colors: [
                              Colors.amber,
                              Colors.green,
                              Colors.lightGreen,
                              Colors.lightBlue,
                              Colors.blue
                            ]),
                      ),
                    ]),
                    BarChartGroupData(x: 4, barRods: [
                      BarChartRodData(
                        toY: 2,
                        width: 25,
                        gradient: const LinearGradient(
                            begin: Alignment.topCenter,
                            colors: [
                              Colors.amber,
                              Colors.green,
                              Colors.lightGreen,
                              Colors.lightBlue,
                              Colors.blue
                            ]),
                      ),
                    ]),
                    BarChartGroupData(x: 5, barRods: [
                      BarChartRodData(
                        toY: 13,
                        width: 25,
                        gradient: const LinearGradient(
                            begin: Alignment.topCenter,
                            colors: [
                              Colors.amber,
                              Colors.green,
                              Colors.lightGreen,
                              Colors.lightBlue,
                              Colors.blue
                            ]),
                      ),
                    ]),
                    BarChartGroupData(x: 6, barRods: [
                      BarChartRodData(
                        toY: 17,
                        width: 25,
                        gradient: const LinearGradient(
                            begin: Alignment.topCenter,
                            colors: [
                              Colors.amber,
                              Colors.green,
                              Colors.lightGreen,
                              Colors.lightBlue,
                              Colors.blue
                            ]),
                      ),
                    ]),
                    BarChartGroupData(x: 7, barRods: [
                      BarChartRodData(
                        toY: 19,
                        width: 25,
                        gradient: const LinearGradient(
                            begin: Alignment.topCenter,
                            colors: [
                              Colors.amber,
                              Colors.green,
                              Colors.lightGreen,
                              Colors.lightBlue,
                              Colors.blue
                            ]),
                      ),
                    ]),
                    BarChartGroupData(x: 8, barRods: [
                      BarChartRodData(
                        toY: 21,
                        width: 25,
                        gradient: const LinearGradient(
                            begin: Alignment.topCenter,
                            colors: [
                              Colors.amber,
                              Colors.green,
                              Colors.lightGreen,
                              Colors.lightBlue,
                              Colors.blue
                            ]),
                      ),
                    ]),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
