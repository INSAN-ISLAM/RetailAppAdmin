import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dropdown_search/dropdown_search.dart';

import '../Widget/AppEevatedButton.dart';
import '../Widget/AppTextField.dart';

class UserByRateScreen extends StatefulWidget {
  const UserByRateScreen({Key? key}) : super(key: key);

  @override
  State<UserByRateScreen> createState() => _UserByRateScreenState();
}

class _UserByRateScreenState extends State<UserByRateScreen> {
  final TextEditingController _URateETController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  String? selectedMobile; // Store selected mobile number here
  List<String> mobileNumbers = []; // List to store fetched mobile numbers

  @override
  void initState() {
    super.initState();
    _fetchMobileNumbers(); // Fetch mobile numbers on init
  }

  Future<void> _fetchMobileNumbers() async {
    try {
      final querySnapshot =
      await FirebaseFirestore.instance.collection('Check').get();
      final List<String> fetchedNumbers =
      querySnapshot.docs.map((doc) => doc['mobile'] as String).toList();
      setState(() {
        mobileNumbers = fetchedNumbers;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error fetching mobile numbers: $e')),
      );
    }
  }

  Future<void> _submitData() async {
    final userRate = double.tryParse(_URateETController.text) ?? 0;
    final userNumber = selectedMobile; // Use selected mobile number

    if (userNumber == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please select a mobile number')),
      );
      return;
    }

    try {
      final querySnapshot = await FirebaseFirestore.instance
          .collection('Check')
          .where('mobile', isEqualTo: userNumber)
          .get();

      if (querySnapshot.docs.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Mobile number not found')),
        );
      } else {
        // Update the document with the new rate
        await querySnapshot.docs.first.reference.update({'rate': userRate});

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Rate updated successfully')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(15.0),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                Center(
                  child: AppTextFieldWidget(
                    controller: _URateETController,
                    hintText: 'User Rate',
                    validator: (value) {
                      if (value?.isEmpty ?? true) {
                        return 'Please enter a rate';
                      }
                      return null;
                    },
                  ),
                ),
                SizedBox(height: 10),
                Center(
                  child: DropdownSearch<String>(
                    items: mobileNumbers,
                    dropdownDecoratorProps: DropDownDecoratorProps(
                      dropdownSearchDecoration: InputDecoration(
                        labelText: "Select Mobile Number",
                        hintText: "Search for a mobile number",
                      ),
                    ),
                    popupProps: PopupProps.dialog(
                      showSearchBox: true,
                    ),
                    onChanged: (value) {
                      setState(() {
                        selectedMobile = value;
                      });
                    },
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please select a mobile number';
                      }
                      return null;
                    },
                  ),
                ),
                SizedBox(height: 15),
                Container(
                  height: 48,
                  width: 358,
                  color: Colors.blueGrey,
                  child: AppElevatedButton(
                    Color: Colors.blueGrey,
                    onTap: () async {
                      if (_formKey.currentState!.validate()) {
                        await _submitData();
                      }
                    },
                    child: Center(
                      child: Text(
                        "Submit",
                        style: GoogleFonts.poppins(
                          textStyle: const TextStyle(
                            color: Color(0xFFFFFFFF),
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
