import 'package:bluetooth_blue_plus_app/screens/homeAr.dart';
import 'package:flutter/material.dart';
import 'package:bluetooth_blue_plus_app/screens/home_screen.dart';

class Startscreen extends StatefulWidget {
  const Startscreen({super.key});

  @override
  State<Startscreen> createState() => _StartscreenState();
}

class _StartscreenState extends State<Startscreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeIn;
  late Animation<Offset> _slideUp;

  static const Color _bg = Colors.white;
  static const Color _card = Color(0xFFF5F7FB);
  static const Color _border = Color(0xFFD8DEF0);
  static const Color _cyan = Color(0xFF00838F);
  static const Color _primary = Color(0xFF1A73E8);
  static const Color _primaryLight = Color(0xFFE8F0FE);
  static const Color _textDark = Color(0xFF1A2A4A);
  static const Color _textMuted = Color(0xFF8A9BBB);

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
    _fadeIn = CurvedAnimation(parent: _controller, curve: Curves.easeOut);
    _slideUp = Tween<Offset>(
      begin: const Offset(0, 0.15),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      body: Stack(
        children: [
          // الدوائر الزخرفية
          Positioned(
            top: -60,
            right: -60,
            child: Container(
              width: 220,
              height: 220,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: _cyan.withOpacity(0.07),
              ),
            ),
          ),
          Positioned(
            bottom: -80,
            left: -80,
            child: Container(
              width: 280,
              height: 280,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: _primary.withOpacity(0.07),
              ),
            ),
          ),

          // المحتوى الرئيسي
          Center(
            child: FadeTransition(
              opacity: _fadeIn,
              child: SlideTransition(
                position: _slideUp,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 32),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // اللوجو
                      Container(
                        width: 90,
                        height: 90,
                        decoration: BoxDecoration(
                          color: _primaryLight.withOpacity(0.5),
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: _cyan.withOpacity(0.35),
                            width: 1.5,
                          ),
                        ),
                        child: Icon(Icons.bluetooth, color: _cyan, size: 44),
                      ),

                      const SizedBox(height: 28),

                      // اسم التطبيق
                      const Text(
                        'AIR SYSTEM',
                        style: TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.w800,
                          color: _textDark,
                          letterSpacing: 3,
                        ),
                      ),

                      const SizedBox(height: 8),

                      // وصف صغير
                      Text(
                        'اختر لغتك  •  Choose your language',
                        style: TextStyle(
                          fontSize: 13,
                          color: _textMuted,
                          letterSpacing: 0.5,
                        ),
                      ),

                      const SizedBox(height: 52),

                      // كارت اختيار اللغة
                      Container(
                        decoration: BoxDecoration(
                          color: _card,
                          borderRadius: BorderRadius.circular(24),
                          border: Border.all(color: _border, width: 1.5),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.07),
                              blurRadius: 24,
                              offset: const Offset(0, 8),
                            ),
                          ],
                        ),
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          children: [
                            // زر العربية
                            _LanguageButton(
                              label: 'العربية',
                              sublabel: 'Arabic',
                              icon: '🇸🇦',
                              color: _cyan,
                              onTap: () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => HomeARScreen(),
                                ),
                              ),
                            ),

                            const SizedBox(height: 14),
                            Row(
                              children: [
                                Expanded(
                                  child: Divider(color: _border, thickness: 1),
                                ),
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                  ),
                                  child: Text(
                                    'OR',
                                    style: TextStyle(
                                      fontSize: 11,
                                      color: _textMuted,
                                      fontWeight: FontWeight.w600,
                                      letterSpacing: 1.5,
                                    ),
                                  ),
                                ),
                                Expanded(
                                  child: Divider(color: _border, thickness: 1),
                                ),
                              ],
                            ),

                            const SizedBox(height: 14),

                            // زر الإنجليزية
                            _LanguageButton(
                              label: 'English',
                              sublabel: 'الإنجليزية',
                              icon: '🇬🇧',
                              color: _primary,
                              onTap: () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => HomeScreen(),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _LanguageButton extends StatefulWidget {
  final String label;
  final String sublabel;
  final String icon;
  final Color color;
  final VoidCallback onTap;

  const _LanguageButton({
    required this.label,
    required this.sublabel,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  State<_LanguageButton> createState() => _LanguageButtonState();
}

class _LanguageButtonState extends State<_LanguageButton> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) {
        setState(() => _pressed = false);
        widget.onTap();
      },
      onTapCancel: () => setState(() => _pressed = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 120),
        curve: Curves.easeOut,
        transform: Matrix4.identity()..scale(_pressed ? 0.97 : 1.0),
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
        decoration: BoxDecoration(
          color: widget.color.withOpacity(_pressed ? 0.13 : 0.07),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: widget.color.withOpacity(_pressed ? 0.55 : 0.3),
            width: 1.5,
          ),
        ),
        child: Row(
          children: [
            Text(widget.icon, style: const TextStyle(fontSize: 26)),
            const SizedBox(width: 16),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.label,
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                    color: widget.color,
                  ),
                ),
                Text(
                  widget.sublabel,
                  style: const TextStyle(
                    fontSize: 11,
                    color: Color(0xFF8A9BBB),
                  ),
                ),
              ],
            ),
            const Spacer(),
            Icon(
              Icons.arrow_forward_ios_rounded,
              color: widget.color.withOpacity(0.6),
              size: 16,
            ),
          ],
        ),
      ),
    );
  }
}
