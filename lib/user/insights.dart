import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class CustomerInsightsScreen extends StatelessWidget {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  CustomerInsightsScreen({super.key});

  Future<List<Map<String, dynamic>>> _fetchCustomerPurchaseBehavior() async {
    List<Map<String, dynamic>> purchaseBehavior = [];
    QuerySnapshot customerSnapshot = await _firestore.collection('users').get();

    for (var customerDoc in customerSnapshot.docs) {
      var customerData = customerDoc.data() as Map<String, dynamic>;
      List<dynamic> purchaseHistory = customerData['purchase_history'] ?? [];
      int totalPurchases = purchaseHistory.length;
      Map<String, int> itemFrequency = {};

      for (var purchase in purchaseHistory) {
        String orderId = purchase['order_id'];
        if (itemFrequency.containsKey(orderId)) {
          itemFrequency[orderId] = itemFrequency[orderId]! + 1;
        } else {
          itemFrequency[orderId] = 1;
        }
      }

      var sortedItems = itemFrequency.entries.toList()
        ..sort((a, b) => b.value.compareTo(a.value));
      var frequentItems = sortedItems.take(3).map((e) => e.key).toList();

      purchaseBehavior.add({
        'customerName':
            customerData['firstName'] + ' ' + customerData['lastName'],
        'totalPurchases': totalPurchases,
        'frequentItems': frequentItems,
      });
    }

    return purchaseBehavior;
  }

  Future<Map<String, double>> _fetchRetentionAndChurnRates() async {
    QuerySnapshot customerSnapshot = await _firestore.collection('users').get();
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
              title: const Text('Customer Insights'),
              bottom: PreferredSize(
                preferredSize: const Size.fromHeight(60.0),
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: TextField(
                    decoration: const InputDecoration(
                      hintText: 'Search',
                      border: OutlineInputBorder(),
                      suffixIcon: Icon(Icons.search),
                    ),
                    onChanged: (value) {
                      // Implement search logic here
                    },
                  ),
                ),
              ),
            ),
            body: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  Expanded(
                    flex: 4,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Customer Purchase Behavior',
                            style: TextStyle(
                                fontSize: 18, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 10),
                        FutureBuilder<List<Map<String, dynamic>>>(
                          future: _fetchCustomerPurchaseBehavior(),
                          builder: (context, snapshot) {
                            if (snapshot.connectionState ==
                                ConnectionState.waiting) {
                              return const Center(
                                  child: CircularProgressIndicator());
                            }

                            if (!snapshot.hasData || snapshot.data!.isEmpty) {
                              return const Text(
                                  'No purchase behavior data available.');
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
                        const SizedBox(height: 20),
                        const Text('Retention and Churn Rates',
                            style: TextStyle(
                                fontSize: 18, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 10),
                        FutureBuilder<Map<String, double>>(
                          future: _fetchRetentionAndChurnRates(),
                          builder: (context, snapshot) {
                            if (snapshot.connectionState ==
                                ConnectionState.waiting) {
                              return const Center(
                                  child: CircularProgressIndicator());
                            }

                            if (!snapshot.hasData) {
                              return const Text(
                                  'No retention and churn rate data available.');
                            }

                            return Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                Column(
                                  children: [
                                    const Text('Retention Rate',
                                        style: TextStyle(fontSize: 16)),
                                    Text(
                                        '${snapshot.data!['retentionRate']!.toStringAsFixed(2)}%'),
                                  ],
                                ),
                                Column(
                                  children: [
                                    const Text('Churn Rate',
                                        style: TextStyle(fontSize: 16)),
                                    Text(
                                        '${snapshot.data!['churnRate']!.toStringAsFixed(2)}%'),
                                  ],
                                ),
                              ],
                            );
                          },
                        ),
                        const SizedBox(height: 20),
                        const Text('Customer Satisfaction Scores',
                            style: TextStyle(
                                fontSize: 18, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 10),
                        FutureBuilder<List<Map<String, dynamic>>>(
                          future: _fetchCustomerSatisfactionScores(),
                          builder: (context, snapshot) {
                            if (snapshot.connectionState ==
                                ConnectionState.waiting) {
                              return const Center(
                                  child: CircularProgressIndicator());
                            }

                            if (!snapshot.hasData || snapshot.data!.isEmpty) {
                              return const Text(
                                  'No satisfaction scores available.');
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
                  const SizedBox(width: 16),
                  Expanded(
                    flex: 1,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Customer Insights Overview',
                            style: TextStyle(
                                fontSize: 18, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 10),
                        FutureBuilder<Map<String, double>>(
                          future: _fetchRetentionAndChurnRates(),
                          builder: (context, snapshot) {
                            if (snapshot.connectionState ==
                                ConnectionState.waiting) {
                              return const Center(
                                  child: CircularProgressIndicator());
                            }

                            if (!snapshot.hasData) {
                              return const Text('No overview data available.');
                            }

                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                    'Retention Rate: ${snapshot.data!['retentionRate']!.toStringAsFixed(2)}%',
                                    style: const TextStyle(fontSize: 16)),
                                Text(
                                    'Churn Rate: ${snapshot.data!['churnRate']!.toStringAsFixed(2)}%',
                                    style: const TextStyle(fontSize: 16)),
                              ],
                            );
                          },
                        ),
                        const SizedBox(height: 20),
                        FutureBuilder<List<Map<String, dynamic>>>(
                          future: _fetchCustomerPurchaseBehavior(),
                          builder: (context, snapshot) {
                            if (snapshot.connectionState ==
                                ConnectionState.waiting) {
                              return const Center(
                                  child: CircularProgressIndicator());
                            }

                            if (!snapshot.hasData || snapshot.data!.isEmpty) {
                              return const Text(
                                  'No purchase behavior data available.');
                            }

                            int totalPurchases = snapshot.data!.fold(
                                0,
                                (sum, data) =>
                                    sum + data['totalPurchases'] as int);

                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Total Purchases: $totalPurchases',
                                    style: const TextStyle(fontSize: 16)),
                                const Text('Frequent Items:',
                                    style: TextStyle(fontSize: 16)),
                                ...snapshot.data!
                                    .expand((data) => data['frequentItems'])
                                    .map((item) => Text(item))
                                    .toList(),
                              ],
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        } else {
          // For non-desktop layouts, you can implement a different layout or redirect the user
          return Scaffold(
            appBar: AppBar(title: const Text('Customer Insights')),
            body: const Center(
                child: Text('This page is only available on desktop')),
          );
        }
      },
    );
  }
}
