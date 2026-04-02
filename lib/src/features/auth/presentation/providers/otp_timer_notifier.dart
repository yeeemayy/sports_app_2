import 'dart:async';

import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'otp_timer_notifier.g.dart';

@riverpod
class OtpTimerNotifier extends _$OtpTimerNotifier {
  Timer? _timer;

  @override
  int build() {
    ref.onDispose(() => _timer?.cancel());
    return 0; // 0 = not counting down
  }

  void start() {
    if (state > 0) return;
    state = 60;
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (state <= 1) {
        state = 0;
        _timer?.cancel();
      } else {
        state--;
      }
    });
  }
}
