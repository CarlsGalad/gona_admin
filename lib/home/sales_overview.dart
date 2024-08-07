import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class SalesOverviewTile extends StatefulWidget {
  const SalesOverviewTile({super.key});

  @override
  State<SalesOverviewTile> createState() => _SalesOverviewTileState();
}

class _SalesOverviewTileState extends State<SalesOverviewTile> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Card(
        elevation: 1,
        color: Colors.white70,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: SizedBox(
          width: 500,
          height: 250,
          child: Padding(
            padding: const EdgeInsets.only(left: 15),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: EdgeInsets.all(10),
                  child: Text(
                    'Manage',
                    style: GoogleFonts.abel(fontWeight: FontWeight.bold),
                  ),
                ),
                Row(
                  children: [
                    MaterialButton(
                      height: 20,
                      color: Colors.orange.shade200,
                      elevation: 2,
                      onPressed: () {},
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10)),
                      child: Padding(
                          padding: EdgeInsets.all(8.0),
                          child: Text(
                            'View',
                            style: GoogleFonts.abel(
                                fontWeight: FontWeight.bold,
                                color: Colors.white70),
                          )),
                    ),
                    const Spacer(),
                    const Icon(
                      Icons.language,
                      color: Colors.grey,
                    ),
                    const Padding(
                      padding: EdgeInsets.all(15.0),
                      child: Text('Top Vendors'),
                    ),
                  ],
                ),
                Row(
                  children: [
                    Text(
                      'Manage Vendors',
                      style: GoogleFonts.abel(
                          fontWeight: FontWeight.bold, fontSize: 18),
                    ),
                  ],
                ),
                const SizedBox(
                  height: 15,
                ),
                Row(
                  children: [
                    MaterialButton(
                      color: Colors.orange.shade200,
                      elevation: 2,
                      onPressed: () {},
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10)),
                      child: Padding(
                          padding: EdgeInsets.all(8.0),
                          child: Text(
                            'View',
                            style: GoogleFonts.abel(
                                fontWeight: FontWeight.bold,
                                color: Colors.grey),
                          )),
                    ),
                    const Spacer(),
                    const Icon(
                      Icons.people,
                      color: Colors.grey,
                    ),
                    const Padding(
                      padding: EdgeInsets.all(15.0),
                      child: Text('Top Customers'),
                    ),
                  ],
                ),
                Row(
                  children: [
                    Text(
                      'Manage Customers',
                      style: GoogleFonts.abel(
                          fontWeight: FontWeight.bold, fontSize: 18),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
