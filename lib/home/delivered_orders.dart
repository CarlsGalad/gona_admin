import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class DeliveredCountTitle extends StatefulWidget {
  const DeliveredCountTitle({super.key});

  @override
  State<DeliveredCountTitle> createState() => _DeliveredCountTitleState();
}

class _DeliveredCountTitleState extends State<DeliveredCountTitle> {
  int _deliveredOrdersCount = 0;

  @override
  void initState() {
    super.initState();
    _fetchDeliveredOrdersCount();
  }

  Future<void> _fetchDeliveredOrdersCount() async {
    final QuerySnapshot<Map<String, dynamic>> querySnapshot =
        await FirebaseFirestore.instance
            .collection('orders')
            .where('orderStatus.placed', isEqualTo: true)
            .where('orderStatus.processed', isEqualTo: true)
            .where('orderStatus.picked', isEqualTo: true)
            .where('orderStatus.shipped', isEqualTo: true)
            .where('orderStatus.hubNear', isEqualTo: true)
            .where('orderStatus.enroute', isEqualTo: true)
            .where('orderStatus.delivered', isEqualTo: true)
            .get();
    setState(() {
      _deliveredOrdersCount = querySnapshot.size;
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
                  Icons.handshake,
                  color: Colors.green,
                  size: 20,
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 1.0, right: 10),
                child: Text(
                  '$_deliveredOrdersCount', // Display the count for orders with status as Shipped
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
                  'Delivered Orders',
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
