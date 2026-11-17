import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class CredSplashGate extends StatefulWidget {
  const CredSplashGate({
    super.key,
    required this.child,
    this.duration = const Duration(milliseconds: 1450),
  });

  final Widget child;
  final Duration duration;

  @override
  State<CredSplashGate> createState() => _CredSplashGateState();
}

class _CredSplashGateState extends State<CredSplashGate>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _fadeIn;
  late final Animation<double> _scaleIn;
  Timer? _exitTimer;
  bool _showDashboard = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 550),
    );
    _fadeIn = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutCubic,
    );
    _scaleIn = Tween<double>(begin: 0.90, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic),
    );
    _controller.forward();

    _exitTimer = Timer(widget.duration, () {
      if (!mounted) return;
      setState(() {
        _showDashboard = true;
      });
    });
  }

  @override
  void dispose() {
    _exitTimer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_showDashboard) {
      return widget.child;
    }

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        body: DecoratedBox(
          decoration: const BoxDecoration(
            gradient: RadialGradient(
              center: Alignment(0.0, -0.35),
              radius: 1.1,
              colors: [
                Color(0xFF232327),
                Color(0xFF141416),
                Color(0xFF0E0E10),
              ],
              stops: [0.0, 0.55, 1.0],
            ),
          ),
          child: Center(
            child: FadeTransition(
              opacity: _fadeIn,
              child: ScaleTransition(
                scale: _scaleIn,
                child: Image.asset(
                  'assets/icon/cred_logo_foreground.png',
                  width: 78,
                  height: 78,
                  fit: BoxFit.contain,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
