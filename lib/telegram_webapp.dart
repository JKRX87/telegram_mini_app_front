import 'dart:js_util' as js_util;
import 'dart:html' as html;

class TelegramWebApp {
  static dynamic get _tg => js_util.getProperty(html.window, '__TG_WEBAPP__');

  static bool get isAvailable => js_util.getProperty(_tg, 'isAvailable') == true;
  static String? get version => js_util.getProperty(_tg, 'version');
  static String? get initData => js_util.getProperty(_tg, 'initData');
  static dynamic get initDataUnsafe => js_util.getProperty(_tg, 'initDataUnsafe');
  static String get colorScheme => js_util.getProperty(_tg, 'colorScheme') ?? 'light';
  static String get platform => js_util.getProperty(_tg, 'platform') ?? 'unknown';

  static void ready() => js_util.callMethod(_tg, 'ready', const []);
  static void expand() => js_util.callMethod(_tg, 'expand', const []);
  static void close() => js_util.callMethod(_tg, 'close', const []);
  static void sendData(String data) => js_util.callMethod(_tg, 'sendData', [data]);
  static void openLink(String url) => js_util.callMethod(_tg, 'openLink', [url]);

  static dynamic get _mainButton => js_util.getProperty(_tg, 'MainButton');
  static void mainButtonSetText(String text) => js_util.callMethod(_mainButton, 'setText', [text]);
  static void mainButtonShow() => js_util.callMethod(_mainButton, 'show', const []);
  static void mainButtonOnClick(void Function() cb) =>
      js_util.callMethod(_mainButton, 'onClick', [js_util.allowInterop(cb)]);
}
