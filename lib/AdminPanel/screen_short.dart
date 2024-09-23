import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class ScreenShortScreen extends StatefulWidget {
   ScreenShortScreen({Key? key, required this.screen_short}) : super(key: key);
  final String screen_short;
  @override
  State<ScreenShortScreen> createState() => _ScreenShortScreenState();
}

class _ScreenShortScreenState extends State<ScreenShortScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Container(
          height: 500,
          width: 400,
          child:Image.network(
            '${widget.screen_short}',
            fit: BoxFit.fill,
          )

      ),
      ),
    );
  }
}
