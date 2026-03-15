import 'package:bluetooth_blue_plus_app/screens/guge.dart';
import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'dart:async';

class ControlArScreen extends StatefulWidget {
  final BluetoothDevice device;
  const ControlArScreen({super.key, required this.device});

  @override
  State<ControlArScreen> createState() => _ControlScreenState();
}

class _ControlScreenState extends State<ControlArScreen> {
  /////////////////////////////////////////////////////المنطق////////////////////////////////////////////////////
  List<BluetoothService> services = [];
  BluetoothCharacteristic? selectedChar; //ff00
  BluetoothCharacteristic? minChar; //0XFF01
  BluetoothCharacteristic? targetChar; // 0XFF03
  BluetoothCharacteristic? maxChar; //0XFF02
  bool isConnected = false;
  String recivedValue = '';
  Timer? _readTimer;
  // قيم العرض
  String displayMin = '';
  String displayMax = '';
  String displayTarget = '';

  // الألوان
  static const Color _card = Color(0xFFF5F7FB);
  static const Color _border = Color(0xFFD8DEF0);
  static const Color _textPri = Color(0xFF1A2A4A);
  static const Color _textSec = Color(0xFF8A9BBB);
  static const Color _hint = Color(0xFFB0BACC);
  static const Color _cyan = Color(0xFF1A73E8);
  static const Color _red = Color(0xFFE05252);
  static const Color _green = Color(0xFF34A853);

  // المتحكمات
  final TextEditingController _mincontroller = TextEditingController();
  final TextEditingController _maxcontroller = TextEditingController();
  final TextEditingController _targetcontroller = TextEditingController();

  ///اختيار الخاصية///
  void findTargetCharacteristic() {
    for (BluetoothService service in services) {
      for (BluetoothCharacteristic c in service.characteristics) {
        if (c.uuid.toString().contains('ff00')) selectedChar = c;
        if (c.uuid.toString().contains('ff01')) minChar = c;
        if (c.uuid.toString().contains('ff02')) maxChar = c;
        if (c.uuid.toString().contains('ff03')) targetChar = c;
      }
    }
  }

