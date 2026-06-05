import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Crea el TextTheme combinando dos fuentes de Google Fonts.
TextTheme createTextTheme(
    BuildContext context,
    String bodyFont,
    String displayFont,
    ) {
  final bodyTextTheme    = GoogleFonts.getTextTheme(bodyFont,    Theme.of(context).textTheme);
  final displayTextTheme = GoogleFonts.getTextTheme(displayFont, Theme.of(context).textTheme);

  return displayTextTheme.copyWith(
    bodyLarge:   bodyTextTheme.bodyLarge,
    bodyMedium:  bodyTextTheme.bodyMedium,
    bodySmall:   bodyTextTheme.bodySmall,
    labelLarge:  bodyTextTheme.labelLarge,
    labelMedium: bodyTextTheme.labelMedium,
    labelSmall:  bodyTextTheme.labelSmall,
  );
}