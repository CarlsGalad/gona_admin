import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

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
            .where('orderStatus.delivered', isEqualTo: true)
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
      child: Container(
        width: 120,
        height: 140,
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topRight,
            colors: [
              Colors.blueGrey,
              Colors.deepPurple,
              Colors.deepPurpleAccent,
              Colors.deepPurple,
            ],
          ),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Padding(
          padding: const EdgeInsets.only(left: 15),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Padding(
                padding: EdgeInsets.only(top: 10.0, right: 10),
                child: Icon(
                  Icons.delivery_dining,
                  color: Colors.grey,
                  size: 30,
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 1.0, right: 10),
                child: Text(
                  '$_deliveredOrdersCount', // Display the count for orders with status as Shipped
                  style: const TextStyle(
                      fontSize: 30,
                      color: Colors.white,
                      fontWeight: FontWeight.bold),
                  textAlign: TextAlign.start,
                  softWrap: false,
                ),
              ),
              const Spacer(),
              const Padding(
                padding: EdgeInsets.only(bottom: 12.0),
                child: Text(
                  'Delivered Orders',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
