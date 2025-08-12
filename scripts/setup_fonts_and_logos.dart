import 'dart:io';
import 'package:http/http.dart' as http;

/// Setup script to download Unicode fonts and crypto logos
class FontAndLogoSetup {
  
  // Google Fonts URLs for Noto fonts
  static const Map<String, String> fontUrls = {
    'NotoSans-Regular.ttf': 'https://fonts.gstatic.com/s/notosans/v36/o-0IIpQlx3QUlC5A4PNr5TRASf6M7Q.ttf',
    'NotoSans-Bold.ttf': 'https://fonts.gstatic.com/s/notosans/v36/o-0NIpQlx3QUlC5A4PNjXhFVZNyB.ttf',
    'NotoSansArabic-Regular.ttf': 'https://fonts.gstatic.com/s/notosansarabic/v18/nwpxtLGrOAZMl5nJ_wfgRg3DrWFZWsnVBJ_sS6tlqHHFlhQ5l3sQWIHPqzCfyGyvu3CBFQLaig.ttf',
    'NotoSansArabic-Bold.ttf': 'https://fonts.gstatic.com/s/notosansarabic/v18/nwpxtLGrOAZMl5nJ_wfgRg3DrWFZWsnVBJ_sS6tlqHHFlhQ5l3sQWIHPqzCfyGyvpXCBFQLaig.ttf',
    'NotoSansThai-Regular.ttf': 'https://fonts.gstatic.com/s/notosansthai/v20/iJWnBXeUZi_OHPqn4wq6hQ2_hbJ1xyN9wd43SofNWcd1MKVQt_So_9CdU5RtpzF-QRvzzXg.ttf',
    'NotoSansThai-Bold.ttf': 'https://fonts.gstatic.com/s/notosansthai/v20/iJWnBXeUZi_OHPqn4wq6hQ2_hbJ1xyN9wd43SofNWcd1MKVQt_So_9CdU5RtpzHaQRvzzXg.ttf',
  };

  // Crypto logo URLs
  static const Map<String, String> cryptoLogoUrls = {
    'bitcoin.png': 'https://raw.githubusercontent.com/spothq/cryptocurrency-icons/master/128/color/btc.png',
    'ethereum.png': 'https://raw.githubusercontent.com/spothq/cryptocurrency-icons/master/128/color/eth.png',
    'litecoin.png': 'https://raw.githubusercontent.com/spothq/cryptocurrency-icons/master/128/color/ltc.png',
    'cardano.png': 'https://raw.githubusercontent.com/spothq/cryptocurrency-icons/master/128/color/ada.png',
    'solana.png': 'https://raw.githubusercontent.com/spothq/cryptocurrency-icons/master/128/color/sol.png',
    'dogecoin.png': 'https://raw.githubusercontent.com/spothq/cryptocurrency-icons/master/128/color/doge.png',
    'binance.png': 'https://raw.githubusercontent.com/spothq/cryptocurrency-icons/master/128/color/bnb.png',
    'bitcoin-cash.png': 'https://raw.githubusercontent.com/spothq/cryptocurrency-icons/master/128/color/bch.png',
    'shiba-inu.png': 'https://raw.githubusercontent.com/spothq/cryptocurrency-icons/master/128/color/shib.png',
  };

  /// Download all fonts
  static Future<void> downloadFonts() async {
    print('📥 Downloading Unicode fonts...');
    
    // Create fonts directory
    final fontsDir = Directory('assets/fonts');
    if (!await fontsDir.exists()) {
      await fontsDir.create(recursive: true);
    }

    for (final entry in fontUrls.entries) {
      final fileName = entry.key;
      final url = entry.value;
      final file = File('${fontsDir.path}/$fileName');

      if (await file.exists()) {
        print('✅ Font already exists: $fileName');
        continue;
      }

      try {
        print('⬇️  Downloading $fileName...');
        final response = await http.get(Uri.parse(url));
        
        if (response.statusCode == 200) {
          await file.writeAsBytes(response.bodyBytes);
          print('✅ Downloaded: $fileName (${response.bodyBytes.length} bytes)');
        } else {
          print('❌ Failed to download $fileName: HTTP ${response.statusCode}');
        }
      } catch (e) {
        print('❌ Error downloading $fileName: $e');
      }
    }
    
    print('🎉 Font download completed!\n');
  }

  /// Download all crypto logos
  static Future<void> downloadCryptoLogos() async {
    print('📥 Downloading crypto logos...');
    
    // Create crypto logos directory
    final logosDir = Directory('assets/crypto_logos');
    if (!await logosDir.exists()) {
      await logosDir.create(recursive: true);
    }

    for (final entry in cryptoLogoUrls.entries) {
      final fileName = entry.key;
      final url = entry.value;
      final file = File('${logosDir.path}/$fileName');

      if (await file.exists()) {
        print('✅ Logo already exists: $fileName');
        continue;
      }

      try {
        print('⬇️  Downloading $fileName...');
        final response = await http.get(Uri.parse(url));
        
        if (response.statusCode == 200) {
          await file.writeAsBytes(response.bodyBytes);
          print('✅ Downloaded: $fileName (${response.bodyBytes.length} bytes)');
        } else {
          print('❌ Failed to download $fileName: HTTP ${response.statusCode}');
        }
      } catch (e) {
        print('❌ Error downloading $fileName: $e');
      }
    }
    
    print('🎉 Crypto logo download completed!\n');
  }

  /// Setup everything
  static Future<void> setupAll() async {
    print('🚀 Setting up fonts and crypto logos for advanced exports...\n');
    
    await downloadFonts();
    await downloadCryptoLogos();
    
    print('✨ Setup completed successfully!');
    print('📁 Files downloaded to:');
    print('   - assets/fonts/ (${fontUrls.length} font files)');
    print('   - assets/crypto_logos/ (${cryptoLogoUrls.length} logo files)');
    print('\n🎯 Your app now supports:');
    print('   ✅ Full Unicode currency symbols');
    print('   ✅ Crypto logos in exports');
    print('   ✅ Professional PDF/Excel formatting');
  }

  /// Verify setup
  static Future<void> verifySetup() async {
    print('🔍 Verifying setup...\n');
    
    // Check fonts
    print('📝 Checking fonts:');
    final fontsDir = Directory('assets/fonts');
    if (await fontsDir.exists()) {
      for (final fontFile in fontUrls.keys) {
        final file = File('${fontsDir.path}/$fontFile');
        final exists = await file.exists();
        final size = exists ? await file.length() : 0;
        print('   ${exists ? "✅" : "❌"} $fontFile ${exists ? "($size bytes)" : "(missing)"}');
      }
    } else {
      print('   ❌ Fonts directory not found');
    }

    // Check crypto logos
    print('\n🪙 Checking crypto logos:');
    final logosDir = Directory('assets/crypto_logos');
    if (await logosDir.exists()) {
      for (final logoFile in cryptoLogoUrls.keys) {
        final file = File('${logosDir.path}/$logoFile');
        final exists = await file.exists();
        final size = exists ? await file.length() : 0;
        print('   ${exists ? "✅" : "❌"} $logoFile ${exists ? "($size bytes)" : "(missing)"}');
      }
    } else {
      print('   ❌ Crypto logos directory not found');
    }
    
    print('\n🎯 Verification completed!');
  }
}

/// Main function to run the setup
void main() async {
  await FontAndLogoSetup.setupAll();
  await FontAndLogoSetup.verifySetup();
}