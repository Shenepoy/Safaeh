import 'dart:js_interop';

@JS('window.open')
external JSAny? _open(JSString url, JSString target);

void openWidgetbook() {
  _open('https://shenepoy.github.io/Safaeh/widgetbook/'.toJS, '_self'.toJS);
}
