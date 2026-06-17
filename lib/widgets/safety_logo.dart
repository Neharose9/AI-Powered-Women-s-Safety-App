import 'package:flutter/material.dart';

class SafetyLogo extends StatelessWidget {
  final double size;
  final Color? color;
  const SafetyLogo({Key? key, this.size = 100, this.color}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final themeColor = color ?? const Color(0xFF7B1FA2);
    return SizedBox(
      height: size * 1.2,
      width: size * 1.2,
      child: CustomPaint(
        painter: _BeautifulLogoPainter(themeColor: themeColor),
      ),
    );
  }
}

class _BeautifulLogoPainter extends CustomPainter {
  final Color themeColor;
  _BeautifulLogoPainter({required this.themeColor});

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final center = Offset(w / 2, h / 2);

    // 1. Soft Outer Glow (Ambient Light)
    final glowPaint = Paint()
      ..shader = RadialGradient(
        colors: [
          themeColor.withOpacity(0.25),
          themeColor.withOpacity(0.0),
        ],
      ).createShader(Rect.fromCircle(center: center, radius: w * 0.5))
      ..style = PaintingStyle.fill;
    canvas.drawCircle(center, w * 0.5, glowPaint);

    // 2. Modern Shield Shape (Premium Elongated)
    final shieldPaint = Paint()
      ..shader = LinearGradient(
        colors: [
          themeColor, 
          themeColor.withOpacity(0.85),
          themeColor.withOpacity(1.0),
        ],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ).createShader(Rect.fromLTWH(w * 0.1, h * 0.1, w * 0.8, h * 0.8))
      ..style = PaintingStyle.fill;

    final shieldPath = Path();
    shieldPath.moveTo(w * 0.5, h * 0.05); // Top center
    shieldPath.quadraticBezierTo(w * 0.15, h * 0.05, w * 0.1, h * 0.2); // Top-left curve
    shieldPath.lineTo(w * 0.1, h * 0.6); // Left side
    shieldPath.quadraticBezierTo(w * 0.1, h * 0.9, w * 0.5, h * 0.95); // Bottom curve
    shieldPath.quadraticBezierTo(w * 0.9, h * 0.9, w * 0.9, h * 0.6); // Right side
    shieldPath.lineTo(w * 0.9, h * 0.2); // Right top
    shieldPath.quadraticBezierTo(w * 0.85, h * 0.05, w * 0.5, h * 0.05); // Top-right curve
    shieldPath.close();

    // Draw shadow for depth
    canvas.drawShadow(shieldPath, themeColor.withOpacity(0.4), 15, true);
    canvas.drawPath(shieldPath, shieldPaint);

    // 3. Inner "Glass" Border Highlight
    final glassHighlight = Paint()
      ..shader = LinearGradient(
        colors: [
          Colors.white.withOpacity(0.4),
          Colors.white.withOpacity(0.0),
          Colors.white.withOpacity(0.2),
        ],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ).createShader(Rect.fromLTWH(w * 0.15, h * 0.15, w * 0.7, h * 0.7))
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;
    
    final innerPath = Path();
    innerPath.moveTo(w * 0.5, h * 0.08);
    innerPath.quadraticBezierTo(w * 0.2, h * 0.08, w * 0.15, h * 0.22);
    innerPath.lineTo(w * 0.15, h * 0.58);
    innerPath.quadraticBezierTo(w * 0.15, h * 0.85, w * 0.5, h * 0.9);
    innerPath.quadraticBezierTo(w * 0.85, h * 0.85, w * 0.85, h * 0.58);
    innerPath.lineTo(w * 0.85, h * 0.22);
    innerPath.quadraticBezierTo(w * 0.8, h * 0.08, w * 0.5, h * 0.08);
    innerPath.close();
    canvas.drawPath(innerPath, glassHighlight);

