import 'package:bluetooth_blue_plus_app/screens/scan2_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'dart:io';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  static const Color _bg = Color.fromRGBO(255, 255, 255, 1);
  static const Color _surface = Colors.white;
  static const Color _primary = Color(0xFF1A73E8);
  static const Color _primaryLight = Color(0xFFE8F0FE);
  static const Color _divider = Color(0xFFEAECF0);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      appBar: AppBar(
        backgroundColor: _surface,
        elevation: 0,
        centerTitle: true,
        toolbarHeight: 80,
        title: Row(
          children: [
            Image.asset("assets/Blu_logo.jpeg", width: 200, height: 50),
          ],
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(color: _divider, height: 1),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'AIR SYSTEM',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: const Color.fromARGB(255, 19, 19, 19),
              ),
            ),
            const Spacer(),

            // Bluetooth icon
            Container(
              width: 100,
              height: 100,
              decoration: const BoxDecoration(
                color: _primaryLight,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.bluetooth, color: _primary, size: 52),
            ),

            const SizedBox(height: 20),

            // Bluetooth state
            StreamBuilder<BluetoothAdapterState>(
              stream: FlutterBluePlus.adapterState,
              builder: (context, snapshot) {
                final state = snapshot.data;
                if (state == BluetoothAdapterState.on) {
                  return Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: 8,
                        height: 8,
                        decoration: const BoxDecoration(
                          color: Color(0xFF34A853),
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 8),
                      const Text(
                        'Bluetooth is On',
                        style: TextStyle(
                          fontSize: 14,
                          color: Color(0xFF34A853),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  );
                }
                return SizedBox(
                  height: 52,
                  child: TextButton.icon(
                    onPressed: () {
                      if (Platform.isAndroid) {
                        FlutterBluePlus.turnOn();
                      }
                    },
                    label: const Text(
                      'Turn on Bluetooth',
                      style: TextStyle(
                        fontSize: 15,
                        color: Colors.red,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                );
              },
            ),

            const Spacer(),

            // Scan button
            Container(
              padding: const EdgeInsets.fromLTRB(0, 16, 0, 32),

              child: SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton.icon(
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const Scan2Screen(),
                    ),
                  ),
                  icon: const Icon(Icons.radar_rounded, size: 20),
                  label: const Text(
                    'Scan Devices',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.3,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _primary,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
