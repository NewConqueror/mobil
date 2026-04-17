import 'package:http/http.dart' as http;
import 'dart:convert';

enum ThresholdType { support, resistance }

class ThresholdAlert {
  final double threshold;
  final String label;
  final bool isActive;
  final ThresholdType type; // Direnç veya Destek

  ThresholdAlert({
    required this.threshold,
    required this.label,
    required this.isActive,
    required this.type,
  });

  Map<String, dynamic> toJson() {
    return {
      'threshold': threshold,
      'label': label,
      'isActive': isActive,
      'type': type.name,
    };
  }

  factory ThresholdAlert.fromJson(Map<String, dynamic> json) {
    return ThresholdAlert(
      threshold: (json['threshold'] as num?)?.toDouble() ?? 0.0,
      label: json['label']?.toString() ?? '',
      isActive: json['isActive'] as bool? ?? true,
      type: json['type'] != null 
          ? ThresholdType.values.firstWhere(
              (e) => e.name == json['type'], 
              orElse: () => ThresholdType.support
            )
          : ThresholdType.support,
    );
  }

  String get typeDisplayName => type == ThresholdType.resistance ? 'Direnç' : 'Destek';
}

class CoinData {
  final String symbol;
  final String name;
  final double price;
  final List<ThresholdAlert> thresholds;
  final bool isActive;

  CoinData({
    required this.symbol,
    required this.name,
    required this.price,
    required this.thresholds,
    required this.isActive,
  });

  // Geriye uyumluluk için ana threshold
  double get threshold => thresholds.isNotEmpty ? 
    thresholds.where((t) => t.isActive).map((t) => t.threshold).reduce((a, b) => a < b ? a : b) : 0.0;

  Map<String, dynamic> toJson() {
    return {
      'symbol': symbol,
      'name': name,
      'price': price,
      'thresholds': thresholds.map((t) => t.toJson()).toList(),
      'isActive': isActive,
    };
  }

  factory CoinData.fromJson(Map<String, dynamic> json) {
    List<ThresholdAlert> thresholdList = [];
    
    // Yeni format kontrolü
    if (json.containsKey('thresholds') && json['thresholds'] is List) {
      thresholdList = (json['thresholds'] as List)
          .map((t) => ThresholdAlert.fromJson(t))
          .toList();
    } 
    // Eski format için geriye uyumluluk
    else if (json.containsKey('threshold')) {
      thresholdList = [
        ThresholdAlert(
          threshold: (json['threshold'] as num?)?.toDouble() ?? 0.0,
          label: 'Ana Hedef',
          isActive: true,
          type: ThresholdType.support, // Varsayılan destek
        )
      ];
    }
    
    return CoinData(
      symbol: json['symbol']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      price: (json['price'] as num?)?.toDouble() ?? 0.0,
      thresholds: thresholdList,
      isActive: json['isActive'] as bool? ?? false,
    );
  }
}

class BinanceAPI {
  static const String baseUrl = 'https://api.binance.com/api/v3/ticker/price';

  static Future<double> getCoinPrice(String symbol) async {
    try {
      // Binance API her zaman USDT ile çalışır
      final String apiSymbol = symbol.toUpperCase() + 'USDT';
      final url = Uri.parse('$baseUrl?symbol=$apiSymbol');
      
      final response = await http.get(url, headers: {
        'Accept': 'application/json',
        'Content-Type': 'application/json',
      });

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        print('API Response for $symbol: ${response.body}');
        
        if (jsonData.containsKey('price')) {
          return double.parse(jsonData['price']);
        } else {
          throw Exception('API yanıtında price alanı bulunamadı');
        }
      } else {
        throw Exception('API Hatası: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      print('API Hatası ($symbol): $e');
      throw Exception('$symbol fiyatı alınamadı: $e');
    }
  }

  static Future<Map<String, double>> getMultipleCoinPrices(List<String> symbols) async {
    Map<String, double> prices = {};
    
    for (String symbol in symbols) {
      try {
        prices[symbol] = await getCoinPrice(symbol);
        // API rate limit için kısa bekleme
        await Future.delayed(Duration(milliseconds: 100));
      } catch (e) {
        print('$symbol fiyatı alınamadı: $e');
        prices[symbol] = 0.0;
      }
    }
    
    return prices;
  }

  // Tüm USDT çiftlerini getir
  static Future<List<String>> getAllUSDTSymbols() async {
    try {
      const String allSymbolsUrl = 'https://api.binance.com/api/v3/exchangeInfo';
      final response = await http.get(Uri.parse(allSymbolsUrl));

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        final symbols = <String>[];
        
        if (jsonData.containsKey('symbols')) {
          for (var symbolInfo in jsonData['symbols']) {
            final String symbol = symbolInfo['symbol'] ?? '';
            // Sadece aktif USDT çiftlerini al
            if (symbol.endsWith('USDT') && 
                symbolInfo['status'] == 'TRADING' &&
                symbolInfo['quoteAsset'] == 'USDT') {
              // USDT'yi çıkar, sadece base asset'i al
              final baseSymbol = symbol.replaceAll('USDT', '');
              symbols.add(baseSymbol);
            }
          }
        }
        
        // Alfabetik sırala
        symbols.sort();
        return symbols;
      } else {
        throw Exception('Exchange info alınamadı: ${response.statusCode}');
      }
    } catch (e) {
      print('Sembol listesi alınamadı: $e');
      return ['BTC', 'ETH', 'SOL', 'ADA', 'DOT', 'LTC', 'LINK', 'UNI', 'XRP']; // Fallback listesi
    }
  }
}

// Geriye uyumluluk için
Future<double> getBtcPrice() async {
  return await BinanceAPI.getCoinPrice('BTC');
}
