import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class UserDetailScreen extends StatefulWidget {
  final String nid_backPart;
  final String nid_frontPart;
  final String num;
  final String address;



   UserDetailScreen( {Key? key, required this.nid_backPart, required this.nid_frontPart, required this.num, required this.address}) : super(key: key);

  @override
  State<UserDetailScreen> createState() => _UserDetailScreenState();
}

class _UserDetailScreenState extends State<UserDetailScreen> {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          centerTitle: true,
          title: Text('User Details',
            style: GoogleFonts.arbutusSlab(
              textStyle: TextStyle(
                color: Colors.white,
                fontSize: 25,
              ),
            ),
          ),
        ),
        body:Padding(
                padding: const EdgeInsets.all(8.0),
                child:Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [

                        Expanded(
                          flex: 35,
                          child: Column(
                            children: [

                              Text("Nid_front Part"),
                              SizedBox(height: 4,),
                              Container(
                                  height: 300,
                                  width: 300,
                                  child:Image.network(
                                    '${widget.nid_frontPart}',
                                    fit: BoxFit.fill,
                                  )

                              ),
                            ],
                          ),


                        ),
                        Expanded(
                          flex: 35,
                          child: Column(
                            children: [

                              Text( 'Nid_back Part'),
                              SizedBox(height: 4,),
                              Container(
                                  height: 300,
                                  width: 300,
                                  child: Image(
                                      fit: BoxFit.fill,
                                      image: NetworkImage(
                                        '${widget.nid_frontPart}',
                                      )),



                                  // Image.network(
                                  //   '${'Nid_backPart'}',
                                  //   fit: BoxFit.fill,
                                  // )



                              ),
                            ],
                          ),


                        ),
                        Expanded(
                            flex: 30,
                            child:Column(
                              children: [

                                // "${userData['address']}",
                                Text("WhatsApp Num:"),
                                Text(widget.num),
                                SizedBox(height: 3,),
                                Text("Addrees:-${ widget.address}",),//$adress
                              ],
                            )

                        ),


                      ],
                    )


                ),
  )



    );
  }
}
