import 'package:bluetooth_blue_plus_app/screens/scanAR.dart';
import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'dart:io';

class HomeARScreen extends StatefulWidget {
  const HomeARScreen({super.key});

  @override
  State<HomeARScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeARScreen> {
  static const Color _bg = Color.fromRGBO(255, 255, 255, 1);
  static const Color _surface = Colors.white;
  static const Color _primary = Color(0xFF1A73E8);
  static const Color _primaryLight = Color(0xFFE8F0FE);
  static const Color _divider = Color(0xFFEAECF0);
  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
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
              const Spacer(),

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
                          'البلوتوث متصل',
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
                        'تشغيل البلوتوث',
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
              Container(
                padding: const EdgeInsets.fromLTRB(0, 16, 0, 32),
                child: SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton.icon(
                    onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const ScanARScreen(),
                      ),
                    ),
                    icon: const Icon(Icons.radar_rounded, size: 20),
                    label: const Text(
                      'البحث عن الأجهزة',
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
      ),
    );
  }
}
