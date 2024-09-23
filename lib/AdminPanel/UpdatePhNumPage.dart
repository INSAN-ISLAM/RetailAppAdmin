import 'package:flutter/material.dart';
//UpdatePhNumScreen
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../Widget/AppTextField.dart';
import '../Widget/SnackBar.dart';
import 'LogInPage.dart';


class UpdatePhNumScreen extends StatefulWidget {
  UpdatePhNumScreen({Key? key}) : super(key: key);

  @override
  State<UpdatePhNumScreen> createState() => _UpdatePhNumScreenState();
}

class _UpdatePhNumScreenState extends State<UpdatePhNumScreen> {
  final TextEditingController BkashNumlETController = TextEditingController();

  final TextEditingController NagadNumETController = TextEditingController();

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  // Future<void> updateProfile() async {
  //
  //   try {
  //
  //
  //     User? user = FirebaseAuth.instance.currentUser;
  //     if (user != null) {
  //       print(user.uid);
  //       final result = FirebaseFirestore.instance.collection('UpdatePhNum').doc(user.uid).update({
  //         'BkashNum': BkashNumlETController.text,
  //         'NagadNum': NagadNumETController.text,
  //
  //       });
  //     }
  //
  //
  //   } catch (e) {
  //     // Error occurred during signup
  //    // print('Error signing up: $e');
  //     showSnackBarMessage(context , 'Registration Failed! Try again', true);
  //   }
  // }

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  bool m = true;

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  void _fetchData() async {
    DocumentSnapshot documentSnapshot = await _firestore.collection('UpdatePhNum').doc('K8XGn7wA2MvP25EGCe2f').get();
    BkashNumlETController.text = documentSnapshot.get('BkashNum');
    NagadNumETController.text = documentSnapshot.get('NagadNum');
    // _controller.text = currentValue;
    setState(() {
      m = false;
    });
  }

  final user = FirebaseAuth.instance.currentUser;






  Future<void> updateProfile() async {


    try {


      User? user = FirebaseAuth.instance.currentUser;
      if (user != null) {

        print(user.uid);
        final result = FirebaseFirestore.instance.collection('UpdatePhNum').doc('K8XGn7wA2MvP25EGCe2f').update({
          'BkashNum': BkashNumlETController.text,
          'NagadNum': NagadNumETController.text,
        });

      }
      showSnackBarMessage(context, 'Registration Successfull! Try again', true);

    } catch (e) {
      // Error occurred during signup
      print('Error signing up: $e');
      showSnackBarMessage(context, 'Registration Failed! Try again', true);
    }
  }





      @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('UpDate Phone Number'),
                  SizedBox(height: 20),
                  AppTextFieldWidget(
                    controller: BkashNumlETController,
                    hintText: 'Bkash Num',
                    validator: (value) {
                      if (value?.isEmpty ?? true) {
                        return 'Enter your Bkash Num';
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 20),
                  AppTextFieldWidget(
                    controller: NagadNumETController,
                    hintText: 'Nagad Num',
                    validator: (value) {
                      if (value?.isEmpty ?? true) {
                        return 'Enter your Nagad Num';
                      }
                      return null;
                    },
                  ),
SizedBox(height: 6,),
                  ElevatedButton(
                    onPressed: () async {
                      if (_formKey.currentState!.validate()) {
                        updateProfile();
                      }
                    },
                    child: Text('UpDate'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
