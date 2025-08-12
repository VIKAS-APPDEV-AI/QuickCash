import 'dart:typed_data';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter/material.dart';

/// Manages Unicode fonts for proper currency symbol rendering
class UnicodeFontManager {
  
  // Font configurations for different regions
  static const Map<String, String> regionalFonts = {
    'arabic': 'NotoSansArabic',
    'devanagari': 'NotoSansDevanagari',
    'thai': 'NotoSansThai',
    'korean': 'NotoSansKR',
    'japanese': 'NotoSansJP',
    'chinese': 'NotoSansSC',
    'symbols': 'NotoSansSymbols',
    'emoji': 'NotoColorEmoji',
  };

  // Currency to font mapping
  static const Map<String, String> currencyFontMap = {
    'AED': 'arabic',
    'SAR': 'arabic',
    'QAR': 'arabic',
    'KWD': 'arabic',
    'BHD': 'arabic',
    'OMR': 'arabic',
    'JOD': 'arabic',
    'LBP': 'arabic',
    'EGP': 'arabic',
    'THB': 'thai',
    'INR': 'devanagari',
    'KRW': 'korean',
    'JPY': 'japanese',
    'CNY': 'chinese',
  };

  /// Get appropriate font for currency
  static String getFontForCurrency(String currencyCode) {
    final fontType = currencyFontMap[currencyCode.toUpperCase()];
    if (fontType != null && regionalFonts.containsKey(fontType)) {
      return regionalFonts[fontType]!;
    }
    return 'NotoSans'; // Default Unicode font
  }

  /// Load font data for PDF generation
  static Future<Uint8List?> loadFontData(String fontName, {bool bold = false}) async {
    try {
      final String fontPath = bold 
          ? 'assets/fonts/$fontName-Bold.ttf'
          : 'assets/fonts/$fontName-Regular.ttf';
      
      final ByteData data = await rootBundle.load(fontPath);
      return data.buffer.asUint8List();
    } catch (e) {
      print('Failed to load font $fontName: $e');
      
      // Try loading default Noto Sans
      try {
        final String fallbackPath = bold 
            ? 'assets/fonts/NotoSans-Bold.ttf'
            : 'assets/fonts/NotoSans-Regular.ttf';
        
        final ByteData data = await rootBundle.load(fallbackPath);
        return data.buffer.asUint8List();
      } catch (e2) {
        print('Failed to load fallback font: $e2');
        return null;
      }
    }
  }

  /// Get TextStyle for Flutter widgets with proper Unicode support
  static TextStyle getUnicodeTextStyle({
    required String currencyCode,
    double fontSize = 14,
    FontWeight fontWeight = FontWeight.normal,
    Color color = Colors.black,
  }) {
    final fontFamily = getFontForCurrency(currencyCode);
    
    return GoogleFonts.getFont(
      fontFamily == 'NotoSans' ? 'Noto Sans' : fontFamily.replaceAll('Noto', 'Noto '),
      fontSize: fontSize,
      fontWeight: fontWeight,
      color: color,
    );
  }

  /// Test if a currency symbol renders properly
  static bool testCurrencySymbolRendering(String currencyCode, String symbol) {
    try {
      // Check if the symbol contains only ASCII characters
      final isAscii = symbol.codeUnits.every((unit) => unit < 128);
      if (isAscii) return true;
      
      // Check if we have appropriate font for this currency
      final hasFont = currencyFontMap.containsKey(currencyCode.toUpperCase());
      return hasFont;
    } catch (e) {
      return false;
    }
  }

  /// Get font fallback chain for a currency
  static List<String> getFontFallbackChain(String currencyCode) {
    final primaryFont = getFontForCurrency(currencyCode);
    
    return [
      primaryFont,
      'NotoSans',
      'NotoSansSymbols',
      'Arial Unicode MS', // System fallback
      'DejaVu Sans',      // Linux fallback
      'Helvetica',        // macOS fallback
    ];
  }

  /// Download and cache Google Fonts
  static Future<void> preloadGoogleFonts() async {
    try {
      print('Preloading Google Fonts for Unicode support...');
      
      // Preload essential fonts
      await GoogleFonts.pendingFonts([
        GoogleFonts.notoSans(),
        GoogleFonts.notoSansArabic(),
        GoogleFonts.notoSansThai(),
        GoogleFonts.notoSansDevanagari(),
      ]);
      
      print('Google Fonts preloaded successfully!');
    } catch (e) {
      print('Failed to preload Google Fonts: $e');
    }
  }

  /// Create font configuration for Excel
  static Map<String, dynamic> getExcelFontConfig(String currencyCode) {
    return {
      'fontName': getFontForCurrency(currencyCode),
      'fontSize': 10,
      'supportUnicode': true,
      'fallbackFonts': getFontFallbackChain(currencyCode),
    };
  }

  /// Validate font availability
  static Future<Map<String, bool>> validateFontAvailability() async {
    final Map<String, bool> availability = {};
    
    for (final fontEntry in regionalFonts.entries) {
      try {
        await loadFontData(fontEntry.value);
        availability[fontEntry.key] = true;
      } catch (e) {
        availability[fontEntry.key] = false;
      }
    }
    
    return availability;
  }

  /// Get comprehensive font info
  static Future<Map<String, dynamic>> getFontInfo() async {
    final availability = await validateFontAvailability();
    
    return {
      'availableFonts': availability,
      'supportedCurrencies': currencyFontMap.keys.toList(),
      'regionalSupport': regionalFonts.keys.toList(),
      'totalFonts': regionalFonts.length,
      'loadedFonts': availability.values.where((v) => v).length,
    };
  }
}