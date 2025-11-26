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

    textPainter.text = TextSpan(
      text: price,
      style: TextStyle(
        fontSize: fontSize,
        fontWeight: FontWeight.bold,
        color: textColor,
      ),
    );

    textPainter.layout();

    final double width = textPainter.width + padding * 2;
    final double height = textPainter.height + padding * 2;

    // Draw shadow
    final Path shadowPath = Path()
      ..addRRect(RRect.fromRectAndRadius(
        Rect.fromLTWH(2, 2, width, height),
        const Radius.circular(30),
      ));
    canvas.drawShadow(shadowPath, Colors.black, 4, true);

    // Draw background pill
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(0, 0, width, height),
        const Radius.circular(30),
      ),
      paint,
    );

    // Draw text
    textPainter.paint(
      canvas,
      Offset(padding, padding),
    );

    final ui.Image image = await pictureRecorder
        .endRecording()
        .toImage(width.toInt(), height.toInt());
    final ByteData? data =
        await image.toByteData(format: ui.ImageByteFormat.png);

    return BitmapDescriptor.fromBytes(data!.buffer.asUint8List());
  }
}
