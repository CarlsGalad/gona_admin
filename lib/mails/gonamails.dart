import 'package:flutter/material.dart';

class GonaMailsScreen extends StatefulWidget {
  const GonaMailsScreen({super.key});

  @override
  GonaMailsScreenState createState() => GonaMailsScreenState();
}

class GonaMailsScreenState extends State<GonaMailsScreen> {
  int? _selectedMailIndex;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: Container(
          width: MediaQuery.of(context).size.width - 160,
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10), color: Colors.blueGrey),
          child: Row(
            children: [
              Expanded(
                flex: 2,
                child: _buildMailsListView(),
              ),
              const VerticalDivider(
                thickness: 1,
                width: 2,
                color: Color.fromARGB(255, 26, 25, 25),
              ),
              Expanded(
                flex: 3,
                child: _selectedMailIndex == null
                    ? Center(
                        child: Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10),
                              color: Colors.grey,
                            ),
                            child: const Padding(
                              padding: EdgeInsets.all(10.0),
                              child: Text('Please select a mail to view'),
                            )),
                      )
                    : _buildMailDetailsView(),
              ),
            ],
          )),
    );
  }

  Widget _buildMailsListView() {
    return Padding(
      padding: const EdgeInsets.all(12.0),
      child: ListView.builder(
        itemCount: 10, // Number of mails
        itemBuilder: (context, index) {
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4.0, vertical: 10),
            child: Container(
              decoration: const BoxDecoration(color: Colors.grey),
              child: ListTile(
                title: Text(
                  'Mail $index',
                  style: const TextStyle(),
                ),
                trailing: const Text(
                  '2 Mins ago',
                  style: TextStyle(fontSize: 16),
                ),
                onTap: () {
                  setState(() {
                    _selectedMailIndex = index;
                  });
                },
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildMailDetailsView() {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Mail ${_selectedMailIndex!}',
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            const Text(
              'Sender: John Doe',
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 5),
            Text(
              'Date: ${DateTime.now().toString()}',
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 20),
            const Text(
              'Mail Content:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            const Text(
              'Lorem ipsum dolor sit amet, consectetur adipiscing elit. Sed non risus.',
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 10),
            const Text(
              'Aenean fermentum risus id tortor. Integer imperdiet vestibulum leo, id gravida neque porttitor eu.',
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 10),
            const Text(
              'Quisque gravida, elit in fermentum ultricies, leo purus hendrerit arcu, id scelerisque nunc libero et nulla.',
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 10),
            const Text(
              'Phasellus sed sapien libero.',
              style: TextStyle(fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }
}
