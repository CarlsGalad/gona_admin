import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:gona_admin/headadmin/admin_manage.dart';

import 'package:gona_admin/home/home_screen.dart';
import 'package:gona_admin/payment_managment.dart';
import 'package:gona_admin/transcactions.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_network/image_network.dart';

import '../categories/category.dart';
import '../disputes/disputes.dart';

import '../marketing/marketing.dart';
import '../news/gonanews.dart';
import '../help/live_chat.dart';
import '../services/admin_service.dart';
import '../services/nofication_service.dart';
import '../services/search_services.dart';
import '../user/users.dart';
import '../vendors/vendors.dart';
import 'search_results.dart';

class AdminHome extends StatefulWidget {
  const AdminHome({super.key});

  @override
  State<AdminHome> createState() => _AdminHomeState();
}

class _AdminHomeState extends State<AdminHome> {
  final _searchBarController = TextEditingController();
  final SearchService _searchService = SearchService();
  int _selectedIndex = 0;
  String? adminId;
  Map<String, dynamic>? adminData;
  bool isLoading = true;
  List<String> notifications = [];
  final NotificationService _notificationService = NotificationService();

  @override
  void initState() {
    super.initState();
    _fetchCurrentUser();
  }

  Future<void> _fetchCurrentUser() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      setState(() {
        adminId = user.uid;
      });
      _fetchAdminData(user.uid);
    }
  }

  Future<void> _fetchAdminData(String adminId) async {
    AdminService adminService = AdminService();
    var data = await adminService.getCurrentAdminData(adminId);
    setState(() {
      adminData = data;
      isLoading = false;
    });
    if (data != null) {
      _notificationService.setupListeners(
          data['role'] ?? '', data['department'] ?? '');
    }
  }

  void _onSearch() async {
    String searchText = _searchBarController.text;
    if (searchText.isNotEmpty) {
      // Show the loading indicator
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(
          child: CircularProgressIndicator(),
        ),
      );

      try {
        List<Map<String, dynamic>> results =
            await _searchService.search(searchText);
        Navigator.pop(context); // Remove the loading indicator

        if (results.isEmpty) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => SearchResultsScreen(
                  searchResults: results, errorMessage: 'No results found.'),
            ),
          );
        } else {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => SearchResultsScreen(searchResults: results),
            ),
          );
        }
      } catch (e) {
        Navigator.pop(context); // Remove the loading indicator
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text('An error occurred during the search.')));
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Search text cannot be empty.')));
    }
  }

  Future<void> _uploadImage() async {
    FilePickerResult? result =
        await FilePicker.platform.pickFiles(type: FileType.image);

    if (result != null) {
      Uint8List? fileBytes = result.files.first.bytes;
      if (fileBytes != null) {
        // Upload the image to Firebase Storage
        Reference ref = FirebaseStorage.instance
            .ref()
            .child('admin_images/${adminId}_profile.jpg');

        UploadTask uploadTask = ref.putData(fileBytes);
        TaskSnapshot snapshot = await uploadTask.whenComplete(() => null);

        // Get the image URL and update the admin data
        String imageUrl = await snapshot.ref.getDownloadURL();
        await AdminService().updateAdminImage(adminId!, imageUrl);

        // Show a snackbar or toast message to indicate success
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Profile image updated successfully'),
        ));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    Widget screen;

    switch (_selectedIndex) {
      case 0:
        screen = const HomeScreen();
        break;
      case 1:
        screen = const ChatPlaceholderWidget();
        break;
      case 2:
        screen = const NewsScreen();
        break;
      case 3:
        screen = const ManageCategoryScreen();
        break;
      case 5:
        screen = const MarketingScreen();
        break;
      case 6:
        screen = const OurVendorsScreen();
        break;
      case 7:
        screen = const OurUsersScreen();
        break;
      case 8:
        screen = const ManageDisputesScreen();
        break;
      case 9:
        screen = const AdminManagementScreen();
        break;
      default:
        screen = Container(); // Add default case or handle error
        break;
    }

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        toolbarHeight: 100,
        leadingWidth: 100,
        leading: Padding(
          padding: const EdgeInsets.only(left: 10.0, top: 10),
          child: SizedBox(
            height: 100,
            width: 150,
            child: Image.asset(
              'lib/images/file.png',
              width: 100,
              fit: BoxFit.cover,
            ),
          ),
        ),
        title: const Padding(
          padding: EdgeInsets.all(8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Dashboard',
                style: TextStyle(color: Colors.white),
              ),
              Text(
                'Overview of Gona market',
                style: TextStyle(
                    color: Colors.grey,
                    fontSize: 10,
                    fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
        backgroundColor: Colors.black,
        foregroundColor: Colors.black54,
        actions: [
          // search bar starts here
          SearchBar(
            backgroundColor:
                WidgetStateColor.resolveWith((states) => Colors.black26),
            textCapitalization: TextCapitalization.sentences,
            constraints: const BoxConstraints(
                maxHeight: 40, maxWidth: 300, minHeight: 40, minWidth: 250),
            trailing: const [
              Padding(
                padding: EdgeInsets.only(right: 10.0),
                child: Icon(
                  Icons.search,
                  color: Colors.grey,
                ),
              )
            ],
            controller: _searchBarController,
            textStyle: WidgetStateProperty.resolveWith(
                (states) => const TextStyle(color: Colors.white)),
            hintText: 'Search ',
            hintStyle: WidgetStateProperty.resolveWith(
                (states) => const TextStyle(color: Colors.grey)),
            onSubmitted: (_) => _onSearch(),
          ),
          const SizedBox(
            width: 200,
          ),
          Padding(
            padding: const EdgeInsets.only(right: 8.0, left: 8),
            child: IconButton(
                tooltip: 'Payment Manangement',
                color: Colors.grey,
                onPressed: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => PaymentManagementScreen()));
                },
                icon: const Icon(Icons.wallet)),
          ),
          Padding(
            padding: const EdgeInsets.only(right: 8.0, left: 8),
            child: IconButton(
                tooltip: 'Transaction History',
                color: Colors.grey,
                onPressed: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const TransactionsScreen()));
                },
                icon: const Icon(Icons.history)),
          ),
          StreamBuilder<List<String>>(
            stream: _notificationService.notificationsStream,
            builder: (context, snapshot) {
              int notificationCount =
                  snapshot.hasData ? snapshot.data!.length : 0;
              return Stack(
                children: [
                  PopupMenuButton(
                    iconColor: Colors.white54,
                    icon: const Icon(Icons.notifications),
                    itemBuilder: (BuildContext context) {
                      if (notificationCount == 0) {
                        return [
                          PopupMenuItem(
                            child: SizedBox(
                                width: 250,
                                height: 650,
                                child: Center(
                                    child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const Icon(
                                      Icons.notifications_none,
                                      size: 50,
                                    ),
                                    Text(
                                      'You have no notifications',
                                      style: GoogleFonts.abel(),
                                    ),
                                  ],
                                ))),
                          ),
                        ];
                      } else {
                        return snapshot.data!.map((String notification) {
                          return PopupMenuItem(
                            child: SelectableText(notification),
                          );
                        }).toList();
                      }
                    },
                  ),
                  if (notificationCount > 0)
                    Positioned(
                      right: 11,
                      top: 11,
                      child: Container(
                        padding: const EdgeInsets.all(2),
                        decoration: BoxDecoration(
                          color: Colors.red,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        constraints: const BoxConstraints(
                          minWidth: 18,
                          minHeight: 18,
                        ),
                        child: Text(
                          '$notificationCount',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                ],
              );
            },
          ),

          isLoading
              ? const CircularProgressIndicator()
              : Padding(
                  padding: const EdgeInsets.only(right: 20.0),
                  child: PopupMenuButton(
                    tooltip: 'My Profile',
                    elevation: 5,
                    iconSize: 25,
                    splashRadius: 30,
                    icon: adminData != null && adminData!['imagePath'] != null
                        ? Container(
                            width: 25,
                            height: 25,
                            decoration:
                                const BoxDecoration(shape: BoxShape.circle),
                            child: ImageNetwork(
                              image: adminData!['imagePath'],
                              width: 25,
                              height: 25,
                            ),
                          )
                        : const Icon(Icons.account_box_rounded),
                    iconColor: Colors.white54,
                    color: Colors.white70,
                    position: PopupMenuPosition.under,
                    popUpAnimationStyle: AnimationStyle(curve: Curves.easeIn),
                    itemBuilder: (BuildContext context) {
                      return [
                        PopupMenuItem(
                          child: Row(
                            children: [
                              Expanded(
                                flex: 2,
                                child: Padding(
                                  padding: const EdgeInsets.only(
                                      top: 15.0, left: 10),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        '${adminData!['firstName']} ${adminData!['lastName']} ',
                                        style: GoogleFonts.roboto(
                                            fontWeight: FontWeight.bold),
                                      ),
                                      Text(
                                        '${adminData!['email']}',
                                        style: GoogleFonts.roboto(fontSize: 12),
                                      ),
                                      adminData!['role'] != null
                                          ? Text(
                                              '${adminData!['role'] ?? ''}',
                                              style: GoogleFonts.roboto(),
                                            )
                                          : const Text(''),
                                      adminData!['department'] != null
                                          ? Text(
                                              '${adminData!['department'] ?? ''}',
                                              style: GoogleFonts.roboto())
                                          : const Text(''),
                                    ],
                                  ),
                                ),
                              ),
                              const VerticalDivider(
                                color: Colors.black,
                                width: 5,
                              ),
                              Expanded(
                                flex: 1,
                                child: Column(
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.all(14.0),
                                      child: Stack(children: [
                                        adminData!['imagePath'] != null
                                            ? Container(
                                                height: 80,
                                                width: 80,
                                                decoration: const BoxDecoration(
                                                    color: Colors.grey,
                                                    shape: BoxShape.circle),
                                                child: ImageNetwork(
                                                  image:
                                                      adminData!['imagePath'],
                                                  width: 60,
                                                  height: 60,
                                                ),
                                              )
                                            : Container(
                                                height: 80,
                                                width: 80,
                                                decoration: const BoxDecoration(
                                                    color: Colors.grey,
                                                    shape: BoxShape.circle),
                                                child: const Icon(Icons.person,
                                                    size: 60),
                                              ),
                                        Positioned(
                                          right: 0,
                                          bottom: 0,
                                          child: InkWell(
                                            onTap: _uploadImage,
                                            child: Container(
                                              width: 30,
                                              decoration: BoxDecoration(
                                                  shape: BoxShape.circle,
                                                  color: Colors.black,
                                                  border: Border.all(
                                                      color: Colors.white)),
                                              child: const Icon(
                                                Icons.edit,
                                                color: Colors.grey,
                                                size: 15,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ]),
                                    ),
                                    const SizedBox(height: 10),
                                    InkWell(
                                      splashFactory: InkSparkle.splashFactory,
                                      splashColor: Colors.white,
                                      onTap: _logout,
                                      child: Container(
                                        decoration: BoxDecoration(
                                            color: Colors.grey,
                                            border: Border.all(
                                                color: Colors.black38),
                                            borderRadius:
                                                BorderRadius.circular(10)),
                                        child: Padding(
                                          padding: const EdgeInsets.only(
                                              left: 16.0,
                                              top: 6,
                                              bottom: 6,
                                              right: 16),
                                          child: Text(
                                            'Logout',
                                            style: GoogleFonts.abel(
                                                fontSize: 14,
                                                fontWeight: FontWeight.bold),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ];
                    },
                  ),
                ),
        ],
      ),
      body: Row(
        children: [
          Expanded(
            child: Row(
              children: <Widget>[
                LayoutBuilder(builder: (context, constraint) {
                  return SingleChildScrollView(
                    child: ConstrainedBox(
                      constraints:
                          BoxConstraints(minHeight: constraint.maxHeight),
                      child: IntrinsicHeight(
                        child: NavigationRail(
                          backgroundColor: Colors.black,
                          selectedIndex: _selectedIndex,
                          unselectedLabelTextStyle:
                              const TextStyle(color: Colors.grey, fontSize: 13),
                          selectedLabelTextStyle:
                              const TextStyle(color: Colors.blue),
                          unselectedIconTheme:
                              const IconThemeData(color: Colors.blue),
                          onDestinationSelected: (int index) {
                            setState(() {
                              _selectedIndex = index;
                            });
                          },
                          labelType: NavigationRailLabelType.all,
                          destinations: const <NavigationRailDestination>[
                            NavigationRailDestination(
                              icon: Icon(Icons.home),
                              label: Text('Home'),
                            ),
                            NavigationRailDestination(
                              icon: Icon(Icons.headset_mic),
                              label: Text('Live Chat'),
                            ),
                            NavigationRailDestination(
                              icon: Icon(Icons.newspaper),
                              label: Text('Gona News'),
                            ),
                            NavigationRailDestination(
                              icon: Icon(Icons.category),
                              label: Text('Manage Categories'),
                            ),
                            NavigationRailDestination(
                              icon: Icon(Icons.attach_money),
                              label: Text('Manage Loans'),
                            ),
                            NavigationRailDestination(
                              icon: Icon(Icons.trending_up),
                              label: Text('Marketing'),
                            ),
                            NavigationRailDestination(
                              icon: Icon(Icons.people),
                              label: Text('Our Vendors'),
                            ),
                            NavigationRailDestination(
                              icon: Icon(Icons.person),
                              label: Text('Users'),
                            ),
                            NavigationRailDestination(
                              icon: Icon(Icons.adjust),
                              label: Text('Manage Disputes'),
                            ),
                            NavigationRailDestination(
                              icon: Icon(Icons.manage_accounts),
                              label: Text('Admin'),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                }),
                const VerticalDivider(
                  thickness: 1,
                  width: 1,
                  color: Color.fromARGB(255, 26, 25, 25),
                ),
                screen,
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _logout() {
    FirebaseAuth.instance.signOut();
    // Navigate to login screen or any other action after logout
  }
}
