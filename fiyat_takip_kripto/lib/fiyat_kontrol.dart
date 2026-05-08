import 'dart:async';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'api.dart';
import 'bildirim.dart';

class PriceMonitoringService {
  static Timer? _timer;
  static bool _isRunning = false;
  static List<CoinData> _trackedCoins = [];
  static final Map<String, DateTime> _lastNotificationTime = {};
  static const String _monitoringEnabledKey = 'monitoring_enabled';

  // Varsayılan coin listesi
  static final List<Map<String, dynamic>> _defaultCoins = [
    {
      'symbol': 'BTC',
      'name': 'Bitcoin',
      'price': 0.0,
      'thresholds': [
        {'threshold': 100000.0, 'label': '100K Alert', 'isActive': true, 'type': 'support'},
        {'threshold': 118000.0, 'label': '118K Alert', 'isActive': true, 'type': 'support'},
        {'threshold': 120000.0, 'label': '120K Alert', 'isActive': true, 'type': 'resistance'},
      ],
      'isActive': true,
    },
    {
      'symbol': 'ETH',
      'name': 'Ethereum',
      'price': 0.0,
      'thresholds': [
        {'threshold': 4000.0, 'label': '4K Alert', 'isActive': true, 'type': 'support'},
        {'threshold': 5000.0, 'label': '5K Alert', 'isActive': false, 'type': 'resistance'},
      ],
      'isActive': true,
    },
    {
      'symbol': 'SOL',
      'name': 'Solana',
      'price': 0.0,
      'thresholds': [
        {'threshold': 200.0, 'label': '200 Alert', 'isActive': true, 'type': 'support'},
        {'threshold': 250.0, 'label': '250 Alert', 'isActive': false, 'type': 'resistance'},
      ],
      'isActive': true,
    },
  ];

  static Future<void> initialize() async {
    try {
      await _loadTrackedCoins();
      
      if (_trackedCoins.isEmpty) {
        await _setDefaultCoins();
      }

      final shouldResumeMonitoring = await isMonitoringEnabled();
      if (shouldResumeMonitoring && !_isRunning) {
        await startMonitoring();
      }
      
      print('PriceMonitoringService initialized with ${_trackedCoins.length} coins');
    } catch (e) {
      print('PriceMonitoringService initialization error: $e');
      await _setDefaultCoins();
    }
  }

  static Future<void> _loadTrackedCoins() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String? coinsJson = prefs.getString('tracked_coins');
      
