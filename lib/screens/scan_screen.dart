// import 'dart:async';

// import 'package:bluetooth_blue_plus_app/screens/control_screen.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_blue_plus/flutter_blue_plus.dart';
// import 'package:permission_handler/permission_handler.dart';
// class ScanScreen extends StatefulWidget {
//   const ScanScreen({super.key});

//   @override
//   State<ScanScreen> createState() => _ScanScreenState();
// }

// class _ScanScreenState extends State<ScanScreen> {
// StreamSubscription? scanSubscription;
//   List <BluetoothDevice> devices = [];
//   List<ScanResult> scannedResults = [];

// Future<void> requestPermissions() async {
//   await Permission.location.request();
//   await Permission.bluetoothScan.request();
//   await Permission.bluetoothConnect.request();
// }
// //scan devices
// void startScan() {
//   FlutterBluePlus.startScan(timeout: Duration(seconds: 5));
  
  
//  scanSubscription = FlutterBluePlus.scanResults.listen((results) {
//     setState(() {
//       scannedResults = results;
//     });
//   });
// }
// //connect
// Future<void> connectToDevice(BluetoothDevice device) async {
//   await FlutterBluePlus.stopScan();
//   try {
//     await device.connect();
//     Navigator.push(
//       context,
//       MaterialPageRoute(
//         builder: (context) =>ControlScreen(device: device),
//       ),
//     );
//   } catch (e) {
//     print('Connection failed: $e');
//   }
// }
// @override
// void dispose() {
//   scanSubscription?.cancel();
//   super.dispose();
// }
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: Text('Scan for ESP32 device'),),
//       body:Padding(
//         padding: const EdgeInsets.all(16),
//         child: Column(
//           children: 
//           [
//             ElevatedButton(onPressed: ()async
//             {
//                await requestPermissions();
//               startScan();
//             },
//              child: Text('Scan')),
//          Text('scaned Devices'),
//         Expanded(
//           child: ListView.builder(
//             itemCount: scannedResults.length,
//             itemBuilder: (context , index){
//               return ListTile(
//   title: Text(scannedResults[index].device.platformName.isEmpty 
//     ? 'Unknown Device' 
//     : scannedResults[index].device.platformName),
//   trailing: Text(scannedResults[index].rssi.toString()),
//   onTap: () {
//      connectToDevice(scannedResults[index].device);
//   },
// );
          
//           }),
//         )
//           ],
//         ),
//       ) ,
//     );
//   }
// }