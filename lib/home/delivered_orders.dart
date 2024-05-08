import 'package:flutter/material.dart';

class DeliveredCountTitle extends StatefulWidget {
  const DeliveredCountTitle({super.key});

  @override
  State<DeliveredCountTitle> createState() => _DeliveredCountTitleState();
}

class _DeliveredCountTitleState extends State<DeliveredCountTitle> {
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
        child: const Padding(
          padding: EdgeInsets.only(left: 15),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: EdgeInsets.only(top: 10.0, right: 10),
                child: Icon(
                  Icons.delivery_dining,
                  color: Colors.grey,
                  size: 30,
                ),
              ),
              Padding(
                padding: EdgeInsets.only(top: 1.0, right: 10),
                child: Text(
                  '367', // Display the count for orders with status as Shipped
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
