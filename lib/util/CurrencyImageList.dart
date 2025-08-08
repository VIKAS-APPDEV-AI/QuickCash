class CurrencyCountryMapper {
  static String getCountryCode(String? currency) {
    switch (currency?.toUpperCase()) {
      case 'USD': return 'US';
      case 'EUR': return 'EU';
      case 'INR': return 'IN';
      case 'GBP': return 'GB';
      case 'AUD': return 'AU';
      case 'CAD': return 'CA';
      case 'JPY': return 'JP';
      case 'CNY': return 'CN';
      case 'CHF': return 'CH';
      case 'NZD': return 'NZ';
      case 'SEK': return 'SE';
      case 'NOK': return 'NO';
      case 'DKK': return 'DK';
      case 'SGD': return 'SG';
      case 'HKD': return 'HK';
      case 'THB': return 'TH';
      case 'ZAR': return 'ZA';
      case 'RUB': return 'RU';
      case 'AED': return 'AE';
      case 'SAR': return 'SA';
      case 'KWD': return 'KW';
      case 'MYR': return 'MY';
      case 'PHP': return 'PH';
      case 'IDR': return 'ID';
      case 'KRW': return 'KR';
      case 'BRL': return 'BR';
      case 'MXN': return 'MX';
      case 'TRY': return 'TR';
      case 'PLN': return 'PL';
      case 'CZK': return 'CZ';
      case 'HUF': return 'HU';
      case 'EGP': return 'EG';
      case 'NGN': return 'NG';
      case 'PKR': return 'PK';
      case 'BDT': return 'BD';
      case 'LKR': return 'LK';
      case 'BTN': return 'BT'; // Bhutan
      case 'FJD': return 'FJ'; // Fiji
      default: return 'US';
    }
  }
}
