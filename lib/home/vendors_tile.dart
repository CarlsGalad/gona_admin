import 'package:flutter/material.dart';

class VendorCountTile extends StatefulWidget {
  const VendorCountTile({super.key});

  @override
  State<VendorCountTile> createState() => _VendorCountTileState();
}

class _VendorCountTileState extends State<VendorCountTile> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Container(
        width: 120,
        height: 120,
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
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
                  Icons.verified_user,
                  color: Colors.grey,
                  size: 25,
                ),
              ),
              Padding(
                padding: EdgeInsets.only(top: 5.0, right: 10),
                child: Text(
                  '10', // Display number of new vendors
                  style: TextStyle(
                      fontSize: 30,
                      fontWeight: FontWeight.bold,
                      color: Colors.white),
                  textAlign: TextAlign.start,
                  softWrap: false,
                ),
              ),
              Spacer(),
              Padding(
                padding: EdgeInsets.only(bottom: 12.0),
                child: Text(
                  'New Vendors',
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
