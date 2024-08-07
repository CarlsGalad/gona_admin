import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ProcessedCountTile extends StatefulWidget {
  const ProcessedCountTile({super.key});

  @override
  State<ProcessedCountTile> createState() => _ProcessedCountTileState();
}

class _ProcessedCountTileState extends State<ProcessedCountTile> {
  int _processedOrdersCount = 0;

  @override
  void initState() {
    super.initState();
    _fetchProcessedOrdersCount();
  }

  Future<void> _fetchProcessedOrdersCount() async {
    final QuerySnapshot<Map<String, dynamic>> querySnapshot =
        await FirebaseFirestore.instance
            .collection('orders')
            .where('orderStatus.placed', isEqualTo: true)
            .where('orderStatus.processed', isEqualTo: true)
            .where('orderStatus.picked', isEqualTo: false)
            .where('orderStatus.shipped', isEqualTo: false)
            .where('orderStatus.hubNear', isEqualTo: false)
            .where('orderStatus.enroute', isEqualTo: false)
            .where('orderStatus.delivered', isEqualTo: false)
            .get();
    setState(() {
      _processedOrdersCount = querySnapshot.size;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: SizedBox(
        width: 120,
        height: 140,
        child: Padding(
          padding: const EdgeInsets.only(left: 15),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Padding(
                padding: EdgeInsets.only(top: 10.0, right: 10),
                child: Icon(
                  Icons.done_all,
                  color: Colors.orange,
                  size: 20,
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 1.0, right: 10),
                child: Text(
                  '$_processedOrdersCount', // Display the count orders with status as process order
                  style: GoogleFonts.aboreto(
                      fontSize: 30,
                      color: Colors.grey,
                      fontWeight: FontWeight.bold),
                  textAlign: TextAlign.start,
                  softWrap: false,
                ),
              ),
              const Spacer(),
              Padding(
                padding: const EdgeInsets.only(bottom: 12.0),
                child: Text(
                  'Processed Orders',
                  style: GoogleFonts.abel(
                      fontWeight: FontWeight.bold, fontSize: 15),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
