import 'package:flutter/material.dart';

class AppLocalizations {
  // Turkish translations
  static const Map<String, String> tr = {
    'app_title': 'Feature-First Architecture',
    'sales': 'Satışlar',
    'home': 'Ana Sayfa',
    'loading': 'Yükleniyor...',
    'error': 'Hata',
    'retry': 'Tekrar Dene',
    'add_sale': 'Satış Ekle',
    'customer_name': 'Müşteri Adı',
    'product_name': 'Ürün Adı',
    'amount': 'Tutar',
    'date': 'Tarih',
    'save': 'Kaydet',
    'cancel': 'İptal',
    'delete': 'Sil',
    'edit': 'Düzenle',
    'search': 'Ara',
    'no_data': 'Veri bulunamadı',
    'success': 'Başarılı',
    'failed': 'Başarısız',
    'configuration': 'Yapılandırma',
    'environment': 'Ortam',
    'debug_mode': 'Hata Ayıklama Modu',
    'api_base': 'API Temel URL',
    'app_version': 'Uygulama Sürümü',
    'view_sales': 'Satışları Görüntüle',
    'filled': 'Dolu',
    'outlined': 'Çerçeveli',
    'text': 'Metin',
  };

  // English translations
  static const Map<String, String> en = {
    'app_title': 'Feature-First Architecture',
    'sales': 'Sales',
    'home': 'Home',
    'loading': 'Loading...',
    'error': 'Error',
    'retry': 'Retry',
    'add_sale': 'Add Sale',
    'customer_name': 'Customer Name',
    'product_name': 'Product Name',
    'amount': 'Amount',
    'date': 'Date',
    'save': 'Save',
    'cancel': 'Cancel',
    'delete': 'Delete',
    'edit': 'Edit',
    'search': 'Search',
    'no_data': 'No data found',
    'success': 'Success',
    'failed': 'Failed',
    'configuration': 'Configuration',
    'environment': 'Environment',
    'debug_mode': 'Debug Mode',
    'api_base': 'API Base URL',
    'app_version': 'App Version',
    'view_sales': 'View Sales',
    'filled': 'Filled',
    'outlined': 'Outlined',
    'text': 'Text',
  };

  static String getString(BuildContext context, String key) {
    final locale = Localizations.localeOf(context);
    final translations = locale.languageCode == 'tr' ? tr : en;
    return translations[key] ?? key;
  }

  // Helper methods for common translations
  static String appTitle(BuildContext context) =>
      getString(context, 'app_title');
  static String sales(BuildContext context) => getString(context, 'sales');
  static String home(BuildContext context) => getString(context, 'home');
  static String loading(BuildContext context) => getString(context, 'loading');
  static String error(BuildContext context) => getString(context, 'error');
  static String retry(BuildContext context) => getString(context, 'retry');
  static String configuration(BuildContext context) =>
      getString(context, 'configuration');
  static String environment(BuildContext context) =>
      getString(context, 'environment');
  static String debugMode(BuildContext context) =>
      getString(context, 'debug_mode');
  static String apiBase(BuildContext context) => getString(context, 'api_base');
  static String appVersion(BuildContext context) =>
      getString(context, 'app_version');
  static String viewSales(BuildContext context) =>
      getString(context, 'view_sales');
}
