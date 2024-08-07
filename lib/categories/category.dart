import 'dart:typed_data';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_network/image_network.dart';
import '../services/admin_service.dart';

class ManageCategoryScreen extends StatefulWidget {
  const ManageCategoryScreen({super.key});

  @override
  ManageCategoryScreenState createState() => ManageCategoryScreenState();
}

class ManageCategoryScreenState extends State<ManageCategoryScreen> {
  int? _selectedCategoryIndex;
  List<DocumentSnapshot> _categories = [];
  PlatformFile? _imageFile;

  late AdminService _adminService;

  String? adminId = FirebaseAuth.instance.currentUser!.uid;

  @override
  void initState() {
    super.initState();
    _fetchCategories();
    _adminService = AdminService(); // Initialize the AdminService instance
  }

  Future<void> _fetchCategories() async {
    final snapshot =
        await FirebaseFirestore.instance.collection('Category').get();
    setState(() {
      _categories = snapshot.docs;
    });
  }

  Future<void> _pickImage() async {
    try {
      FilePickerResult? result =
          await FilePicker.platform.pickFiles(type: FileType.image);
      if (result == null) return;

      setState(() {
        _imageFile = result.files.first;
      });
    } catch (e) {
      print(e);
    }
  }

  Future<void> _addCategory(
      String categoryName, List<String> subcategories) async {
    if (categoryName.isEmpty || _imageFile == null) {
      return;
    }

    final storage = FirebaseStorage.instance;
    final timeStamp = DateTime.now().millisecondsSinceEpoch;
    final ref = storage.ref().child('categoryimages/$timeStamp.jpg');
    await ref.putData(Uint8List.fromList(_imageFile!.bytes!));
    final imageUrl = await ref.getDownloadURL();

    final newCategory =
        await FirebaseFirestore.instance.collection('Category').add({
      'name': categoryName,
      'imagePath': imageUrl,
    });

    for (String subcategory in subcategories) {
      await newCategory.collection('Subcategories').add({'name': subcategory});
    }

    // Log the activity
    await _adminService.logActivity(
      adminId!,
      'Added a new category',
      'Added $categoryName and subcategories $subcategories with an image $imageUrl',
    );

    // Clear the image after adding category
    setState(() {
      _imageFile = null;
    });

    _fetchCategories(); // Refresh the categories list
  }

  Future<void> _addSubcategory(String subcategoryName) async {
    if (_selectedCategoryIndex == null || subcategoryName.isEmpty) {
      return;
    }

    final selectedCategory = _categories[_selectedCategoryIndex!];
    await FirebaseFirestore.instance
        .collection('Category')
        .doc(selectedCategory.id)
        .collection('Subcategories')
        .add({'name': subcategoryName});

    // Log the activity
    await _adminService.logActivity(
      adminId!,
      'Added a Subcategory',
      'category_id $selectedCategory.id subcategory_name $subcategoryName',
    );

    // Refresh the UI to reflect the new subcategory
    setState(() {});
  }

  Future<void> _editSubcategory(String subcategoryId, String newName) async {
    if (_selectedCategoryIndex == null || newName.isEmpty) {
      return;
    }

    final selectedCategory = _categories[_selectedCategoryIndex!];
    await FirebaseFirestore.instance
        .collection('Category')
        .doc(selectedCategory.id)
        .collection('Subcategories')
        .doc(subcategoryId)
        .update({'name': newName});

    // Log the activity
    await _adminService.logActivity(
      adminId!,
      'Edited a subcategory',
      'category_id ${selectedCategory.id} subcategory id $subcategoryId the new name is $newName',
    );

    // Refresh the UI to reflect the edited subcategory
    setState(() {});
  }

