// Widgetbook 3.x settings use SDK Material, independently of the preview.
// ignore: deprecated_member_use
import 'package:flutter/material.dart';
import 'package:widgetbook/widgetbook.dart';

/// Widgetbook 3.x's StringField uses an initialValue-only TextFormField.
/// Keep its editor in sync when a URL or localized default changes externally.
extension CatalogTextKnob on BuildContext {
  String catalogString({required String label, required String initialValue}) =>
      knobs.onKnobAdded<String>(
        _TextKnob(label: label, initialValue: initialValue),
      )!;
}

class _TextKnob extends Knob<String?> {
  _TextKnob({required super.label, required super.initialValue});

  @override
  List<Field> get fields => [
    _TextField(name: label, initialValue: initialValue),
  ];

  @override
  String? valueFromQueryGroup(Map<String, String> group) =>
      valueOf(label, group);
}

class _TextField extends StringField {
  _TextField({required super.name, required super.initialValue});

  @override
  Widget toWidget(BuildContext context, String group, String? value) =>
      _TextEditor(
        key: ValueKey((WidgetbookState.of(context).path, group, name)),
        value: value ?? '',
        onChanged: (value) => updateField(context, group, value),
      );
}

class _TextEditor extends StatefulWidget {
  const _TextEditor({super.key, required this.value, required this.onChanged});
  final String value;
  final ValueChanged<String> onChanged;

  @override
  State<_TextEditor> createState() => _TextEditorState();
}

class _TextEditorState extends State<_TextEditor> {
  late final _controller = TextEditingController(text: widget.value);

  @override
  void didUpdateWidget(_TextEditor oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (_controller.text != widget.value) {
      _controller.value = TextEditingValue(
        text: widget.value,
        selection: TextSelection.collapsed(offset: widget.value.length),
      );
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => TextFormField(
    controller: _controller,
    maxLines: null,
    decoration: const InputDecoration(hintText: 'Enter a value'),
    onChanged: widget.onChanged,
  );
}
