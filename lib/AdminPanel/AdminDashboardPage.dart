import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../Widget/AppEevatedButton.dart';
import 'DepositAcceptPage.dart';
import 'DepositHisPage.dart';
import 'RechargeAcceptPage.dart';
import 'RechargeHisPage.dart';
import 'SettingPage.dart';

import 'SignUpPage.dart';
import 'TransferHisPage.dart';
import 'UpdatePhNumPage.dart';
import 'UserByRatePage.dart';

class AdminDashBoardScreen extends StatefulWidget {
  const AdminDashBoardScreen({Key? key}) : super(key: key);

  @override
  State<AdminDashBoardScreen> createState() => _AdminDashBoardScreenState();
}

class _AdminDashBoardScreenState extends State<AdminDashBoardScreen> {
  MySnackBar(message, context) {
    return ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }

  MyAlertDialog(context) {
    return showDialog(
        context: context,
        builder: (BuildContext context) {
          return Expanded(
              child: AlertDialog(
                title: Text("Log Out"),
                content: Text("Are You sure you want to log out?"),
                actions: [
                  Center(
                    child: Column(
                      children: [
                        AppElevatedButton(
                          Color: Colors.yellow,
                          onTap: () {
                            // Navigator.of(context).pop();
                            //_signOut();
                            //Navigator.push(context, MaterialPageRoute(builder: (context) =>  LogInScreen()));
                          },
                          child: Center(
                            child: Text(
                              "Confirm",
                              style: GoogleFonts.poppins(
                                textStyle: const TextStyle(
                                  color: Colors.black,
                                  fontSize: 14,
                                  //fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          ),
                        ),
                        // TextButton(
                        //     onPressed: () {
                        //       // MySnackBar("Thanks", context);
                        //       // Navigator.of(context).pop();
                        //     },
                        //     child: Text("No")),
                        SizedBox(height: 5),
                        AppElevatedButton(
                          onTap: () {
                            Navigator.of(context).pop();
                            // Navigator.push(context, MaterialPageRoute(builder: (context) => const MainBottomNavBar()));
                          },
                          child: Center(
                            child: Text(
                              "Cancel",
                              style: GoogleFonts.poppins(
                                textStyle: const TextStyle(
                                  color: Colors.black,
                                  fontSize: 14,
                                  //fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ));
        });
  }












  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  late Future<QuerySnapshot> _depositFuture;
  late Future<QuerySnapshot> _receiptFuture;

  @override
  void initState() {
    super.initState();
    _depositFuture = _getDepositDetails();
    _receiptFuture = _getReceiptDetails();
  }

  Future<QuerySnapshot> _getDepositDetails() async {
    try {
      return await _firestore.collection('DepositDetails').where('Status', isEqualTo: 'paid').get();
    } catch (e) {
      throw Exception('Error fetching deposit details: $e');
    }
  }

  Future<QuerySnapshot> _getReceiptDetails() async {
    try {
      return await _firestore.collection('ReceiptDetails').where('Status', isEqualTo: 'Approve').get();
    } catch (e) {
      throw Exception('Error fetching receipt details: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: [
          TextButton(
    

            onPressed: (){


            Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(
                    builder: (context) =>  RegisterScreen()), (route) => true);
          }, child: Text('Create New Account',

          style: TextStyle(

              color: Colors.black),
          ),

          )
        ],
      ),

      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: FutureBuilder(
              future: Future.wait([_depositFuture, _receiptFuture]),
              builder: (BuildContext context, AsyncSnapshot<List<QuerySnapshot>> snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }

                double totalUserDiamond = 0;
                num totalDepositAmount = 0;
                double todayUserDiamond = 0;
                num todayDepositAmount = 0;

                snapshot.data![0].docs.forEach((doc) {
                  double userDiamond = double.tryParse(doc['User Diamond'] ?? '0') ?? 0;
                  totalUserDiamond += userDiamond;

                  DateTime now = DateTime.now();
                  DateTime startOfDay = DateTime(now.year, now.month, now.day);
                  DateTime endOfDay = DateTime(now.year, now.month, now.day, 23, 59, 59);

                  Timestamp createdAt = doc['created_at'];
                  if (createdAt.toDate().isAfter(startOfDay) &&
                      createdAt.toDate().isBefore(endOfDay)) {
                    todayUserDiamond += userDiamond;
                  }
                });

                snapshot.data![0].docs.forEach((doc) {
                  var depositAmount = doc['Amount'] ?? '0' ?? 0;
                  totalDepositAmount += depositAmount;

                  DateTime now = DateTime.now();
                  DateTime startOfDay = DateTime(now.year, now.month, now.day);
                  DateTime endOfDay =
                  DateTime(now.year, now.month, now.day, 23, 59, 59);

                  Timestamp createdAt = doc['created_at'];
                  if (createdAt.toDate().isAfter(startOfDay) &&
                      createdAt.toDate().isBefore(endOfDay)) {
                    todayDepositAmount += depositAmount;
                  }
                });
               num totalAdvanceAmount=0;
                num todayAdvanceAmount=0;
                double totalTransferDiamond = 0;
                double todayTransferDiamond = 0;
                snapshot.data![1].docs.forEach((doc) {
                  var advanceAmount = doc['amount'] ?? '0' ?? 0;
                  totalAdvanceAmount += advanceAmount;

                  DateTime now = DateTime.now();
                  DateTime startOfDay = DateTime(now.year, now.month, now.day);
                  DateTime endOfDay =
                  DateTime(now.year, now.month, now.day, 23, 59, 59);

                  Timestamp createdAt = doc['created_at'];
                  if (createdAt.toDate().isAfter(startOfDay) &&
                      createdAt.toDate().isBefore(endOfDay)) {
                    todayAdvanceAmount += advanceAmount;
                  }
                });

               //  print(totalAdvanceAmount);
                // print(totalAdvanceAmount);
                //
                 //print(totalDepositAmount);
                //num totalUserTaka=totalDepositAmount-totalAdvanceAmount;
               // print(totalUserTaka);
                snapshot.data![1].docs.forEach((doc) {
                  double transferDiamond =
                      double.tryParse(doc['TransferDiamond'] ?? '0') ?? 0;
                  totalTransferDiamond += transferDiamond;

                  DateTime now = DateTime.now();
                  DateTime startOfDay = DateTime(now.year, now.month, now.day);
                  DateTime endOfDay =
                  DateTime(now.year, now.month, now.day, 23, 59, 59);

                  Timestamp createdAt = doc['created_at'];
                  if (createdAt.toDate().isAfter(startOfDay) &&
                      createdAt.toDate().isBefore(endOfDay)) {
                    todayTransferDiamond += transferDiamond;
                  }
                });


                int totalResult = (totalUserDiamond - totalTransferDiamond).toInt();
                int todayResult = (todayUserDiamond - todayTransferDiamond).toInt();

// Ensure the int values are converted to String when used in Text widgets
//                 Text('Total Result: ${totalResult.toString()}'),
//                 Text('Today Result: ${todayResult.toString()}'),


                return Column(
                  children: [
                    Card(
                      elevation: 10,
                      child: Container(
                          height: 150,
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: Colors.deepOrange,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(15.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                CircleAvatar(
                                  radius: 10,

                                ),

                                SizedBox(
                                  height: 10,
                                ),
                                Text("Today Diamond Availabe"),

                                SizedBox(
                                  height: 10,
                                ),
                                Row(
                                  children: [
                                    Text(
                                      "${todayResult.toString()} ",
                                      style: TextStyle(
                                        fontSize: 20,
                                      ),
                                    ),
                                    Icon(FontAwesomeIcons.sketch,)
                                  ],
                                ),
                              ],
                            ),
                          )),
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    Card(
                      elevation: 10,
                      child: Container(
                          height: 150,
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: Colors.deepOrange,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(15.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // IconButton(onPressed: (){
                                //
                                //   // Navigator.pushAndRemoveUntil(context, MaterialPageRoute(
                                //   //     builder: (context) => SettingScreen()), (route) => true);},
                                //   // icon: Icon(Icons.settings),
                                // ),
                                CircleAvatar(
                                  radius: 10,
                                  //   backgroundImage:AssetImage('assets/images/profile.png'),
                                ),
                                SizedBox(
                                  height: 10,
                                ),
                                Text("Total Diamond Availabe"),

                                SizedBox(
                                  height: 10,
                                ),
                                Row(
                                  children: [
                                    Text(
                                      '${totalResult.toString()}',
                                      style: TextStyle(
                                        fontSize: 20,
                                      ),
                                    ),
                                    Icon(FontAwesomeIcons.sketch,)
                                  ],
                                ),
                              ],
                            ),
                          )),
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    Row(
                      children: [
                        Expanded(
                          flex: 40,
                          child: Card(
                            elevation: 10,
                            child: Container(
                                height: 90,
                                width: 150,
                                decoration: BoxDecoration(
                                  color: Colors.teal[900],
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: InkWell(
                                  onTap: () {
                                    // Navigator.pushAndRemoveUntil(context, MaterialPageRoute(
                                    //     builder: (context) => TransferDaimondImoScreen()), (route) => true);
                                  },
                                  child: Column(
                                    //mainAxisAlignment: MainAxisAlignment.start,
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    crossAxisAlignment:
                                    CrossAxisAlignment.start,
                                    children: [
                                      SizedBox(
                                        height: 15,
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.all(6.0),
                                        child: Text(
                                          "Today Deposit Daimond", //Diamond
                                          style: TextStyle(color: Colors.white),
                                        ),
                                      ),
                                      SizedBox(
                                        height: 5,
                                      ),
                                      Row(
                                        children: [
                                          Padding(
                                            padding: EdgeInsets.only(
                                              left: 6.0,
                                            ),
                                            child: Text(
                                              "${todayUserDiamond.toStringAsFixed(2)}",
                                              style: TextStyle(
                                                  fontSize: 20,
                                                  color: Colors.white),
                                            ),
                                          ),
                                          Padding(
                                              padding: EdgeInsets.only(
                                                left: 5.0,
                                              ),
                                              child: Icon(FontAwesomeIcons.sketch, color: Colors.black,)
                                          )
                                        ],
                                      ),
                                    ],
                                  ),
                                )),
                          ),
                        ),
                        Expanded(
                          flex: 40,
                          child: Card(
                            elevation: 10,
                            child: Container(
                                height: 90,
                                width: 150,
                                decoration: BoxDecoration(
                                  color: Colors.teal[900],
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: InkWell(
                                  onTap: () {
                                    // Navigator.pushAndRemoveUntil(context, MaterialPageRoute(
                                    //     builder: (context) => TransferDaimondImoScreen()), (route) => true);
                                  },
                                  child: Column(
                                    //mainAxisAlignment: MainAxisAlignment.start,
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    crossAxisAlignment:
                                    CrossAxisAlignment.start,
                                    children: [
                                      SizedBox(
                                        height: 15,
                                      ),
                                      Padding(
                                        padding: EdgeInsets.only(
                                          left: 6.0,
                                        ),
                                        child: Text(
                                          "today Diposit Taka ", //Total Diamond
                                          style: TextStyle(color: Colors.white),
                                        ),
                                      ),
                                      SizedBox(
                                        height: 5,
                                      ),
                                      Row(
                                        children: [
                                          Padding(
                                            padding: EdgeInsets.only(
                                              left: 6.0,
                                            ),
                                            child: Text(
                                              "$todayDepositAmount",
                                              style: TextStyle(
                                                  fontSize: 20,
                                                  color: Colors.white),
                                            ),
                                          ),
                                          SizedBox(
                                            width: 4,
                                          ),
                                          Padding(
                                              padding: EdgeInsets.only(
                                                left: 6.0,
                                              ),
                                              child:Icon(FontAwesomeIcons.sketch, color: Colors.black,)
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                )),
                          ),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        Expanded(
                          flex: 50,
                          child: Card(
                            elevation: 10,
                            child: Container(
                                height: 90,
                                width: 150,
                                decoration: BoxDecoration(
                                  color: Colors.teal[900],
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: InkWell(
                                  onTap: () {
                                    // Navigator.pushAndRemoveUntil(context, MaterialPageRoute(
                                    //     builder: (context) => TransferDaimondImoScreen()), (route) => true);
                                  },
                                  child: Column(
                                    //mainAxisAlignment: MainAxisAlignment.start,
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    crossAxisAlignment:
                                    CrossAxisAlignment.start,
                                    children: [
                                      SizedBox(
                                        height: 15,
                                      ),
                                      Padding(
                                        padding: EdgeInsets.only(
                                          left: 16.0,
                                        ),
                                        child: Text(
                                          "Total Deposit Daimond",
                                          style: TextStyle(color: Colors.white),
                                        ),
                                      ),
                                      SizedBox(
                                        height: 5,
                                      ),
                                      Row(
                                        children: [
                                          Padding(
                                            padding: EdgeInsets.only(
                                              left: 16.0,
                                            ),
                                            child: Text(
                                              "${totalUserDiamond.toStringAsFixed(2)}",
                                              style: TextStyle(
                                                  fontSize: 20,
                                                  color: Colors.white),
                                            ),
                                          ),
                                          Padding(
                                              padding: EdgeInsets.only(
                                                left: 6.0,
                                              ),
                                              child: Icon(FontAwesomeIcons.sketch, color: Colors.black,)
                                          )
                                        ],
                                      ),
                                    ],
                                  ),
                                )),
                          ),
                        ),
                        Expanded(
                          flex: 50,
                          child: Card(
                            elevation: 10,
                            child: Container(
                                height: 90,
                                width: 150,
                                decoration: BoxDecoration(
                                  color: Colors.teal[900],
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: InkWell(
                                  onTap: () {
                                    // Navigator.pushAndRemoveUntil(context, MaterialPageRoute(
                                    //     builder: (context) => TransferDaimondImoScreen()), (route) => true);
                                  },
                                  child: Column(
                                    //mainAxisAlignment: MainAxisAlignment.start,
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    crossAxisAlignment:
                                    CrossAxisAlignment.start,
                                    children: [
                                      SizedBox(
                                        height: 15,
                                      ),
                                      Padding(
                                        padding: EdgeInsets.only(
                                          left: 16.0,
                                        ),
                                        child: Text(
                                          "Total sales Diamond",
                                          style: TextStyle(color: Colors.white),
                                        ),
                                      ),
                                      SizedBox(
                                        height: 5,
                                      ),
                                      Row(
                                        children: [
                                          Padding(
                                            padding: EdgeInsets.only(
                                              left: 16.0,
                                            ),
                                            child: Text(
                                              "$totalDepositAmount",
                                              style: TextStyle(
                                                  fontSize: 20,
                                                  color: Colors.white),
                                            ),
                                          ),
                                          Padding(
                                            padding: EdgeInsets.only(
                                              left: 16.0,
                                            ),
                                            child: Text(
                                              "Taka",
                                              style: TextStyle(
                                                  fontSize: 20,
                                                  color: Colors.white),
                                            ),
                                          ),

                                        ],
                                      ),
                                    ],
                                  ),
                                )),
                          ),
                        ),
                      ],
                    ),
                  ],
                );
              }),
        ),
      ),
      // floatingActionButtonLocation:FloatingActionButtonLocation.endFloat,
      // floatingActionButton: FloatingActionButton(
      //   elevation: 10,
      //   child: Icon(Icons.add,color:Colors.blue) ,
      //   backgroundColor: Colors.green,
      //
      //   onPressed: (){
      //     MySnackBar("I am floating action button",context);
      //   },
      //   foregroundColor:Colors.pink,
      //
      //   focusColor: Colors.brown,
      //
      //   // autoFocus: true,
      // ),

      drawer: Drawer(
        child: ListView(
          children: [
            DrawerHeader(
              padding: EdgeInsets.all(10),
              child: Center(
                  child: Text("Main Dachbord",
                      style: TextStyle(color: Colors.black))),

            ),
            ListTile(
              title: Text("Navigation"),
            ),
            ListTile(
                leading: const Icon(Icons.add_box_outlined),
                title: Text("User By Rate"),
                onTap: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => UserByRateScreen()));
                }),
            ListTile(
                leading: Icon(Icons.add_box_outlined),
                title: Text("Recharge Accept"),
                onTap: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => RechargeAcceptScreen()));
                }),
            ListTile(
                leading: Icon(Icons.add_box_outlined),
                title: Text("Deposit Request Accept"),
                onTap: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => DepositAcceptScreen()));
                }),
            ListTile(
                leading: Icon(Icons.add_box_outlined),
                title: Text("Deposit History"),
                onTap: () {
                  Navigator.push(context,
                      MaterialPageRoute(builder: (context) => OrderScreen()));
                }),
            ListTile(
                leading: Icon(Icons.add_box_outlined),
                title: Text("Recharge History"),
                onTap: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => ReceiptAcceptScreen()));
                }),
            ListTile(
                leading: Icon(Icons.work_history_rounded),
                title: Text("Transfer History"),
                onTap: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => TransferScreen()));
                }),
            ListTile(
                leading: Icon(Icons.work_history_rounded),
                title: Text("UpdatePhNum"),
                onTap: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => UpdatePhNumScreen()));
                }),
            ListTile(
                leading: Icon(Icons.settings),
                title: Text("Setting"),
                onTap: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => SettingScreen()));
                }),

          ],
        ),
      ),
    );

  }

}

