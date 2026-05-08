import 'dart:io';
import 'package:fiyat_takip_kripto/api.dart';

void main() async {
  print('=== API Test Başlatılıyor ===');
  
  try {
    // BTC fiyatını test et
    print('BTC fiyatı alınıyor...');
    double btcPrice = await BinanceAPI.getCoinPrice('BTC');
    print('BTC Fiyatı: \$${btcPrice.toStringAsFixed(2)}');
    
    // ETH fiyatını test et
    print('ETH fiyatı alınıyor...');
    double ethPrice = await BinanceAPI.getCoinPrice('ETH');
    print('ETH Fiyatı: \$${ethPrice.toStringAsFixed(2)}');
    
    // Tüm coin listesini test et
    print('Tüm coin listesi alınıyor...');
    List<String> allCoins = await BinanceAPI.getAllUSDTSymbols();
    print('Toplam ${allCoins.length} coin bulundu');
    print('İlk 10 coin: ${allCoins.take(10).join(', ')}');
    
    // ThresholdAlert test et
    print('ThresholdAlert testi...');
    ThresholdAlert supportAlert = ThresholdAlert(
      threshold: 100000.0,
      label: 'Test Support',
      isActive: true,
      type: ThresholdType.support,
    );
    
    ThresholdAlert resistanceAlert = ThresholdAlert(
      threshold: 120000.0,
      label: 'Test Resistance',
      isActive: true,
      type: ThresholdType.resistance,
    );
    
    print('Destek Hedefi: ${supportAlert.typeDisplayName} - \$${supportAlert.threshold}');
    print('Direnç Hedefi: ${resistanceAlert.typeDisplayName} - \$${resistanceAlert.threshold}');
    
    print('=== Tüm Testler Başarılı! ===');
    
  } catch (e) {
    print('Test Hatası: $e');
    exit(1);
  }
}
