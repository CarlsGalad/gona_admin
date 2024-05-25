import 'package:flutter/material.dart';

import 'package:gona_admin/home/topitems.dart';


import 'daily_chart.dart';
import 'delivered_orders.dart';
import 'new_users_tile.dart';
import 'pending_orders.dart';
import 'proccessed_order.dart';
import 'sales_overview.dart';
import 'shipped_orders.dart';
import 'sub_screens/delivered_orders.dart';
import 'sub_screens/pending_orders.dart';
import 'sub_screens/processed_orders.dart';
import 'sub_screens/shipped_orders.dart';
import 'top_locations.dart';
import 'total_sales.dart';
import 'vendors_tile.dart';

class MainHome extends StatefulWidget {
  const MainHome({super.key});

  @override
  State<MainHome> createState() => _MainHomeState();
}

class _MainHomeState extends State<MainHome> {
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Container(
        color: Colors.black54,
        child: Column(
          children: [
            Container(
              decoration: const BoxDecoration(
                  color: Color.fromARGB(255, 26, 25, 25),
                  borderRadius:
                      BorderRadius.only(topRight: Radius.circular(15))),
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    //first row
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Column(
                          children: [
                            Row(
                              children: [
                                const TotalSalesTile(),
                                GestureDetector(
                                    onTap: () {
                                      Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                              builder: (context) =>
                                                  const PendingOrderScreen()));
                                    },
                                    child: const PendingOrderTile()),
                              ],
                            ),
                            //Second Row
                            Row(
                              children: [
                                GestureDetector(
                                    onTap: () {
                                      Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                              builder: (context) =>
                                                  const ProcessedOrderScreen()));
                                    },
                                    child: const ProcessedCountTile()),
                                GestureDetector(
                                    onTap: () {
                                      Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                              builder: (context) =>
                                                  const ShippedOrderScreen()));
                                    },
                                    child: const ShippedOdersCount()),
                                GestureDetector(
                                    onTap: () {
                                      Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                              builder: (context) =>
                                                  const DeliveredOrderScreen()));
                                    },
                                    child: const DeliveredCountTitle()),
                              ],
                            ),

                            // Third Row
                            const Row(
                              children: [
                                VendorCountTile(),
                                NewUsersCountTile(),
                              ],
                            ),
                            const PieChartWidget(),
                          ],
                        ),
                        const Column(
                          children: [
                            SalesOverviewTile(),
                            DailyChart(),
                          ],
                        ),
                        // Top Items
                        const TopItems(),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