class AdminDepositScreen extends StatefulWidget {
  const AdminDepositScreen({Key? key}) : super(key: key);

  @override
  State<AdminDepositScreen> createState() => _AdminDepositScreenState();
}

class _AdminDepositScreenState extends State<AdminDepositScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;


  final CollectionReference _itemsCollection = FirebaseFirestore.instance.collection('DepositDetails');

  void _showDeleteConfirmationDialog(String id) {
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
                _deleteItem(id);
              },
            ),
          ],
        );
      },
    );
  }

  void _deleteItem(String id) {
    _itemsCollection.doc(id).delete().then((_) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Item deleted')));
    }).catchError((error) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to delete item: $error')));
    });
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: Center(child: Text("Deposit History")),

        ),
        body: SafeArea(
          child: Padding(
            padding: EdgeInsets.all(5.0),
            child: Container(
                height: 800,
                width: MediaQuery.of(context).size.width,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(16),
                    bottomRight: Radius.circular(16),
                  ),
                ),
                child: Padding(
                  padding: EdgeInsets.fromLTRB(0, 5, 5, 0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Text("Receipt List"),
                      Row(
                        children: [
                          Expanded(
                              flex:25,
                              child: Text("Name",

                                style: TextStyle(
                                  fontSize: 12,
                                ),)),
                          Expanded(
                              flex:25,
                              child: Text("Amount",
                                style: TextStyle(
                                  fontSize: 12,
                                ),)),
                          Expanded(
                              flex:15,
                              child: Text("Stutas",
                                style: TextStyle(
                                  fontSize: 12,
                                ),)),
                          Expanded(
                              flex:20,
                              child: Text("CreateTime",
                                style: TextStyle(
                                  fontSize: 12,
                                ),)),
                          Expanded(
                              flex: 15,
                              child: Text('Action',
                                style: TextStyle(
                                  fontSize: 12,
                                ),)

                          ),
                        ],
                      ),
                      SizedBox(
                        height: 5,
                      ),
                      Expanded(
                        child: StreamBuilder(
                          stream: _firestore.collection('DepositDetails').orderBy('created_at', descending: true).snapshots(),
                          builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
                            if (snapshot.connectionState ==
                                ConnectionState.waiting) {
                              return Center(child: CircularProgressIndicator());
                            }

                            if (!snapshot.hasData) {
                              return Center(child: Text('No data found'));
                            }

                            var documents = snapshot.data!.docs;

                            return ListView.builder(
                              itemCount: documents.length,
                              itemBuilder: (context, index) {
                                var document = documents[index];
                                var date = document['created_at'].toDate();
                                var formattedDate = DateFormat.yMMMd().format(date);

                                return Row(
                                  children: [
                                    Expanded(
                                        flex:25,
                                        child: Text("${document['name']}",
                                          style: TextStyle(
                                            fontSize: 12,
                                          ),
                                        )),
                                    Expanded(
                                        flex:25,
                                        child: Text("${document['Amount']}",
                                          style: TextStyle(
                                            fontSize: 12,
                                          ),)),
                                    Expanded(
                                        flex:15,
                                        child: Text("${document['Status']}",
                                          style: TextStyle(
                                            fontSize: 12,
                                          ),)),
                                    Expanded(
                                        flex:20,
                                        child: Text(
                                          "$formattedDate",
                                          style: TextStyle(
                                            fontSize: 12,
                                          ),
                                          //   "CreateTime"
                                        )),
                                    Expanded(
                                        flex: 15,
                                        child: TextButton(
                                          //onPressed: () => _deleteDocument(document.id),
                                            onPressed: () {

                                              _showDeleteConfirmationDialog(document.id);
                                            },
                                            child: Icon(Icons.delete,size: 15,))),
                                  ],
                                );
                              },
                            );
                          },
                        ),
                      ),

                    ],
                  ),
                )),
          ),
        ));
  }
}

