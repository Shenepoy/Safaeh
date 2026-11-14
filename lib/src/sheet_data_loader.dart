import 'dart:async';
import 'dart:math' as math;

import 'package:material_ui/material_ui.dart';

import 'sheet_template.dart';

/// Localize in the host; raw exceptions are never used as display copy.
class SafaehSheetLoadLabels {
  const SafaehSheetLoadLabels({
    this.loading = 'Loading details…',
    this.error = 'Couldn’t load these details. Please try again.',
    this.retry = 'Retry',
  });
  final String loading, error, retry;
}

/// One read-only load per sheet identity, with cache, timeout, and safe retry.
///
/// Supply [initialData] to bypass loading. Successful data is retained across
/// parent rebuilds so edits are not reset. Use a new key to load another record.
/// [load] must only read data: timing out or dismissing cannot cancel its work,
/// but late results are ignored. Prefetch and cache invalidation stay in the host.
/// Never use this loader to run a purchase, deletion, or another mutation.
class SafaehSheetDataLoader<T extends Object> extends StatefulWidget {
  const SafaehSheetDataLoader({
    super.key,
    required this.load,
    required this.builder,
    this.initialData,
    this.header,
    this.icon = Icons.hourglass_top_rounded,
    this.labels = const SafaehSheetLoadLabels(),
    this.timeout = const Duration(seconds: 20),
    this.onError,
    this.loadingBuilder,
    this.errorBuilder,
    this.retryKey,
    this.padding,
  });

  final FutureOr<T> Function(bool retry) load;
  final Widget Function(BuildContext context, T data) builder;
  final T? initialData;
  final Widget? header;
  final IconData icon;
  final SafaehSheetLoadLabels labels;
  final Duration timeout;
  final void Function(Object error, StackTrace stack)? onError;
  final WidgetBuilder? loadingBuilder;
  final Widget Function(
    BuildContext context,
    Object error,
    StackTrace stack,
    VoidCallback retry,
  )?
  errorBuilder;
  final Key? retryKey;
  final EdgeInsetsGeometry? padding;

  @override
  State<SafaehSheetDataLoader<T>> createState() =>
      _SafaehSheetDataLoaderState<T>();
}

class _SafaehSheetDataLoaderState<T extends Object>
    extends State<SafaehSheetDataLoader<T>> {
  T? _data;
  Object? _error;
  StackTrace? _stack;
  bool _loading = true;
  Timer? _timeout;
  int _attempt = 0;

  @override
  void initState() {
    super.initState();
    _data = widget.initialData;
    if (_data != null) {
      _loading = false;
    } else {
      unawaited(_load(false));
    }
  }

  @override
  void dispose() {
    _attempt++;
    _timeout?.cancel();
    super.dispose();
  }

  void _fail(Object error, StackTrace stack) {
    setState(() {
      _error = error;
      _stack = stack;
      _loading = false;
    });
    try {
      widget.onError?.call(error, stack);
    } catch (reportError, reportStack) {
      FlutterError.reportError(
        FlutterErrorDetails(
          exception: reportError,
          stack: reportStack,
          library: 'safaeh',
          context: ErrorDescription('reporting a sheet read failure'),
        ),
      );
    }
  }

  Future<void> _load(bool retry) async {
    final attempt = ++_attempt;
    // A host may invalidate a provider during retry. Leave the build phase.
    await Future<void>.value();
    if (!mounted || attempt != _attempt) return;
    _timeout = Timer(widget.timeout, () {
      if (!mounted || attempt != _attempt) return;
      _attempt++; // Quarantine this future before allowing another attempt.
      _fail(
        TimeoutException('Sheet read timed out', widget.timeout),
        StackTrace.current,
      );
    });
    try {
      final data = await Future<T>.sync(() => widget.load(retry));
      if (!mounted || attempt != _attempt) return;
      _timeout?.cancel();
      setState(() {
        _data = data;
        _loading = false;
      });
    } catch (error, stack) {
      if (!mounted || attempt != _attempt) return;
      _timeout?.cancel();
      _fail(error, stack);
    }
  }

  void _retry() {
    if (!mounted || _loading || _error == null || _data != null) return;
    setState(() {
      _loading = true;
      _error = null;
      _stack = null;
    });
    unawaited(_load(true));
  }

  @override
  Widget build(BuildContext context) {
    final data = _data;
    if (data != null) return widget.builder(context, data);
    final error = _error;
    if (error != null && widget.errorBuilder != null) {
      return widget.errorBuilder!(context, error, _stack!, _retry);
    }
    if (_loading && widget.loadingBuilder != null) {
      return widget.loadingBuilder!(context);
    }
    final cs = Theme.of(context).colorScheme;
    return SafaehSheetTemplate(
      header: widget.header,
      padding: widget.padding,
      body: SafaehSheetSurface(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              AnimatedSwitcher(
                duration: MediaQuery.disableAnimationsOf(context)
                    ? Duration.zero
                    : const Duration(milliseconds: 180),
                child: Icon(
                  error != null ? Icons.error_outline : widget.icon,
                  key: ValueKey(error != null),
                  color: error != null ? cs.error : cs.primary,
                  size: 28,
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                height: 4,
                child: _loading
                    ? LinearProgressIndicator(
                        semanticsLabel: widget.labels.loading,
                      )
                    : null,
              ),
              const SizedBox(height: 16),
              LayoutBuilder(
                builder: (context, constraints) {
                  // Reserve the larger localized message, including text scaling.
                  var height = 0.0;
                  for (final label in [
                    widget.labels.loading,
                    widget.labels.error,
                  ]) {
                    final painter = TextPainter(
                      text: TextSpan(
                        text: label,
                        style: DefaultTextStyle.of(context).style,
                      ),
                      textDirection: Directionality.of(context),
                      textScaler: MediaQuery.textScalerOf(context),
                    )..layout(maxWidth: constraints.maxWidth);
                    height = math.max(height, painter.height);
                    painter.dispose();
                  }
                  return SizedBox(
                    height: height,
                    child: Semantics(
                      liveRegion: true,
                      child: Text(
                        error != null
                            ? widget.labels.error
                            : widget.labels.loading,
                        textAlign: TextAlign.center,
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(height: 8),
              // Reserve the retry footprint at the user's text scale.
              Visibility(
                visible: error != null,
                maintainState: true,
                maintainAnimation: true,
                maintainSize: true,
                child: TextButton.icon(
                  key: widget.retryKey,
                  onPressed: error != null ? _retry : null,
                  icon: const Icon(Icons.refresh),
                  label: Text(widget.labels.retry),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
