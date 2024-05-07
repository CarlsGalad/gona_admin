import 'package:flutter/material.dart';

class TotalSalesTile extends StatefulWidget {
  const TotalSalesTile({super.key});

  @override
  State<TotalSalesTile> createState() => _TotalSalesTileState();
}

class _TotalSalesTileState extends State<TotalSalesTile> {
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
        child: const Padding(
          padding: EdgeInsets.only(left: 15),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: EdgeInsets.only(top: 10.0, right: 10),
                child: Icon(
                  Icons.money_sharp,
                  size: 30,
                  color: Colors.grey,
                ),
              ),
              Padding(
                padding: EdgeInsets.only(top: 5.0, right: 10),
                child: Text(
                  '₦150,000', // Display the total sales count
                  style: TextStyle(
                      fontSize: 30,
                      color: Colors.white,
                      fontWeight: FontWeight.bold),
                  textAlign: TextAlign.start,
                  softWrap: false,
                ),
              ),
              Spacer(),
              Padding(
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
