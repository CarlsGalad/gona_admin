import 'package:flutter/material.dart';

class OurUsersScreen extends StatefulWidget {
  const OurUsersScreen({super.key});

  @override
  OurUsersScreenState createState() => OurUsersScreenState();
}

class OurUsersScreenState extends State<OurUsersScreen> {
  int? _selectedUserIndex;

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
        itemCount: 10, // Number of users
        itemBuilder: (context, index) {
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4.0, vertical: 10),
            child: Container(
              decoration: const BoxDecoration(color: Colors.grey),
              child: ListTile(
                title: Text('User $index'),
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
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'User ${_selectedUserIndex!} Image',
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            Text(
              'User ${_selectedUserIndex!} Names',
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Text(
              'Email: user$_selectedUserIndex@example.com',
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 5),
            const Text(
              'Adrress: Selected Users address',
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 5),
            const Text(
              'Last 5 Purchase:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            _buildLastPurchase(),
          ],
        ),
      ),
    );
  }

  Widget _buildLastPurchase() {
    // Simulated last purchase data
    return const Card(
      child: ListTile(
        title: Text('Product Name'),
        subtitle: Column(
          children: [
            Text('Price: \$100'),
            Text('Qty: 13'),
          ],
        ),
        trailing: Text('Date: 2024-05-10'),
      ),
    );
  }
}
