import 'package:material_ui/material_ui.dart';
import 'package:safaeh_example/catalog.dart';

String storyText(BuildContext context, String key) =>
    translateCatalog(key, Localizations.localeOf(context).languageCode);

/// A scrollable surface for compact widgets; full-screen stories supply theirs.
class StoryPage extends StatelessWidget {
  const StoryPage({super.key, required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) => Scaffold(
    body: SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 60, 16, 24),
        child: child,
      ),
    ),
  );
}

class StoryResult extends StatefulWidget {
  const StoryResult({super.key, required this.label, required this.onOpen});
  final String label;
  final Future<Object?> Function(BuildContext context) onOpen;

  @override
  State<StoryResult> createState() => _StoryResultState();
}

class _StoryResultState extends State<StoryResult> {
  String? _result;
  @override
  Widget build(BuildContext context) => StoryPage(
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        FilledButton(
          onPressed: () async {
            final result = await widget.onOpen(context);
            if (mounted) {
              setState(() => _result = result?.toString() ?? 'Dismissed');
            }
          },
          child: Text(widget.label),
        ),
        if (_result != null)
          Padding(
            padding: const EdgeInsets.only(top: 16),
            child: Text(_result!, key: const ValueKey('story_result')),
          ),
      ],
    ),
  );
}
