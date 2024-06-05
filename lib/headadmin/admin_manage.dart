import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_fonts/google_fonts.dart';

class AdminManagementScreen extends StatefulWidget {
  const AdminManagementScreen({super.key});

  @override
  AdminManagementScreenState createState() => AdminManagementScreenState();
}

class AdminManagementScreenState extends State<AdminManagementScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  DocumentSnapshot? _selectedAdmin;
  DocumentSnapshot? _headAdmin;

  @override
  void initState() {
    super.initState();
    _fetchHeadAdminDetails();
  }

  Future<void> _fetchHeadAdminDetails() async {
    User? currentUser = _auth.currentUser;
    if (currentUser != null) {
      DocumentSnapshot headAdminSnapshot =
          await _firestore.collection('admin').doc(currentUser.uid).get();
      setState(() {
        _headAdmin = headAdminSnapshot;
      });
    }
  }

  Future<List<DocumentSnapshot>> _fetchAdmins() async {
    QuerySnapshot adminSnapshot = await _firestore.collection('admin').get();
    return adminSnapshot.docs;
  }

  Future<DocumentSnapshot> _fetchAdminDetails(String adminId) async {
    return await _firestore.collection('admin').doc(adminId).get();
  }

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints:
          BoxConstraints(maxWidth: MediaQuery.of(context).size.width - 150),
      child: Scaffold(
        appBar: AppBar(
          title: Text('Admin Management',
              style: GoogleFonts.roboto(color: Colors.white)),
          backgroundColor: Colors.black,
          centerTitle: true,
        ),
        body: Row(
          children: [
            // Left Flex 1: Head Admin Details
            Expanded(
              flex: 1,
              child: Container(
                padding: EdgeInsets.all(16.0),
                color: Colors.grey[200],
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Head Admin Details',
                        style: GoogleFonts.aboreto(
                            fontSize: 18, fontWeight: FontWeight.bold)),
                    const Divider(),
                    _headAdmin == null
                        ? Center(child: CircularProgressIndicator())
                        : Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Name: ${_headAdmin!['firstName']}',
                                  style: GoogleFonts.abel(fontSize: 16)),
                              Text('Email: ${_headAdmin!['email']}',
                                  style: GoogleFonts.abel(fontSize: 16)),
                              // Add other head admin details as needed
                            ],
                          ),
                  ],
                ),
              ),
            ),
            const VerticalDivider(width: 1),

            // Center Flex 2: List of Admins
            Expanded(
              flex: 2,
              child: Container(
                padding: EdgeInsets.all(16.0),
                color: Colors.white,
                child: FutureBuilder<List<DocumentSnapshot>>(
                  future: _fetchAdmins(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    if (!snapshot.hasData || snapshot.data!.isEmpty) {
                      return Center(
                          child: Text('No admins found.',
                              style: GoogleFonts.abel()));
                    }

                    List<DocumentSnapshot> admins = snapshot.data!;
                    return ListView.builder(
                      itemCount: admins.length,
                      itemBuilder: (context, index) {
                        var admin =
                            admins[index].data() as Map<String, dynamic>;
                        return ListTile(
                          leading: CircleAvatar(
                            backgroundImage:
                                NetworkImage(admin['imagePath'] ?? ''),
                          ),
                          title: Text(admin['firstName'],
                              style: GoogleFonts.abel()),
                          subtitle: Text(
                              '${admin['department'] ?? ''} - ${admin['role'] ?? ''}',
                              style: GoogleFonts.abel()),
                          onTap: () async {
                            DocumentSnapshot adminDetails =
                                await _fetchAdminDetails(admins[index].id);
                            setState(() {
                              _selectedAdmin = adminDetails;
                            });
                          },
                        );
                      },
                    );
                  },
                ),
              ),
            ),
            const VerticalDivider(width: 1),

            // Right Flex 1: Admin Details and Activity Logs
            Expanded(
              flex: 1,
              child: Container(
                padding: EdgeInsets.all(16.0),
                color: Colors.grey[100],
                child: _selectedAdmin == null
                    ? Center(
                        child: Text('Select an admin to view details.',
                            style: GoogleFonts.abel()))
                    : Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Admin Details',
                              style: GoogleFonts.aboreto(
                                  fontSize: 18, fontWeight: FontWeight.bold)),
                          const Divider(),
                          // Display selected admin details here
                          Text('Name: ${_selectedAdmin!['firstName']}',
                              style: GoogleFonts.abel(fontSize: 16)),
                          Text('Email: ${_selectedAdmin!['email']}',
                              style: GoogleFonts.abel(fontSize: 16)),
                          Text(
                              'Department: ${_selectedAdmin!['department'] ?? ''}',
                              style: GoogleFonts.abel(fontSize: 16)),
                          Text('Role: ${_selectedAdmin!['role'] ?? ''}',
                              style: GoogleFonts.abel(fontSize: 16)),
                          const Divider(),
                          Text('Activity Logs',
                              style: GoogleFonts.aboreto(
                                  fontSize: 18, fontWeight: FontWeight.bold)),
                          const Divider(),
                          // Display activity logs here
                          Expanded(
                            child: ListView.builder(
                              itemCount: (_selectedAdmin!['activityLogs'] ??
                                      '' as List)
                                  .length,
                              itemBuilder: (context, index) {
                                var log = (_selectedAdmin!['activityLogs'] ??
                                    '' as List)[index];
                                return ListTile(
                                  title: Text(log, style: GoogleFonts.abel()),
                                );
                              },
                            ),
                          ),
                        ],
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
