export default {
  // Navigation & Tabs
  tabs: {
    orders: 'Siparişler',
    calendar: 'Kiralama Takvimi',
  },

  // Chips
  chips: {
    tailoring: 'Dikim',
    rental: 'Kiralama',
  },

  // Order Types
  orderType: {
    TAILORING: 'Dikim',
    RENTAL: 'Kiralama',
  },

  // Statuses
  status: {
    ACTIVE: 'Aktif',
    CANCELLED: 'İptal',
    COMPLETED: 'Tamamlandı',
  },

  // Employee Management
  employees: {
    title: 'Personel Yönetimi',
    list: 'Personel Listesi',
    card: 'Personel Kartı',
    add: 'Yeni Personel Ekle',
    edit: 'Personel Düzenle',
    delete: 'Personel Sil',
    
    // Employee Status
    status: {
      ACTIVE: 'Aktif',
      PASSIVE: 'Pasif',
      PROBATION: 'Deneme'
    },
    
    // Wage Types
    wageType: {
      FIXED: 'Sabit Maaş',
      HOURLY: 'Saatlik Ücret'
    },
    
    // Time Entry
    timeEntry: {
      title: 'Mesai Kayıtları',
      add: 'Mesai Ekle',
      addOvertime: 'Fazla Mesai Ekle',
      normal: 'Normal Mesai',
      overtime: 'Fazla Mesai',
      approved: 'Onaylı',
      pending: 'Beklemede',
      rejected: 'Reddedildi',
      approval: 'Mesai Onayları'
    },
    
    // Allowances
    allowance: {
      title: 'Yol/Yemek Kayıtları',
      add: 'Yol/Yemek Ekle',
      meal: 'Yemek',
      transport: 'Yol',
      other: 'Diğer'
    },
    
    // Payroll
    payroll: {
      title: 'Bordro Yönetimi',
      calculate: 'Haftalık Hesapla',
      preview: 'Bordro Önizlemesi',
      run: 'Bordro Çalıştır',
      lock: 'Kilitle',
      pay: 'Öde',
      bulkPay: 'Toplu Öde',
      draft: 'Taslak',
      posted: 'Kilitli',
      gross: 'Brüt Maaş',
      overtime: 'Fazla Mesai',
      allowances: 'Yol/Yemek',
      deductions: 'Kesintiler',
      net: 'Net Ödenecek'
    },
    
    // SGK
    sgk: {
      title: 'SGK Kayıtları',
      paid: 'Yatırıldı',
      unpaid: 'Yatırılmadı'
    },
    
    // Filters
    filters: {
      search: 'Arama',
      status: 'Durum',
      department: 'Departman',
      position: 'Pozisyon',
      sgkStatus: 'SGK Durumu',
      period: 'Dönem',
      week: 'Hafta',
      month: 'Ay',
      thisWeek: 'Bu Hafta',
      lastWeek: 'Geçen Hafta',
      thisMonth: 'Bu Ay'
    },
    
    // General Info
    general: {
      firstName: 'Ad',
      lastName: 'Soyad',
      tcNo: 'TC No',
      sgkNo: 'SGK No',
      position: 'Pozisyon',
      department: 'Departman',
      hireDate: 'İşe Giriş',
      terminationDate: 'İşten Çıkış',
      phone: 'Telefon',
      email: 'E-posta',
      address: 'Adres',
      iban: 'IBAN',
      normalWeeklyHours: 'Haftalık Norm',
      baseWage: 'Temel Ücret'
    }
  },

  // Stages - Tailoring
  stageTailoring: {
    CREATED: 'Sipariş Alındı',
    IN_PROGRESS_50: 'İşlemde %50',
    IN_PROGRESS_80: 'İşlemde %80',
    READY: 'Hazır',
    DELIVERED: 'Teslim Edildi',
  },

  // Stages - Rental
  stageRental: {
    BOOKED: 'Rezerve Edildi',
    PICKED_UP: 'Teslim Alındı',
    RETURNED: 'İade Edildi',
  },

  // Product Status
  productStatus: {
    AVAILABLE: 'Müsait',
    IN_USE: 'Kullanımda',
    MAINTENANCE: 'Bakımda',
  },

  // Agenda Event Types
  agendaType: {
    DRY_CLEANING: 'Kuru Temizleme',
    ALTERATION: 'Tadilat',
    OUT_OF_SERVICE: 'Kullanım Dışı',
  },

  // Filters
  filters: {
    customer: 'Müşteri',
    type: 'Tür',
    organization: 'Organizasyon',
    product: 'Ürün',
    status: 'Durum',
    delivery: 'Teslim Tarihi',
    rentPeriod: 'Kiralama Dönemi',
    dateRange: 'Tarih Aralığı',
    all: 'Hepsi',
  },

  // Table Columns
  table: {
    orderDate: 'Sipariş Tarihi',
    deliveryRent: 'Teslim / Kira',
    customer: 'Müşteri',
    type: 'Tür',
    organization: 'Organizasyon',
    product: 'Ürün',
    total: 'Toplam',
    collected: 'Tahsilat',
    balance: 'Bakiye',
    currentBalance: 'Cari Bakiye',
    status: 'Durum',
    stage: 'Aşama',
  },

  // Tool Palette
  tools: {
    newRental: 'Yeni Kiralama',
    dryCleaning: 'Kuru Temizleme',
    alteration: 'Tadilat',
    outOfService: 'Kullanım Dışı',
  },

  // Common
  common: {
    search: 'Ara',
    filter: 'Filtrele',
    reset: 'Sıfırla',
    save: 'Kaydet',
    cancel: 'İptal',
    delete: 'Sil',
    edit: 'Düzenle',
    add: 'Ekle',
    loading: 'Yükleniyor...',
    noData: 'Veri bulunamadı',
  },
}

