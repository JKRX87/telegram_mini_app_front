import 'dart:js_util' as js_util;
import 'dart:html' as html;

class TelegramWebApp {
  static dynamic get _tg => js_util.getProperty(html.window, '__TG_WEBAPP__');

  static bool get isAvailable => js_util.getProperty(_tg, 'isAvailable') == true;
  static String? get initData => js_util.getProperty(_tg, 'initData');
  static dynamic get initDataUnsafe => js_util.getProperty(_tg, 'initDataUnsafe');

  static String get colorScheme => js_util.getProperty(_tg, 'colorScheme') ?? 'light';
  static String get platform => js_util.getProperty(_tg, 'platform') ?? 'unknown';

  static void ready() { try { js_util.callMethod(_tg, 'ready', const []); } catch (_) {} }
  static void expand() { try { js_util.callMethod(_tg, 'expand', const []); } catch (_) {} }
  static void close() { try { js_util.callMethod(_tg, 'close', const []); } catch (_) {} }
  static void sendData(String data) { try { js_util.callMethod(_tg, 'sendData', [data]); } catch (_) {} }

  // MainButton
  static dynamic get _mainButton => js_util.getProperty(_tg, 'MainButton');
  static void mainButtonSetText(String text) { try { js_util.callMethod(_mainButton, 'setText', [text]); } catch (_) {} }
  static void mainButtonShow() { try { js_util.callMethod(_mainButton, 'show', const []); } catch (_) {} }
  static void mainButtonHide() { try { js_util.callMethod(_mainButton, 'hide', const []); } catch (_) {} }
  static void mainButtonOnClick(void Function() cb) {
    try { js_util.callMethod(_mainButton, 'onClick', [js_util.allowInterop(cb)]); } catch (_) {}
  }
}
