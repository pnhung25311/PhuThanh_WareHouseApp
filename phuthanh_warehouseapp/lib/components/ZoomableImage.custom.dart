import 'dart:typed_data';

import 'package:flutter/material.dart';

/// Ảnh (từ bytes) lấp đầy khung chứa, có phóng to/thu nhỏ: pinch, chạm đúp,
/// hoặc 3 nút +, -, vừa khung (đặt ngay dưới ảnh, không đè lên ảnh). Kéo để
/// di chuyển khi đã phóng to, nên xem được mọi góc của ảnh.
class ZoomableImage extends StatefulWidget {
  final Uint8List bytes;

  /// true khi đặt trên nền tối (màn hình xem full) để nút hiện màu sáng.
  final bool onDark;

  const ZoomableImage({super.key, required this.bytes, this.onDark = false});

  @override
  State<ZoomableImage> createState() => _ZoomableImageState();
}

class _ZoomableImageState extends State<ZoomableImage> {
  static const double _maxScale = 8;
  static const double _buttonStep = 1.6;
  static const double _doubleTapScale = 3;

  final TransformationController _controller = TransformationController();
  Size _viewport = Size.zero;
  Offset _doubleTapPosition = Offset.zero;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  double get _scale => _controller.value.getMaxScaleOnAxis();

  /// Phóng/thu về mức [newScale] quanh điểm [focal] (tọa độ trong khung).
  void _zoomTo(double newScale, Offset focal) {
    final scale = newScale.clamp(1.0, _maxScale).toDouble();
    if (scale <= 1.0) {
      _controller.value = Matrix4.identity();
      return;
    }

    final scenePoint = _controller.toScene(focal);
    final matrix = Matrix4.identity()
      ..translateByDouble(focal.dx, focal.dy, 0, 1)
      ..scaleByDouble(scale, scale, 1, 1)
      ..translateByDouble(-scenePoint.dx, -scenePoint.dy, 0, 1);

    // Giữ ảnh không bị kéo trượt ra khỏi khung.
    final translation = matrix.getTranslation();
    final tx = translation.x
        .clamp(_viewport.width - _viewport.width * scale, 0.0)
        .toDouble();
    final ty = translation.y
        .clamp(_viewport.height - _viewport.height * scale, 0.0)
        .toDouble();
    matrix.setTranslationRaw(tx, ty, 0);
    _controller.value = matrix;
  }

  void _zoomByButton(double factor) => _zoomTo(
    _scale * factor,
    Offset(_viewport.width / 2, _viewport.height / 2),
  );

  void _onDoubleTap() {
    if (_scale > 1.01) {
      _controller.value = Matrix4.identity();
    } else {
      _zoomTo(_doubleTapScale, _doubleTapPosition);
    }
  }

  Widget _controlButton(IconData icon, String tooltip, VoidCallback onTap) {
    return IconButton.filledTonal(
      tooltip: tooltip,
      icon: Icon(icon),
      style: IconButton.styleFrom(
        foregroundColor: widget.onDark ? Colors.white : Colors.black87,
        backgroundColor: widget.onDark ? Colors.white24 : Colors.black12,
      ),
      onPressed: onTap,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: LayoutBuilder(
            builder: (context, constraints) {
              _viewport = constraints.biggest;
              return GestureDetector(
                onDoubleTapDown: (details) =>
                    _doubleTapPosition = details.localPosition,
                onDoubleTap: _onDoubleTap,
                child: InteractiveViewer(
                  transformationController: _controller,
                  minScale: 1,
                  maxScale: _maxScale,
                  child: SizedBox.expand(
                    child: Image.memory(widget.bytes, fit: BoxFit.contain),
                  ),
                ),
              );
            },
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 6),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _controlButton(
                Icons.zoom_out,
                'Thu nhỏ',
                () => _zoomByButton(1 / _buttonStep),
              ),
              const SizedBox(width: 12),
              _controlButton(
                Icons.zoom_in,
                'Phóng to',
                () => _zoomByButton(_buttonStep),
              ),
              const SizedBox(width: 12),
              _controlButton(
                Icons.fit_screen,
                'Vừa khung',
                () => _controller.value = Matrix4.identity(),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
