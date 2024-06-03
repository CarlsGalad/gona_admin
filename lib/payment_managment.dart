import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/rendering.dart';
import 'package:google_fonts/google_fonts.dart';

class PaymentManagementScreen extends StatefulWidget {
  @override
  _PaymentManagementScreenState createState() =>
      _PaymentManagementScreenState();
}

class _PaymentManagementScreenState extends State<PaymentManagementScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  Future<List<Map<String, dynamic>>> _fetchPaymentReleases() async {
    List<Map<String, dynamic>> paymentReleases = [];
    QuerySnapshot orderSnapshot = await _firestore
        .collection('orders')
        .where('orderStatus.placed', isEqualTo: true)
        .where('orderStatus.processed', isEqualTo: true)
        .where('orderStatus.picked', isEqualTo: true)
        .where('orderStatus.shipped', isEqualTo: true)
        .where('orderStatus.hubNear', isEqualTo: true)
        .where('orderStatus.enroute', isEqualTo: true)
        .where('orderStatus.delivered', isEqualTo: true)
        .get();

    for (var orderDoc in orderSnapshot.docs) {
      var orderData = orderDoc.data() as Map<String, dynamic>;
      List<dynamic> orderItems = orderData['orderItems'] ?? [];
      String farmId = orderData['farmId'];

      for (var item in orderItems) {
        double price = item['price'];
        int quantity = item['quantity'];
        double deliveryFee = item['deliveryFee'] ?? 0.0;
        double totalAmount = (price * quantity) * 0.94 - deliveryFee;

        DocumentSnapshot farmDoc =
            await _firestore.collection('farms').doc(farmId).get();
        var farmData = farmDoc.data() as Map<String, dynamic>;
        var accountDetails = farmData['accountDetails'];

        paymentReleases.add({
          'farmName': farmData['farmName'],
          'totalAmount': totalAmount,
          'accountNumber': accountDetails['accountNumber'],
          'bankName': accountDetails['bankName'],
          'accountName': accountDetails['accountName'],
        });
      }
    }

