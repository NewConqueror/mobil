# Ruh Hali Takibi ve Günlük Uygulaması 😊

Flutter ile geliştirilmiş, yerel veri saklamalı basit bir "Ruh Hali Takibi ve Günlük" uygulaması.

## 🌟 Özellikler

### Ana Fonksiyonlar
- **Günlük Ruh Hali Girişi**: 8 farklı ruh hali emojisi ile hislerinizi kaydedin
- **Kısa Günlük Yazısı**: Ruh halinizle birlikte notlarınızı ekleyin
- **Yerel Veri Saklama**: Tüm veriler cihazınızda güvenli şekilde saklanır
- **Geçmiş Kayıtları Görüntüleme**: Önceki ruh hali kayıtlarınızı tarih sırasına göre görün
- **Haftalık Analiz**: Bar chart ile en çok görülen ruh halinizi analiz edin
- **Günlük Bildirimler**: Her gün saat 13:00'te ruh hali girişi hatırlatması

### Ruh Hali Seçenekleri
- 😊 Mutlu
- 😢 Üzgün  
- 😠 Öfkeli
- 😌 Huzurlu
- 😴 Yorgun
- 🤩 Heyecanlı
- 😰 Endişeli
- 😐 Nötr

## 📱 Ekranlar

### 1. Ana Ekran (Home)
- Bugünkü ruh hali girişi durumu
- "Yeni Ruh Hali Girişi Yap" butonu
- "Geçmiş Kayıtlar" ve "Haftalık Analiz" hızlı erişim butonları
- Son kayıtların önizlemesi

### 2. Yeni Giriş Ekranı
- Interaktif ruh hali seçici (emoji'lerle)
- Kısa günlük yazısı alanı (500 karakter)
- Tarih seçici
- Kaydet/Güncelle butonu

### 3. Geçmiş Ekranı
- Tarih sırasına göre kayıt listesi
- Arama fonksionu (notlarda arama)
- Filtreleme (Bu hafta, Bu ay, Tüm kayıtlar)
- Kayıt düzenleme ve silme

### 4. Haftalık Analiz Ekranı
- Bar chart ile ruh hali dağılımı
- Detaylı istatistikler
- En sık hissedilen ruh hali
- İçgörüler ve öneriler

## 🛠 Teknik Özellikler

### Kullanılan Teknolojiler
- **Framework**: Flutter 3.32.6
- **State Management**: Provider
- **Veri Saklama**: SharedPreferences (yerel)
- **Bildirimler**: flutter_local_notifications
- **Grafikler**: fl_chart
- **Tarih İşlemleri**: intl
- **JSON Serialization**: json_annotation, json_serializable

### Mimari
```
lib/
├── main.dart                    # Ana uygulama giriş noktası
├── models/                      # Veri modelleri
│   ├── mood.dart               # Ruh hali enum'u
│   └── mood_entry.dart         # Ruh hali kaydı modeli
├── screens/                     # Ekranlar
│   ├── home_screen.dart        # Ana ekran
│   ├── add_entry_screen.dart   # Yeni kayıt ekleme/düzenleme
│   ├── history_screen.dart     # Geçmiş kayıtlar
│   └── analysis_screen.dart    # Haftalık analiz
├── widgets/                     # Özel widget'lar
│   ├── mood_selector.dart      # Ruh hali seçici
│   └── mood_entry_card.dart    # Ruh hali kayıt kartı
├── services/                    # Servisler
│   ├── storage_service.dart    # Veri saklama
│   ├── mood_provider.dart      # State management
│   └── notification_service.dart # Bildirim yönetimi
└── utils/                       # Yardımcı fonksiyonlar
    ├── mood_colors.dart        # Renkler ve tema
    └── date_extensions.dart    # Tarih uzantıları
```

## 🚀 Kurulum ve Çalıştırma

### Gereksinimler
- Flutter SDK 3.32.6 veya üzeri
- Dart SDK
- Android Studio / VS Code
- Android emülatör veya fiziksel cihaz

### Kurulum Adımları

1. **Repoyu klonlayın:**
```bash
git clone <repo-url>
cd daily_mood
```

2. **Bağımlılıkları yükleyin:**
```bash
flutter pub get
```

3. **JSON kod üretimi yapın:**
```bash
dart run build_runner build
```

4. **Uygulamayı çalıştırın:**
```bash
flutter run
```

### Platform Desteği
- ✅ Android
- ✅ iOS
- ✅ Web
- ✅ macOS
- ✅ Windows
- ✅ Linux

## 🎨 Tasarım Özellikleri

### UI/UX
- **Modern ve Minimalist**: Sade, pastel renk paleti
- **Kullanıcı Dostu**: Sezgisel navigasyon ve interaktif elementler
- **Erişilebilir**: Büyük dokunma alanları ve net tipografi
- **Responsive**: Farklı ekran boyutlarına uyum

### Renk Paleti
- **Mutlu**: Açık sarı (#FFE082)
- **Üzgün**: Açık mavi (#90CAF9)
- **Öfkeli**: Açık kırmızı (#EF9A9A)
- **Huzurlu**: Açık yeşil (#A5D6A7)
- **Yorgun**: Açık mor (#CE93D8)
- **Heyecanlı**: Açık turuncu (#FFAB91)
- **Endişeli**: Açık pembe (#F8BBD9)
- **Nötr**: Gri (#E0E0E0)

## 🔒 Gizlilik ve Güvenlik

- ✅ **Tamamen Offline**: İnternet bağlantısı gerektirmez
- ✅ **Yerel Veri Saklama**: Tüm veriler cihazınızda kalır
- ✅ **Veri Güvenliği**: Üçüncü parti servislere veri gönderilmez
- ✅ **Anonim Kullanım**: Hesap oluşturma veya giriş yapma gerektirmez

## 📊 Özellik Detayları

### Bildirim Sistemi
- Günlük saat 13:00'te otomatik hatırlatma
- Bildirim izni isteği
- Platform spesifik bildirim ayarları

### Veri Analizi
- Haftalık, aylık ve tüm zamanlar için analiz
- Ruh hali dağılım grafikleri
- İstatistiksel öngörüler
- En sık yaşanan duygu analizi

### Veri Yönetimi
- JSON formatında veri saklama
- Otomatik veri yedekleme (yerel)
- Veri silme ve temizleme seçenekleri
- Import/Export fonksiyonları (gelecek sürüm)

## 🔄 Gelecek Güncellemeler

- [ ] Veri export/import fonksiyonu
- [ ] Daha detaylı analiz raporları
- [ ] Özel ruh hali kategorileri
- [ ] Dark mode desteği
- [ ] Widget desteği (Android/iOS)
- [ ] Backup ve restore fonksiyonları

## 🤝 Katkıda Bulunma

1. Fork edin
2. Feature branch oluşturun (`git checkout -b feature/AmazingFeature`)
3. Değişikliklerinizi commit edin (`git commit -m 'Add some AmazingFeature'`)
4. Branch'i push edin (`git push origin feature/AmazingFeature`)
5. Pull Request oluşturun

## 📄 Lisans

Bu proje MIT lisansı altında lisanslanmıştır. Detaylar için `LICENSE` dosyasına bakın.

## 👨‍💻 Geliştirici

Bu uygulama Flutter ve modern mobil uygulama geliştirme best practice'leri kullanılarak geliştirilmiştir.

---

**Not**: Bu uygulama eğitim ve kişisel kullanım amaçlıdır. Profesyonel psikolojik destek almak için uzman desteği alın.
