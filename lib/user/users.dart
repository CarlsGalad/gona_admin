import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class OurUsersScreen extends StatefulWidget {
  const OurUsersScreen({super.key});

  @override
  OurUsersScreenState createState() => OurUsersScreenState();
}

class OurUsersScreenState extends State<OurUsersScreen> {
  int? _selectedUserIndex;
  List<DocumentSnapshot> _users = [];

  @override
  void initState() {
    super.initState();
    _fetchUsers();
  }

  Future<void> _fetchUsers() async {
    final snapshot = await FirebaseFirestore.instance.collection('users').get();
    setState(() {
      _users = snapshot.docs;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: Container(
        width: MediaQuery.of(context).size.width - 180,
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10), color: Colors.blueGrey),
        child: Row(
          children: [
            Expanded(
              flex: 2,
              child: _buildUsersListView(),
            ),
            const VerticalDivider(
              thickness: 1,
              width: 2,
              color: Color.fromARGB(255, 26, 25, 25),
            ),
            Expanded(
              flex: 3,
              child: _selectedUserIndex == null
                  ? const Center(
                      child: Text('Please select a user'),
                    )
                  : _buildUserDetailsView(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUsersListView() {
    return Padding(
      padding: const EdgeInsets.all(12.0),
      child: ListView.builder(
        itemCount: _users.length, // Number of users
        itemBuilder: (context, index) {
          final user = _users[index];
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4.0, vertical: 10),
            child: Container(
              decoration: const BoxDecoration(color: Colors.grey),
              child: ListTile(
                title: Text('${user['firstName']} ${user['lastName']}'),
                onTap: () {
                  setState(() {
                    _selectedUserIndex = index;
                  });
                },
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildUserDetailsView() {
    final user = _users[_selectedUserIndex!];

    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (user['imagePath'] != null) Image.network(user['imagePath']),
            Text(
              '${user['firstName']} ${user['lastName']}',
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Text(
              'Email: ${user['email']}',
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 5),
            Text(
              'Mobile: ${user['mobile']}',
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 5),
            Text(
              'Address: ${user['address']}',
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 5),
            const Text(
              'Last 5 Purchases:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            _buildLastPurchases(user['purchase_history'] ?? []),
          ],
        ),
      ),
    );
  }

  Widget _buildLastPurchases(List<dynamic> purchases) {
    if (purchases.isEmpty) {
      return const Text('No purchases available');
    }

    return Column(
      children: purchases.take(5).map((purchase) {
        return Card(
          child: ListTile(
            title: Text(purchase['productName'] ?? 'No Product Name'),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Price: \$${purchase['price'] ?? 'N/A'}'),
                Text('Qty: ${purchase['quantity'] ?? 'N/A'}'),
              ],
            ),
            trailing: Text('Date: ${purchase['date'] ?? 'No Date'}'),
          ),
        );
      }).toList(),
    );
  }
}
