import 'package:bluetooth_blue_plus_app/screens/guge.dart';
import 'package:bluetooth_blue_plus_app/screens/startscreen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'dart:async';

class ControlScreen extends StatefulWidget {
  final BluetoothDevice device;
  const ControlScreen({super.key, required this.device});
  @override
  State<ControlScreen> createState() => _ControlScreenState();
}

class _ControlScreenState extends State<ControlScreen> {
  List<BluetoothService> services = [];
  BluetoothCharacteristic? selectedChar;
  BluetoothCharacteristic? minChar;
  BluetoothCharacteristic? targetChar;
  BluetoothCharacteristic? maxChar;
  bool isConnected = false;
  String recivedValue = '';
  Timer? _readTimer;
  String displayMin = '';
  String displayMax = '';
  String displayTarget = '';

  static const Color _card = Color(0xFFF5F7FB);
  static const Color _border = Color(0xFFD8DEF0);
  static const Color _textPri = Color(0xFF1A2A4A);
  static const Color _textSec = Color(0xFF8A9BBB);
  static const Color _hint = Color(0xFFB0BACC);
  static const Color _cyan = Color(0xFF1A73E8);
  static const Color _red = Color(0xFFE05252);
  static const Color _green = Color(0xFF34A853);

  final TextEditingController _mincontroller = TextEditingController();
  final TextEditingController _maxcontroller = TextEditingController();
  final TextEditingController _targetcontroller = TextEditingController();

  void findTargetCharacteristic() {
    for (BluetoothService service in services) {
      for (BluetoothCharacteristic c in service.characteristics) {
        if (c.uuid.toString().contains('00ffffff')) selectedChar = c;
        if (c.uuid.toString().contains('03ffffff')) minChar = c;
        if (c.uuid.toString().contains('01ffffff')) maxChar = c;
        if (c.uuid.toString().contains('02ffffff')) targetChar = c;
      }
    }
  }

  void startNotify() async {
    if (selectedChar == null) {
      debugPrint('selectedChar is null');
      return;
    }
    if (minChar != null) {
      try {
        final val = await minChar!.read();
        if (val.isNotEmpty && val[0] != 0) {
          setState(() => displayMin = val[0].toString());
        }
      } catch (e) {
        debugPrint('minChar read error: $e');
      }
    }
    if (targetChar != null) {
      try {
        final val = await targetChar!.read();
        if (val.isNotEmpty && val[0] != 0) {
          setState(() => displayTarget = val[0].toString());
        }
      } catch (e) {
        debugPrint('targetChar read error: $e');
      }
    }
    if (maxChar != null) {
      try {
        final val = await maxChar!.read();
        if (val.isNotEmpty && val[0] != 0) {
          setState(() => displayMax = val[0].toString());
        }
      } catch (e) {
        debugPrint('maxChar read error: $e');
      }
    }
    await selectedChar!.setNotifyValue(true);
    selectedChar!.onValueReceived.listen((value) {
      debugPrint('Data received: $value');
      if (mounted && value.isNotEmpty) {
        setState(() {
          recivedValue = value[0].toString();
        });
      }
    });
  }

  Future<void> sendonRe(BluetoothCharacteristic? char, List<int> value) async {
    if (char == null) return;
    await char.write(value, withoutResponse: true);
  }

  Future<void> discoverServices() async {
    List<BluetoothService> foundServices = await widget.device
        .discoverServices();
    setState(() {
      services = foundServices;
      isConnected = true;
    });
    printAllServices();
    findTargetCharacteristic();
    startNotify();
  }

