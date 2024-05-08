import 'package:flutter/material.dart';

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
      child: Container(
        width: 500,
        height: 250,
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.bottomLeft,
            colors: [
              Colors.blueGrey,
              Colors.deepPurple,
              Colors.deepPurpleAccent,
              Colors.teal,
              Colors.tealAccent,
              Colors.blueGrey,
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
                padding: EdgeInsets.all(10),
                child: Text(
                  'Sales Overview',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
              Row(
                children: [
                  Container(
                    decoration: const BoxDecoration(
                        color: Colors.black38,
                        borderRadius: BorderRadius.all(Radius.circular(10))),
                    child: const Padding(
                        padding: EdgeInsets.all(8.0),
                        child: Text(
                          'View',
                          style: TextStyle(
                              fontWeight: FontWeight.bold, color: Colors.grey),
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
              const Row(
                children: [
                  Text(
                    'Manage Vendors',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                  ),
                ],
              ),
              const SizedBox(
                height: 15,
              ),
              Row(
                children: [
                  Container(
                    decoration: const BoxDecoration(
                        color: Colors.black38,
                        borderRadius: BorderRadius.all(Radius.circular(10))),
                    child: const Padding(
                        padding: EdgeInsets.all(8.0),
                        child: Text(
                          'View',
                          style: TextStyle(
                              fontWeight: FontWeight.bold, color: Colors.grey),
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
              const Row(
                children: [
                  Text(
                    'Manage Customers',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
