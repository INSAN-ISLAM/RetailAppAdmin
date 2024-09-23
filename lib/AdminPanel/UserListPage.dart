import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;

import 'UserDetailsPage.dart';

class SignUpListScreen extends StatefulWidget {
  const SignUpListScreen({Key? key}) : super(key: key);

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

  void _deleteItem(String id, uid) {
    _itemsCollection.doc(id).delete().then((_) async {
      await _deleteUser(uid);

      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Item deleted')));
    }).catchError((error) {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to delete item: $error')));
    });
  }

  _deleteUser(uid) async {
    String url = 'https://pulsefinance.us/public/api/firebase_delete_user/${uid.toString()}';

    http.Response response = await http.delete(Uri.parse(url));
    print(response);
    if (response.statusCode == 200) {

      print("User delete successfully");
    } else {
      print("Something went wrong");
    }
  }

  //num totalDepositAmount = 0;

  final _advance = <String, int>{};

  num totalUserAmount=0;

  //print($total);
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
      body: FutureBuilder(
          future: Future.wait([
            FirebaseFirestore.instance.collection('Check').get(),
            FirebaseFirestore.instance.collection('DepositDetails').where('Status', isEqualTo: 'paid').get(),
          FirebaseFirestore.instance.collection('ReceiptDetails').where('Status', isEqualTo: 'Approve').get(),
          ]),


          builder: (context, AsyncSnapshot<List<dynamic>> snapshot) {
            if (!snapshot.hasData) {
              return Center(child: CircularProgressIndicator());
            }

            // Collection 1 Data
            List<DocumentSnapshot> users = snapshot.data![0].docs;
            // snapshot.data![0].docs.forEach((doc) {
            //   var userId = doc['uid']  ?? 0;
            //   print(userId);
            //   var totalAdvance = _advance[doc['uid']] ?? 0 ;
            //   var totalDiposit  = sum[doc['uid']] ?? 0 ;
            //   print(totalDiposit);
            //   //userData['uid']] ?? 0 ;
            //
            //   //totalDepositAmounts += depositAmount;
            // });





            // Collection 2 Data
            //  List<DocumentSnapshot> collection2Data = snapshot.data![1].docs;
           // final sum = <String, int>{};
            //
             var totalDepositAmounts=0;
            final sum = <String, int>{};
            snapshot.data![1].docs.forEach((doc) {
              var depositAmount = (doc['Amount'] as int?) ?? 0;
              var user_id = doc['user'] ?? '0' ?? 0;

              sum[user_id] = (sum[user_id] ?? 0) + depositAmount;
             //totalDepositAmounts += depositAmount;
            });

            print(sum);
            //print(totalDepositAmounts);
            var totalAdvanceAmount=0;
            final _advance = <String, int>{};
            snapshot.data![2].docs.forEach((doc) {
              var advanceAmount = (doc['amount'] as int?) ?? 0;
              var uid = doc['user'] ?? '0' ?? 0;
              _advance[uid] = (_advance[uid] ?? 0) + advanceAmount;
             // totalAdvanceAmount += advanceAmount;
            });
           //print(_advance);
         //   print(totalAdvanceAmount);

   //var totalUserTaka=totalDepositAmounts-totalAdvanceAmount;
           // print(totalUserTaka);
          //  num totalUserResult=0;
            // print(totalUserResult);
            //print(users.length);




            return Padding(
              padding: const EdgeInsets.all(8.0),
              child: ListView.separated(
                itemCount: users.length,
               // addAutomaticKeepAlives: true,
                scrollDirection: Axis.vertical,
                itemBuilder: (context, index) {
                  var user = users[index];
                  var userData = user.data() as Map<String, dynamic>;
                  print(userData);
                  var totalDiposit  = sum[userData['uid']] ?? 0 ;
                  var totalAdvance = _advance[userData['uid']] ?? 0 ;
                  var total_result = totalDiposit-totalAdvance;

                  totalUserAmount = totalUserAmount+total_result;


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
                                              nid_backPart:
                                                  userData['nid_back'],
                                              // userData['nid_back'],
                                              nid_frontPart:
                                                  userData['nid_front'],
                                              // userData['nid_front'],
                                              num: userData['whats_app'],
                                              //userData['whats_app'],
                                              address: userData[
                                                  'address'], //userData['address'],
                                            )));
                              }
                            },
                            child: ListTile(
                              title: Text('Name : ${userData['name'] ?? 'No Name'}'),
                              subtitle: Text("Total= $total_result Tk & Rate=${userData['rate'] ?? 'No Name'}%  "),  //${sum[userData['uid']] ?? 0 }
                              leading: Container(
                                height: 100,
                                width: 100,
                                child: Image.network(userData['user_photo'] ?? 'No Image',),

                              ),
                            )),
                      ),


                      Expanded(
                          flex: 10,
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: IconButton(
                                onPressed: () {


                                  _showDeleteConfirmationDialog(
                                      user.id, userData['uid']);
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
          }),
    );
  }
}
