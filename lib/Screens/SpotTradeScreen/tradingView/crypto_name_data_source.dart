class CryptoNameDataSource {
  static String binanceSourceEuro(String cryptoName, String mTradingViewCurrency) {
    return 'BINANCE:$cryptoName$mTradingViewCurrency';
  }

  static String cryptoNameAndSource(String name) {
    return '''
<!DOCTYPE html>
<html lang="en">
<head>
<title>Load file or HTML string example</title>
</head>
<body>
<div class="tradingview-widget-container">
<div id="tradingview_4418d">
</div>
<div class="tradingview-widget-copyright">
<a href="https://www.tradingview.com/" rel="noopener nofollow" target="_blank">
<span class="blue-text">Track all markets on TradingView
</span>
</a>
</div>
<script type="text/javascript" src="https://s3.tradingview.com/tv.js">
</script>
<script type="text/javascript">
new TradingView.widget({
  "width": "100%",
  "height": 1180,
  "symbol": "$name",
  "interval": "5",
  "timezone": "Etc/UTC",
  "theme": "light",
  "style": "1",
  "locale": "en", 
  "enable_publishing": false,
  "save_image": true,
  "hide_volume": true,
  "allow_symbol_change": false,
  "calendar": true,
  "container_id": "tradingview_4418d"
  });
</script>
</div>
</body>
</html>''';
  }
}
