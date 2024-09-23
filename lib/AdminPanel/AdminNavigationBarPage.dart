import 'package:flutter/material.dart';

import 'AdminDashboardPage.dart';
import 'UserListPage.dart';




class AdminMainBottomNavBar extends StatefulWidget {
  AdminMainBottomNavBar({Key? key}) : super(key: key);

  @override
  State<AdminMainBottomNavBar> createState() => _AdminMainBottomNavBarState();
}

class _AdminMainBottomNavBarState extends State<AdminMainBottomNavBar> {
  int _selectedScreen = 0;
  final List<Widget> _screens =  [
    AdminDashBoardScreen(),
    AdminDepositScreen(),
    AdminReachargeScreen(),
    AdminTransferScreen(),
    SignUpListScreen(),

  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [

            Expanded(child: _screens[_selectedScreen]),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        selectedItemColor: Colors.green,
        unselectedItemColor: Colors.black,
        backgroundColor: Colors.grey,
        showUnselectedLabels: true,
        unselectedIconTheme: IconThemeData(
          color: Colors.deepOrangeAccent,
        ),


        onTap: (index) {
          _selectedScreen = index;
          setState(() {});
        },

        currentIndex: _selectedScreen,
        items: const [
          BottomNavigationBarItem(
              icon: Icon(Icons.home), label: 'Dashboard'),
          BottomNavigationBarItem(
              icon: Icon(Icons.send), label: 'DepositHistory'),
          BottomNavigationBarItem(
              icon: Icon(Icons.card_travel_sharp), label: 'RechargeHistory'),
          BottomNavigationBarItem(icon: Icon(Icons.threed_rotation_rounded), label: 'TransferHistory'),
          BottomNavigationBarItem(icon: Icon(Icons.people), label: 'UserList'),

        ],
      ),
    );
  }
}

