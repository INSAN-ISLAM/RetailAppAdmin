import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;

import 'UserDetailsPage.dart';

class SignUpListScreen extends StatefulWidget {
  SignUpListScreen({Key? key}) : super();

  @override
  State<SignUpListScreen> createState() => _UserListScreenState();
}

class _UserListScreenState extends State<SignUpListScreen> {
  final CollectionReference _itemsCollection = FirebaseFirestore.instance.collection('Check');

  final user = FirebaseAuth.instance.currentUser;

  void _showDeleteConfirmationDialog(String id, String uid) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Confirm Deletion'),
          content: Text('Are you sure you want to delete this item?'),
          actions: <Widget>[
            TextButton(
              child: Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text('Delete'),
              onPressed: () {
                Navigator.of(context).pop();
                _deleteItem(id, uid);
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> deleteUserDataFromAllCollections(String userId) async {
    try {
      await FirebaseFirestore.instance.collection('profiles').doc(userId).delete();

      QuerySnapshot ordersSnapshot = await FirebaseFirestore.instance
          .collection('orders')
          .where('userId', isEqualTo: userId)
          .get();

      for (var doc in ordersSnapshot.docs) {
        await doc.reference.delete();
      }

      QuerySnapshot messagesSnapshot = await FirebaseFirestore.instance
          .collection('messages')
          .where('userId', isEqualTo: userId)
          .get();

      for (var doc in messagesSnapshot.docs) {
        await doc.reference.delete();
      }

      print('All user data deleted from Firestore collections.');
    } catch (e) {
      print('Failed to delete user data from collections: $e');
    }
  }

  Future<void> deleteFirebaseUser(String userId) async {
    try {
      User? user = FirebaseAuth.instance.currentUser;

      if (user != null) {
        await user.delete();
        print('User account deleted successfully.');
      } else {
        print('No user is signed in.');
      }
    } catch (e) {
      print('Error deleting user: $e');
    }
  }
  void _deleteItem(String id, String uid) {
    _itemsCollection.doc(id).delete().then((_) async {
      // Delete associated documents from DepositDetails and ReceiptDetails collections
      await _deleteDocumentsWithUID(uid);

      await _deleteUser(uid);

    //await deleteFirebaseUser(uid);

      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Item deleted')));
    }).catchError((error) {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to delete item: $error')));
    });
  }

  Future<void> _deleteDocumentsWithUID(String uid) async {
    // Delete documents from DepositDetails with matching uid
    QuerySnapshot depositDetailsSnapshot = await FirebaseFirestore.instance
        .collection('DepositDetails')
        .where('user', isEqualTo: uid)
        .get();

    for (var doc in depositDetailsSnapshot.docs) {
      await doc.reference.delete();
    }

    // Delete documents from ReceiptDetails with matching uid
    QuerySnapshot receiptDetailsSnapshot = await FirebaseFirestore.instance
        .collection('ReceiptDetails')
        .where('user', isEqualTo: uid)
        .get();

    for (var doc in receiptDetailsSnapshot.docs) {
      await doc.reference.delete();
    }

    print('Documents from DepositDetails and ReceiptDetails deleted for uid: $uid');
  }

  _deleteUser(uid) async {


    String url = 'https://google.smartbiniyog.com/api/delete_user/${uid.toString()}';

    http.Response response = await http.delete(Uri.parse(url));
    print(response);
    print('code' + response.statusCode.toString());
    if (response.statusCode == 200) {
      print("User delete successfully");
    } else {
      print("Something went wrong");
    }
  }

  final _advance = <String, int>{};
  num totalUserAmount = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          'User List',
          style: GoogleFonts.arbutusSlab(
            textStyle: TextStyle(
              color: Colors.white,
              fontSize: 25,
            ),
          ),
        ),
      ),
      body: StreamBuilder(
        stream: FirebaseFirestore.instance.collection('Check').snapshots(),
        builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (!snapshot.hasData) {
            return Center(child: CircularProgressIndicator());
          }

          List<DocumentSnapshot> users = snapshot.data!.docs;

          return StreamBuilder(
            stream: Stream.fromFuture(Future.wait([
              FirebaseFirestore.instance
                  .collection('DepositDetails')
                  .where('Status', isEqualTo: 'paid')
                  .get(),
              FirebaseFirestore.instance
                  .collection('ReceiptDetails')
                  .where('Status', isEqualTo: 'Approve')
                  .get(),
            ])),
            builder: (context, AsyncSnapshot<List<QuerySnapshot>> collectionSnapshot) {
              if (!collectionSnapshot.hasData) {
                return Center(child: CircularProgressIndicator());
              }

              var totalDepositAmounts = 0;
              final sum = <String, int>{};
              collectionSnapshot.data![0].docs.forEach((doc) {
                var depositAmount = (doc['Amount'] as int?) ?? 0;
                var userId = doc['user'] ?? '0';

                sum[userId] = (sum[userId] ?? 0) + depositAmount;
              });

              var totalAdvanceAmount = 0;
              final _advance = <String, int>{};
              collectionSnapshot.data![1].docs.forEach((doc) {
                var advanceAmount = (doc['amount'] as int?) ?? 0;
                var uid = doc['user'] ?? '0';
                _advance[uid] = (_advance[uid] ?? 0) + advanceAmount;
              });

              return Padding(
                padding: const EdgeInsets.all(8.0),
                child: ListView.separated(
                  itemCount: users.length,
                  itemBuilder: (context, index) {
                    var user = users[index];
                    var userData = user.data() as Map<String, dynamic>;
                    var totalDeposit = sum[userData['uid']] ?? 0;
                    var totalAdvance = _advance[userData['uid']] ?? 0;
                    var totalResult = totalDeposit - totalAdvance;

                    totalUserAmount = totalUserAmount + totalResult;

                    return Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Expanded(
                          flex: 90,
                          child: InkWell(
                              onTap: () {
                                if (userData['user_photo'].isNotEmpty) {
                                  Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) => UserDetailScreen(
                                            nid_backPart: userData['nid_back'],
                                            nid_frontPart: userData['nid_front'],
                                            num: userData['whats_app'],
                                            address: userData['address'],
                                          )));
                                }
                              },
                              child: ListTile(
                                title: Text('Name : ${userData['name'] ?? 'No Name'}'),
                                subtitle: Text("Total= $totalResult Tk & Rate=${userData['rate'] ?? 'No Rate'}%"),
                                leading: Container(
                                  height: 80,
                                  width: 80,
                                  child: userData['user_photo'] ==null? Icon(Icons.person,size: 40,): Image.network(userData['user_photo']),
                                ),
                              )),
                        ),
                        Expanded(
                            flex: 10,
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: IconButton(
                                  onPressed: () {
                                    _showDeleteConfirmationDialog(user.id, userData['uid']);
                                  },
                                  icon: Icon(Icons.pending)),
                            )),
                      ],
                    );
                  },
                  separatorBuilder: (context, index) {
                    return Divider(
                      thickness: 2,
                      height: 30,
                      color: Colors.deepOrange,
                    );
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}