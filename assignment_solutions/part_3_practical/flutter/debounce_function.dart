import 'dart:async';

class SearchDebouncer {
  Timer? timer;

  void run(Function action) {
    timer?.cancel();

    timer = Timer(const Duration(milliseconds: 500), () {
      action();
    });
  }

  void dispose() {
    timer?.cancel();
  }
}
