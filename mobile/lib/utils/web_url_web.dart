// ignore: avoid_web_libraries_in_flutter
import 'dart:html' as html;

// Uses window.location.assign() (not window.open) to avoid iOS popup blocking.
// Deep links like whatsapp:// and mailto: are intercepted by the OS directly.
void navigateTo(String url) {
  html.window.location.assign(url);
}
