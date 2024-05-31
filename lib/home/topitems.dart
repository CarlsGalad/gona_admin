import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

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
        child: Container(
          decoration: BoxDecoration(
            color: Colors.black,
            borderRadius: BorderRadius.circular(15),
          ),
          child: Padding(
            padding: const EdgeInsets.all(15.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Title
                const Text(
                  'Top Items',
                  style: TextStyle(
                    color: Colors.white,
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
                        return const Center(child: CircularProgressIndicator());
                      }
                      if (snapshot.data!.isEmpty) {
                        return const Center(
                          child: Text(
                            'No top items available',
                            style: TextStyle(color: Colors.white),
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
                              style: const TextStyle(
                                  color: Colors.blueGrey, fontSize: 13),
                              softWrap: false,
                            ),
                            subtitle: Text(
                              'Quantity Sold: ${item['quantitySold']}',
                              style: const TextStyle(
                                  color: Colors.grey, fontSize: 10),
                              softWrap: false,
                            ),
                            trailing: Text(
                              'Vendor: ${item['vendorName']}',
                              style: const TextStyle(
                                  color: Colors.grey, fontSize: 10),
                              softWrap: false,
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
