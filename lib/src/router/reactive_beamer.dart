part of '../core/reactive_core.dart';


class ReactiveRouteObserver extends NavigatorObserver {
  @override
  void didPush(Route route, Route? previousRoute) {
    setRoute(route.settings.name ?? "/");
  }

  @override
  void didPop(Route route, Route? previousRoute) {
    setRoute(previousRoute?.settings.name ?? "/");
  }
}
