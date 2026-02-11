import 'dart:html' as html;
import 'dart:js' as js;

// Listen for messages posted from web/index.html (One-Tap callback)
void addOneTapListener(void Function(String idToken) callback) {
  html.window.addEventListener('message', (event) {
    final ev = event as html.MessageEvent;
    final data = ev.data;
    if (data is Map) {
      final type = data['type'];
      final token = data['token'];
      if (type == 'googleOneTap' && token is String) {
        callback(token);
      }
    }
  });
}

// Trigger One-Tap prompt by calling the global helper defined in web/index.html
void promptOneTap() {
  try {
    js.context.callMethod('launchOneTap');
  } catch (_) {}
}
