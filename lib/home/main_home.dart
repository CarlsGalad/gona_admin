import 'package:flutter/material.dart';
import 'package:gona_admin/home/topitems.dart';
import 'package:gona_admin/home/sub_screens/delivered_orders.dart';
import 'package:gona_admin/home/sub_screens/pending_orders.dart';
import 'package:gona_admin/home/sub_screens/processed_orders.dart';
import 'package:gona_admin/home/sub_screens/shipped_orders.dart';
import 'package:gona_admin/services/admin_service.dart'; // Import the AdminService

import 'daily_chart.dart';
import 'delivered_orders.dart';
import 'new_users_tile.dart';
import 'pending_orders.dart';
import 'proccessed_order.dart';
import 'sales_overview.dart';
import 'shipped_orders.dart';
import 'top_locations.dart';
import 'total_sales.dart';
import 'vendors_tile.dart';

class MainHome extends StatefulWidget {
  const MainHome({super.key});

  @override
  State<MainHome> createState() => _MainHomeState();
}

class _MainHomeState extends State<MainHome> {
  String? adminId =
      'admin_id_placeholder'; // Replace with actual admin ID logic

  // Log the activity when a tile is tapped
  Future<void> _logTileTap(
      String tileName, Widget Function() navigateTo) async {
    if (adminId != null) {
      await AdminService()
          .logActivity(adminId!, 'Navigation', 'Navigated to $tileName');
    }
    if (mounted) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => navigateTo()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Container(
        color: Colors.white,
        child: Column(
          children: [
            Container(
              decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius:
                      BorderRadius.only(topRight: Radius.circular(15))),
              child: Padding(
                padding: const EdgeInsets.only(left: 20.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // First Row
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Column(
                          children: [
                            Row(
                              children: [
                                const TotalSalesTile(),
                                GestureDetector(
                                  onTap: () => _logTileTap('Pending Orders',
                                      () => const PendingOrderScreen()),
                                  child: const PendingOrderTile(),
                                ),
                              ],
                            ),
                            // Second Row
                            Row(
                              children: [
                                GestureDetector(
                                  onTap: () => _logTileTap('Processed Orders',
                                      () => const ProcessedOrderScreen()),
                                  child: const ProcessedCountTile(),
                                ),
                                GestureDetector(
                                  onTap: () => _logTileTap('Shipped Orders',
                                      () => const ShippedOrderScreen()),
                                  child: const ShippedOrdersCount(),
                                ),
                                GestureDetector(
                                  onTap: () => _logTileTap('Delivered Orders',
                                      () => const DeliveredOrderScreen()),
                                  child: const DeliveredCountTitle(),
                                ),
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
                            DailyChart(),
                            SalesOverviewTile(),
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
