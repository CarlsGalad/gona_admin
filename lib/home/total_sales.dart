import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class TotalSalesTile extends StatefulWidget {
  const TotalSalesTile({super.key});

  @override
  State<TotalSalesTile> createState() => _TotalSalesTileState();
}

class _TotalSalesTileState extends State<TotalSalesTile> {
  int totalSales = 0;

  @override
  void initState() {
    super.initState();
    _fetchTotalSales();
  }

  Future<void> _fetchTotalSales() async {
    int salesSum = 0;

    // Query the sales collection
    QuerySnapshot salesSnapshot =
        await FirebaseFirestore.instance.collection('sales').get();

    // Sum up the quantity of all sales
    for (var doc in salesSnapshot.docs) {
      salesSum += doc['quantity'] as int;
    }

    // Update the state with the total sales
    setState(() {
      totalSales = salesSum;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Container(
        width: 255,
        height: 120,
        decoration: BoxDecoration(
          gradient: const LinearGradient(begin: Alignment.topLeft, colors: [
            Colors.deepPurple,
            Colors.deepPurpleAccent,
            Colors.deepPurple,
            Colors.blueGrey
          ]),
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
                  Icons.money_sharp,
                  size: 30,
                  color: Colors.grey,
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 5.0, right: 10),
                child: Text(
                  '₦$totalSales', // Display the total sales count
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
                  'Total Sales',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
