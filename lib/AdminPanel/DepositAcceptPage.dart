import 'dart:ui';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:retailadminpanel/AdminPanel/screen_short.dart';

import '../core/firebase_api.dart';

class DepositAcceptScreen extends StatefulWidget {
  const DepositAcceptScreen({Key? key}) : super(key: key);

  @override
  State<DepositAcceptScreen> createState() => _RechargeAcceptScreenState();
}

class _RechargeAcceptScreenState extends State<DepositAcceptScreen> {
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
      return await _firestore.collection('DepositDetails').doc(user.uid).get();
    } catch (e) {
      throw Exception('Error fetching document: $e');
    }
  }

  Future<void> _updateStatus(String documentId, String newStatus) async {
    try {
      await _firestore
          .collection('DepositDetails')
          .doc(documentId)
          .update({'Status': newStatus});


      final document = await _firestore.collection('ReceiptDetails').doc(documentId).get();


      final user = await _firestore.collection('Check').doc(document['user']).get();

      final userToken = user['token'];

      await FirebaseApi.sendMessage('Deposit Request Accepted', 'Your deposit request of ${document['User Diamond']} diamond has been approved', userToken);

    } catch (e) {
      throw Exception('Error updating status: $e');
    }
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'unpaid':
        return Colors.orange;
      case 'paid':
        return Colors.green;
      case 'reject':
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
    final transectionId = document['TrxID'].toString().toLowerCase();
    final amount = document['Amount'].toString().toLowerCase();
    return transectionId.contains(_searchQuery) ||
        amount.contains(_searchQuery);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Deposit Request List'),
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
                    hintText: 'Search by any...',
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
                    stream: _firestore
                        .collection('DepositDetails')
                        .where('Status', whereIn: ['unpaid','reject']).snapshots(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return Center(child: CircularProgressIndicator());
                      }

                      if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                        return Center(child: Text('No unpaid request.'));
                      }

                      final filteredDocuments = snapshot.data!.docs
                          .where((document) => _isDocumentMatch(document))
                          .toList();

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
                            title: SelectableText("Trangection ID: ${document['TrxID']} Name:${document['name']}"),
                            subtitle: SelectableText("Amount: ${document['Amount']}"),
                            leading:Image.network("${document['user_photo']}"),
                            trailing: DropdownButton<String>(
                              value: document['Status'],
                              items: <String>['unpaid', 'paid','reject']
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
                                if (newValue != null) {
                                  _updateStatus(document.id, newValue);
                                }
                              },
                            ),
                            tileColor: _getStatusColor(document['Status']),
                            onTap: () {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => ScreenShortScreen(
                                        screen_short: document['user_photo'],
                                      )));

                            },
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
