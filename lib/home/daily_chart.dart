import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class DailyChart extends StatefulWidget {
  const DailyChart({super.key});

  @override
  State<DailyChart> createState() => _DailyChartState();
}

class _DailyChartState extends State<DailyChart> {
  List<BarChartGroupData> barGroups = [];
  List<String> daysOfWeek = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchSalesData();
  }

  Future<void> _fetchSalesData() async {
    // Get the current date and the date 7 days ago
    DateTime now = DateTime.now();
    DateTime startDate = now.subtract(const Duration(days: 6));

    // Initialize a map to store sales data
    Map<String, int> salesData = {
      for (int i = 0; i < 7; i++)
        DateFormat('EEE').format(startDate.add(Duration(days: i))): 0
    };

    try {
      // Query the sales collection for the last 7 days
      QuerySnapshot salesSnapshot = await FirebaseFirestore.instance
          .collection('sales')
          .where('saleDate', isGreaterThanOrEqualTo: startDate)
          .get();

      // Sum up the sales for each day
      for (var doc in salesSnapshot.docs) {
        Timestamp saleDate = doc['saleDate'];
        DateTime saleDateTime = saleDate.toDate();
        String day = DateFormat('EEE').format(saleDateTime);
        if (salesData.containsKey(day)) {
          salesData[day] = (salesData[day] ?? 0) + doc['quantity'] as int;
        }
      }

      // Create the bar chart groups
      List<String> sortedDaysOfWeek = salesData.keys.toList();
      sortedDaysOfWeek.sort((a, b) => DateFormat('EEE')
          .parse(a)
          .weekday
          .compareTo(DateFormat('EEE').parse(b).weekday));
      barGroups = sortedDaysOfWeek.asMap().entries.map((entry) {
        int index = entry.key;
        String day = entry.value;
        return BarChartGroupData(
          x: index,
          barRods: [
            BarChartRodData(
              toY: salesData[day]?.toDouble() ?? 0.0,
              width: 25,
              gradient: const LinearGradient(
                begin: Alignment.topCenter,
                colors: [
                  Colors.amber,
                  Colors.green,
                  Colors.lightGreen,
                  Colors.lightBlue,
                  Colors.blue
                ],
              ),
            ),
          ],
        );
      }).toList();

      // Update the state with the new data
      setState(() {
        daysOfWeek = sortedDaysOfWeek;
        isLoading = false;
      });
    } catch (e) {
      print('Error fetching sales data: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(10),
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
              child: isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : BarChart(
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
                              showTitles: true,
                              reservedSize: 30,
                            ),
                            axisNameWidget: Text(
                              'Sales',
                              style: TextStyle(color: Colors.grey[300]),
                            ),
                          ),
                          bottomTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              reservedSize: 30,
                              getTitlesWidget: (value, meta) {
                                if (value < 0 || value >= daysOfWeek.length) {
                                  return Container();
                                }
                                return Padding(
                                  padding: const EdgeInsets.only(top: 8.0),
                                  child: Text(
                                    daysOfWeek[value.toInt()],
                                    style: TextStyle(color: Colors.grey[300]),
                                  ),
                                );
                              },
                            ),
                            axisNameWidget: Text(
                              'Last Seven Days',
                              style: TextStyle(color: Colors.grey[300]),
                            ),
                          ),
                        ),
                        borderData: FlBorderData(
                          border: const Border(
                            top: BorderSide.none,
                            right: BorderSide.none,
                            left: BorderSide(width: 1, color: Colors.grey),
                            bottom: BorderSide(width: 1, color: Colors.grey),
                          ),
                        ),
                        groupsSpace: 10,
                        barGroups: barGroups,
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }
}
