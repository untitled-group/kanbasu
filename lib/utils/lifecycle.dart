// https://github.com/rrousselGit/flutter_hooks/issues/192#issuecomment-756106520

import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

ValueNotifier<AppLifecycleState> useAppLifecycleState(
    [ChangeAppLifecycleListener? onChangeListener]) {
  return use(_AppLifecycleStateHook(onChangeListener: onChangeListener));
}

class _AppLifecycleStateHook extends Hook<ValueNotifier<AppLifecycleState>> {
  final ChangeAppLifecycleListener? onChangeListener;
  _AppLifecycleStateHook({this.onChangeListener});

  @override
  _AppLifecycleStateHookState createState() => _AppLifecycleStateHookState();
}

class _AppLifecycleStateHookState extends HookState<
    ValueNotifier<AppLifecycleState>, _AppLifecycleStateHook> {
  late ValueNotifier<AppLifecycleState> notifier;
  late _AppLifecycleStateObserver _observer;

  @override
  void initHook() {
    super.initHook();
    notifier = ValueNotifier(AppLifecycleState.resumed);
    _observer = _AppLifecycleStateObserver(_appLifecycleStateListener);
    WidgetsBinding.instance?.addObserver(_observer);
  }

  void _appLifecycleStateListener(AppLifecycleState state) {
    notifier.value = state;
    hook.onChangeListener?.call(state);
  }

  @override
  ValueNotifier<AppLifecycleState> build(BuildContext context) => notifier;

  @override
  String get debugLabel => 'useAppLifecycleState()';

  @override
  void dispose() {
    WidgetsBinding.instance?.removeObserver(_observer);
    notifier.dispose();
    super.dispose();
  }
}

class _AppLifecycleStateObserver extends WidgetsBindingObserver {
  _AppLifecycleStateObserver(this._changeLifecycleListener);

  final ChangeAppLifecycleListener _changeLifecycleListener;

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    _changeLifecycleListener(state);
  }
}

typedef ChangeAppLifecycleListener = void Function(AppLifecycleState state);

ValueNotifier<AppLifecycleState> useAppLifecycleStateAutoRefresh([
  List<AppLifecycleState>? states,
]) {
  final refreshKey = useState(0);
  return useAppLifecycleState((state) {
    if (states?.contains(state) ?? true) refreshKey.value += 1;
  });
}
