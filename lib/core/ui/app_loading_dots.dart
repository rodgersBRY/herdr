import 'dart:math' as math;

import 'package:flutter/material.dart';

class AppLoadingDots extends StatefulWidget {
  final Color color;
  final double dotSize;
  final int dotCount;
  final double gap;

  const AppLoadingDots({
    super.key,
    this.color = Colors.white,
    this.dotSize = 6,
    this.dotCount = 3,
    this.gap = 4,
  });

  @override
  State<AppLoadingDots> createState() => _AppLoadingDotsState();
}

class _AppLoadingDotsState extends State<AppLoadingDots>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  double _dotScale(int index) {
    final shift = index / widget.dotCount;
    final phase = (_controller.value + shift) % 1;
    final wave = (math.sin(phase * 2 * math.pi) + 1) / 2;
    return 0.65 + (wave * 0.35);
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (_, __) {
        return LayoutBuilder(
          builder: (context, constraints) {
            final maxWidth =
                constraints.maxWidth.isFinite
                    ? constraints.maxWidth
                    : double.infinity;

            final baseWidth =
                (widget.dotSize * widget.dotCount) +
                (widget.gap * (widget.dotCount - 1));
            final shrinkRatio =
                maxWidth.isFinite && maxWidth > 0
                    ? (maxWidth / baseWidth).clamp(0.4, 1.0)
                    : 1.0;

            final effectiveDotSize = widget.dotSize * shrinkRatio;
            final effectiveGap = widget.gap * shrinkRatio;

            return Row(
              mainAxisSize: MainAxisSize.min,
              children: List.generate(widget.dotCount, (index) {
                final scale = _dotScale(index);
                return Padding(
                  padding: EdgeInsets.only(
                    right: index == widget.dotCount - 1 ? 0 : effectiveGap,
                  ),
                  child: Transform.scale(
                    scale: scale,
                    child: Container(
                      width: effectiveDotSize,
                      height: effectiveDotSize,
                      decoration: BoxDecoration(
                        color: widget.color,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                );
              }),
            );
          },
        );
      },
    );
  }
}
