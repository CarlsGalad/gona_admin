import 'package:flutter/material.dart';

class PendingOrderTile extends StatefulWidget {
  const PendingOrderTile({super.key});

  @override
  State<PendingOrderTile> createState() => _PendingOrderTileState();
}

class _PendingOrderTileState extends State<PendingOrderTile> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Container(
        width: 120,
        height: 120,
        decoration: BoxDecoration(
          gradient: const LinearGradient(begin: Alignment.bottomLeft, colors: [
            Colors.blueGrey,
            Colors.deepPurple,
            Colors.deepPurpleAccent,
            Colors.deepPurple,
          ], stops: [
            0.1,
            0.3,
            0.9,
            1.0
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
                  Icons.access_time,
                  color: Colors.grey,
                  size: 30,
                ),
              ),
              Padding(
                padding: EdgeInsets.only(top: 1.0, right: 10),
                child: Text(
                  '500', // Display the pending order
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
                  'Pending Orders',
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