  @override
  void initState() {
    super.initState();
    discoverServices();
    widget.device.connectionState.listen((state) {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _readTimer?.cancel();
    super.dispose();
  }

  void printAllServices() {
    for (BluetoothService service in services) {
      debugPrint('Service: ${service.uuid}');
      for (BluetoothCharacteristic c in service.characteristics) {
        debugPrint(
          '  Characteristic: ${c.uuid} | read: ${c.properties.read} | notify: ${c.properties.notify} | write: ${c.properties.write}',
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        await widget.device.disconnect();
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => const Startscreen()),
          (route) => false,
        );
        return false;
      },
      child: Scaffold(
        backgroundColor: const Color.fromARGB(255, 255, 255, 255),
        appBar: AppBar(
          iconTheme: const IconThemeData(color: Color(0xFF1A2A4A)),
          backgroundColor: _card,
          elevation: 0,
          title: Text(
            widget.device.platformName.isEmpty
                ? "Unknown"
                : widget.device.platformName,
            style: const TextStyle(
              color: _textPri,
              fontWeight: FontWeight.w600,
            ),
          ),
          actions: [
            Padding(
              padding: const EdgeInsets.only(right: 16),
              child: Row(
                children: [
                  Icon(
                    Icons.circle,
                    size: 14,
                    color: widget.device.isConnected ? _green : _red,
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    icon: const Icon(Icons.bluetooth_disabled, color: _red),
                    onPressed: () async {
                      await widget.device.disconnect();
                      Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const Startscreen(),
                        ),
                        (route) => false,
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              // Live Pressure Card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: _card,
                  border: Border.all(color: _border),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Row(
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
                          'LIVE PRESSURE READING',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 1.2,
                            color: _textSec,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          recivedValue.isEmpty ? '_' : recivedValue,
                          style: const TextStyle(
                            fontSize: 60,
                            fontWeight: FontWeight.w800,
                            color: _textPri,
                            height: 1,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'PSI/',
                              style: TextStyle(
                                fontSize: 28,
                                fontWeight: FontWeight.w700,
                                color: _cyan,
                              ),
                            ),
                            const SizedBox(width: 6),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                SizedBox(
                                  width: 60,
                                  height: 30,
                                  child: TextField(
                                    controller: _targetcontroller,
                                    keyboardType: TextInputType.number,
                                    style: const TextStyle(
                                      fontSize: 13,
                                      color: _textPri,
                                    ),
                                    decoration: const InputDecoration(
                                      isDense: true,
                                      contentPadding: EdgeInsets.symmetric(
                                        vertical: 4,
                                      ),
                                      hintText: '_ _',
                                      hintStyle: TextStyle(
                                        fontSize: 11,
                                        color: _hint,
                                      ),
                                      border: InputBorder.none,
                                      enabledBorder: InputBorder.none,
                                      focusedBorder: UnderlineInputBorder(
                                        borderSide: BorderSide(color: _cyan),
                                      ),
                                    ),
                                    onSubmitted: (value) async {
                                      if (value.isEmpty) return;
                                      if (displayMin.isEmpty) {
                                        ScaffoldMessenger.of(
                                          context,
                                        ).showSnackBar(
                                          const SnackBar(
                                            content: Text(
                                              "Please set Min first",
                                            ),
                                          ),
                                        );
                                        _targetcontroller.clear();
                                        return;
                                      }
                                      final targetVal = int.parse(value);
                                      final minVal = int.tryParse(displayMin);
                                      final maxVal = int.tryParse(displayMax);
                                      if (minVal != null &&
                                          targetVal < minVal) {
                                        ScaffoldMessenger.of(
                                          context,
                                        ).showSnackBar(
                                          const SnackBar(
                                            content: Text(
                                              "Target can't be less than Min",
                                            ),
                                          ),
                                        );
                                        _targetcontroller.clear();
                                        return;
                                      }
                                      if (maxVal != null &&
                                          targetVal > maxVal) {
                                        ScaffoldMessenger.of(
                                          context,
                                        ).showSnackBar(
                                          const SnackBar(
                                            content: Text(
                                              "Target can't be greater than Max",
                                            ),
                                          ),
                                        );
                                        _targetcontroller.clear();
                                        return;
                                      }
                                      await sendonRe(
                                        targetChar,
                                        value.codeUnits,
                                      );
                                      setState(() => displayTarget = value);
                                      _targetcontroller.clear();
                                    },
                                  ),
                                ),
                                if (displayTarget.isNotEmpty)
                                  Text(
                                    'Target: $displayTarget',
                                    style: const TextStyle(
                                      fontSize: 10,
                                      color: _cyan,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),
              PressureGauge(
                current: double.tryParse(recivedValue) ?? 0,
                target: double.tryParse(displayTarget) ?? 0,
                max: double.tryParse(displayMax) ?? 0,
              ),

              const SizedBox(height: 16),
              // Min Card
              Container(
                padding: const EdgeInsets.fromLTRB(16, 18, 16, 16),
                decoration: BoxDecoration(
                  color: _card,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: _border, width: 1.5),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: 16,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: _red.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(Icons.speed, color: _red, size: 22),
                    ),
                    const SizedBox(width: 8),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Min',
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            color: _textPri,
                          ),
                        ),
                        if (displayMin.isNotEmpty)
                          Text(
                            displayMin,
                            style: const TextStyle(
                              fontSize: 12,
                              color: _red,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(width: 60),
                    Expanded(
                      child: TextField(
                        controller: _mincontroller,
                        keyboardType: TextInputType.number,
                        style: const TextStyle(color: _textPri),
                        decoration: const InputDecoration(
                          border: InputBorder.none,
                          enabledBorder: InputBorder.none,
                          focusedBorder: InputBorder.none,
                          hintText: 'set min',
                          hintStyle: TextStyle(fontSize: 10, color: _hint),
                        ),
                        onSubmitted: (value) async {
                          if (value.isEmpty) return;
                          if (displayTarget.isNotEmpty &&
                              int.parse(value) > int.parse(displayTarget)) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                  "Min can't be greater than Target",
                                ),
                              ),
                            );
                            _mincontroller.clear();
                            return;
                          }
                          if (displayMax.isNotEmpty &&
                              int.parse(value) > int.parse(displayMax)) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text("Min can't be greater than Max"),
                              ),
                            );
                            _mincontroller.clear();
                            return;
                          }
                          await sendonRe(minChar, value.codeUnits);
                          setState(() => displayMin = value);
                          _mincontroller.clear();
                        },
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 12),

              // Max Card
              Container(
                padding: const EdgeInsets.fromLTRB(16, 18, 16, 16),
                decoration: BoxDecoration(
                  color: _card,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: _border, width: 1.5),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: 16,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: _green.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(Icons.speed, color: _green, size: 24),
                    ),
                    const SizedBox(width: 8),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Max',
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            color: _textPri,
                          ),
                        ),
                        if (displayMax.isNotEmpty)
                          Text(
                            displayMax,
                            style: const TextStyle(
                              fontSize: 12,
                              color: _green,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(width: 60),
                    Expanded(
                      child: TextField(
                        controller: _maxcontroller,
                        keyboardType: TextInputType.number,
                        style: const TextStyle(color: _textPri),
                        decoration: const InputDecoration(
                          border: InputBorder.none,
                          enabledBorder: InputBorder.none,
                          focusedBorder: InputBorder.none,
                          hintText: 'set Max',
                          hintStyle: TextStyle(fontSize: 10, color: _hint),
                        ),
                        onSubmitted: (value) async {
                          if (value.isEmpty) return;
                          if (displayMin.isEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text("Please set Min first"),
                              ),
                            );
                            _maxcontroller.clear();
                            return;
                          }
                          if (displayTarget.isEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text("Please set Target first"),
                              ),
                            );
                            _maxcontroller.clear();
                            return;
                          }
                          if (int.parse(value) < int.parse(displayMin)) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text("Max can't be less than Min"),
                              ),
                            );
                            _maxcontroller.clear();
                            return;
                          }
                          if (int.parse(value) < int.parse(displayTarget)) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text("Max can't be less than Target"),
                              ),
                            );
                            _maxcontroller.clear();
                            return;
                          }
                          await sendonRe(maxChar, value.codeUnits);
                          setState(() => displayMax = value);
                          _maxcontroller.clear();
                        },
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 30),
              // Photo Card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: _card,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: _border, width: 1.5),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: 16,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: const Color(0xFF6C63FF).withOpacity(0.15),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.photo,
                        color: Color(0xFF6C63FF),
                        size: 22,
                      ),
                    ),
                    const Text('photo', style: TextStyle(color: _textSec)),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              // Status
              Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: _green.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      Icons.circle,
                      color: displayMax.isEmpty
                          ? Colors.white24
                          : (double.tryParse(recivedValue) ?? 0) >=
                                (double.tryParse(displayMax) ?? 0)
                          ? _green
                          : Colors.white24,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 20),
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: _red.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      Icons.circle,
                      color: displayMin.isEmpty
                          ? Colors.white24
                          : (double.tryParse(recivedValue) ?? 0) <=
                                (double.tryParse(displayMin) ?? 0)
                          ? _red
                          : Colors.white24,
                      size: 24,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
