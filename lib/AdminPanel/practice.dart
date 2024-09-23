// import 'package:flutter/material.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
//
// class FirebaseListAmountExample extends StatefulWidget {
//   @override
//   _FirebaseListAmountExampleState createState() => _FirebaseListAmountExampleState();
// }
//
// class _FirebaseListAmountExampleState extends State<FirebaseListAmountExample> {
//   // Function to calculate sum of amounts for a particular item
//   double calculateItemTotal(List<dynamic> amounts) {
//     double total = 0;
//     for (var amount in amounts) {
//       total += amount;
//     }
//     return total;
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('Firestore Amounts List'),
//       ),
//       body: StreamBuilder<QuerySnapshot>(
//         stream: FirebaseFirestore.instance.collection('items').snapshots(),
//         builder: (context, snapshot) {
//           if (snapshot.hasError) {
//             return Center(child: Text('Error: ${snapshot.error}'));
//           }
//           if (snapshot.connectionState == ConnectionState.waiting) {
//             return Center(child: CircularProgressIndicator());
//           }
//
//           // Extracting data from the snapshot
//           var items = snapshot.data!.docs;
//
//           return ListView.builder(
//             itemCount: items.length,
//             itemBuilder: (context, index) {
//               var item = items[index];
//               var name = item['name'];
//               var amounts = item['amounts']; // This should be a list of amounts
//
//               // Calculating total for this item
//               var itemTotal = calculateItemTotal(amounts);
//
//               return Card(
//                 margin: EdgeInsets.all(8.0),
//                 child: ListTile(
//                   title: Text(name),
//                   subtitle: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       Text('Amounts: ${amounts.join(', ')}'),
//                       Text(
//                         'Total: \$${itemTotal.toStringAsFixed(2)}',
//                         style: TextStyle(fontWeight: FontWeight.bold),
//                       ),
//                     ],
//                   ),
//                 ),
//               );
//             },
//           );
//         },
//       ),
//     );
//   }
// }
//
