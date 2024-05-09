import 'package:flutter/material.dart';

class ManageDisputesScreen extends StatefulWidget {
  const ManageDisputesScreen({super.key});

  @override
  ManageDisputesScreenState createState() => ManageDisputesScreenState();
}

class ManageDisputesScreenState extends State<ManageDisputesScreen> {
  int? _selectedDisputeIndex;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(12.0),
      child: Container(
        width: MediaQuery.of(context).size.width - 160,
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10), color: Colors.blueGrey),
        child: Row(
          children: [
            Expanded(
              flex: 2,
              child: _buildDisputesListView(),
            ),
            const VerticalDivider(
              thickness: 1,
              width: 2,
              color: Color.fromARGB(255, 26, 25, 25),
            ),
            Expanded(
              flex: 3,
              child: _selectedDisputeIndex == null
                  ? const Center(
                      child: Text('Please select a dispute'),
                    )
                  : _buildDisputeDetailsView(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDisputesListView() {
    return Padding(
      padding: const EdgeInsets.all(12.0),
      child: ListView.builder(
        itemCount: 10, // Number of disputes
        itemBuilder: (context, index) {
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4.0, vertical: 10),
            child: Container(
              decoration: const BoxDecoration(color: Colors.grey),
              child: ListTile(
                title: Text('Dispute $index'),
                onTap: () {
                  setState(
                    () {
                      _selectedDisputeIndex = index;
                    },
                  );
                },
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildDisputeDetailsView() {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Dispute ${_selectedDisputeIndex!}',
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            const Text(
              'Details:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 5),
            const Text(
              'Description of the dispute will be shown here.',
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 20),
            Center(
              child: ElevatedButton(
                onPressed: () {
                  // Handle settle dispute action
                },
                child: const Text('Settle Dispute'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
