import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shimmer/shimmer.dart';

class TopItems extends StatefulWidget {
  const TopItems({super.key});

  @override
  State<TopItems> createState() => _TopItemsState();
}

class _TopItemsState extends State<TopItems> {
  Future<List<Map<String, dynamic>>> _fetchTopItems() async {
    // Query the sales collection to get all sales data
    QuerySnapshot salesSnapshot =
        await FirebaseFirestore.instance.collection('sales').get();

    // Aggregate sales data by itemId
    Map<String, Map<String, dynamic>> itemSales = {};

    for (var doc in salesSnapshot.docs) {
      String itemId = doc['itemId'];
      int quantity = doc['quantity'];

      // Get item details
      DocumentSnapshot itemDoc = await FirebaseFirestore.instance
          .collection('items')
          .doc(itemId)
          .get();
      if (itemDoc.exists) {
        String itemName = itemDoc['name'];
        String vendorName = itemDoc['itemFarm'];

        if (!itemSales.containsKey(itemId)) {
          itemSales[itemId] = {
            'itemName': itemName,
            'vendorName': vendorName,
            'quantitySold': 0
          };
        }
        itemSales[itemId]!['quantitySold'] += quantity;
      }
    }

    // Convert to list and sort by quantity sold
    List<Map<String, dynamic>> topItems = itemSales.values.toList();
    topItems.sort((a, b) => b['quantitySold'].compareTo(a['quantitySold']));

    return topItems;
  }

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: SizedBox(
          child: Padding(
            padding: const EdgeInsets.all(15.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Title
                Text(
                  'Top Items',
                  style: GoogleFonts.abel(
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                  ),
                  softWrap: false,
                ),
                const SizedBox(height: 10),
                // List
                SizedBox(
                  height: 600,
                  child: FutureBuilder<List<Map<String, dynamic>>>(
                    future: _fetchTopItems(),
                    builder: (context, snapshot) {
                      if (!snapshot.hasData) {
                        return ListView.builder(
                          itemCount: 8, // Example placeholder count
                          itemBuilder: (context, index) {
                            return Shimmer.fromColors(
                              baseColor: Colors.grey[300]!,
                              highlightColor: Colors.grey[100]!,
                              child: ListTile(
                                title: Container(
                                  width: double.infinity,
                                  height: 14.0,
                                  color: Colors.white,
                                ),
                                subtitle: Container(
                                  width: double.infinity,
                                  height: 10.0,
                                  color: Colors.white,
                                ),
                                trailing: Container(
                                  width: 60.0,
                                  height: 10.0,
                                  color: Colors.white,
                                ),
                              ),
                            );
                          },
                        );
                      }
                      if (snapshot.data!.isEmpty) {
                        return Center(
                          child: Text(
                            'No top items available',
                            style: GoogleFonts.abel(color: Colors.black),
                          ),
                        );
                      }

                      final topItemsData = snapshot.data!;
                      return ListView.builder(
                        itemCount: topItemsData.length,
                        itemBuilder: (context, index) {
                          final item = topItemsData[index];
                          return ListTile(
                            title: Text(
                              item['itemName'],
                              style: GoogleFonts.abel(
                                  color: Colors.black, fontSize: 13),
                              softWrap: false,
                              overflow: TextOverflow.fade,
                            ),
                            subtitle: Text(
                              'Quantity Sold: ${item['quantitySold']}',
                              style: GoogleFonts.abel(
                                  color: Colors.grey, fontSize: 10),
                              softWrap: false,
                            ),
                            trailing: Text(
                              'Vendor: ${item['vendorName']}',
                              style: GoogleFonts.abel(
                                  color: Colors.grey, fontSize: 10),
                              softWrap: false,
                              overflow: TextOverflow.fade,
                            ),
                          );
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
