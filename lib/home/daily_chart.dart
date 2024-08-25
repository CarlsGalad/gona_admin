import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:shimmer/shimmer.dart';

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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Align(
            alignment: Alignment.topLeft,
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                'Performance Chart',
                style: GoogleFonts.lato(
                    color: Colors.black, fontWeight: FontWeight.bold),
              ),
            ),
          ),
          SizedBox(
            width: 500,
            height: 350,
            child: Padding(
              padding: const EdgeInsets.only(
                  top: 20.0, right: 10, bottom: 10, left: 10),
              child: isLoading
                  ? Shimmer.fromColors(
                      baseColor: Colors.grey[300]!,
                      highlightColor: Colors.grey[100]!,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            width: double.infinity,
                            height: 300,
                            color: Colors.white,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                // Shimmer for bars
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceEvenly,
                                  children: List.generate(7, (index) {
                                    return Container(
                                      width: 25,
                                      height: 100 + (index * 10).toDouble(),
                                      color: Colors.white,
                                    );
                                  }),
                                ),
                                const SizedBox(height: 20),
                                // Shimmer for bottom titles
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceEvenly,
                                  children: List.generate(7, (index) {
                                    return Container(
                                      width: 40,
                                      height: 20,
                                      color: Colors.white,
                                    );
                                  }),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    )
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
                              style: GoogleFonts.abel(color: Colors.grey[900]),
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
                                    style: GoogleFonts.abel(
                                        color: Colors.grey[900]),
                                  ),
                                );
                              },
                            ),
                            axisNameWidget: Text(
                              'Last Seven Days',
                              style: TextStyle(color: Colors.grey[900]),
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
