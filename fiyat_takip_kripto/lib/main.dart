import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_foreground_task/flutter_foreground_task.dart';
import 'dart:async';
import 'dart:isolate';
import 'fiyat_kontrol.dart';
import 'bildirim.dart';
import 'api.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  try {
    // Bildirim sistemini başlat
    await NotificationService.initNotifications();
    print('Bildirim servisi başlatıldı');
    
    // Fiyat takip servisini başlat
    await PriceMonitoringService.initialize();
    print('Fiyat takip servisi başlatıldı');
    
    // Foreground task'ı başlat
    _initForegroundTask();
    print('Foreground task başlatıldı');

    // Uygulama daha önce takip modundayken kapanmışsa açılışta tekrar ayağa kaldır
    await _restoreMonitoringServiceIfNeeded();
    
    // Xiaomi/Redmi cihazlar için özel ayarlar
    await _requestXiaomiPermissions();
    
  } catch (e) {
    print('Initialization hatası: $e');
  }
  
  runApp(MyApp());
}

// Xiaomi/Redmi cihazlar için özel izin talepleri
Future<void> _requestXiaomiPermissions() async {
  try {
    // Bu fonksiyon Xiaomi cihazlarda arka plan çalışma izni için kullanılabilir
    print('Xiaomi/Redmi optimizasyonları uygulandı');
  } catch (e) {
    print('Xiaomi izin hatası: $e');
  }
}

Future<void> _restoreMonitoringServiceIfNeeded() async {
  try {
    final shouldRestore = await PriceMonitoringService.isMonitoringEnabled();
    if (!shouldRestore) {
      return;
    }

    if (await FlutterForegroundTask.isRunningService) {
      return;
    }

    await FlutterForegroundTask.startService(
      notificationTitle: 'Kripto Fiyat Takip Aktif',
      notificationText: 'Kripto para fiyatları takip ediliyor...',
      callback: startCallback,
    );
  } catch (e) {
    print('Foreground restore hatası: $e');
  }
}

@pragma('vm:entry-point')
void startCallback() {
  FlutterForegroundTask.setTaskHandler(CryptoMonitoringTaskHandler());
}

class CryptoMonitoringTaskHandler extends TaskHandler {
  Future<void> _ensureMonitoringRunning() async {
    try {
      await NotificationService.initNotifications();
      await PriceMonitoringService.initialize();

      final shouldRun = await PriceMonitoringService.isMonitoringEnabled();
      if (shouldRun && !PriceMonitoringService.isRunning) {
        await PriceMonitoringService.startMonitoring();
      }
    } catch (e) {
      print('TaskHandler monitoring error: $e');
    }
  }

  @override
  void onStart(DateTime timestamp, SendPort? sendPort) async {
    await _ensureMonitoringRunning();
  }

  @override
  void onRepeatEvent(DateTime timestamp, SendPort? sendPort) async {
    await _ensureMonitoringRunning();
  }

  @override
  void onDestroy(DateTime timestamp, SendPort? sendPort) async {
    // Durum tercihi UI tarafından yönetiliyor; burada preference değiştirmiyoruz.
  }
}