      if (coinsJson != null && coinsJson.isNotEmpty) {
        final List<dynamic> coinsList = json.decode(coinsJson);
        _trackedCoins = coinsList.map((coin) => CoinData.fromJson(coin)).toList();
      } else {
        _trackedCoins = [];
      }
    } catch (e) {
      print('Coin verileri yüklenemedi: $e');
      _trackedCoins = [];
    }
  }

  static Future<void> _setDefaultCoins() async {
    _trackedCoins = _defaultCoins.map((coin) => CoinData(
      symbol: coin['symbol'],
      name: coin['name'],
      price: 0.0,
      thresholds: (coin['thresholds'] as List).map((t) => ThresholdAlert(
        threshold: t['threshold'],
        label: t['label'],
        isActive: t['isActive'],
        type: t['type'] == 'resistance' ? ThresholdType.resistance : ThresholdType.support,
      )).toList(),
      isActive: coin['isActive'],
    )).toList();
    
    await _saveTrackedCoins();
  }

  static Future<void> _saveTrackedCoins() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String coinsJson = json.encode(_trackedCoins.map((coin) => coin.toJson()).toList());
      await prefs.setString('tracked_coins', coinsJson);
      print('Coin verileri kaydedildi: ${_trackedCoins.length} coin');
    } catch (e) {
      print('Coin verileri kaydedilemedi: $e');
    }
  }

  static Future<void> startMonitoring() async {
    if (_isRunning) return;
    
    _isRunning = true;
    await _setMonitoringEnabled(true);
    print('Fiyat takibi başlatıldı...');
    
    await NotificationService.showServiceNotification(
      title: 'Kripto Takip',
      body: 'Kripto fiyat takibi başlatıldı',
    );

    // İlk kontrolü hemen yap
    await _checkPrices();
    
    // 1 saniyede bir kontrol et
    _timer = Timer.periodic(Duration(seconds: 1), (timer) async {
      await _checkPrices();
    });
  }

  static Future<void> stopMonitoring() async {
    _isRunning = false;
    _timer?.cancel();
    _timer = null;
    await _setMonitoringEnabled(false);
    print('Fiyat takibi durduruldu');
    
    await NotificationService.showServiceNotification(
      title: 'Kripto Takip',
      body: 'Kripto fiyat takibi durduruldu',
    );
  }

  static bool get isRunning => _isRunning;

  static Future<void> _setMonitoringEnabled(bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_monitoringEnabledKey, enabled);
  }

  static Future<bool> isMonitoringEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_monitoringEnabledKey) ?? false;
  }

  static Future<void> _checkPrices() async {
    if (!_isRunning) return;
    
    print('Fiyat kontrolü yapılıyor...');
    
    try {
      // Aktif coinlerin listesini al
      final activeCoinSymbols = _trackedCoins
          .where((coin) => coin.isActive)
          .map((coin) => coin.symbol)
          .toList();

      if (activeCoinSymbols.isEmpty) {
        print('Takip edilen aktif coin yok');
        return;
      }

      // Tüm coinlerin fiyatlarını al
      final prices = await BinanceAPI.getMultipleCoinPrices(activeCoinSymbols);
      
      // Her coin için kontrol
      for (CoinData coin in _trackedCoins.where((c) => c.isActive)) {
        try {
          final double currentPrice = prices[coin.symbol] ?? 0.0;
          
          if (currentPrice <= 0) {
            print('${coin.symbol} için geçersiz fiyat alındı');
            continue;
          }

          // Coin fiyatını güncelle
          final coinIndex = _trackedCoins.indexWhere((c) => c.symbol == coin.symbol);
          if (coinIndex != -1) {
            _trackedCoins[coinIndex] = CoinData(
              symbol: coin.symbol,
              name: coin.name,
              price: currentPrice,
              thresholds: coin.thresholds,
              isActive: coin.isActive,
            );
          }

          print('${coin.symbol}: \$${currentPrice.toStringAsFixed(2)}');

          // Her threshold için kontrol
          for (ThresholdAlert threshold in coin.thresholds.where((t) => t.isActive)) {
            bool shouldAlert = false;
            
            // Direnç/Destek tipine göre kontrol
            if (threshold.type == ThresholdType.resistance) {
              // Direnç: Fiyat threshold'un üstüne çıktığında bildirim
              shouldAlert = currentPrice >= threshold.threshold;
            } else {
              // Destek: Fiyat threshold'un altına düştüğünde bildirim
              shouldAlert = currentPrice <= threshold.threshold;
            }
            
            if (shouldAlert) {
              await _sendPriceAlert(coin.symbol, coin.name, currentPrice, threshold.threshold, threshold.label, threshold.type);
            }
          }

          // Rate limit için kısa bekleme
          await Future.delayed(Duration(milliseconds: 100));
          
        } catch (e) {
          print('${coin.symbol} fiyatı alınamadı: $e');
        }
      }

      // Güncellenmiş verileri kaydet
      await _saveTrackedCoins();
      
    } catch (e) {
      print('Fiyat kontrol hatası: $e');
    }
  }

  static Future<void> _sendPriceAlert(String symbol, String name, double currentPrice, double threshold, String label, ThresholdType type) async {
    // Spam önlemek için aynı coin+threshold için 5 dakikada bir bildirim gönder
    final String key = '${symbol}_${threshold}_${type.name}';
    final DateTime now = DateTime.now();
    
    if (_lastNotificationTime.containsKey(key)) {
      final DateTime lastTime = _lastNotificationTime[key]!;
      if (now.difference(lastTime).inMinutes < 5) {
        return; // Çok yakın zamanda bildirim gönderilmiş
      }
    }

    _lastNotificationTime[key] = now;
    
    final String typeText = type == ThresholdType.resistance ? 'direnci' : 'desteği';
    final String priceDirection = type == ThresholdType.resistance ? 'üstüne çıktı' : 'altına düştü';
    
    await NotificationService.showPriceAlert(
      coinSymbol: symbol,
      coinName: name,
      currentPrice: currentPrice,
      threshold: threshold,
    );
    
    print('📢 $name için $label uyarı bildirimi gönderildi! ($typeText \$$threshold)');
  }

  static List<CoinData> getTrackedCoins() {
    return List.from(_trackedCoins);
  }

  static Future<void> updateCoinThreshold(String symbol, double newThreshold) async {
    final coinIndex = _trackedCoins.indexWhere((coin) => coin.symbol == symbol);
    if (coinIndex != -1) {
      final coin = _trackedCoins[coinIndex];
      List<ThresholdAlert> updatedThresholds = List.from(coin.thresholds);
      
      if (updatedThresholds.isNotEmpty) {
        updatedThresholds[0] = ThresholdAlert(
          threshold: newThreshold,
          label: updatedThresholds[0].label,
          isActive: updatedThresholds[0].isActive,
          type: updatedThresholds[0].type,
        );
      }

      _trackedCoins[coinIndex] = CoinData(
        symbol: coin.symbol,
        name: coin.name,
        price: coin.price,
        thresholds: updatedThresholds,
        isActive: coin.isActive,
      );
      
      await _saveTrackedCoins();
    }
  }

  static Future<void> addThresholdToCoin(String symbol, double threshold, String label, ThresholdType type) async {
    final coinIndex = _trackedCoins.indexWhere((coin) => coin.symbol == symbol);
    if (coinIndex != -1) {
      final coin = _trackedCoins[coinIndex];
      List<ThresholdAlert> updatedThresholds = List.from(coin.thresholds);
      
      updatedThresholds.add(ThresholdAlert(
        threshold: threshold,
        label: label,
        isActive: true,
        type: type,
      ));

      _trackedCoins[coinIndex] = CoinData(
        symbol: coin.symbol,
        name: coin.name,
        price: coin.price,
        thresholds: updatedThresholds,
        isActive: coin.isActive,
      );
      
      await _saveTrackedCoins();
    }
  }

  static Future<void> toggleThreshold(String symbol, int thresholdIndex) async {
    final coinIndex = _trackedCoins.indexWhere((coin) => coin.symbol == symbol);
    if (coinIndex != -1 && thresholdIndex < _trackedCoins[coinIndex].thresholds.length) {
      final coin = _trackedCoins[coinIndex];
      List<ThresholdAlert> updatedThresholds = List.from(coin.thresholds);
      
      final oldThreshold = updatedThresholds[thresholdIndex];
      updatedThresholds[thresholdIndex] = ThresholdAlert(
        threshold: oldThreshold.threshold,
        label: oldThreshold.label,
        isActive: !oldThreshold.isActive,
        type: oldThreshold.type,
      );

      _trackedCoins[coinIndex] = CoinData(
        symbol: coin.symbol,
        name: coin.name,
        price: coin.price,
        thresholds: updatedThresholds,
        isActive: coin.isActive,
      );
      
      await _saveTrackedCoins();
    }
  }

  static Future<void> removeThreshold(String symbol, int thresholdIndex) async {
    final coinIndex = _trackedCoins.indexWhere((coin) => coin.symbol == symbol);
    if (coinIndex != -1 && thresholdIndex < _trackedCoins[coinIndex].thresholds.length) {
      final coin = _trackedCoins[coinIndex];
      List<ThresholdAlert> updatedThresholds = List.from(coin.thresholds);
      
      if (updatedThresholds.length > 1) { // En az bir threshold kalmalı
        updatedThresholds.removeAt(thresholdIndex);

        _trackedCoins[coinIndex] = CoinData(
          symbol: coin.symbol,
          name: coin.name,
          price: coin.price,
          thresholds: updatedThresholds,
          isActive: coin.isActive,
        );
        
        await _saveTrackedCoins();
      }
    }
  }

  static Future<void> addNewCoin(String symbol, String name) async {
    // Zaten var mı kontrol et
    final exists = _trackedCoins.any((coin) => coin.symbol.toLowerCase() == symbol.toLowerCase());
    if (exists) {
      throw Exception('Bu coin zaten takip ediliyor');
    }

    // Yeni coin ekle
    final newCoin = CoinData(
      symbol: symbol.toUpperCase(),
      name: name,
      price: 0.0,
      thresholds: [
        ThresholdAlert(
          threshold: 0.0,
          label: 'Ana Hedef',
          isActive: false,
          type: ThresholdType.support,
        )
      ],
      isActive: true,
    );

    _trackedCoins.add(newCoin);
    await _saveTrackedCoins();
  }

  static Future<void> removeCoin(String symbol) async {
    _trackedCoins.removeWhere((coin) => coin.symbol == symbol);
    await _saveTrackedCoins();
  }
}
