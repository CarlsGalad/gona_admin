import 'package:flutter/material.dart';

import '../welcomemsg.dart';
import 'daily_chart.dart';
import 'delivered_orders.dart';
import 'new_users_tile.dart';
import 'pending_orders.dart';
import 'proccessed_order.dart';
import 'sales_overview.dart';
import 'shipped_orders.dart';
import 'sub_screens/delivered_orders.dart';
import 'sub_screens/pendening_orders.dart';
import 'sub_screens/processed_orders.dart';
import 'sub_screens/shipped_orders.dart';
import 'top_locations.dart';
import 'topitems.dart';
import 'total_sales.dart';
import 'vendors_tile.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: SingleChildScrollView(
        child: Container(
          color: Colors.black54,
          child: Column(
            children: [
              const WelcomeBackWidget(),

              // Render other content if not Live Chat
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
                          Column(
                            children: [
                              const SalesOverviewTile(),
                              Padding(
                                padding:
                                    const EdgeInsets.only(top: 10.0, right: 10),
                                child: Container(
                                  decoration: BoxDecoration(
                                      color: Colors.black,
                                      borderRadius: BorderRadius.circular(10)),
                                  child: const Padding(
                                    padding: EdgeInsets.all(8.0),
                                    child: Text(
                                      'Performance Chart',
                                      style: TextStyle(color: Colors.white),
                                    ),
                                  ),
                                ),
                              ),
                              const DailyChart(),
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
      ),
    );
  }
}
