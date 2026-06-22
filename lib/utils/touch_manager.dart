import 'package:eClassify/utils/log.dart';
import 'package:flutter/material.dart';

@Deprecated('Deprecated')
class TouchManager {
  static bool isTouchInProgress = false;

  static bool canProcessTouch() {
    if (isTouchInProgress) return false;
    isTouchInProgress = true;
    return true;
  }

  static void touchProcessed() {
    isTouchInProgress = false;
  }
}

class TapGuard {
  bool _busy = false;

  Future<T?> run<T>(Future<T> Function() action) async {
    Log.info('$_busy');
    if (_busy) return null;
    _busy = true;
    try {
      return await action();
    } finally {
      _busy = false;
    }
  }
}

class GuardedTap extends StatelessWidget {
  GuardedTap({
    required this.onTap,
    required this.child,
  }) : _guard = TapGuard();

  final Future<void> Function() onTap;
  final Widget child;
  final TapGuard _guard;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _guard.run(onTap),
      child: child,
    );
  }
}
