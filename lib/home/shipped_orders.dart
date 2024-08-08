import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ShippedOdersCount extends StatefulWidget {
  const ShippedOdersCount({super.key});

  @override
  State<ShippedOdersCount> createState() => _ShippedOdersCountState();
}

class _ShippedOdersCountState extends State<ShippedOdersCount> {
  int _shippedOrdersCount = 0;

  @override
  void initState() {
    super.initState();
    _fetchShippedOrdersCount();
  }

  Future<void> _fetchShippedOrdersCount() async {
    final QuerySnapshot<Map<String, dynamic>> querySnapshot =
        await FirebaseFirestore.instance
            .collection('orders')
            .where('orderStatus.placed', isEqualTo: true)
            .where('orderStatus.processed', isEqualTo: true)
            .where('orderStatus.picked', isEqualTo: true)
            .where('orderStatus.shipped', isEqualTo: true)
            .where('orderStatus.hubNear', isEqualTo: false)
            .where('orderStatus.enroute', isEqualTo: false)
            .where('orderStatus.delivered', isEqualTo: false)
            .get();
    setState(() {
      _shippedOrdersCount = querySnapshot.size;
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
                  Icons.flight_takeoff,
                  color: Colors.deepOrange,
                  size: 20,
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 1.0, right: 10),
                child: Text(
                  '$_shippedOrdersCount', // Display the count for orders with status as Shipped
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
                padding: EdgeInsets.only(bottom: 12.0),
                child: Text(
                  'Shipped Orders',
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
