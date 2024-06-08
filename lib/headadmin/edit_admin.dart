import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

class EditAdminDialog extends StatefulWidget {
  final Map<String, dynamic>? adminData;

  const EditAdminDialog({super.key, this.adminData});

  @override
  EditAdminDialogState createState() => EditAdminDialogState();
}

class EditAdminDialogState extends State<EditAdminDialog> {
  late TextEditingController _firstNameController;
  late TextEditingController _lastNameController;
  late TextEditingController _emailController;
  late TextEditingController _departmentController;
  late TextEditingController _roleController;
  late TextEditingController _dobController;
  late List<Map<String, String>> _qualifications;

  @override
  void initState() {
    super.initState();
    _firstNameController =
        TextEditingController(text: widget.adminData?['firstName']);
    _lastNameController =
        TextEditingController(text: widget.adminData?['lastName']);
    _emailController = TextEditingController(text: widget.adminData?['email']);
    _dobController =
        TextEditingController(text: widget.adminData?['birthDate']);
    _departmentController =
        TextEditingController(text: widget.adminData?['department']);
    _roleController = TextEditingController(text: widget.adminData?['role']);

    // Convert qualifications from List<Map<String, dynamic>> to List<Map<String, String>>
    _qualifications = (widget.adminData?['qualification'] as List<dynamic>?)
            ?.map((qual) => Map<String, String>.from(qual))
            .toList() ??
        [];
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _departmentController.dispose();
    _roleController.dispose();
    super.dispose();
  }

  void _addQualification() {
    setState(() {
      _qualifications.add({
        'year': '',
        'courseStudied': '',
        'certificateNo': '',
        'institution': ''
      });
    });
  }

  void _saveChanges() async {
    final updatedAdminData = {
      'firstName': _firstNameController.text,
      'lastName': _lastNameController.text,
      'email': _emailController.text,
      'birthDay': _dobController.text,
      'department': _departmentController.text,
      'role': _roleController.text,
      'qualification': _qualifications,
    };

    try {
      final docId = widget.adminData?['userId'];
      if (docId != null) {
        await FirebaseFirestore.instance
            .collection('admins')
            .doc(docId)
            .update(updatedAdminData);
        Navigator.of(context).pop();
      } else {
        print('Document ID is null');
      }
    } catch (e) {
      print('Error updating admin data: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(
        'Edit Admin Details',
        style: GoogleFonts.lato(),
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              style: GoogleFonts.abel(fontSize: 16),
              controller: _firstNameController,
              decoration: InputDecoration(
                  labelText: 'First Name', labelStyle: GoogleFonts.oswald()),
            ),
            TextField(
              style: GoogleFonts.abel(fontSize: 16),
              controller: _lastNameController,
              decoration: InputDecoration(
                  labelText: 'Last Name', labelStyle: GoogleFonts.oswald()),
            ),
            TextField(
              style: GoogleFonts.abel(fontSize: 16),
              controller: _emailController,
              decoration: InputDecoration(
                  labelText: 'Email', labelStyle: GoogleFonts.oswald()),
            ),
            TextField(
              controller: _dobController,
              decoration: InputDecoration(
                labelText: 'Date of Birth',
                labelStyle: GoogleFonts.abel(),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.calendar_today),
                  onPressed: () async {
                    DateTime? pickedDate = await showDatePicker(
                      context: context,
                      initialDate: DateTime.now(),
                      firstDate: DateTime(1900),
                      lastDate: DateTime.now(),
                    );
                    if (pickedDate != null) {
                      setState(() {
                        _dobController.text =
                            DateFormat('yyyy-MM-dd').format(pickedDate);
                      });
                    }
                  },
                ),
              ),
            ),
            TextField(
              style: GoogleFonts.abel(fontSize: 16),
              controller: _departmentController,
              decoration: InputDecoration(
                  labelText: 'Department', labelStyle: GoogleFonts.oswald()),
            ),
            TextField(
              style: GoogleFonts.abel(fontSize: 16),
              controller: _roleController,
              decoration: InputDecoration(
                  labelText: 'Role', labelStyle: GoogleFonts.oswald()),
            ),
            const SizedBox(height: 20),
            Text('Qualifications',
                style: GoogleFonts.lato(fontWeight: FontWeight.bold)),
            ..._qualifications.asMap().entries.map((entry) {
              int index = entry.key;
              Map<String, String> qualification = entry.value;
              return QualificationField(
                index: index,
                qualification: qualification,
                onChanged: (updatedQualification) {
                  setState(() {
                    _qualifications[index] = updatedQualification;
                  });
                },
              );
            }).toList(),
            TextButton.icon(
              onPressed: _addQualification,
              icon: const Icon(Icons.add),
              label: Text('Add Qualification', style: GoogleFonts.oswald()),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(
            'Cancel',
            style: GoogleFonts.oswald(),
          ),
        ),
        TextButton(
          onPressed: _saveChanges,
          child: Text('Save', style: GoogleFonts.oswald()),
        ),
      ],
    );
  }
}

class QualificationField extends StatelessWidget {
  final int index;
  final Map<String, String> qualification;
  final ValueChanged<Map<String, String>> onChanged;

  const QualificationField({
    super.key,
    required this.index,
    required this.qualification,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: SizedBox(
        height: 250,
        child: Column(
          children: [
            TextField(
              style: GoogleFonts.abel(fontSize: 16),
              decoration: InputDecoration(
                  labelText: 'Year', labelStyle: GoogleFonts.oswald()),
              onChanged: (value) =>
                  onChanged({...qualification, 'year': value}),
            ),
            TextField(
              style: GoogleFonts.abel(fontSize: 16),
              decoration: InputDecoration(
                  labelText: 'Course Studied',
                  labelStyle: GoogleFonts.oswald()),
              onChanged: (value) =>
                  onChanged({...qualification, 'courseStudied': value}),
            ),
            TextField(
              style: GoogleFonts.abel(fontSize: 16),
              decoration: InputDecoration(
                  labelText: 'Certificate No.',
                  labelStyle: GoogleFonts.oswald()),
              onChanged: (value) =>
                  onChanged({...qualification, 'certificateNo': value}),
            ),
            TextField(
              style: GoogleFonts.abel(fontSize: 16),
              decoration: InputDecoration(
                  labelText: 'Institution', labelStyle: GoogleFonts.oswald()),
              onChanged: (value) =>
                  onChanged({...qualification, 'institution': value}),
            ),
            const Divider(),
          ],
        ),
      ),
    );
  }
}
