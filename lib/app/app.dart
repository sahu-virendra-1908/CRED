import 'package:flutter/material.dart';

import 'router/app_router.dart';
import 'theme/app_theme.dart';

class CardManagementApp extends StatefulWidget {
  const CardManagementApp({super.key});

  @override
  State<CardManagementApp> createState() => _CardManagementAppState();
}

class _CardManagementAppState extends State<CardManagementApp>
    with WidgetsBindingObserver {
  late final AppRouter _appRouter;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _appRouter = AppRouter();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _appRouter.router.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'CRED Card Management',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      routerConfig: _appRouter.router,
    );
  }
}
