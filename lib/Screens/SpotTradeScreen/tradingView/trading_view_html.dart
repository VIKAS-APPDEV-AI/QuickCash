import 'package:flutter/material.dart';
import 'package:quickcash/Screens/SpotTradeScreen/tradingView/crypto_name_data_source.dart';
import 'package:quickcash/constants.dart';
import 'package:webview_flutter/webview_flutter.dart';

class TradingViewWidgetHtml extends StatefulWidget {
  const TradingViewWidgetHtml({
    required this.cryptoName,
    required this.currency,
    super.key,
  });

  final String cryptoName;
  final String currency;

  @override
  State<TradingViewWidgetHtml> createState() => _TradingViewWidgetHtmlState();
}

class _TradingViewWidgetHtmlState extends State<TradingViewWidgetHtml> {
  late final WebViewController controller;
  bool isLoading = true;
  double _zoomLevel = 1.0;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    
    controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(const Color(0x00000000))
      ..setNavigationDelegate(
        NavigationDelegate(
          onProgress: (int progress) {
            debugPrint('Loading: $progress%');
          },
          onPageStarted: (String url) {
            debugPrint('Page started loading');
            setState(() {
              isLoading = true;
              _errorMessage = null;
            });
          },
          onPageFinished: (String url) {
            debugPrint('Page finished loading');
            setState(() => isLoading = false);
            _applyZoom();
          },
          onWebResourceError: (WebResourceError error) {
            debugPrint('Error loading page: ${error.description}');
            setState(() {
              isLoading = false;
              _errorMessage = 'Failed to load chart. Please check your symbol ($symbolPair)';
            });
          },
        ),
      )
      ..enableZoom(true)
      ..loadHtmlString(_getTradingViewHtml());
  }

  String get symbolPair {
    // Format the symbol pair correctly for Binance
    final base = widget.cryptoName.toUpperCase();
    final quote = widget.currency.toUpperCase();
    
    // Handle cases where USDT is expected instead of USD
    if (quote == 'USD') {
      return '${base}USDT';
    }
    return '${base}$quote';
  }

  String _getTradingViewHtml() {
    return '''
      <!DOCTYPE html>
      <html>
      <head>
        <meta charset="utf-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <title>TradingView</title>
        <script type="text/javascript" src="https://s3.tradingview.com/tv.js"></script>
        <style>
          body {
            margin: 0;
            padding: 0;
            overflow: hidden;
            background-color: #ffffff;
          }
          #tradingview {
            width: 100%;
            height: 100vh;
          }
          .error-message {
            display: flex;
            justify-content: center;
            align-items: center;
            height: 100vh;
            color: #ff0000;
            font-family: Arial, sans-serif;
            padding: 20px;
            text-align: center;
          }
        </style>
      </head>
      <body>
        <div id="tradingview"></div>
        <div id="error" class="error-message" style="display: none;"></div>
        <script type="text/javascript">
          try {
            new TradingView.widget({
              "autosize": true,
              "symbol": "BINANCE:$symbolPair",
              "interval": "1",
              "timezone": "Etc/UTC",
              "theme": "light",
              "style": "3",
              "locale": "en",
              "toolbar_bg": "#f1f3f6",
              "enable_publishing": false,
              "hide_top_toolbar": false,
              "hide_side_toolbar": true,
              "allow_symbol_change": true,
              "details": true,
              "container_id": "tradingview",
              "overrides": {
                "mainSeriesProperties.style": 0,
                "paneProperties.background": "#ffffff",
                "paneProperties.vertGridProperties.color": "#f0f0f0",
                "paneProperties.horzGridProperties.color": "#f0f0f0",
                "symbolWatermarkProperties.transparency": 90,
                "scalesProperties.textColor": "#333333",
                "scalesProperties.fontSize": 12,
                "scalesProperties.lineColor": "#dddddd"
              },
              "studies_overrides": {
                "volume.volume.color.0": "#FF0000",
                "volume.volume.color.1": "#00FF00",
                "volume.volume.transparency": 70
              }
            });
          } catch (error) {
            document.getElementById('error').innerText = 'Error loading chart: ' + error.message;
            document.getElementById('error').style.display = 'block';
            document.getElementById('tradingview').style.display = 'none';
          }
        </script>
      </body>
      </html>
    ''';
  }

  Future<void> _applyZoom() async {
    await controller.runJavaScript('document.body.style.zoom = "$_zoomLevel"');
  }

  void _handleZoom(double delta) {
    setState(() {
      _zoomLevel = (_zoomLevel + delta).clamp(0.5, 3.0);
    });
    _applyZoom();
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>()!;
    
    return Scaffold(
      body: Stack(
        children: [
          WebViewWidget(controller: controller),
          
          if (isLoading)
            Center(
              child: CircularProgressIndicator(color: colors.primary),
            ),
            
          if (_errorMessage != null)
            Center(
              child: Container(
                padding: const EdgeInsets.all(20),
                color: Colors.white,
                child: Text(
                  _errorMessage!,
                  style: TextStyle(
                    color: Colors.red,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
            
          Positioned(
            right: 16,
            bottom: 16,
            child: Column(
              children: [
                FloatingActionButton.small(
                  heroTag: 'zoomIn',
                  onPressed: () => _handleZoom(0.1),
                  backgroundColor: colors.primary,
                  child: const Icon(Icons.add, color: Colors.white),
                ),
                const SizedBox(height: 8),
                FloatingActionButton.small(
                  heroTag: 'zoomOut',
                  onPressed: () => _handleZoom(-0.1),
                  backgroundColor: colors.primary,
                  child: const Icon(Icons.remove, color: Colors.white),
                ),
                const SizedBox(height: 8),
                FloatingActionButton.small(
                  heroTag: 'resetZoom',
                  onPressed: () {
                    setState(() => _zoomLevel = 1.0);
                    _applyZoom();
                  },
                  backgroundColor: colors.primary,
                  child: const Icon(Icons.refresh, color: Colors.white),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}