class AdminReachargeScreen extends StatefulWidget {
  const AdminReachargeScreen({Key? key}) : super(key: key);

  @override
  State<AdminReachargeScreen> createState() => _AdminReachargeScreenState();
}

class _AdminReachargeScreenState extends State<AdminReachargeScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;




  final CollectionReference _itemsCollection = FirebaseFirestore.instance.collection('ReceiptDetails');

  void _showDeleteConfirmationDialog(String id) {
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
                _deleteItem(id);
              },
            ),
          ],
        );
      },
    );
  }

  void _deleteItem(String id) {
    _itemsCollection.doc(id).delete().then((_) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Item deleted')));
    }).catchError((error) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to delete item: $error')));
    });
  }









  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: Center(child: Text("Reacharge History"))),
        body:  SafeArea(
          child: Padding(
            padding: EdgeInsets.all(5.0),
            child:Container(
                height: 800,
                width: MediaQuery.of(context).size.width,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(16),
                    bottomRight: Radius.circular(16),
                  ),
                ),
                child: Padding(
                  padding: EdgeInsets.fromLTRB(0, 5, 5, 0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Text("Receipt List"),
                      Row(
                        children: [
                          Expanded(flex: 23, child: Text("Name",
                            style: TextStyle(
                              fontSize: 12,
                            ),
                          )),
                          Expanded(flex: 23, child: Text("Receipt Number",
                            style: TextStyle(
                              fontSize: 12,
                            ),
                          )),
                          Expanded(flex: 15 ,child: Text("Diamond",
                            style: TextStyle(
                              fontSize: 12,
                            ),
                          )),
                          Expanded(flex: 15, child: Text("Status",
                            style: TextStyle(
                              fontSize: 12,
                            ),
                          )),
                          Expanded(flex: 15, child: Text("CreateTime",

                            style: TextStyle(
                              fontSize: 12,
                            ),)),
                          Expanded(flex: 10, child: Text('Action',

                            style: TextStyle(
                              fontSize: 12,
                            ),)
                          ),


                        ],
                      ),
                      SizedBox(height: 5,),
                      Expanded(
                        child: StreamBuilder(
                          stream: _firestore.collection('ReceiptDetails').orderBy('created_at', descending: true).snapshots(),
                          builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
                            if (snapshot.connectionState == ConnectionState.waiting) {
                              return Center(child: CircularProgressIndicator());
                            }

                            if (!snapshot.hasData) {
                              return Center(child: Text('No data found'));
                            }

                            final documents = snapshot.data!.docs;

                            return ListView.builder(
                              itemCount: documents.length,
                              itemBuilder: (context, index) {
                                final document = documents[index];
                                var date= document['created_at'].toDate();
                                var formattedDate = DateFormat.yMMMd().format(date);

                                return Row(
                                  children: [
                                    Expanded(
                                        flex: 23,
                                        child:
                                        Text("${document['name']}",
                                          style: TextStyle(
                                            fontSize: 12,
                                          ),
                                        )),
                                    Expanded(
                                        flex: 23,
                                        child:
                                        Text("${document['ReceiptNumber']}",
                                          style: TextStyle(
                                            fontSize: 12,
                                          ),
                                        )),
                                    Expanded(
                                        flex: 15,
                                        child:
                                        Text("${document['TransferDiamond']}",
                                          style: TextStyle(
                                            fontSize: 12,
                                          ),
                                        )),
                                    Expanded(
                                        flex: 15,
                                        child: Text("${document['Status']}",
                                          style: TextStyle(
                                            fontSize: 12,
                                          ),)),
                                    Expanded(
                                        flex: 15,
                                        child: Text(
                                          "$formattedDate",
                                          style: TextStyle(
                                            fontSize: 12,
                                          ),
                                          //   "CreateTime"
                                        )),

                                    Expanded(
                                        flex: 10,
                                        child: TextButton(
                                          //onPressed: () => _deleteDocument(document.id),
                                            onPressed: () {

                                              _showDeleteConfirmationDialog(document.id);
                                            },
                                            child: Icon(Icons.delete,size: 15,))),

                                  ],
                                );
                              },
                            );
                          },
                        ),
                      ),


                    ],
                  ),
                )


            ),
          ),

        )
    );
  }
}

