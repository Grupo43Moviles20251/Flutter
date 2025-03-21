import 'package:flutter/material.dart';

import 'analytics_service.dart';

class AnalyticsNavigatorObserver extends NavigatorObserver {
  final AnalyticsService _analyticsService = AnalyticsService();
  late DateTime _startTime;
  String _currentScreenName = "Unknown";

  @override
  void didPush(Route route, Route? previousRoute) {
    // Iniciar el tiempo cuando se abre una nueva pantalla
    _startTime = DateTime.now();
    _currentScreenName = route.settings.name ?? "Unknown";
    super.didPush(route, previousRoute);
  }

  @override
  void didPop(Route route, Route? previousRoute) {
    // Calcular la duración y enviar los datos cuando se cierra la pantalla
    _sendScreenTime(route.settings.name ?? "Unknown");
    super.didPop(route, previousRoute);
  }

  @override
  void didRemove(Route route, Route? previousRoute) {
    // Calcular la duración y enviar los datos cuando se elimina la pantalla
    _sendScreenTime(route.settings.name ?? "Unknown");
    super.didRemove(route, previousRoute);
  }

  @override
  void didReplace({Route? newRoute, Route? oldRoute}) {
    // Calcular la duración y enviar los datos cuando se reemplaza la pantalla
    if (oldRoute != null) {
      _sendScreenTime(oldRoute.settings.name ?? "Unknown");
    }
    // Iniciar el tiempo para la nueva pantalla
    if (newRoute != null) {
      _startTime = DateTime.now();
      _currentScreenName = newRoute.settings.name ?? "Unknown";
    }
    super.didReplace(newRoute: newRoute, oldRoute: oldRoute);
  }

  void _sendScreenTime(String screenName) {
    final duration = DateTime.now().difference(_startTime).inSeconds;
    _analyticsService.trackScreenTime(screenName, duration);
  }
}