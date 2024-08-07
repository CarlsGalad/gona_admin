import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class VendorCountTile extends StatefulWidget {
  const VendorCountTile({super.key});

  @override
  State<VendorCountTile> createState() => _VendorCountTileState();
}

class _VendorCountTileState extends State<VendorCountTile> {
  int _newVendorCount = 0;

  @override
  void initState() {
    super.initState();
    _fetchNewVendorCount();
  }

  Future<void> _fetchNewVendorCount() async {
    // Get the current date and time
    final DateTime now = DateTime.now();

    // Calculate the date one week ago
    final DateTime oneWeekAgo = now.subtract(const Duration(days: 7));

    // Query the 'farms' collection in Firestore
    final QuerySnapshot<Map<String, dynamic>> querySnapshot =
        await FirebaseFirestore.instance
            .collection('farms')
            .where('createdAt', isGreaterThan: oneWeekAgo)
            .get();

    // Update the _newVendorCount with the count of documents returned by the query
    setState(() {
      _newVendorCount = querySnapshot.size;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: SizedBox(
        width: 120,
        height: 120,
        child: Padding(
          padding: const EdgeInsets.only(left: 15),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Padding(
                padding: EdgeInsets.only(top: 10.0, right: 10),
                child: Icon(
                  Icons.verified_user,
                  color: Colors.green,
                  size: 20,
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 5.0, right: 10),
                child: Text(
                  '$_newVendorCount', // Display number of new vendors
                  style: GoogleFonts.aboreto(
                      fontSize: 30,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey),
                  textAlign: TextAlign.start,
                  softWrap: false,
                ),
              ),
              const Spacer(),
              Padding(
                padding: const EdgeInsets.only(bottom: 12.0),
                child: Text(
                  'New Vendors',
                  style: GoogleFonts.abel(fontWeight: FontWeight.bold),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
