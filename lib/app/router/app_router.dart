import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../features/card_management/presentation/screens/card_management_screen.dart';

class AppRouter {
  AppRouter()
      : router = GoRouter(
          initialLocation: '/',
          routes: [
            GoRoute(
              path: '/',
              name: 'card_management',
              builder: (BuildContext context, GoRouterState state) {
                return const CardManagementScreen();
              },
            ),
          ],
        );

  final GoRouter router;
}
