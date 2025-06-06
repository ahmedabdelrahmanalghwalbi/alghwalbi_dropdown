part of 'custom_dropdown.dart';

class _OverlayBuilder extends StatefulWidget {
  final Widget Function(Size, VoidCallback) overlay;
  final Widget Function(VoidCallback) child;

  const _OverlayBuilder({required this.overlay, required this.child});

  @override
  _OverlayBuilderState createState() => _OverlayBuilderState();
}

class _OverlayBuilderState extends State<_OverlayBuilder> {
  OverlayEntry? overlayEntry;

  bool get isShowingOverlay => overlayEntry != null;

  void showOverlay() {
    overlayEntry = OverlayEntry(
      builder: (_) {
        if (mounted) {
          final renderBox = context.findRenderObject() as RenderBox;
          final size = renderBox.size;
          return widget.overlay(size, hideOverlay);
        }
        return const SizedBox();
      },
    );
    addToOverlay(overlayEntry!);
  }

  void addToOverlay(OverlayEntry entry) => Overlay.of(context).insert(entry);

  void hideOverlay() {
    Future.delayed(const Duration(milliseconds: 100), () {
      if (mounted) {
        log('Overlay is being hidden');
        overlayEntry?.remove();
        overlayEntry = null;
      }
    });
  }

  @override
  void dispose() {
    overlayEntry?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => widget.child(showOverlay);
}
