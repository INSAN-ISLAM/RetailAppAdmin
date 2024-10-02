import 'dart:ui';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:retailadminpanel/core/firebase_api.dart';

class RechargeAcceptScreen extends StatefulWidget {
  const RechargeAcceptScreen({Key? key}) : super(key: key);

  @override
  State<RechargeAcceptScreen> createState() => _RechargeAcceptScreenState();
}

class _RechargeAcceptScreenState extends State<RechargeAcceptScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  late Future<DocumentSnapshot> _documentFuture;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _documentFuture = _getDocument();
  }

  Future<DocumentSnapshot> _getDocument() async {
    try {
      User? user = FirebaseAuth.instance.currentUser;
      print(user!.uid);
      return await _firestore.collection('ReceiptDetails').doc(user.uid).get();
    } catch (e) {
      throw Exception('Error fetching document: $e');
    }
  }

  Future<void> _updateStatus(String documentId, String newStatus) async {
    try {
      await _firestore
          .collection('ReceiptDetails')
          .doc(documentId)
          .update({'Status': newStatus});

      final document = await _firestore.collection('ReceiptDetails').doc(documentId).get();


      final user = await _firestore.collection('Check').doc(document['user']).get();

      final userToken = user['token'] as List;

      await FirebaseApi.sendMessage('Recharge Request Accepted', 'Your recharge request of ${document['TransferDiamond']} diamond has been approved', userToken);

    } catch (e) {
      throw Exception('Error updating status: $e');
    }
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'Pending':
        return Colors.orange;
      case 'Approve':

        return Colors.green;
      case 'Reject':
        return Colors.red;
      default:
        return Colors.black;
    }
  }

  void _searchDocuments(String query) {
    setState(() {
      _searchQuery = query.toLowerCase();
    });
  }

  bool _isDocumentMatch(QueryDocumentSnapshot document) {
    final receiptNumber = document['ReceiptNumber'].toString().toLowerCase();
    final diamond = document['TransferDiamond'].toString().toLowerCase();
    return receiptNumber.contains(_searchQuery) || diamond.contains(_searchQuery);
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Receipt List'),
      ),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(5.0),
          child: Column(
            children: [
              Padding(
                padding: EdgeInsets.all(8.0),
                child: TextField(
                  decoration: InputDecoration(
                    hintText: 'Search by receipt number or diamond...',
                    prefixIcon: Icon(Icons.search),
                  ),
                  onChanged: _searchDocuments,
                ),
              ),
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: StreamBuilder<QuerySnapshot>(
                    stream: _firestore.collection('ReceiptDetails').where('Status', whereIn: ['Pending', 'Reject']).snapshots(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return Center(child: CircularProgressIndicator());
                      }

                      if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                        return Center(
                            child: Text('No pending or rejected receipts.'));
                      }

                      final filteredDocuments = snapshot.data!.docs.where((document) => _isDocumentMatch(document)).toList();

                      if (filteredDocuments.isEmpty) {
                        return Center(child: Text('No results found.'));
                      }

                      return ListView.builder(
                        itemCount: filteredDocuments.length,
                        itemBuilder: (context, index) {
                          final document = filteredDocuments[index];
                          var date = document['created_at'].toDate();
                          var formattedDate = DateFormat.yMMMd().format(date);

                          return ListTile(
                            title: SelectableText(
                                "Rpt Number: ${document['ReceiptNumber']} Name:${document['name']}"),
                                //"Receipt Number: ${document['ReceiptNumber']}  Name:${document['name']}"),
                            subtitle: SelectableText("Diamond: ${document['TransferDiamond']}"),
                            trailing: DropdownButton<String>(
                              value: document['Status'],
                              items: <String>['Pending', 'Approve', 'Reject']
                                  .map((String value) {
                                return DropdownMenuItem<String>(
                                  value: value,
                                  child: Text(
                                    value,
                                    style: TextStyle(
                                        color: _getStatusColor(value)),
                                  ),
                                );
                              }).toList(),
                              onChanged: (String? newValue) {
                                print(newValue);
                                if (newValue != null) {
                                  _updateStatus(document.id, newValue);
                                }
                              },
                            ),
                            tileColor: _getStatusColor(document['Status']),

                            onTap: () {},
                          );
                        },
                      );
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
