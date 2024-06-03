import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class PaymentManagementScreen extends StatefulWidget {
  const PaymentManagementScreen({super.key});

  @override
  PaymentManagementScreenState createState() => PaymentManagementScreenState();
}

class PaymentManagementScreenState extends State<PaymentManagementScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

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
        title: const Text('Payment Management'),
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

                              return DataTable(
                                columns: const [
                                  DataColumn(label: Text('Vendor')),
                                  DataColumn(label: Text('Amount')),
                                  DataColumn(label: Text('Account Number')),
                                  DataColumn(label: Text('Bank Name')),
                                  DataColumn(label: Text('Account Name')),
                                ],
                                rows: snapshot.data!.map((payment) {
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

                              return DataTable(
                                columns: const [
                                  DataColumn(label: Text('Resolve')),
                                  DataColumn(label: Text('First Name')),
                                  DataColumn(label: Text('Last Name')),
                                  DataColumn(label: Text('Amount')),
                                  DataColumn(label: Text('Email')),
                                  DataColumn(label: Text('Mobile')),
                                ],
                                rows: snapshot.data!.map((refund) {
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
                Expanded(
                  flex: 1,
                  child: SingleChildScrollView(
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
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
                                return const Text(
                                    'No escrow details available.');
                              }

                              return DataTable(
                                columns: const [
                                  DataColumn(label: Text('Vendor')),
                                  DataColumn(label: Text('Amount')),
                                  DataColumn(label: Text('Release Schedule')),
                                ],
                                rows: snapshot.data!.map((escrow) {
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

                        return DataTable(
                          columns: const [
                            DataColumn(label: Text('Vendor')),
                            DataColumn(label: Text('Amount')),
                            DataColumn(label: Text('Account Number')),
                            DataColumn(label: Text('Bank Name')),
                            DataColumn(label: Text('Account Name')),
                          ],
                          rows: snapshot.data!.map((payment) {
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

                        return DataTable(
                          columns: const [
                            DataColumn(label: Text('Vendor')),
                            DataColumn(label: Text('Amount')),
                            DataColumn(label: Text('Release Schedule')),
                          ],
                          rows: snapshot.data!.map((escrow) {
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

                        return DataTable(
                          columns: const [
                            DataColumn(label: Text('Resolve')),
                            DataColumn(label: Text('First Name')),
                            DataColumn(label: Text('Last Name')),
                            DataColumn(label: Text('Amount')),
                            DataColumn(label: Text('Email')),
                            DataColumn(label: Text('Mobile')),
                          ],
                          rows: snapshot.data!.map((refund) {
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
