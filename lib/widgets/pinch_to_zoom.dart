// lib/widgets/pinch_to_zoom.dart

import 'package:flutter/material.dart';

/// Smooth pinch-to-zoom with overlay.
/// - Responds quickly with a small threshold
/// - Draggable while zoomed
/// - Springs back with easeOutCubic on release
class PinchToZoom extends StatefulWidget {
  final Widget child;
  const PinchToZoom({super.key, required this.child});

  @override
  State<PinchToZoom> createState() => _PinchToZoomState();
}

class _PinchToZoomState extends State<PinchToZoom>
    with SingleTickerProviderStateMixin {
  OverlayEntry? _overlay;
  final _containerKey = GlobalKey();
  Rect _widgetRect = Rect.zero;

  double _scale = 1.0;
  double _previousScale = 1.0;
  Offset _translate = Offset.zero;
  Offset _previousTranslate = Offset.zero;
  bool _isZooming = false;

  late AnimationController _animCtrl;
  Animation<double>? _scaleAnim;
  Animation<Offset>? _translateAnim;

  @override
  void initState() {
    super.initState();
    _animCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    )..addListener(_onAnimTick);
  }

  @override
  void dispose() {
    _animCtrl.dispose();
    _removeOverlay();
    super.dispose();
  }

  void _removeOverlay() {
    _overlay?.remove();
    _overlay = null;
  }

  void _showOverlay() {
    final box =
        _containerKey.currentContext?.findRenderObject() as RenderBox?;
    if (box == null) return;
    _widgetRect = box.localToGlobal(Offset.zero) & box.size;

    _overlay = OverlayEntry(builder: (_) => _buildOverlayWidget());
    Overlay.of(context).insert(_overlay!);
  }

  void _refreshOverlay() => _overlay?.markNeedsBuild();

  Widget _buildOverlayWidget() {
    return Positioned.fill(
      child: IgnorePointer(
        child: Material(
          color: Colors.transparent,
          child: Stack(
            children: [
              Positioned.fill(
                child: ColoredBox(
                  color: Colors.black
                      .withOpacity(((_scale - 1.0) / 3.0).clamp(0.0, 0.88)),
                ),
              ),
              Positioned(
                left: _widgetRect.left + _translate.dx,
                top: _widgetRect.top + _translate.dy,
                width: _widgetRect.width,
                height: _widgetRect.height,
                child: Transform.scale(
                  scale: _scale,
                  child: widget.child,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _onScaleStart(ScaleStartDetails d) {
    _animCtrl.stop();
    _scaleAnim = null;
    _translateAnim = null;

    _previousScale = _scale;
    _previousTranslate = _translate;
  }

  void _onScaleUpdate(ScaleUpdateDetails d) {
    final newScale = (_previousScale * d.scale).clamp(1.0, 5.0);
    final isPinching = d.pointerCount >= 2 || newScale > 1.01;

    if (!isPinching && !_isZooming) return;

    final newTranslate = _previousTranslate + d.focalPointDelta;

    if (!_isZooming && newScale > 1.01) {
      _isZooming = true;
      if (_overlay == null) _showOverlay();
      setState(() {});
    }

    if (_isZooming) {
      _scale = newScale;
      _translate = newTranslate;
      _refreshOverlay();
    }
  }

  void _onScaleEnd(ScaleEndDetails d) {
    if (!_isZooming) return;
    _springBack();
  }

  void _springBack() {
    final startScale = _scale;
    final startTranslate = _translate;

    _scaleAnim = Tween<double>(begin: startScale, end: 1.0).animate(
      CurvedAnimation(parent: _animCtrl, curve: Curves.easeOutCubic),
    );
    _translateAnim =
        Tween<Offset>(begin: startTranslate, end: Offset.zero).animate(
      CurvedAnimation(parent: _animCtrl, curve: Curves.easeOutCubic),
    );

    _animCtrl.reset();
    _animCtrl.forward();
  }

  void _onAnimTick() {
    if (_scaleAnim == null) return;
    _scale = _scaleAnim!.value;
    _translate = _translateAnim!.value;
    _refreshOverlay();

    if (_animCtrl.isCompleted) {
      _isZooming = false;
      _scale = 1.0;
      _translate = Offset.zero;
      _removeOverlay();
      if (mounted) setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return Listener(
      child: GestureDetector(
        key: _containerKey,
        onScaleStart: _onScaleStart,
        onScaleUpdate: _onScaleUpdate,
        onScaleEnd: _onScaleEnd,
        child: Opacity(
          opacity: _isZooming ? 0.0 : 1.0,
          child: widget.child,
        ),
      ),
    );
  }
}