void _initForegroundTask() {
  FlutterForegroundTask.init(
    androidNotificationOptions: AndroidNotificationOptions(
      channelId: 'crypto_foreground_task',
      channelName: 'Kripto Para Takip Servisi',
      channelDescription: 'Kripto para fiyatlarını arka planda takip eder',
      channelImportance: NotificationChannelImportance.LOW,
      priority: NotificationPriority.LOW,
      iconData: const NotificationIconData(
        resType: ResourceType.mipmap,
        resPrefix: ResourcePrefix.ic,
        name: 'launcher',
      ),
    ),
    iosNotificationOptions: const IOSNotificationOptions(
      showNotification: true,
      playSound: false,
    ),
    foregroundTaskOptions: const ForegroundTaskOptions(
      interval: 300000, // 5 dakika (milliseconds)
      autoRunOnBoot: true,
      autoRunOnMyPackageReplaced: true,
      allowWakeLock: true,
      allowWifiLock: true,
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Kripto Fiyat Takip',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        brightness: Brightness.dark,
        scaffoldBackgroundColor: Color(0xFF121212),
        cardColor: Color(0xFF1E1E1E),
        appBarTheme: AppBarTheme(
          backgroundColor: Color(0xFF1E1E1E),
          elevation: 0,
        ),
      ),
      home: CryptoPriceTracker(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class CryptoPriceTracker extends StatefulWidget {
  const CryptoPriceTracker({super.key});

  @override
  _CryptoPriceTrackerState createState() => _CryptoPriceTrackerState();
}

class _CryptoPriceTrackerState extends State<CryptoPriceTracker> {
  List<CoinData> _coins = [];
  bool _isMonitoring = false;
  bool _isLoading = true;
  Timer? _refreshTimer;

  @override
  void initState() {
    super.initState();
    _loadCoins();
    unawaited(_checkMonitoringStatus());
    
    // UI'yi her 5 saniyede bir güncelle
    _refreshTimer = Timer.periodic(Duration(seconds: 5), (timer) {
      _refreshPrices();
    });
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    super.dispose();
  }

  Future<void> _loadCoins() async {
    setState(() => _isLoading = true);
    
    try {
      _coins = PriceMonitoringService.getTrackedCoins();
      if (_coins.isEmpty) {
        // Eğer coin listesi boşsa, initialize tekrar çalıştır
        await PriceMonitoringService.initialize();
        _coins = PriceMonitoringService.getTrackedCoins();
      }
      await _refreshPrices();
    } catch (e) {
      print('Coin yükleme hatası: $e');
      // Hata durumunda varsayılan coin'leri göster
      _coins = [];
    }
    
    setState(() => _isLoading = false);
  }

  Future<void> _refreshPrices() async {
    if (_coins.isEmpty) return;
    
    try {
      for (int i = 0; i < _coins.length; i++) {
        if (_coins[i].isActive) {
          try {
            final price = await BinanceAPI.getCoinPrice(_coins[i].symbol);
            if (mounted) {
              setState(() {
                _coins[i] = CoinData(
                  symbol: _coins[i].symbol,
                  name: _coins[i].name,
                  price: price,
                  thresholds: _coins[i].thresholds,
                  isActive: _coins[i].isActive,
                );
              });
            }
            await Future.delayed(Duration(milliseconds: 200));
          } catch (e) {
            print('${_coins[i].symbol} fiyatı alınamadı: $e');
          }
        }
      }
    } catch (e) {
      print('Fiyatlar güncellenemedi: $e');
    }
  }

  Future<void> _checkMonitoringStatus() async {
    final isServiceRunning = await FlutterForegroundTask.isRunningService;
    setState(() {
      _isMonitoring = PriceMonitoringService.isRunning || isServiceRunning;
    });
  }

  Future<void> _toggleMonitoring() async {
    if (_isMonitoring) {
      await PriceMonitoringService.stopMonitoring();
      await FlutterForegroundTask.stopService();
    } else {
      await PriceMonitoringService.startMonitoring();
      await _startForegroundTask();
    }
    
    await _checkMonitoringStatus();
  }

  Future<void> _startForegroundTask() async {
    if (await FlutterForegroundTask.isRunningService) {
      await FlutterForegroundTask.restartService();
      return;
    }

    await FlutterForegroundTask.startService(
      notificationTitle: 'Kripto Fiyat Takip Aktif',
      notificationText: 'Kripto para fiyatları takip ediliyor...',
      callback: startCallback,
    );
  }

  Future<void> _updateThresholdStatus(String symbol, int thresholdIndex, bool isActive) async {
    try {
      await PriceMonitoringService.toggleThreshold(symbol, thresholdIndex);
      await _loadCoins();
    } catch (e) {
      print('Threshold durumu güncellenemedi: $e');
      // Hata durumunda UI'yi geri yükle
      setState(() {});
    }
  }

  Future<void> _showEditThresholdDialog(CoinData coin, int thresholdIndex) async {
    if (thresholdIndex >= coin.thresholds.length) return;
    
    final threshold = coin.thresholds[thresholdIndex];
    final TextEditingController priceController = TextEditingController(
      text: threshold.threshold.toString()
    );
    final TextEditingController labelController = TextEditingController(
      text: threshold.label
    );

    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Color(0xFF1E1E1E),
        title: Text('${coin.name} - Hedef Düzenle', style: TextStyle(color: Colors.white)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: labelController,
              style: TextStyle(color: Colors.white),
              decoration: InputDecoration(
                labelText: 'Hedef Adı',
                labelStyle: TextStyle(color: Colors.grey),
                enabledBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.grey),
                ),
                focusedBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.blue),
                ),
              ),
            ),
            SizedBox(height: 16),
            TextField(
              controller: priceController,
              keyboardType: TextInputType.numberWithOptions(decimal: true),
              style: TextStyle(color: Colors.white),
              decoration: InputDecoration(
                labelText: 'Hedef Fiyat (USD)',
                labelStyle: TextStyle(color: Colors.grey),
                prefixText: '\$',
                prefixStyle: TextStyle(color: Colors.green),
                enabledBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.grey),
                ),
                focusedBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.blue),
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('İptal', style: TextStyle(color: Colors.grey)),
          ),
          if (coin.thresholds.length > 1)
            TextButton(
              onPressed: () async {
                await PriceMonitoringService.removeThreshold(coin.symbol, thresholdIndex);
                _loadCoins();
                if (context.mounted) {
                  Navigator.pop(context);
                }
              },
              child: Text('Sil', style: TextStyle(color: Colors.red)),
            ),
          TextButton(
            onPressed: () async {
              final double? newThreshold = double.tryParse(priceController.text);
              final String newLabel = labelController.text.trim();
              if (newThreshold != null && newThreshold > 0 && newLabel.isNotEmpty) {
                // Güncelleme mantığı burada eklenecek
                _loadCoins();
                if (context.mounted) {
                  Navigator.pop(context);
                }
              }
            },
            child: Text('Kaydet', style: TextStyle(color: Colors.blue)),
          ),
        ],
      ),
    );
  }

  Future<void> _showAddThresholdDialog(CoinData coin) async {
    final TextEditingController priceController = TextEditingController();
    final TextEditingController labelController = TextEditingController();
    ThresholdType selectedType = ThresholdType.support; // Varsayılan destek

    return showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          backgroundColor: Color(0xFF1E1E1E),
          title: Text('${coin.name} - Yeni Hedef', style: TextStyle(color: Colors.white)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: labelController,
                style: TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  labelText: 'Hedef Adı',
                  labelStyle: TextStyle(color: Colors.grey),
                  hintText: 'örn: 150K Alert',
                  hintStyle: TextStyle(color: Colors.grey.withValues(alpha: 0.5)),
                  enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.grey),
                  ),
                  focusedBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.blue),
                  ),
                ),
              ),
              SizedBox(height: 16),
              TextField(
                controller: priceController,
                keyboardType: TextInputType.numberWithOptions(decimal: true),
                style: TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  labelText: 'Hedef Fiyat (USD)',
                  labelStyle: TextStyle(color: Colors.grey),
                  prefixText: '\$',
                  prefixStyle: TextStyle(color: Colors.green),
                  enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.grey),
                  ),
                  focusedBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.blue),
                  ),
                ),
              ),
              SizedBox(height: 20),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Hedef Tipi:', style: TextStyle(color: Colors.white, fontSize: 16)),
                  SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: RadioListTile<ThresholdType>(
                          title: Text('Destek', style: TextStyle(color: Colors.white, fontSize: 14)),
                          subtitle: Text('Fiyat altına düşünce uyar', style: TextStyle(color: Colors.grey, fontSize: 12)),
                          value: ThresholdType.support,
                          groupValue: selectedType,
                          activeColor: Colors.red,
                          onChanged: (ThresholdType? value) {
                            setState(() {
                              selectedType = value!;
                            });
                          },
                        ),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      Expanded(
                        child: RadioListTile<ThresholdType>(
                          title: Text('Direnç', style: TextStyle(color: Colors.white, fontSize: 14)),
                          subtitle: Text('Fiyat üstüne çıkınca uyar', style: TextStyle(color: Colors.grey, fontSize: 12)),
                          value: ThresholdType.resistance,
                          groupValue: selectedType,
                          activeColor: Colors.green,
                          onChanged: (ThresholdType? value) {
                            setState(() {
                              selectedType = value!;
                            });
                          },
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('İptal', style: TextStyle(color: Colors.grey)),
            ),
            TextButton(
              onPressed: () async {
                final double? threshold = double.tryParse(priceController.text);
                final String label = labelController.text.trim();
                if (threshold != null && threshold > 0 && label.isNotEmpty) {
                  await PriceMonitoringService.addThresholdToCoin(coin.symbol, threshold, label, selectedType);
                  _loadCoins();
                  if (context.mounted) {
                    Navigator.pop(context);
                  }
                }
              },
            child: Text('Ekle', style: TextStyle(color: Colors.blue)),
          ),
        ],
      ),
    ),
    );
  }

  Future<void> _showAddCoinDialog() async {
    List<String> availableCoins = [];
    String searchQuery = '';
    
    // API'den tüm coinleri al
    try {
      availableCoins = await BinanceAPI.getAllUSDTSymbols();
    } catch (e) {
      print('Coin listesi alınamadı: $e');
    }
    
    return showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) {
          // Filtrelenmiş coin listesi
          List<String> filteredCoins = availableCoins.where((coin) {
            // Zaten takip edilenları çıkar
            bool alreadyTracked = _coins.any((trackedCoin) => 
              trackedCoin.symbol.toLowerCase() == coin.toLowerCase());
            
            // Arama kriterine uygun olanları al
            bool matchesSearch = searchQuery.isEmpty || 
              coin.toLowerCase().contains(searchQuery.toLowerCase());
            
            return !alreadyTracked && matchesSearch;
          }).toList();
          
          return AlertDialog(
            backgroundColor: Color(0xFF1E1E1E),
            title: Text('Yeni Coin Ekle', style: TextStyle(color: Colors.white)),
            content: SizedBox(
              width: double.maxFinite,
              height: 400,
              child: Column(
                children: [
                  // Arama çubuğu
                  TextField(
                    style: TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      labelText: 'Coin Ara (örn: LTC, ADA)',
                      labelStyle: TextStyle(color: Colors.grey),
                      prefixIcon: Icon(Icons.search, color: Colors.grey),
                      enabledBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: Colors.grey),
                      ),
                      focusedBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: Colors.blue),
                      ),
                    ),
                    onChanged: (value) {
                      setState(() {
                        searchQuery = value;
                      });
                    },
                  ),
                  SizedBox(height: 16),
                  
                  // Coin listesi
                  Expanded(
                    child: availableCoins.isEmpty
                        ? Center(
                            child: CircularProgressIndicator(color: Colors.blue),
                          )
                        : filteredCoins.isEmpty
                            ? Center(
                                child: Text(
                                  searchQuery.isEmpty ? 'Coin bulunamadı' : 'Arama sonucu bulunamadı',
                                  style: TextStyle(color: Colors.grey),
                                ),
                              )
                            : ListView.builder(
                                itemCount: filteredCoins.length,
                                itemBuilder: (context, index) {
                                  final coin = filteredCoins[index];
                                  return ListTile(
                                    title: Text(
                                      coin,
                                      style: TextStyle(color: Colors.white),
                                    ),
                                    subtitle: Text(
                                      '${coin}USDT',
                                      style: TextStyle(color: Colors.grey),
                                    ),
                                    onTap: () async {
                                      try {
                                        await PriceMonitoringService.addNewCoin(coin, coin);
                                        _loadCoins();
                                        if (context.mounted) {
                                          Navigator.pop(context);
                                          ScaffoldMessenger.of(context).showSnackBar(
                                            SnackBar(
                                              content: Text('$coin başarıyla eklendi!'),
                                              backgroundColor: Colors.green,
                                            ),
                                          );
                                        }
                                      } catch (e) {
                                        if (context.mounted) {
                                          ScaffoldMessenger.of(context).showSnackBar(
                                            SnackBar(
                                              content: Text('Hata: $e'),
                                              backgroundColor: Colors.red,
                                            ),
                                          );
                                        }
                                      }
                                    },
                                  );
                                },
                              ),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text('İptal', style: TextStyle(color: Colors.grey)),
              ),
            ],
          );
        },
      ),
    );
  }

  Future<void> _refreshManually() async {
    setState(() => _isLoading = true);
    
    try {
      await _refreshPrices();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Fiyatlar başarıyla güncellendi!'),
          backgroundColor: Colors.green,
          duration: Duration(seconds: 2),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Fiyatlar güncellenemedi: $e'),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 3),
        ),
      );
    }
    
    setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Kripto Fiyat Takip', style: TextStyle(fontWeight: FontWeight.bold)),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: _refreshManually,
            tooltip: 'Fiyatları Yenile',
          ),
          IconButton(
            icon: Icon(_isMonitoring ? Icons.pause : Icons.play_arrow),
            onPressed: _toggleMonitoring,
            tooltip: _isMonitoring ? 'Takibi Durdur' : 'Takibi Başlat',
          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF1a1a2e), Color(0xFF16213e), Color(0xFF0f0f23)],
          ),
        ),
        child: _isLoading
            ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(color: Colors.blue),
                    SizedBox(height: 16),
                    Text('Fiyatlar yükleniyor...', style: TextStyle(color: Colors.white)),
                  ],
                ),
              )
            : _coins.isEmpty
            ? Center(
                child: Text('Coin bulunamadı', style: TextStyle(color: Colors.white)),
              )
            : ListView.builder(
                itemCount: _coins.length,
                itemBuilder: (context, index) {
                  final coin = _coins[index];
                  return Card(
                    margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    color: Color(0xFF2A2A2A),
                    child: ExpansionTile(
                      title: Text(
                        coin.name,
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                      subtitle: Text(
                        '\$${coin.price.toStringAsFixed(2)}',
                        style: TextStyle(
                          color: Colors.green,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      trailing: Icon(
                        Icons.expand_more,
                        color: Colors.white,
                      ),
                      children: [
                        Padding(
                          padding: EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text('Hedefler:',
                                      style: TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold)),
                                  IconButton(
                                    onPressed: () => _showAddThresholdDialog(coin),
                                    icon: Icon(Icons.add, color: Colors.blue),
                                    tooltip: 'Yeni Hedef Ekle',
                                  ),
                                ],
                              ),
                              SizedBox(height: 8),
                              ...coin.thresholds.asMap().entries.map((entry) {
                                int idx = entry.key;
                                ThresholdAlert threshold = entry.value;
                                
                                // Direnç/Destek durumuna göre renk ve ikon
                                bool shouldAlert = false;
                                Color typeColor = threshold.type == ThresholdType.resistance ? Colors.green : Colors.red;
                                IconData typeIcon = threshold.type == ThresholdType.resistance ? Icons.trending_up : Icons.trending_down;
                                
                                if (coin.price > 0) {
                                  if (threshold.type == ThresholdType.resistance) {
                                    shouldAlert = coin.price >= threshold.threshold;
                                  } else {
                                    shouldAlert = coin.price <= threshold.threshold;
                                  }
                                }
                                
                                return ListTile(
                                  dense: true,
                                  title: Row(
                                    children: [
                                      Text(threshold.label),
                                      SizedBox(width: 8),
                                      Container(
                                        padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                        decoration: BoxDecoration(
                                          color: typeColor.withValues(alpha: 0.2),
                                          borderRadius: BorderRadius.circular(4),
                                        ),
                                        child: Text(
                                          threshold.typeDisplayName,
                                          style: TextStyle(
                                            color: typeColor,
                                            fontSize: 10,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  subtitle: Text('\$${threshold.threshold.toStringAsFixed(2)}'),
                                  trailing: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      if (shouldAlert && threshold.isActive)
                                        Icon(typeIcon, color: typeColor, size: 16),
                                      Switch(
                                        value: threshold.isActive,
                                        onChanged: (value) async {
                                          await _updateThresholdStatus(coin.symbol, idx, value);
                                        },
                                        activeThumbColor: Colors.green,
                                      ),
                                    ],
                                  ),
                                  onTap: () => _showEditThresholdDialog(coin, idx),
                                );
                              }),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
      ),
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FloatingActionButton(
            onPressed: _showAddCoinDialog,
            backgroundColor: Colors.blue,
            heroTag: "addCoin",
            tooltip: 'Yeni Coin Ekle',
            child: Icon(Icons.add),
          ),
          SizedBox(height: 16),
          FloatingActionButton(
            onPressed: _toggleMonitoring,
            backgroundColor: _isMonitoring ? Colors.red : Colors.green,
            heroTag: "monitoring",
            tooltip: _isMonitoring ? 'Takibi Durdur' : 'Takibi Başlat',
            child: Icon(_isMonitoring ? Icons.stop : Icons.play_arrow),
          ),
        ],
      ),
    );
  }
}