class AdminTransferScreen extends StatefulWidget {
  const AdminTransferScreen({Key? key}) : super(key: key);

  @override
  State<AdminTransferScreen> createState() => _AdminTransferScreenState();
}

class _AdminTransferScreenState extends State<AdminTransferScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;


  final CollectionReference _itemsCollection = FirebaseFirestore.instance.collection('TransferDetails');

  void _showDeleteConfirmationDialog(String id) {
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
                _deleteItem(id);
              },
            ),
          ],
        );
      },
    );
  }

  void _deleteItem(String id) {
    _itemsCollection.doc(id).delete().then((_) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Item deleted')));
    }).catchError((error) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to delete item: $error')));
    });
  }








  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Center(child: Text("Transfer History"))),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(5.0),
          child:Container(
              height: 800,
              width:MediaQuery.of(context).size.width,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(16),
                  bottomRight: Radius.circular(16),
                ),
              ),
              child: Padding(
                padding: EdgeInsets.fromLTRB(0, 5, 5, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Text("INDEX") ,
                    Row(
                      children: [
                        Expanded(
                            flex:30,
                            child: Text("TransferNumber")),
                        Expanded(
                            flex:30,
                            child: Text("Daimond Amount")),
                        Expanded(
                            flex:30,
                            child: Text("CreateTime")),

                        Expanded(
                            flex: 10,
                            child: Text('Action')

                        ),

                      ],
                    ),
                    SizedBox(height: 5,),
                    Expanded(
                      child: StreamBuilder(
                        stream: _firestore.collection('TransferDetails').orderBy('created_at', descending: true).snapshots(),
                        builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
                          if (snapshot.connectionState == ConnectionState.waiting) {
                            return Center(child: CircularProgressIndicator());
                          }

                          if (!snapshot.hasData) {
                            return Center(child: Text('No data found'));
                          }

                          final documents = snapshot.data!.docs;

                          return ListView.builder(
                            itemCount: documents.length,
                            itemBuilder: (context, index) {
                              final document = documents[index];
                              var date= document['created_at'].toDate();
                              var formattedDate = DateFormat.yMMMd().format(date);

                              return Row(
                                children: [
                                  Expanded(
                                      flex:30,
                                      child: Text("${document['TransferNumber']}")),
                                  Expanded(
                                      flex:30,
                                      child: Text("${document['TransferDiamond']}")),
                                  Expanded(
                                      flex:30,
                                      child: Text(
                                        "$formattedDate",
                                        //   "CreateTime"
                                      )),
                                  Expanded(
                                      flex: 10,
                                      child: TextButton(
                                        //onPressed: () => _deleteDocument(document.id),
                                          onPressed: () {

                                            _showDeleteConfirmationDialog(document.id);
                                          },
                                          child: Icon(Icons.delete))),

                                ],
                              );
                            },
                          );
                        },
                      ),
                    ),


                  ],
                ),
              )


          ),
        ),

      ),
    );
  }
}