  Future<void> _deleteSubcategory(String subcategoryId) async {
    if (_selectedCategoryIndex == null) {
      return;
    }

    final selectedCategory = _categories[_selectedCategoryIndex!];
    await FirebaseFirestore.instance
        .collection('Category')
        .doc(selectedCategory.id)
        .collection('Subcategories')
        .doc(subcategoryId)
        .delete();

    // Log the activity
    await _adminService.logActivity(
      adminId!,
      'Deleted a subcategory',
      'category id $selectedCategory.id subcategory_id $subcategoryId',
    );

    // Refresh the UI to reflect the deleted subcategory
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(20), bottomRight: Radius.circular(20)),
      child: SizedBox(
        width: MediaQuery.of(context).size.width - 150,
        child: Scaffold(
          appBar: AppBar(
            centerTitle: true,
            title: Text(
              'Categories',
              style: GoogleFonts.lato(fontSize: 20, 
              color: Colors.white),
            ),
            toolbarHeight: 50,
            elevation: 5,
            backgroundColor: Colors.grey[900],
          ),
          body: Row(
            children: [
              Expanded(
                flex: 2,
                child: _buildCategoriesGridView(),
              ),
              VerticalDivider(
                thickness: 1,
                width: 2,
                color: Colors.grey[900],
              ),
              Expanded(
                flex: 3,
                child: _selectedCategoryIndex == null
                    ? Center(
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.grey[300],
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(10.0),
                            child: Text(
                              'Please select a category',
                              style: GoogleFonts.abel(color: Colors.black),
                            ),
                          ),
                        ),
                      )
                    : _buildSubcategoriesListView(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCategoriesGridView() {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(10.0),
        child: GridView.builder(
          itemCount: _categories.length,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3, // Number of columns in the grid
              crossAxisSpacing: 10.0,
              mainAxisSpacing: 10.0,
              childAspectRatio: 2 / 2.2),
          itemBuilder: (context, index) {
            final category = _categories[index];
            return GestureDetector(
              onTap: () {
                setState(() {
                  _selectedCategoryIndex = index;
                });
              },
              child: Container(
                decoration: BoxDecoration(
                  color: _selectedCategoryIndex == index
                      ? Colors.grey[200]
                      : Colors.grey[900],
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Center(
                  child: Column(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: FutureBuilder(
                          future: FirebaseStorage.instance
                              .refFromURL(category['imagePath'])
                              .getDownloadURL(),
                          builder: (BuildContext context,
                              AsyncSnapshot<String> snapshot) {
                            if (snapshot.connectionState ==
                                ConnectionState.waiting) {
                              return LinearProgressIndicator(
                                  color: Colors.blue[
                                      200]); // Placeholder for loading state
                            } else if (snapshot.hasError) {
                              return const Text(
                                  'Error loading image'); // Placeholder for error state
                            } else {
                              return ImageNetwork(
                                onLoading: LinearProgressIndicator(
                                    color: Colors.blue[200]),
                                image: snapshot.data!,
                                height: 100,
                                width: 200,
                              );
                            }
                          },
                        ),
                      ),
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(
                            category['name'],
                            style: GoogleFonts.abel(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: _selectedCategoryIndex == index
                                  ? Colors.grey[900]
                                  : Colors.grey[200],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddCategoryDialog,
        backgroundColor: Colors.orange.shade200,
        child: const Icon(Icons.add),
      ),
    );
  }

  void _showAddCategoryDialog() {
    final TextEditingController categoryNameController =
        TextEditingController();
    final TextEditingController subcategoryController = TextEditingController();
    List<String> subcategories = [];

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Add New Category'),
          content: SingleChildScrollView(
            child: Column(
              children: [
                TextField(
                  controller: categoryNameController,
                  decoration: const InputDecoration(labelText: 'Category Name'),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: subcategoryController,
                  decoration:
                      const InputDecoration(labelText: 'Add Subcategory'),
                  onSubmitted: (value) {
                    if (value.isNotEmpty) {
                      setState(() {
                        subcategories.add(value);
                        subcategoryController.clear();
                      });
                    }
                  },
                ),
                const SizedBox(height: 10),
                Wrap(
                  children: subcategories
                      .map((subcategory) => Chip(label: Text(subcategory)))
                      .toList(),
                ),
                const SizedBox(height: 10),
                GestureDetector(
                  onTap: _pickImage,
                  child: Container(
                    alignment: Alignment.center,
                    width: 100,
                    height: 100,
                    color: Colors.grey[900],
                    child: _imageFile != null
                        ? Image.memory(
                            Uint8List.fromList(_imageFile!.bytes!),
                            fit: BoxFit.cover,
                          )
                        : const Icon(
                            Icons.add_a_photo,
                            size: 50,
                          ),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                _addCategory(categoryNameController.text, subcategories);
                Navigator.of(context).pop();
              },
              child: const Text('Add'),
            ),
          ],
        );
      },
    );
  }

  Widget _buildSubcategoriesListView() {
    final selectedCategory = _categories[_selectedCategoryIndex!];
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('Category')
          .doc(selectedCategory.id)
          .collection('Subcategories')
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(
              child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 50.0),
            child: LinearProgressIndicator(color: Colors.blue[200]),
          ));
        }

        final subcategories = snapshot.data!.docs;

        return Scaffold(
          backgroundColor: Colors.white,
          body: ListView.builder(
            itemCount: subcategories.length,
            itemBuilder: (context, index) {
              final subcategory = subcategories[index];
              return Padding(
                padding: const EdgeInsets.all(8.0),
                child: Container(
                  decoration: BoxDecoration(color: Colors.grey[900]),
                  child: ListTile(
                    title: Text(
                      subcategory['name'],
                      style: GoogleFonts.abel(
                          fontWeight: FontWeight.bold, color: Colors.white),
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.edit),
                          color: Colors.amber,
                          onPressed: () {
                            _showEditSubcategoryDialog(
                                subcategory.id, subcategory['name']);
                          },
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete),
                          color: Colors.red,
                          onPressed: () {
                            _showDeleteSubcategoryDialog(subcategory.id);
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
          floatingActionButton: FloatingActionButton(
            child: const Icon(Icons.add),
            backgroundColor: Colors.orange[200],
            onPressed: _showAddSubcategoryDialog,
          ),
        );
      },
    );
  }

  void _showAddSubcategoryDialog() {
    final TextEditingController subcategoryController = TextEditingController();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Add New Subcategory'),
          content: TextField(
            controller: subcategoryController,
            decoration: const InputDecoration(labelText: 'Subcategory Name'),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                _addSubcategory(subcategoryController.text);
                Navigator.of(context).pop();
              },
              child: const Text('Add'),
            ),
          ],
        );
      },
    );
  }

  void _showEditSubcategoryDialog(String subcategoryId, String currentName) {
    final TextEditingController subcategoryController =
        TextEditingController(text: currentName);

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          title: const Text('Edit Subcategory'),
          content: TextField(
            controller: subcategoryController,
            decoration: const InputDecoration(labelText: 'Subcategory Name'),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
            MaterialButton(
              elevation: 5,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
              color: Colors.orange.shade200,
              onPressed: () {
                _editSubcategory(subcategoryId, subcategoryController.text);
                Navigator.of(context).pop();
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }

  void _showDeleteSubcategoryDialog(String subcategoryId) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Delete Subcategory? '),
          content:
              const Text('Are you sure you want to delete this subcategory?'),
          actions: [
            MaterialButton(
              elevation: 5,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                _deleteSubcategory(subcategoryId);
                Navigator.of(context).pop();
              },
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );
  }
}
