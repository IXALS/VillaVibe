import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class MapMarkerHelper {
  static Future<BitmapDescriptor> createPriceMarker(
      String price, bool isSelected) async {
    final ui.PictureRecorder pictureRecorder = ui.PictureRecorder();
    final Canvas canvas = Canvas(pictureRecorder);

    final Color color = isSelected ? Colors.black : Colors.white;
    final Color textColor = isSelected ? Colors.white : Colors.black;

    final Paint paint = Paint()..color = color;
    final TextPainter textPainter = TextPainter(
      textDirection: TextDirection.ltr,
    );

    const double padding = 20.0;
    const double fontSize = 30.0;
    const double shadowMargin = 32.0; // Increased margin for shadow

    textPainter.text = TextSpan(
      text: price,
      style: TextStyle(
        fontSize: fontSize,
        fontWeight: FontWeight.bold,
        color: textColor,
      ),
    );

    textPainter.layout();

    final double contentWidth = textPainter.width + padding * 2;
    final double contentHeight = textPainter.height + padding * 2;
    
    final double totalWidth = contentWidth + shadowMargin * 2;
    final double totalHeight = contentHeight + shadowMargin * 2;

    // Draw shadow
    final Path shadowPath = Path()
      ..addRRect(RRect.fromRectAndRadius(
        Rect.fromLTWH(shadowMargin + 2, shadowMargin + 4, contentWidth, contentHeight),
        const Radius.circular(30),
      ));
    canvas.drawShadow(shadowPath, Colors.black.withOpacity(0.5), 8, true);

    // Draw background pill
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(shadowMargin, shadowMargin, contentWidth, contentHeight),
        const Radius.circular(30),
      ),
      paint,
    );

    // Draw text
    textPainter.paint(
      canvas,
      Offset(padding + shadowMargin, padding + shadowMargin),
    );

    final ui.Image image = await pictureRecorder
        .endRecording()
        .toImage(totalWidth.toInt(), totalHeight.toInt());
    final ByteData? data =
        await image.toByteData(format: ui.ImageByteFormat.png);

    return BitmapDescriptor.fromBytes(data!.buffer.asUint8List());
  }
}
