import 'dart:async';
import 'package:bluetooth_blue_plus_app/screens/control_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:permission_handler/permission_handler.dart';
import 'dart:io';

class Scan2Screen extends StatefulWidget {
  const Scan2Screen({super.key});

  @override
  State<Scan2Screen> createState() => _Scan2ScreenState();
}

class _Scan2ScreenState extends State<Scan2Screen> {
  StreamSubscription? _scanSub;
  List<ScanResult> scanedDevices = [];
  bool isConnecting = false;

  // ── Colors (white theme) ─────────────────────────────
  static const Color _bg = Colors.white;
  static const Color _card = Color(0xFFF5F7FB);
  static const Color _border = Color(0xFFD8DEF0);
  static const Color _textPri = Color(0xFF1A2A4A);
  static const Color _textSec = Color(0xFF8A9BBB);
  static const Color _cyan = Color(0xFF1A73E8);
  static const Color _red = Color(0xFFE05252);
  static const Color _green = Color(0xFF34A853);

  @override
  void initState() {
    super.initState();
    startScan();
  }

  // Future<void> requestPermissions() async {
  //   await Permission.location.request();
  //   await Permission.bluetoothScan.request();
  //   await Permission.bluetoothConnect.request();
  // }

  Future<void> requestPermissions() async {
    if (Platform.isAndroid) {
      await Permission.location.request();
      await Permission.bluetoothScan.request();
      await Permission.bluetoothConnect.request();
    } else if (Platform.isIOS) {
      await Permission.bluetooth.request();
      await Permission.locationWhenInUse.request();
    }
  }

  void startScan() {
    _scanSub?.cancel();
    setState(() => scanedDevices = []);

    FlutterBluePlus.startScan(timeout: const Duration(seconds: 5));

    _scanSub = FlutterBluePlus.scanResults.listen((result) {
      final espDevices = result
          .where((r) => r.advertisementData.advName.contains('AIR SYSTEM'))
          .toList();
      setState(() => scanedDevices = espDevices);
    });
  }

  Future<void> connectToDevice(BluetoothDevice device) async {
    if (isConnecting) return;
    setState(() => isConnecting = true);

    await FlutterBluePlus.stopScan();
    await Future.delayed(const Duration(milliseconds: 300));

    try {
      await device.connect(timeout: const Duration(seconds: 15));
      if (mounted) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ControlScreen(device: device),
          ),
        );
      }
    } catch (e) {
      print('Connection failed: $e');
    } finally {
      if (mounted) setState(() => isConnecting = false);
    }
  }

  @override
  void dispose() {
    _scanSub?.cancel();
    FlutterBluePlus.stopScan();
    super.dispose();
  }

  Widget _buildDeviceCard(ScanResult result) {
    final name = result.device.platformName.isEmpty
        ? 'Unknown Device'
        : result.device.platformName;
    final rssi = result.rssi;

    // signal strength color
    Color rssiColor = rssi > -60
        ? _green
        : rssi > -80
        ? _cyan
        : _red;

    return GestureDetector(
      onTap: isConnecting ? null : () => connectToDevice(result.device),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: _card,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: _border, width: 1.5),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 16,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: _cyan.withOpacity(0.10),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.bluetooth, color: _cyan, size: 24),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: _textPri,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    result.device.remoteId.toString(),
                    style: const TextStyle(
                      fontSize: 11,
                      color: _textSec,
                      fontFamily: 'monospace',
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '$rssi dBm',
                  style: TextStyle(
                    fontSize: 11,
                    color: rssiColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Icon(Icons.chevron_right_rounded, color: _textSec, size: 20),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: _cyan.withOpacity(0.10),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.bluetooth_searching,
              size: 40,
              color: _cyan,
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            'No devices found',
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w600,
              color: _textPri,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Make sure your AIR SYSTEM device\nis powered on and nearby',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 13, color: _textSec, height: 1.5),
          ),
        ],
      ),
    );
  }

  Widget _buildScanButton() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: SizedBox(
        width: double.infinity,
        height: 52,
        child: ElevatedButton.icon(
          onPressed: () async {
            await requestPermissions();
            startScan();
          },
          icon: const Icon(Icons.radar_rounded, size: 20),
          label: const Text(
            'Scan for Devices',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.3,
            ),
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor: _cyan,
            foregroundColor: Colors.white,
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      appBar: AppBar(
        toolbarHeight: 80,
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        iconTheme: const IconThemeData(color: _textPri),
        title: Image.asset("assets/Blu_logo.jpeg", width: 200, height: 50),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(color: _border, height: 1),
        ),
      ),
      body: Column(
        children: [
          // ── header ──────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 20, 16, 8),
            child: Row(
              children: [
                Container(
                  width: 10,
                  height: 10,
                  decoration: const BoxDecoration(
                    color: _cyan,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 8),
                const Text(
                  'NEARBY DEVICES',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.2,
                    color: _textSec,
                  ),
                ),
                const Spacer(),
                if (isConnecting)
                  const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: _cyan,
                    ),
                  ),
              ],
            ),
          ),

          // ── list ────────────────────────────────────────
          Expanded(
            child: scanedDevices.isEmpty
                ? _buildEmptyState()
                : ListView.builder(
                    padding: const EdgeInsets.only(top: 4, bottom: 8),
                    itemCount: scanedDevices.length,
                    itemBuilder: (context, index) =>
                        _buildDeviceCard(scanedDevices[index]),
                  ),
          ),

          // ── scan button ─────────────────────────────────
          _buildScanButton(),
        ],
      ),
    );
  }
}
