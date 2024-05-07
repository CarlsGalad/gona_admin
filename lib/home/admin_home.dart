import 'package:flutter/material.dart';

import 'package:gona_admin/home/delivered_orders.dart';
import 'package:gona_admin/home/new_users_tile.dart';
import 'package:gona_admin/home/pending_orders.dart';
import 'package:gona_admin/home/proccessed_order.dart';
import 'package:gona_admin/home/sales_overview.dart';
import 'package:gona_admin/home/shipped_orders.dart';
import 'package:gona_admin/home/total_sales.dart';
import 'package:gona_admin/home/vendors_tile.dart';

import '../welcomemsg.dart';

class AdminHome extends StatefulWidget {
  const AdminHome({super.key});

  @override
  State<AdminHome> createState() => _AdminHomeState();
}

class _AdminHomeState extends State<AdminHome> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        toolbarHeight: 100,
        leadingWidth: 100,
        leading: Padding(
          padding: const EdgeInsets.only(left: 10.0, top: 10),
          child: SizedBox(
            height: 100,
            width: 150,
            child: Image.asset(
              'lib/images/file.png',
              width: 100,
              fit: BoxFit.cover,
            ),
          ),
        ),
        title: const Padding(
          padding: EdgeInsets.all(8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Dashboard',
                style: TextStyle(color: Colors.white),
              ),
              Text(
                'Overview of Gona market',
                style: TextStyle(
                    color: Colors.grey,
                    fontSize: 10,
                    fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
        backgroundColor: Colors.black,
        foregroundColor: Colors.black54,
      ),
      body: Row(
        children: [
          Expanded(
            // Wrap the row with Expanded
            child: Row(
              children: <Widget>[
                LayoutBuilder(builder: (context, constraint) {
                  return SingleChildScrollView(
                    child: ConstrainedBox(
                      constraints:
                          BoxConstraints(minHeight: constraint.maxHeight),
                      child: IntrinsicHeight(
                        child: NavigationRail(
                          backgroundColor: Colors.black,
                          selectedIndex: _selectedIndex,
                          unselectedLabelTextStyle:
                              const TextStyle(color: Colors.grey, fontSize: 13),
                          selectedLabelTextStyle:
                              const TextStyle(color: Colors.white),
                          unselectedIconTheme:
                              const IconThemeData(color: Colors.white),
                          onDestinationSelected: (int index) {
                            setState(() {
                              _selectedIndex = index;
                            });
                          },
                          labelType: NavigationRailLabelType.all,
                          destinations: const <NavigationRailDestination>[
                            NavigationRailDestination(
                              icon: Icon(Icons.home),
                              label: Text('Home'),
                            ),
                            NavigationRailDestination(
                              icon: Icon(Icons.headset_mic),
                              label: Text('Live Chat'),
                            ),
                            NavigationRailDestination(
                              icon: Icon(Icons.newspaper),
                              label: Text('Gona News'),
                            ),
                            NavigationRailDestination(
                              icon: Icon(Icons.category),
                              label: Text('Manage Categories'),
                            ),
                            NavigationRailDestination(
                              icon: Icon(Icons.attach_money),
                              label: Text('Manage Loans'),
                            ),
                            NavigationRailDestination(
                              icon: Icon(Icons.mail),
                              label: Text('Gona Mails'),
                            ),
                            NavigationRailDestination(
                              icon: Icon(Icons.people),
                              label: Text('Our Vendors'),
                            ),
                            NavigationRailDestination(
                              icon: Icon(Icons.person),
                              label: Text('Users'),
                            ),
                            NavigationRailDestination(
                              icon: Icon(Icons.adjust),
                              label: Text('Manage Disputes'),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                }),
                const VerticalDivider(
                  thickness: 1,
                  width: 1,
                  color: Color.fromARGB(255, 26, 25, 25),
                ),
                // This is the main content.
                Expanded(
                  child: SingleChildScrollView(
                    child: Container(
                      color: Colors.black54,
                      child: Column(
                        children: [
                          const WelcomeBackWidget(),
                          Container(
                            decoration: const BoxDecoration(
                                color: Color.fromARGB(255, 26, 25, 25),
                                borderRadius: BorderRadius.only(
                                    topRight: Radius.circular(15))),
                            child: const Padding(
                              padding: EdgeInsets.all(8.0),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  //first row
                                  Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Column(
                                        children: [
                                          Row(
                                            children: [
                                              TotalSalesTile(),
                                              PendingOrderTile(),
                                            ],
                                          ),
                                          //Second Row
                                          Row(
                                            children: [
                                              ProcessedCountTile(),
                                              ShippedOdersCount(),
                                              DeliveredCountTitle(),
                                            ],
                                          ),

                                          // Third Row
                                          Row(
                                            children: [
                                              VendorCountTile(),
                                              NewUsersCountTile(),
                                            ],
                                          ),
                                        ],
                                      ),
                                      SalesOverviewTile(),
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
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
