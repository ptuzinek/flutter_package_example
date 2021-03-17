import 'package:flutter/material.dart';

class RippleEffect extends StatefulWidget {
  final Widget child;
  final GestureTapCallback onTap;

  const RippleEffect({Key key, this.onTap, this.child}) : super(key: key);

  @override
  _RippleEffectState createState() => _RippleEffectState();
}

class _RippleEffectState extends State<RippleEffect>
    with SingleTickerProviderStateMixin {
  static const double minRadius = 50;
  static const double maxRadius = 120;

  AnimationController controller;
  Tween<double> radiusTween;
  Tween<double> borderWidthTween;
  Animation<double> radiusAnimation;
  Animation<double> borderWidthAnimation;
  AnimationStatus status;
  Offset _tapPosition;

  @override
  void initState() {
    super.initState();

    controller =
        AnimationController(vsync: this, duration: Duration(milliseconds: 400))
          ..addListener(() {
            setState(() {});
          })
          ..addStatusListener((listener) {
            status = listener;
          });
    radiusTween = Tween<double>(begin: 0, end: 50);
    radiusAnimation = radiusTween
        .animate(CurvedAnimation(curve: Curves.ease, parent: controller));

    borderWidthTween = Tween<double>(begin: 25, end: 1);
    borderWidthAnimation = borderWidthTween.animate(
        CurvedAnimation(curve: Curves.fastOutSlowIn, parent: controller));
  }

  void _handleTap(TapUpDetails tapUpDetails) {
    RenderBox renderBox = context.findRenderObject();
    _tapPosition = renderBox.globalToLocal(tapUpDetails.globalPosition);
    double radius = (renderBox.size.width > renderBox.size.height)
        ? renderBox.size.width
        : renderBox.size.height;

    double constraintRadius;
    if (radius > maxRadius) {
      constraintRadius = maxRadius;
    } else if (radius < minRadius) {
      constraintRadius = minRadius;
    } else {
      constraintRadius = radius;
    }

    radiusTween.end = constraintRadius * 0.6;
    borderWidthTween.begin = radiusTween.end / 2;
    borderWidthTween.end = radiusTween.end * 0.01;
    controller.forward(from: 0);
    widget.onTap();
  }

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: SplashPaint(
        radius: radiusAnimation.value,
        borderWidth: borderWidthAnimation.value,
        status: status,
        tapPosition: _tapPosition,
      ),
      child: GestureDetector(
        child: widget.child,
        onTapUp: _handleTap,
      ),
    );
  }
}

class SplashPaint extends CustomPainter {
  final double radius;
  final Paint blackPaint;
  final double borderWidth;
  final AnimationStatus status;
  final Offset tapPosition;

  SplashPaint({
    @required this.radius,
    @required this.borderWidth,
    @required this.status,
    @required this.tapPosition,
  }) : blackPaint = Paint()
          ..color = Colors.black
          ..style = PaintingStyle.stroke
          ..strokeWidth = borderWidth;

  @override
  void paint(Canvas canvas, Size size) {
    if (status == AnimationStatus.forward) {
      canvas.drawCircle(tapPosition, radius, blackPaint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}
