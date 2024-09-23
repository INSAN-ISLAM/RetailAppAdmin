import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../Widget/AppEevatedButton.dart';
import 'ChangePasswordPage.dart';
import 'LogInPage.dart';


class SettingScreen extends StatefulWidget {
  const SettingScreen({Key? key}) : super(key: key);

  @override
  State<SettingScreen> createState() => _SettingScreenState();
}

class _SettingScreenState extends State<SettingScreen> {
  MySnackBar(message, context) {
    return ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }
  // MyAlertDialog(context) {
  //   return showDialog(
  //       context: context,
  //       builder: (BuildContext context) {
  //         return Expanded(
  //             child: AlertDialog(
  //               title: Text("Log Out"),
  //               content: Text("Are You sure you want to log out?"),
  //               actions: [
  //                 Center(
  //                   child: Column(
  //                     children: [
  //                       AppElevatedButton(
  //                         Color: Colors.yellow,
  //                         onTap: () {
  //                           // Navigator.of(context).pop();
  //                           _signOut();
  //                           //Navigator.push(context, MaterialPageRoute(builder: (context) =>  LogInScreen()));
  //                         },
  //                         child: Center(
  //                           child: Text(
  //                             "Confirm",
  //                             style: GoogleFonts.poppins(
  //                               textStyle: const TextStyle(
  //                                 color: Colors.black,
  //                                 fontSize: 14,
  //                                 //fontWeight: FontWeight.w700,
  //                               ),
  //                             ),
  //                           ),
  //                         ),
  //                       ),
  //                       // TextButton(
  //                       //     onPressed: () {
  //                       //       // MySnackBar("Thanks", context);
  //                       //       // Navigator.of(context).pop();
  //                       //     },
  //                       //     child: Text("No")),
  //                       SizedBox(height: 5),
  //                       AppElevatedButton(
  //                         onTap: () {
  //                           Navigator.of(context).pop();
  //                           // Navigator.push(context, MaterialPageRoute(builder: (context) => const MainBottomNavBar()));
  //                         },
  //                         child: Center(
  //                           child: Text(
  //                             "Cancel",
  //                             style: GoogleFonts.poppins(
  //                               textStyle: const TextStyle(
  //                                 color: Colors.black,
  //                                 fontSize: 14,
  //                                 //fontWeight: FontWeight.w700,
  //                               ),
  //                             ),
  //                           ),
  //                         ),
  //                       ),
  //                     ],
  //                   ),
  //                 ),
  //               ],
  //             ));
  //       });
  // }


  void _showDeleteConfirmationDialog(){
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Log Out'),
          content: Text('Are You sure you want to log out?'),
          actions: <Widget>[
            TextButton(
              child: Text('Confirm'),
              onPressed: () {
                _signOut();
              },
            ),
            TextButton(
              child: Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();

              },
            ),
          ],
        );
      },
    );
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView(
        children: [

          ListTile(
              trailing: Icon(Icons.arrow_forward_ios_outlined),
              title: Text("Change Password"),
              onTap: () {
                Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const ChangePassword()), (route) => true);
              }),

          ListTile(
              trailing: Icon(Icons.arrow_forward_ios_outlined),
              title: Text("Privacy "
                  "policy"),
              onTap: () {
                MySnackBar("I am phone", context);
              }),

          ListTile(
              trailing: Icon(Icons.arrow_forward_ios_outlined),
              title: Text("Log Out"),
              onTap: () {
                // MyAlertDialog(context);
                _showDeleteConfirmationDialog();

              }),
        ],
      ),
    );
  }



  final FirebaseAuth _auth = FirebaseAuth.instance;

  void _signOut() async {
    await _auth.signOut();
    // Optionally, you can navigate to the login screen or show a message
    Navigator.of(context)
        .pushReplacement(MaterialPageRoute(builder: (context) => LogInScreen()));
  }
}



