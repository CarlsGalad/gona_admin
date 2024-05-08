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
      child: SizedBox(
        width: 500,
        height: 300,
        child: BarChart(
          BarChartData(
            titlesData: const FlTitlesData(
                show: true,
                leftTitles: AxisTitles(
                    sideTitles: SideTitles(showTitles: true),
                    axisNameWidget: Text(
                      'Sales',
                      style: TextStyle(color: Colors.grey),
                    )),
                bottomTitles: AxisTitles(
                    sideTitles: SideTitles(showTitles: true),
                    axisNameWidget: Text(
                      'Last Seven Days',
                      style: TextStyle(color: Colors.grey),
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
    );
  }
}