    return paymentReleases;
  }

  Future<List<Map<String, dynamic>>> _fetchEscrowDetails() async {
    List<Map<String, dynamic>> escrowDetails = [];
    QuerySnapshot orderSnapshot = await _firestore
        .collection('orders')
        .where('orderStatus.placed', isEqualTo: true)
        .where('orderStatus.processed', isEqualTo: true)
        .where('orderStatus.picked', isEqualTo: true)
        .where('orderStatus.shipped', isEqualTo: true)
        .where('orderStatus.hubNear', isEqualTo: true)
        .where('orderStatus.enroute', isEqualTo: true)
        .where('orderStatus.delivered', isEqualTo: true)
        .get();

    for (var orderDoc in orderSnapshot.docs) {
      var orderData = orderDoc.data() as Map<String, dynamic>;
      List<dynamic> orderItems = orderData['orderItems'] ?? [];
      String farmId = orderData['farmId'];

      for (var item in orderItems) {
        double price = item['price'];
        int quantity = item['quantity'];
        double deliveryFee = item['deliveryFee'] ?? 0.0;
        double totalAmount = (price * quantity) * 0.94 - deliveryFee;

        DocumentSnapshot farmDoc =
            await _firestore.collection('farms').doc(farmId).get();
        var farmData = farmDoc.data() as Map<String, dynamic>;

        escrowDetails.add({
          'farmName': farmData['farmName'],
          'totalAmount': totalAmount,
          'releaseSchedule': '6 PM Daily',
        });
      }
    }

    return escrowDetails;
  }

  Future<List<Map<String, dynamic>>> _fetchRefunds() async {
    List<Map<String, dynamic>> refunds = [];
    QuerySnapshot disputeSnapshot = await _firestore
        .collection('disputes')
        .where('resolve', isEqualTo: 'refund')
        .get();

    for (var disputeDoc in disputeSnapshot.docs) {
      var disputeData = disputeDoc.data() as Map<String, dynamic>;
      String userId = disputeData['userId'];
      double amount = disputeData['amount'];

      DocumentSnapshot userDoc =
          await _firestore.collection('users').doc(userId).get();
      var userData = userDoc.data() as Map<String, dynamic>;

      refunds.add({
        'resolve': disputeData['resolve'],
        'firstName': userData['firstName'],
        'lastName': userData['lastName'],
        'amount': amount,
        'email': userData['email'],
        'mobile': userData['mobile'],
      });
    }

    return refunds;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: Text(
          'Payment Management',
          style: GoogleFonts.roboto(color: Colors.white54),
        ),
        centerTitle: true,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(kToolbarHeight),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 200.0, vertical: 8),
            child: TextField(
              controller: _searchController,
              onChanged: (value) {
                setState(() {
                  _searchQuery = value.toLowerCase();
                });
              },
              decoration: InputDecoration(
                fillColor: Colors.white,
                hintText: 'Search...',
                border: OutlineInputBorder(
                  borderSide: const BorderSide(color: Colors.white),
                  borderRadius: BorderRadius.circular(8.0),
                ),
                prefixIcon: const Icon(
                  Icons.search,
                  color: Colors.white54,
                ),
              ),
            ),
          ),
        ),
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          if (constraints.maxWidth > 800) {
            // Two-column layout for larger screens
            return Row(
              children: [
                Expanded(
                  flex: 4,
                  child: SingleChildScrollView(
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Releasing Payments to Vendors',
                              style: GoogleFonts.aboreto(
                                  fontWeight: FontWeight.bold, fontSize: 18)),
                          const Divider(
                            indent: 5,
                            endIndent: 5,
                          ),
                          FutureBuilder<List<Map<String, dynamic>>>(
                            future: _fetchPaymentReleases(),
                            builder: (context, snapshot) {
                              if (snapshot.connectionState ==
                                  ConnectionState.waiting) {
                                return const Center(
                                    child: CircularProgressIndicator());
                              }

                              if (!snapshot.hasData || snapshot.data!.isEmpty) {
                                return Center(
                                  child: Text(
                                    'No payments to release.',
                                    style: GoogleFonts.abel(),
                                  ),
                                );
                              }

                              List<Map<String, dynamic>> filteredData =
                                  snapshot.data!.where((payment) {
                                return payment['farmName']
                                        .toString()
                                        .toLowerCase()
                                        .contains(_searchQuery) ||
                                    payment['accountNumber']
                                        .toString()
                                        .toLowerCase()
                                        .contains(_searchQuery) ||
                                    payment['bankName']
                                        .toString()
                                        .toLowerCase()
                                        .contains(_searchQuery) ||
                                    payment['accountName']
                                        .toString()
                                        .toLowerCase()
                                        .contains(_searchQuery);
                              }).toList();

                              return DataTable(
                                columns: const [
                                  DataColumn(label: Text('Vendor')),
                                  DataColumn(label: Text('Amount')),
                                  DataColumn(label: Text('Account Number')),
                                  DataColumn(label: Text('Bank Name')),
                                  DataColumn(label: Text('Account Name')),
                                ],
                                rows: filteredData.map((payment) {
                                  return DataRow(
                                    cells: [
                                      DataCell(Text(payment['farmName'])),
                                      DataCell(Text(payment['totalAmount']
                                          .toStringAsFixed(2))),
                                      DataCell(Text(payment['accountNumber'])),
                                      DataCell(Text(payment['bankName'])),
                                      DataCell(Text(payment['accountName'])),
                                    ],
                                  );
                                }).toList(),
                              );
                            },
                          ),
                          const SizedBox(height: 20),
                          const Divider(
                            thickness: 1,
                          ),
                          Text(
                            'Refund Management',
                            style: GoogleFonts.aboreto(
                                fontWeight: FontWeight.bold, fontSize: 18),
                          ),
                          const Divider(
                            height: 0.5,
                            indent: 5,
                            endIndent: 5,
                          ),
                          FutureBuilder<List<Map<String, dynamic>>>(
                            future: _fetchRefunds(),
                            builder: (context, snapshot) {
                              if (snapshot.connectionState ==
                                  ConnectionState.waiting) {
                                return const Center(
                                    child: CircularProgressIndicator());
                              }

                              if (!snapshot.hasData || snapshot.data!.isEmpty) {
                                return Center(
                                  child: Text(
                                    'No refunds available.',
                                    style: GoogleFonts.abel(),
                                  ),
                                );
                              }

                              List<Map<String, dynamic>> filteredData =
                                  snapshot.data!.where((refund) {
                                return refund['firstName']
                                        .toString()
                                        .toLowerCase()
                                        .contains(_searchQuery) ||
                                    refund['lastName']
                                        .toString()
                                        .toLowerCase()
                                        .contains(_searchQuery) ||
                                    refund['email']
                                        .toString()
                                        .toLowerCase()
                                        .contains(_searchQuery) ||
                                    refund['mobile']
                                        .toString()
                                        .toLowerCase()
                                        .contains(_searchQuery);
                              }).toList();

                              return DataTable(
                                columns: const [
                                  DataColumn(label: Text('Resolve')),
                                  DataColumn(label: Text('First Name')),
                                  DataColumn(label: Text('Last Name')),
                                  DataColumn(label: Text('Amount')),
                                  DataColumn(label: Text('Email')),
                                  DataColumn(label: Text('Mobile')),
                                ],
                                rows: filteredData.map((refund) {
                                  return DataRow(
                                    cells: [
                                      DataCell(Text(refund['resolve'])),
                                      DataCell(Text(refund['firstName'])),
                                      DataCell(Text(refund['lastName'])),
                                      DataCell(Text(
                                          refund['amount'].toStringAsFixed(2))),
                                      DataCell(Text(refund['email'])),
                                      DataCell(Text(refund['mobile'])),
                                    ],
                                  );
                                }).toList(),
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const VerticalDivider(
                  width: 1,
                ),
                Expanded(
                  flex: 1,
                  child: SingleChildScrollView(
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Escrow Account Details',
                            style: GoogleFonts.aboreto(
                                fontWeight: FontWeight.bold, fontSize: 18),
                          ),
                          const Divider(
                            indent: 5,
                            endIndent: 600,
                          ),
                          FutureBuilder<List<Map<String, dynamic>>>(
                            future: _fetchEscrowDetails(),
                            builder: (context, snapshot) {
                              if (snapshot.connectionState ==
                                  ConnectionState.waiting) {
                                return const Center(
                                    child: CircularProgressIndicator());
                              }

                              if (!snapshot.hasData || snapshot.data!.isEmpty) {
                                return Center(
                                  child: Text(
                                    'No escrow details available.',
                                    style: GoogleFonts.abel(),
                                  ),
                                );
                              }

                              List<Map<String, dynamic>> filteredData =
                                  snapshot.data!.where((escrow) {
                                return escrow['farmName']
                                    .toString()
                                    .toLowerCase()
                                    .contains(_searchQuery);
                              }).toList();

                              return DataTable(
                                columns: const [
                                  DataColumn(label: Text('Vendor')),
                                  DataColumn(label: Text('Amount')),
                                  DataColumn(label: Text('Release Schedule')),
                                ],
                                rows: filteredData.map((escrow) {
                                  return DataRow(
                                    cells: [
                                      DataCell(Text(escrow['farmName'])),
                                      DataCell(Text(escrow['totalAmount']
                                          .toStringAsFixed(2))),
                                      DataCell(Text(escrow['releaseSchedule'])),
                                    ],
                                  );
                                }).toList(),
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            );
          } else {
            // Single-column layout for smaller screens
            return SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Releasing Payments to Vendors',
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 18)),
                    FutureBuilder<List<Map<String, dynamic>>>(
                      future: _fetchPaymentReleases(),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const Center(
                              child: CircularProgressIndicator());
                        }

                        if (!snapshot.hasData || snapshot.data!.isEmpty) {
                          return const Text('No payments to release.');
                        }

                        List<Map<String, dynamic>> filteredData =
                            snapshot.data!.where((payment) {
                          return payment['farmName']
                                  .toString()
                                  .toLowerCase()
                                  .contains(_searchQuery) ||
                              payment['accountNumber']
                                  .toString()
                                  .toLowerCase()
                                  .contains(_searchQuery) ||
                              payment['bankName']
                                  .toString()
                                  .toLowerCase()
                                  .contains(_searchQuery) ||
                              payment['accountName']
                                  .toString()
                                  .toLowerCase()
                                  .contains(_searchQuery);
                        }).toList();

                        return DataTable(
                          columns: const [
                            DataColumn(label: Text('Vendor')),
                            DataColumn(label: Text('Amount')),
                            DataColumn(label: Text('Account Number')),
                            DataColumn(label: Text('Bank Name')),
                            DataColumn(label: Text('Account Name')),
                          ],
                          rows: filteredData.map((payment) {
                            return DataRow(
                              cells: [
                                DataCell(Text(payment['farmName'])),
                                DataCell(Text(
                                    payment['totalAmount'].toStringAsFixed(2))),
                                DataCell(Text(payment['accountNumber'])),
                                DataCell(Text(payment['bankName'])),
                                DataCell(Text(payment['accountName'])),
                              ],
                            );
                          }).toList(),
                        );
                      },
                    ),
                    const SizedBox(height: 20),
                    const Text('Refund Management',
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 18)),
                    FutureBuilder<List<Map<String, dynamic>>>(
                      future: _fetchRefunds(),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const Center(
                              child: CircularProgressIndicator());
                        }

                        if (!snapshot.hasData || snapshot.data!.isEmpty) {
                          return const Text('No refunds available.');
                        }

                        List<Map<String, dynamic>> filteredData =
                            snapshot.data!.where((refund) {
                          return refund['firstName']
                                  .toString()
                                  .toLowerCase()
                                  .contains(_searchQuery) ||
                              refund['lastName']
                                  .toString()
                                  .toLowerCase()
                                  .contains(_searchQuery) ||
                              refund['email']
                                  .toString()
                                  .toLowerCase()
                                  .contains(_searchQuery) ||
                              refund['mobile']
                                  .toString()
                                  .toLowerCase()
                                  .contains(_searchQuery);
                        }).toList();

                        return DataTable(
                          columns: const [
                            DataColumn(label: Text('Resolve')),
                            DataColumn(label: Text('First Name')),
                            DataColumn(label: Text('Last Name')),
                            DataColumn(label: Text('Amount')),
                            DataColumn(label: Text('Email')),
                            DataColumn(label: Text('Mobile')),
                          ],
                          rows: filteredData.map((refund) {
                            return DataRow(
                              cells: [
                                DataCell(Text(refund['resolve'])),
                                DataCell(Text(refund['firstName'])),
                                DataCell(Text(refund['lastName'])),
                                DataCell(
                                    Text(refund['amount'].toStringAsFixed(2))),
                                DataCell(Text(refund['email'])),
                                DataCell(Text(refund['mobile'])),
                              ],
                            );
                          }).toList(),
                        );
                      },
                    ),
                    const SizedBox(height: 20),
                    const Text('Escrow Account Details',
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 18)),
                    FutureBuilder<List<Map<String, dynamic>>>(
                      future: _fetchEscrowDetails(),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const Center(
                              child: CircularProgressIndicator());
                        }

                        if (!snapshot.hasData || snapshot.data!.isEmpty) {
                          return const Text('No escrow details available.');
                        }

                        List<Map<String, dynamic>> filteredData =
                            snapshot.data!.where((escrow) {
                          return escrow['farmName']
                              .toString()
                              .toLowerCase()
                              .contains(_searchQuery);
                        }).toList();

                        return DataTable(
                          columns: const [
                            DataColumn(label: Text('Vendor')),
                            DataColumn(label: Text('Amount')),
                            DataColumn(label: Text('Release Schedule')),
                          ],
                          rows: filteredData.map((escrow) {
                            return DataRow(
                              cells: [
                                DataCell(Text(escrow['farmName'])),
                                DataCell(Text(
                                    escrow['totalAmount'].toStringAsFixed(2))),
                                DataCell(Text(escrow['releaseSchedule'])),
                              ],
                            );
                          }).toList(),
                        );
                      },
                    ),
                  ],
                ),
              ),
            );
          }
        },
      ),
    );
  }
}
