import 'package:flutter/material.dart';

class FullScreenImageView extends StatefulWidget {
  final String imageUrl;

  const FullScreenImageView({Key? key, required this.imageUrl}) : super(key: key);

  @override
  _FullScreenImageViewState createState() => _FullScreenImageViewState();
}

class _FullScreenImageViewState extends State<FullScreenImageView>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  double _verticalDrag = 0.0;
  bool _isDragging = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _animation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOut,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleDragUpdate(DragUpdateDetails details) {
    setState(() {
      _isDragging = true;
      _verticalDrag += details.delta.dy;
    });
  }

  void _handleDragEnd(DragEndDetails details) {
    if (_verticalDrag.abs() > 150) {
      Navigator.pop(context);
    } else {
      // Reset position with a spring animation
      _controller.reset();
      _controller.forward();
      setState(() {
        _isDragging = false;
        _verticalDrag = 0.0;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // Calculate drag effects without clamping for continuous motion
    double dragPercent = _verticalDrag / 300; // No clamp for fluid drag
    double backgroundOpacity = (1.0 - (dragPercent.abs() * 0.7)).clamp(0.0, 1.0); // Only clamp opacity
    double scale = 1.0 - (dragPercent.abs() * 0.2); // Scale based on drag
    double rotation = _verticalDrag / 5000; // Subtle rotation for dynamic effect

    // Use AnimatedBuilder for smooth animation when resetting
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        double animatedDrag = _isDragging
            ? _verticalDrag
            : _verticalDrag * (1.0 - _animation.value);

        return GestureDetector(
          onVerticalDragUpdate: _handleDragUpdate,
          onVerticalDragEnd: _handleDragEnd,
          onTap: () => Navigator.pop(context),
          child: Scaffold(
            backgroundColor: Colors.black.withValues(alpha: backgroundOpacity),
            body: Center(
              child: Hero(
                tag: widget.imageUrl,
                child: Transform(
                  transform: Matrix4.identity()
                    ..translate(0.0, animatedDrag)
                    ..scale(scale)
                    ..rotateZ(rotation), // Subtle rotation
                  alignment: Alignment.center,
                  child: Image.network(
                    widget.imageUrl,
                    fit: BoxFit.contain,
                    loadingBuilder: (context, child, loadingProgress) {
                      if (loadingProgress == null) return child;
                      return const CircularProgressIndicator();
                    },
                    errorBuilder: (context, error, stackTrace) {
                      return const Icon(Icons.error, color: Colors.white);
                    },
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}