    // 4. The "Core Pulse" (Center Motif)
    // A glowing circle representing protection and safety
    final pulseGlow = Paint()
      ..shader = RadialGradient(
        colors: [
          Colors.white.withOpacity(0.9),
          Colors.white.withOpacity(0.2),
          Colors.transparent,
        ],
        stops: const [0.0, 0.6, 1.0],
      ).createShader(Rect.fromCircle(center: center, radius: w * 0.35))
      ..style = PaintingStyle.fill;
    canvas.drawCircle(center, w * 0.35, pulseGlow);

    // 5. Minimalist Woman Silhouette (Elegant & Modern)
    final silhouettePaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;
    
    double cx = center.dx;
    double cy = center.dy;
    double r = w * 0.12; // Head radius base

    // Draw Head (Slightly elongated for elegance)
    canvas.drawCircle(Offset(cx, cy - r * 1.0), r * 0.45, silhouettePaint);

    // Draw Hair/Outline (Abstract flowing style)
    final hairPath = Path();
    hairPath.moveTo(cx - r * 0.8, cy - r * 0.6);
    hairPath.quadraticBezierTo(cx - r * 0.9, cy - r * 1.8, cx, cy - r * 1.8);
    hairPath.quadraticBezierTo(cx + r * 0.9, cy - r * 1.8, cx + r * 0.8, cy - r * 0.6);
    hairPath.quadraticBezierTo(cx + r * 1.0, cy - r * 0.2, cx + r * 0.6, cy - r * 0.1);
    hairPath.lineTo(cx - r * 0.6, cy - r * 0.1);
    hairPath.quadraticBezierTo(cx - r * 1.0, cy - r * 0.2, cx - r * 0.8, cy - r * 0.6);
    hairPath.close();
    canvas.drawPath(hairPath, silhouettePaint);

    // Draw Torso (Abstract elegant curves)
    final bodyPath = Path();
    bodyPath.moveTo(cx - r * 0.3, cy - r * 0.1);
    bodyPath.lineTo(cx + r * 0.3, cy - r * 0.1);
    bodyPath.quadraticBezierTo(cx + r * 0.9, cy - r * 0.1, cx + r * 1.1, cy + r * 0.8);
    bodyPath.lineTo(cx - r * 1.1, cy + r * 0.8);
    bodyPath.quadraticBezierTo(cx - r * 0.9, cy - r * 0.1, cx - r * 0.3, cy - r * 0.1);
    bodyPath.close();
    
    // Gradient for the body to blend with the glow
    final bodyGradient = Paint()
      ..shader = LinearGradient(
        colors: [Colors.white, Colors.white.withOpacity(0.8)],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      ).createShader(Rect.fromLTWH(cx - r, cy - r, r * 2, r * 2))
      ..style = PaintingStyle.fill;
    
    canvas.drawPath(bodyPath, bodyGradient);

    // 6. Minimalist "Spark" (Compass/Navigation symbol)
    // Small spark at the bottom for navigation feel
    final sparkPaint = Paint()
      ..color = Colors.white.withOpacity(0.7)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    
    double sw = w * 0.05;
    canvas.drawLine(center + Offset(0, r * 1.1), center + Offset(0, r * 1.1 + sw), sparkPaint);
    canvas.drawLine(center + Offset(-sw/2, r * 1.1 + sw/2), center + Offset(sw/2, r * 1.1 + sw/2), sparkPaint);

    // 7. Reflection Highlight (Metallic/Glass feel)
    final reflectionPaint = Paint()
      ..shader = LinearGradient(
        colors: [
          Colors.white.withOpacity(0.3),
          Colors.white.withOpacity(0.0),
        ],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      ).createShader(Rect.fromLTWH(w * 0.1, h * 0.1, w * 0.8, h * 0.4))
      ..style = PaintingStyle.fill;
    
    final reflectionPath = Path()
      ..moveTo(w * 0.15, h * 0.25)
      ..quadraticBezierTo(w * 0.5, h * 0.15, w * 0.85, h * 0.25)
      ..lineTo(w * 0.85, h * 0.15)
      ..quadraticBezierTo(w * 0.5, h * 0.05, w * 0.15, h * 0.15)
      ..close();
    canvas.drawPath(reflectionPath, reflectionPaint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}

