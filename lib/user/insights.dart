import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class CustomerInsightsScreen extends StatelessWidget {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<List<Map<String, dynamic>>> _fetchCustomerPurchaseBehavior() async {
    List<Map<String, dynamic>> purchaseBehavior = [];
    QuerySnapshot customerSnapshot =
        await _firestore.collection('users').get();

    for (var customerDoc in customerSnapshot.docs) {
      var customerData = customerDoc.data() as Map<String, dynamic>;
      List<dynamic> purchases = customerData['purchases'] ?? [];
      int totalPurchases = purchases.length;
      Map<String, int> itemFrequency = {};

      for (var purchase in purchases) {
        String itemId = purchase['itemId'];
        if (itemFrequency.containsKey(itemId)) {
          itemFrequency[itemId] = itemFrequency[itemId]! + 1;
        } else {
          itemFrequency[itemId] = 1;
        }
      }

      var sortedItems = itemFrequency.entries.toList()
        ..sort((a, b) => b.value.compareTo(a.value));
      var frequentItems = sortedItems.take(3).map((e) => e.key).toList();

      purchaseBehavior.add({
        'customerName': customerData['name'],
        'totalPurchases': totalPurchases,
        'frequentItems': frequentItems,
      });
    }

    return purchaseBehavior;
  }

  Future<Map<String, double>> _fetchRetentionAndChurnRates() async {
    QuerySnapshot customerSnapshot =
        await _firestore.collection('users').get();
    int totalCustomers = customerSnapshot.size;
    int retainedCustomers = 0;
    int churnedCustomers = 0;

    for (var customerDoc in customerSnapshot.docs) {
      var customerData = customerDoc.data() as Map<String, dynamic>;
      bool isRetained = customerData['isRetained'] ?? false;
      if (isRetained) {
        retainedCustomers++;
      } else {
        churnedCustomers++;
      }
    }

    double retentionRate =
        totalCustomers > 0 ? (retainedCustomers / totalCustomers) * 100 : 0;
    double churnRate =
        totalCustomers > 0 ? (churnedCustomers / totalCustomers) * 100 : 0;

    return {
      'retentionRate': retentionRate,
      'churnRate': churnRate,
    };
  }

  Future<List<Map<String, dynamic>>> _fetchCustomerSatisfactionScores() async {
    List<Map<String, dynamic>> satisfactionScores = [];
    QuerySnapshot feedbackSnapshot =
        await _firestore.collection('feedback').get();

    for (var feedbackDoc in feedbackSnapshot.docs) {
      var feedbackData = feedbackDoc.data() as Map<String, dynamic>;
      satisfactionScores.add({
        'customerName': feedbackData['customerName'],
        'score': feedbackData['score'],
        'comment': feedbackData['comment'],
      });
    }

    return satisfactionScores;
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth > 800) {
          // Desktop layout
          return Scaffold(
            appBar: AppBar(
              title: Text('Customer Insights'),
            ),
            body: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Customer Purchase Behavior',
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  SizedBox(height: 10),
                  FutureBuilder<List<Map<String, dynamic>>>(
                    future: _fetchCustomerPurchaseBehavior(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return Center(child: CircularProgressIndicator());
                      }

                      if (!snapshot.hasData || snapshot.data!.isEmpty) {
                        return Text('No purchase behavior data available.');
                      }

                      return Expanded(
                        child: ListView.builder(
                          itemCount: snapshot.data!.length,
                          itemBuilder: (context, index) {
                            var data = snapshot.data![index];
                            return Card(
                              child: ListTile(
                                title: Text(data['customerName']),
                                subtitle: Text(
                                  'Total Purchases: ${data['totalPurchases']}\nFrequent Items: ${data['frequentItems'].join(', ')}',
                                ),
                              ),
                            );
                          },
                        ),
                      );
                    },
                  ),
                  SizedBox(height: 20),
                  Text('Retention and Churn Rates',
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  SizedBox(height: 10),
                  FutureBuilder<Map<String, double>>(
                    future: _fetchRetentionAndChurnRates(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return Center(child: CircularProgressIndicator());
                      }

                      if (!snapshot.hasData) {
                        return Text(
                            'No retention and churn rate data available.');
                      }

                      return Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Column(
                            children: [
                              Text('Retention Rate',
                                  style: TextStyle(fontSize: 16)),
                              Text(
                                  '${snapshot.data!['retentionRate']!.toStringAsFixed(2)}%'),
                            ],
                          ),
                          Column(
                            children: [
                              Text('Churn Rate',
                                  style: TextStyle(fontSize: 16)),
                              Text(
                                  '${snapshot.data!['churnRate']!.toStringAsFixed(2)}%'),
                            ],
                          ),
                        ],
                      );
                    },
                  ),
                  SizedBox(height: 20),
                  Text('Customer Satisfaction Scores',
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  SizedBox(height: 10),
                  FutureBuilder<List<Map<String, dynamic>>>(
                    future: _fetchCustomerSatisfactionScores(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return Center(child: CircularProgressIndicator());
                      }

                      if (!snapshot.hasData || snapshot.data!.isEmpty) {
                        return Text('No satisfaction scores available.');
                      }

                      return Expanded(
                        child: ListView.builder(
                          itemCount: snapshot.data!.length,
                          itemBuilder: (context, index) {
                            var data = snapshot.data![index];
                            return Card(
                              child: ListTile(
                                title: Text(data['customerName']),
                                subtitle: Text(
                                  'Score: ${data['score']}\nComment: ${data['comment']}',
                                ),
                              ),
                            );
                          },
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          );
        } else {
          // Display a message for non-desktop users
          return Scaffold(
            body: Center(
              child: Text('Customer Insights is available on desktop only.'),
            ),
          );
        }
      },
    );
  }
}
