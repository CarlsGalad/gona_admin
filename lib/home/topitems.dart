import 'package:flutter/material.dart';

class TopItems extends StatefulWidget {
  const TopItems({Key? key}) : super(key: key);

  @override
  State<TopItems> createState() => _TopItemsState();
}

class _TopItemsState extends State<TopItems> {
  @override
  Widget build(BuildContext context) {
    // Dummy data for placeholders
    List<Map<String, dynamic>> topItemsData = [
      {'itemName': 'Item 1', 'quantitySold': 100, 'vendorName': 'Vendor A'},
      {'itemName': 'Item 2', 'quantitySold': 90, 'vendorName': 'Vendor B'},
      {'itemName': 'Item 1', 'quantitySold': 900, 'vendorName': 'Vendor A'},
      {'itemName': 'Item 1', 'quantitySold': 100, 'vendorName': 'Vendor A'},
      {'itemName': 'Item 1', 'quantitySold': 160, 'vendorName': 'Vendor A'},
      {'itemName': 'Item 1', 'quantitySold': 100, 'vendorName': 'Vendor A'},
      // Add more dummy data here
    ];

    //top sold items
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
                  height: 550,
                  child: ListView.builder(
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
                          style:
                              const TextStyle(color: Colors.grey, fontSize: 10),
                          softWrap: false,
                        ),
                        trailing: Text(
                          'Vendor: ${item['vendorName']}',
                          style:
                              const TextStyle(color: Colors.grey, fontSize: 10),
                          softWrap: false,
                        ),
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
