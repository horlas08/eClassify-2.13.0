import 'package:eClassify/utils/touch_manager.dart';
import 'package:eClassify/utils/ui_utils.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

mixin MenuItemAction {
  Future<void> execute(BuildContext context, {bool guarded = false});

  Future<void> runGuarded(
    BuildContext context,
    Future<void> Function() action, {
    required bool guarded,
  }) async {
    if (guarded) {
      UiUtils.checkUser(context: context, onNotGuest: action);
    } else {
      await action();
    }
  }
}

class ScreenPushAction with MenuItemAction {
  ScreenPushAction({required this.route, this.args});

  final String route;
  final dynamic args;

  @override
  Future<void> execute(BuildContext context, {bool guarded = false}) {
    return runGuarded(context, () async {
      await Navigator.pushNamed(context, route, arguments: args);
    }, guarded: guarded);
  }
}

class CustomAction with MenuItemAction {
  CustomAction({required this.onTap});

  final AsyncCallback onTap;
  final TapGuard _tapGuard = TapGuard();

  @override
  Future<void> execute(BuildContext context, {bool guarded = false}) {
    return runGuarded(context, () => _tapGuard.run(onTap), guarded: guarded);
  }
}
