import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';

/// Manages crypto logos for exports
class CryptoLogoManager {
  
  // High-quality crypto logo URLs
  static const Map<String, String> cryptoLogoUrls = {
    'BTC': 'https://raw.githubusercontent.com/spothq/cryptocurrency-icons/master/128/color/btc.png',
    'ETH': 'https://raw.githubusercontent.com/spothq/cryptocurrency-icons/master/128/color/eth.png',
    'LTC': 'https://raw.githubusercontent.com/spothq/cryptocurrency-icons/master/128/color/ltc.png',
    'ADA': 'https://raw.githubusercontent.com/spothq/cryptocurrency-icons/master/128/color/ada.png',
    'SOL': 'https://raw.githubusercontent.com/spothq/cryptocurrency-icons/master/128/color/sol.png',
    'DOGE': 'https://raw.githubusercontent.com/spothq/cryptocurrency-icons/master/128/color/doge.png',
    'BNB': 'https://raw.githubusercontent.com/spothq/cryptocurrency-icons/master/128/color/bnb.png',
    'BCH': 'https://raw.githubusercontent.com/spothq/cryptocurrency-icons/master/128/color/bch.png',
    'SHIB': 'https://raw.githubusercontent.com/spothq/cryptocurrency-icons/master/128/color/shib.png',
    'XRP': 'https://raw.githubusercontent.com/spothq/cryptocurrency-icons/master/128/color/xrp.png',
    'DOT': 'https://raw.githubusercontent.com/spothq/cryptocurrency-icons/master/128/color/dot.png',
    'AVAX': 'https://raw.githubusercontent.com/spothq/cryptocurrency-icons/master/128/color/avax.png',
    'MATIC': 'https://raw.githubusercontent.com/spothq/cryptocurrency-icons/master/128/color/matic.png',
    'LINK': 'https://raw.githubusercontent.com/spothq/cryptocurrency-icons/master/128/color/link.png',
    'UNI': 'https://raw.githubusercontent.com/spothq/cryptocurrency-icons/master/128/color/uni.png',
  };

  // Cache directory for downloaded logos
  static Directory? _cacheDir;

  /// Initialize cache directory
  static Future<void> initialize() async {
    final appDir = await getApplicationDocumentsDirectory();
    _cacheDir = Directory('${appDir.path}/crypto_logos');
    if (!await _cacheDir!.exists()) {
      await _cacheDir!.create(recursive: true);
    }
  }

  /// Download and cache crypto logo
  static Future<Uint8List?> downloadAndCacheLogo(String currencyCode) async {
    try {
      await initialize();
      
      final url = cryptoLogoUrls[currencyCode.toUpperCase()];
      if (url == null) return null;

      // Check if already cached
      final cacheFile = File('${_cacheDir!.path}/${currencyCode.toLowerCase()}.png');
      if (await cacheFile.exists()) {
        return await cacheFile.readAsBytes();
      }

      // Download logo
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        // Cache the logo
        await cacheFile.writeAsBytes(response.bodyBytes);
        return response.bodyBytes;
      }
    } catch (e) {
      print('Failed to download crypto logo for $currencyCode: $e');
    }
    return null;
  }

  /// Load crypto logo from assets (fallback)
  static Future<Uint8List?> loadFromAssets(String currencyCode) async {
    try {
      final assetPath = 'assets/crypto_logos/${currencyCode.toLowerCase()}.png';
      final ByteData data = await rootBundle.load(assetPath);
      return data.buffer.asUint8List();
    } catch (e) {
      print('Failed to load crypto logo from assets for $currencyCode: $e');
    }
    return null;
  }

  /// Get crypto logo with fallback strategy
  static Future<Uint8List?> getLogo(String currencyCode) async {
    // Try downloading first
    Uint8List? logoData = await downloadAndCacheLogo(currencyCode);
    
    // Fallback to assets
    if (logoData == null) {
      logoData = await loadFromAssets(currencyCode);
    }
    
    // Generate placeholder if nothing found
    if (logoData == null) {
      logoData = await generatePlaceholderLogo(currencyCode);
    }
    
    return logoData;
  }

  /// Generate a simple placeholder logo
  static Future<Uint8List?> generatePlaceholderLogo(String currencyCode) async {
    try {
      // Create a simple colored circle with currency code
      // This would require additional image generation libraries
      // For now, return null and handle gracefully
      return null;
    } catch (e) {
      return null;
    }
  }

  /// Preload all crypto logos
  static Future<void> preloadAllLogos() async {
    print('Preloading crypto logos...');
    
    for (final currency in cryptoLogoUrls.keys) {
      await downloadAndCacheLogo(currency);
      // Small delay to avoid overwhelming the server
      await Future.delayed(const Duration(milliseconds: 100));
    }
    
    print('Crypto logos preloaded successfully!');
  }

  /// Clear logo cache
  static Future<void> clearCache() async {
    try {
      await initialize();
      if (await _cacheDir!.exists()) {
        await _cacheDir!.delete(recursive: true);
      }
    } catch (e) {
      print('Failed to clear crypto logo cache: $e');
    }
  }

  /// Get cache size
  static Future<int> getCacheSize() async {
    try {
      await initialize();
      if (!await _cacheDir!.exists()) return 0;
      
      int totalSize = 0;
      await for (final file in _cacheDir!.list()) {
        if (file is File) {
          totalSize += await file.length();
        }
      }
      return totalSize;
    } catch (e) {
      return 0;
    }
  }

  /// Format cache size for display
  static String formatCacheSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }
}