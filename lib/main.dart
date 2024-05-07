import 'package:flutter/material.dart';

import 'package:gona_admin/welcomemsg.dart';

void main() {
  runApp(const GonaAdmin());
}

class GonaAdmin extends StatelessWidget {
  const GonaAdmin({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: AdminHome(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class AdminHome extends StatefulWidget {
  const AdminHome({super.key});

  @override
  State<AdminHome> createState() => _AdminHomeState();
}

class _AdminHomeState extends State<AdminHome> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Admin',
          style: TextStyle(color: Colors.white),
        ),
        centerTitle: true,
        backgroundColor: Colors.black,
        foregroundColor: Colors.black54,
      ),
      body: SingleChildScrollView(
        child: Container(
          color: Colors.black54,
          child: Column(
            children: [
              const WelcomeBackWidget(),
              Container(
                decoration: const BoxDecoration(
                    color: Color.fromARGB(255, 26, 25, 25),
                    borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(15),
                        topRight: Radius.circular(15))),
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      //first row
                      Row(
                        children: [
                          Column(
                            children: [
                              Row(
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Container(
                                      width: 240,
                                      height: 120,
                                      decoration: BoxDecoration(
                                        color: Colors.grey,
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                      child: const Padding(
                                        padding: EdgeInsets.only(left: 15),
                                        child: Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.start,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Padding(
                                              padding: EdgeInsets.only(
                                                  top: 10.0, right: 10),
                                              child: Text(
                                                '150,000', // Display the total sales count
                                                style: TextStyle(fontSize: 30),
                                                textAlign: TextAlign.start,
                                                softWrap: false,
                                              ),
                                            ),
                                            Spacer(),
                                            Padding(
                                              padding:
                                                  EdgeInsets.only(bottom: 12.0),
                                              child: Text(
                                                'Total Sales',
                                                style: TextStyle(
                                                    fontWeight:
                                                        FontWeight.bold),
                                              ),
                                            )
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Container(
                                      width: 120,
                                      height: 120,
                                      decoration: BoxDecoration(
                                        color: Colors.grey,
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                      child: const Padding(
                                        padding: EdgeInsets.only(left: 15),
                                        child: Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.start,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Padding(
                                              padding: EdgeInsets.only(
                                                  top: 10.0, right: 10),
                                              child: Text(
                                                '500', // Display the pending order
                                                style: TextStyle(fontSize: 30),
                                                textAlign: TextAlign.start,
                                                softWrap: false,
                                              ),
                                            ),
                                            Spacer(),
                                            Padding(
                                              padding:
                                                  EdgeInsets.only(bottom: 12.0),
                                              child: Text(
                                                'Pending Orders',
                                                style: TextStyle(
                                                    fontWeight:
                                                        FontWeight.bold),
                                              ),
                                            )
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),

// secon row
                              Row(
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Container(
                                      width: 120,
                                      height: 120,
                                      decoration: BoxDecoration(
                                        color: Colors.grey,
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                      child: const Padding(
                                        padding: EdgeInsets.only(left: 15),
                                        child: Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.start,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Padding(
                                              padding: EdgeInsets.only(
                                                  top: 10.0, right: 10),
                                              child: Text(
                                                '10', // Display number of new vendors
                                                style: TextStyle(fontSize: 30),
                                                textAlign: TextAlign.start,
                                                softWrap: false,
                                              ),
                                            ),
                                            Spacer(),
                                            Padding(
                                              padding:
                                                  EdgeInsets.only(bottom: 12.0),
                                              child: Text(
                                                'New Vendors',
                                                style: TextStyle(
                                                    fontWeight:
                                                        FontWeight.bold),
                                              ),
                                            )
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Container(
                                      width: 240,
                                      height: 120,
                                      decoration: BoxDecoration(
                                        color: Colors.grey,
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                      child: const Padding(
                                        padding: EdgeInsets.only(left: 15),
                                        child: Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.start,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Padding(
                                              padding: EdgeInsets.only(
                                                  top: 10.0, right: 10),
                                              child: Text(
                                                '300', // Display the num of new users inthe last one week
                                                style: TextStyle(fontSize: 30),
                                                textAlign: TextAlign.start,
                                                softWrap: false,
                                              ),
                                            ),
                                            Spacer(),
                                            Padding(
                                              padding:
                                                  EdgeInsets.only(bottom: 12.0),
                                              child: Text(
                                                'New Users',
                                                style: TextStyle(
                                                    fontWeight:
                                                        FontWeight.bold),
                                              ),
                                            )
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Container(
                                width: 350,
                                height: 250,
                                decoration: BoxDecoration(
                                  color: Colors.grey,
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.only(left: 15),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      const Padding(
                                        padding: EdgeInsets.all(10),
                                        child: Text(
                                          'Sales Overview',
                                          style: TextStyle(
                                              fontWeight: FontWeight.bold),
                                        ),
                                      ),
                                      Row(
                                        children: [
                                          Container(
                                            decoration: const BoxDecoration(
                                                color: Colors.black38,
                                                borderRadius: BorderRadius.all(
                                                    Radius.circular(10))),
                                            child: const Padding(
                                                padding: EdgeInsets.all(8.0),
                                                child: Text(
                                                  'View',
                                                  style: TextStyle(
                                                      fontWeight:
                                                          FontWeight.bold),
                                                )),
                                          ),
                                          const Spacer(),
                                          const Icon(Icons.language),
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
                                            style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 18),
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
                                                borderRadius: BorderRadius.all(
                                                    Radius.circular(10))),
                                            child: const Padding(
                                                padding: EdgeInsets.all(8.0),
                                                child: Text(
                                                  'View',
                                                  style: TextStyle(
                                                      fontWeight:
                                                          FontWeight.bold),
                                                )),
                                          ),
                                          const Spacer(),
                                          const Icon(Icons.people),
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
                                            style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 18),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),

                      const Padding(
                        padding: EdgeInsets.all(8.0),
                        child: Text(
                          'Testing me',
                          textAlign: TextAlign.start,
                          style: TextStyle(
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