  // startnotify
  void startNotify() async {
    if (selectedChar == null) {
      debugPrint('selectedChar empty');
      return;
    }
    await selectedChar!.setNotifyValue(true);
    selectedChar!.onValueReceived.listen((value) {
      debugPrint('value recived: $value');
      if (mounted) {
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

  ////////////////////////////////////////////////////Endlogic///////////////////////////////////////////////////
  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: const Color.fromRGBO(30, 43, 75, 1),
        appBar: AppBar(
          iconTheme: const IconThemeData(color: Colors.white),
          backgroundColor: _card,
          elevation: 0,
          title: Text(
            widget.device.platformName.isEmpty
                ? "غير معروف"
                : widget.device.platformName,
            style: const TextStyle(
              color: _textPri,
              fontWeight: FontWeight.w600,
            ),
          ),
          actions: [
            Padding(
              padding: const EdgeInsets.only(left: 16),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.bluetooth_disabled, color: _red),
                    onPressed: () async {
                      await widget.device.disconnect();
                      Navigator.pop(context);
                    },
                  ),
                  const SizedBox(width: 8),
                  Icon(
                    Icons.circle,
                    size: 14,
                    color: widget.device.isConnected ? _green : _red,
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
              // كارت قراءة الضغط المباشر
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
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        const Text(
                          'قراءة الضغط المباشر',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 1.2,
                            color: _textSec,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          width: 10,
                          height: 10,
                          decoration: const BoxDecoration(
                            color: _cyan,
                            shape: BoxShape.circle,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                SizedBox(
                                  width: 60,
                                  height: 30,
                                  child: TextField(
                                    controller: _targetcontroller,
                                    keyboardType: TextInputType.number,
                                    textAlign: TextAlign.right,
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
                                      if (value.isNotEmpty) {
                                        await sendonRe(
                                          targetChar,
                                          value.codeUnits,
                                        );
                                        await Future.delayed(
                                          const Duration(milliseconds: 200),
                                        );
                                        setState(() {
                                          displayTarget = value;
                                        });
                                        // final val = await targetChar!.read();
                                        // setState(
                                        //   () =>
                                        //       displayTarget = val[0].toString(),
                                        // );
                                        _targetcontroller.clear();
                                      }
                                    },
                                  ),
                                ),
                                if (displayTarget.isNotEmpty)
                                  Text(
                                    'الهدف: $displayTarget',
                                    style: const TextStyle(
                                      fontSize: 10,
                                      color: _cyan,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                              ],
                            ),
                            const SizedBox(width: 6),
                            const Text(
                              '/PSI',
                              style: TextStyle(
                                fontSize: 28,
                                fontWeight: FontWeight.w700,
                                color: _cyan,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(width: 12),
                        Text(
                          recivedValue.isEmpty ? '_' : recivedValue,
                          style: const TextStyle(
                            fontSize: 60,
                            fontWeight: FontWeight.w800,
                            color: _textPri,
                            height: 1,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),
              // العداد
              PressureGauge(
                current: double.tryParse(recivedValue) ?? 0,
                target: double.tryParse(displayTarget) ?? 0,
                max: double.tryParse(displayMax) ?? 0,
              ),

              const SizedBox(height: 16),

              // كارت الحد الأدنى
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
                    Expanded(
                      child: TextField(
                        controller: _mincontroller,
                        keyboardType: TextInputType.number,
                        textAlign: TextAlign.right,
                        style: const TextStyle(color: _textPri),
                        decoration: const InputDecoration(
                          border: InputBorder.none,
                          enabledBorder: InputBorder.none,
                          focusedBorder: InputBorder.none,
                          hintText: 'تعيين الحد الأدنى',
                          hintStyle: TextStyle(fontSize: 10, color: _hint),
                        ),
                        onSubmitted: (value) async {
                          if (value.isNotEmpty) {
                            await sendonRe(minChar, value.codeUnits);
                            await Future.delayed(
                              const Duration(milliseconds: 200),
                            );
                            setState(() {
                              displayMin = value;
                            });
                            // final val = await minChar!.read();
                            // setState(() => displayMin = val[0].toString());
                            _mincontroller.clear();
                          }
                        },
                      ),
                    ),
                    const SizedBox(width: 60),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        const Text(
                          'الحد الأدنى',
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
                    const SizedBox(width: 8),
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: _red.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(Icons.speed, color: _red, size: 22),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 12),

              // كارت الحد الأقصى
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
                    Expanded(
                      child: TextField(
                        controller: _maxcontroller,
                        keyboardType: TextInputType.number,
                        textAlign: TextAlign.right,
                        style: const TextStyle(color: _textPri),
                        decoration: const InputDecoration(
                          border: InputBorder.none,
                          enabledBorder: InputBorder.none,
                          focusedBorder: InputBorder.none,
                          hintText: 'تعيين الحد الأقصى',
                          hintStyle: TextStyle(fontSize: 10, color: _hint),
                        ),
                        onSubmitted: (value) async {
                          if (value.isNotEmpty) {
                            await sendonRe(maxChar, value.codeUnits);
                            await Future.delayed(
                              const Duration(milliseconds: 200),
                            );
                            setState(() => displayMax = value);

                            // final val = await maxChar!.read();
                            // setState(() => displayMax = val[0].toString());
                            _maxcontroller.clear();
                          }
                        },
                      ),
                    ),
                    const SizedBox(width: 60),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        const Text(
                          'الحد الأقصى',
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
                    const SizedBox(width: 8),
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: _green.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(Icons.speed, color: _green, size: 24),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 30),
              // كارت الصورة
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
                  crossAxisAlignment: CrossAxisAlignment.end,
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
                    const Text('صورة', style: TextStyle(color: _textSec)),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              // الحالة
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
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
                  const SizedBox(width: 20),
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
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
