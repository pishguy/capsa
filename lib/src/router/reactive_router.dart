part of '../core/reactive_core.dart';

final currentRoute = Signal<String>("/");

void setRoute(String r) {
  currentRoute.value = r;
}
