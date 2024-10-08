import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

class TransactionsScreen extends StatefulWidget {
  const TransactionsScreen({super.key});

  @override
  TransactionsScreenState createState() => TransactionsScreenState();
}

class TransactionsScreenState extends State<TransactionsScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  DateTime? _selectedDate;
  final TextEditingController _searchController = TextEditingController();
  String _searchText = '';
  Map<String, double> _transactionSums = {};
  double _positiveTotal = 0.0;
  double _outgoingTotal = 0.0;

  Stream<QuerySnapshot> _getTransactionsStream(
      DateTime? selectedDate, String searchText) {
    Query query = _firestore.collection('transactions');

    if (selectedDate != null) {
      DateTime startOfDay =
          DateTime(selectedDate.year, selectedDate.month, selectedDate.day);
      DateTime endOfDay = startOfDay.add(const Duration(days: 1));
      query = query
          .where('transactionDate',
              isGreaterThanOrEqualTo: Timestamp.fromDate(startOfDay))
          .where('transactionDate', isLessThan: Timestamp.fromDate(endOfDay));
    }

    if (searchText.isNotEmpty) {
      query = query
          .where('description', isGreaterThanOrEqualTo: searchText)
          .where('description', isLessThan: searchText + 'z');
    }

    return query.snapshots();
  }

  void _calculateTransactionSums(QuerySnapshot snapshot) {
    _transactionSums = {};
    _positiveTotal = 0.0;
    _outgoingTotal = 0.0;

    for (var doc in snapshot.docs) {
      String type = doc['transactionType'] ?? 'Unknown';
      double amount = doc['amount'] ?? 0.0;

      if (_transactionSums.containsKey(type)) {
        _transactionSums[type] = _transactionSums[type]! + amount;
      } else {
        _transactionSums[type] = amount;
      }

      if (type == 'sales' || type == 'revenue') {
        _positiveTotal += amount;
      } else {
        _outgoingTotal += amount;
      }
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  void _updateSearchText(String text) {
    setState(() {
      _searchText = text.toLowerCase();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[300],
      appBar: AppBar(
        backgroundColor: Colors.black,
        leading: IconButton(
            color: Colors.white54,
            onPressed: () => Navigator.pop(context),
            icon: const Icon(CupertinoIcons.back)),
        title: Text(
          'Transactions',
          style: GoogleFonts.robotoCondensed(color: Colors.white54),
        ),
        centerTitle: true,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 50.0),
            child: IconButton(
              color: Colors.white54,
              icon: const Icon(Icons.calendar_today),
              onPressed: () => _selectDate(context),
            ),
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(kToolbarHeight),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 200, vertical: 10),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search by Description or Transaction Type',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10.0),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: Colors.white,
              ),
              onChanged: _updateSearchText,
            ),
          ),
        ),
      ),
      body: Row(
        children: [
          Expanded(
            flex: 4,
            child: StreamBuilder<QuerySnapshot>(
              stream: _getTransactionsStream(_selectedDate, _searchText),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return Center(
                      child: Text(
                    'No transactions found.',
                    style: GoogleFonts.abel(),
                  ));
                }

                List<DocumentSnapshot> transactions = snapshot.data!.docs;
                _calculateTransactionSums(snapshot.data!);

                return SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: DataTable(
                    columns: <DataColumn>[
                      DataColumn(
                          label: Text(
                        'Index',
                        style: GoogleFonts.roboto(fontWeight: FontWeight.bold),
                      )),
                      DataColumn(
                          label: Text(
                        'Transaction Type',
                        style: GoogleFonts.roboto(fontWeight: FontWeight.bold),
                      )),
                      DataColumn(
                          label: Text(
                        'Transaction Id',
                        style: GoogleFonts.roboto(fontWeight: FontWeight.bold),
                      )),
                      DataColumn(
                          label: Text(
                        'Amount',
                        style: GoogleFonts.roboto(fontWeight: FontWeight.bold),
                      )),
                      DataColumn(
                          label: Text(
                        'Transaction Date',
                        style: GoogleFonts.roboto(fontWeight: FontWeight.bold),
                      )),
                      DataColumn(
                          label: Text(
                        'Time',
                        style: GoogleFonts.roboto(fontWeight: FontWeight.bold),
                      )),
                      DataColumn(
                          label: Text(
                        'Description',
                        style: GoogleFonts.roboto(fontWeight: FontWeight.bold),
                      )),
                    ],
                    rows: transactions.asMap().entries.map((entry) {
                      int index = entry.key;
                      DocumentSnapshot transaction = entry.value;
                      Timestamp timestamp = transaction['transactionDate'];
                      DateTime dateTime = timestamp.toDate();
                      String formattedDate =
                          DateFormat('yyyy-MM-dd').format(dateTime);
                      String formattedTime =
                          DateFormat('kk:mm').format(dateTime);

                      String transactionType =
                          transaction['transactionType'] ?? 'N/A';
                      double amount = transaction['amount'];
                      bool isPositiveTransaction = transactionType == 'sales' ||
                          transactionType == 'revenue';
                      IconData iconData = isPositiveTransaction
                          ? Icons.arrow_upward
                          : Icons.arrow_downward;
                      Color iconColor =
                          isPositiveTransaction ? Colors.green : Colors.red;

                      return DataRow(
                        cells: <DataCell>[
                          DataCell(Text((index + 1).toString())),
                          DataCell(Text(
                            transactionType,
                            style: GoogleFonts.roboto(),
                          )),
                          DataCell(Text(
                            transaction['transactionId'] ?? 'N/A',
                            style: GoogleFonts.roboto(),
                          )),
                          DataCell(Row(
                            children: [
                              Text(
                                amount.toString(),
                                style: GoogleFonts.roboto(),
                              ),
                              Icon(iconData, color: iconColor),
                            ],
                          )),
                          DataCell(Text(
                            formattedDate,
                            style: GoogleFonts.roboto(),
                          )),
                          DataCell(Text(
                            formattedTime,
                            style: GoogleFonts.roboto(),
                          )),
                          DataCell(Text(
                            transaction['description'] ?? 'N/A',
                            style: GoogleFonts.roboto(),
                          )),
                        ],
                      );
                    }).toList(),
                  ),
                );
              },
            ),
          ),
          const VerticalDivider(),
          Expanded(
            flex: 1,
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Summary (Last 3 months)',
                    style: GoogleFonts.aboreto(fontWeight: FontWeight.bold),
                  ),
                  const Divider(),
                  Expanded(
                    child: ListView(
                      children: _transactionSums.entries.map((entry) {
                        return ListTile(
                          title: Text(entry.key),
                          trailing: Text(entry.value.toStringAsFixed(2)),
                        );
                      }).toList(),
                    ),
                  ),
                  const Divider(),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 15, vertical: 8),
                    decoration: BoxDecoration(
                        color: Colors.white,
                        border: Border.all(color: Colors.black54)),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          mainAxisSize: MainAxisSize.max,
                          children: [
                            Text(
                              'Total Incoming Transactions:',
                              style: GoogleFonts.roboto(
                                  fontSize: 12, fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(
                              width: 6,
                            ),
                            Text(
                              '\$${_positiveTotal.toStringAsFixed(2)}',
                              style: GoogleFonts.aboreto(color: Colors.green),
                            ),
                          ],
                        ),
                        const SizedBox(
                          width: 6,
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          mainAxisSize: MainAxisSize.max,
                          children: [
                            Text(
                              'Total Outgoing Transactions:',
                              style: GoogleFonts.roboto(
                                  fontSize: 12, fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(
                              width: 6,
                            ),
                            Text(
                              '\$${_outgoingTotal.toStringAsFixed(2)}',
                              style: GoogleFonts.aboreto(color: Colors.red),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
